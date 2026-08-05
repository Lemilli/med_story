import importlib
import re
from datetime import date, timedelta
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.core import mail
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from medical.models import (
    AuditLog,
    Document,
    DocumentAsset,
    EncryptedBlob,
    MedicalEvent,
    StorageDeletionJob,
    Subject,
)
from medical.original_storage import MemoryObjectStore, store_upload
from users.models import ConsentRecord, EmailChallenge
from users.services import consume_email_challenge
from users.tasks import cleanup_unverified_accounts_task


class AuthTests(APITestCase):
    def setUp(self):
        MemoryObjectStore.clear()

    def tearDown(self):
        MemoryObjectStore.clear()
        super().tearDown()

    def test_register_requires_verification_and_records_consents(self):
        response = self.client.post(
            "/api/v1/auth/register",
            {
                "email": "user@example.com",
                "password": "StrongPass123!",
                "full_name": "Jane Doe",
                "locale": "en",
                "privacy_notice_version": "2026-08-06",
                "privacy_accepted": True,
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(response.data["user"]["email"], "user@example.com")
        self.assertTrue(response.data["verification_required"])
        user = get_user_model().objects.get(email="user@example.com")
        self.assertFalse(user.is_active)
        self.assertEqual(user.consent_records.count(), 1)
        self.assertEqual(user.consent_records.get().kind, ConsentRecord.Kind.PRIVACY_NOTICE)
        self.assertNotRegex(EmailChallenge.objects.get(user=user).code_digest, r"^\d{6}$")
        self.assertEqual(len(mail.outbox), 1)
        self.assertTrue(
            Subject.objects.filter(
                user__email="user@example.com",
                display_name="Jane Doe",
                relationship=Subject.Relationship.SELF,
                is_default=True,
            ).exists()
        )

    def test_verify_email_consumes_code_and_returns_session(self):
        register = self.client.post(
            "/api/v1/auth/register",
            {
                "email": "verify@example.com",
                "password": "StrongPass123!",
                "privacy_notice_version": "2026-08-06",
                "privacy_accepted": True,
            },
            format="json",
        )
        self.assertEqual(register.status_code, status.HTTP_202_ACCEPTED)
        code = re.search(r"\b(\d{6})\b", mail.outbox[-1].body).group(1)

        response = self.client.post(
            "/api/v1/auth/verify-email",
            {"email": "verify@example.com", "code": code},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)
        self.assertTrue(get_user_model().objects.get(email="verify@example.com").is_active)
        self.assertFalse(ConsentRecord.objects.filter(user__email="verify@example.com", kind="ai_processing").exists())

    def test_resend_invalidates_previous_verification_code(self):
        with patch("users.services.secrets.randbelow", side_effect=[111111, 222222]):
            self.client.post(
                "/api/v1/auth/register",
                {"email": "resend@example.com", "password": "StrongPass123!", "privacy_notice_version": "2026-08-06", "privacy_accepted": True},
                format="json",
            )
            old_code = re.search(r"\b(\d{6})\b", mail.outbox[-1].body).group(1)
            response = self.client.post("/api/v1/auth/resend-verification", {"email": "resend@example.com"}, format="json")
        new_code = re.search(r"\b(\d{6})\b", mail.outbox[-1].body).group(1)
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertIsNone(consume_email_challenge(email="resend@example.com", purpose="verify_email", code=old_code))
        self.assertIsNotNone(consume_email_challenge(email="resend@example.com", purpose="verify_email", code=new_code))

    def test_challenge_locks_after_five_attempts(self):
        self.client.post(
            "/api/v1/auth/register",
            {"email": "attempts@example.com", "password": "StrongPass123!", "privacy_notice_version": "2026-08-06", "privacy_accepted": True},
            format="json",
        )
        valid_code = re.search(r"\b(\d{6})\b", mail.outbox[-1].body).group(1)
        for _ in range(5):
            self.assertIsNone(consume_email_challenge(email="attempts@example.com", purpose="verify_email", code="000000"))
        self.assertIsNone(consume_email_challenge(email="attempts@example.com", purpose="verify_email", code=valid_code))

    def test_cleanup_removes_only_old_unverified_accounts(self):
        old = get_user_model().objects.create_user(email="old@example.com", password="StrongPass123!", is_active=False)
        active = get_user_model().objects.create_user(email="active@example.com", password="StrongPass123!")
        get_user_model().objects.filter(id=old.id).update(date_joined=timezone.now() - timedelta(hours=25))
        cleanup_unverified_accounts_task()
        self.assertFalse(get_user_model().objects.filter(id=old.id).exists())
        self.assertTrue(get_user_model().objects.filter(id=active.id).exists())

    def test_password_reset_is_generic_and_revokes_refresh_tokens(self):
        user = get_user_model().objects.create_user(email="reset@example.com", password="StrongPass123!")
        login = self.client.post("/api/v1/auth/login", {"email": user.email, "password": "StrongPass123!"}, format="json")
        request = self.client.post("/api/v1/auth/password-reset/request", {"email": user.email}, format="json")
        missing = self.client.post("/api/v1/auth/password-reset/request", {"email": "missing@example.com"}, format="json")
        self.assertEqual(request.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(missing.status_code, status.HTTP_202_ACCEPTED)
        code = re.search(r"\b(\d{6})\b", mail.outbox[-1].body).group(1)

        confirmed = self.client.post(
            "/api/v1/auth/password-reset/confirm",
            {"email": user.email, "code": code, "new_password": "NewStrongPass123!"},
            format="json",
        )
        replay = self.client.post("/api/v1/auth/refresh", {"refresh": login.data["refresh"]}, format="json")
        self.assertEqual(confirmed.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(replay.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_ai_consent_endpoint_is_not_exposed(self):
        user = get_user_model().objects.create_user(email="consent@example.com", password="StrongPass123!")
        self.client.force_authenticate(user=user)
        response = self.client.put("/api/v1/me/consents/ai-processing", {"granted": False}, format="json")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_consent_list_exposes_only_privacy_notice_acceptance(self):
        user = get_user_model().objects.create_user(email="privacy@example.com", password="StrongPass123!")
        ConsentRecord.objects.create(user=user, kind="privacy_notice", notice_version="2026-08-06", granted=True)
        ConsentRecord.objects.create(user=user, kind="ai_processing", notice_version="2026-08-05", granted=False)
        self.client.force_authenticate(user=user)

        response = self.client.get("/api/v1/me/consents")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["kind"], "privacy_notice")

    def test_current_notice_combines_mandatory_ai_disclosure(self):
        response = self.client.get("/api/v1/legal/notices/current?locale=en")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["version"], "2026-08-06")
        self.assertIn("core features use AI", response.data["privacy_notice"])
        self.assertNotIn("ai_processing", response.data)

    def test_registration_rejects_removed_ai_consent_field(self):
        response = self.client.post(
            "/api/v1/auth/register",
            {
                "email": "legacy@example.com",
                "password": "StrongPass123!",
                "privacy_notice_version": "2026-08-06",
                "privacy_accepted": True,
                "ai_processing_accepted": True,
            },
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("ai_processing_accepted", response.data["error"]["details"])

    def test_ai_consent_data_migration_deletes_only_ai_records(self):
        user = get_user_model().objects.create_user(email="migration@example.com", password="StrongPass123!")
        ConsentRecord.objects.create(user=user, kind="privacy_notice", notice_version="2026-08-06", granted=True)
        ConsentRecord.objects.create(user=user, kind="ai_processing", notice_version="2026-08-05", granted=False)
        migration = importlib.import_module("users.migrations.0003_remove_ai_processing_consent")

        migration.delete_ai_processing_consents(importlib.import_module("django.apps").apps, None)

        self.assertFalse(ConsentRecord.objects.filter(user=user, kind="ai_processing").exists())
        self.assertTrue(ConsentRecord.objects.filter(user=user, kind="privacy_notice").exists())

    def test_me_requires_authentication(self):
        response = self.client.get("/api/v1/me")

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_me_returns_authenticated_user(self):
        user = get_user_model().objects.create_user(
            email="user@example.com",
            password="StrongPass123!",
            full_name="Jane Doe",
        )
        self.client.force_authenticate(user=user)

        response = self.client.get("/api/v1/me")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["email"], "user@example.com")

    def test_login_creates_audit_log(self):
        user = get_user_model().objects.create_user(
            email="user@example.com",
            password="StrongPass123!",
            full_name="Jane Doe",
        )

        response = self.client.post(
            "/api/v1/auth/login",
            {"email": "user@example.com", "password": "StrongPass123!"},
            format="json",
            REMOTE_ADDR="203.0.113.10",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("access", response.data)
        self.assertTrue(
            AuditLog.objects.filter(
                user=user,
                action=AuditLog.Action.LOGIN,
                ip_address="203.0.113.10",
            ).exists()
        )

    def test_delete_me_hard_deletes_user_data_and_invalidates_access_token(self):
        user = get_user_model().objects.create_user(
            email="user@example.com",
            password="StrongPass123!",
            full_name="Jane Doe",
        )
        other_user = get_user_model().objects.create_user(
            email="other@example.com",
            password="StrongPass123!",
            full_name="Other User",
        )
        subject = Subject.objects.create(
            user=user,
            display_name="Jane Doe",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        other_subject = Subject.objects.create(
            user=other_user,
            display_name="Other User",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        document = Document.objects.create(
            user=user,
            subject=subject,
            title="Lab result",
            doc_type=Document.DocumentType.LAB_RESULT,
            mime_type="application/pdf",
            size_bytes=512,
        )
        stored = store_upload(user=user, payload=b"private original")
        DocumentAsset.objects.create(
            document=document,
            blob=stored.blob,
            position=1,
            file_name="lab.pdf",
            mime_type="application/pdf",
            size_bytes=len(b"private original"),
        )
        object_key = stored.blob.object_key
        MedicalEvent.objects.create(
            user=user,
            subject=subject,
            source_document=document,
            event_type=MedicalEvent.EventType.NOTE,
            title="User event",
            event_date=date(2026, 6, 1),
        )
        MedicalEvent.objects.create(
            user=other_user,
            subject=other_subject,
            event_type=MedicalEvent.EventType.NOTE,
            title="Other event",
            event_date=date(2026, 6, 2),
        )
        login_response = self.client.post(
            "/api/v1/auth/login",
            {"email": "user@example.com", "password": "StrongPass123!"},
            format="json",
        )
        access = login_response.data["access"]
        refresh = login_response.data["refresh"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")

        delete_response = self.client.delete("/api/v1/me", {"refresh": refresh}, format="json")
        after_delete_response = self.client.get("/api/v1/me")

        self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(get_user_model().objects.filter(id=user.id).exists())
        self.assertFalse(Subject.objects.filter(user_id=user.id).exists())
        self.assertFalse(Document.objects.filter(user_id=user.id).exists())
        self.assertFalse(EncryptedBlob.objects.filter(user_id=user.id).exists())
        self.assertTrue(
            StorageDeletionJob.objects.filter(object_key=object_key).exists()
        )
        self.assertFalse(MedicalEvent.objects.filter(user_id=user.id).exists())
        self.assertTrue(get_user_model().objects.filter(id=other_user.id).exists())
        self.assertTrue(MedicalEvent.objects.filter(user=other_user, title="Other event").exists())
        self.assertTrue(AuditLog.objects.filter(user__isnull=True, action=AuditLog.Action.ACCOUNT_DELETE).exists())
        self.assertEqual(after_delete_response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_delete_me_ignores_invalid_refresh_token(self):
        user = get_user_model().objects.create_user(
            email="user@example.com",
            password="StrongPass123!",
            full_name="Jane Doe",
        )
        self.client.force_authenticate(user=user)

        response = self.client.delete("/api/v1/me", {"refresh": "not-a-jwt"}, format="json")

        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(get_user_model().objects.filter(id=user.id).exists())
