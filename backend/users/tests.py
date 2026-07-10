from datetime import date

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

from medical.models import AuditLog, Document, MedicalEvent, Subject


class AuthTests(APITestCase):
    def test_register_returns_user_and_tokens(self):
        response = self.client.post(
            "/api/v1/auth/register",
            {
                "email": "user@example.com",
                "password": "StrongPass123!",
                "full_name": "Jane Doe",
                "locale": "en",
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["user"]["email"], "user@example.com")
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)
        self.assertTrue(get_user_model().objects.filter(email="user@example.com").exists())
        self.assertTrue(
            Subject.objects.filter(
                user__email="user@example.com",
                display_name="Jane Doe",
                relationship=Subject.Relationship.SELF,
                is_default=True,
            ).exists()
        )

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
