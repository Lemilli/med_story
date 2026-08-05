from types import SimpleNamespace
from unittest.mock import patch
from uuid import uuid4

from django.contrib.auth import get_user_model
from django.core.cache import cache
from rest_framework import status
from rest_framework.test import APITestCase
from users.models import ConsentRecord
from users.services import record_consent


class ThrottlingTests(APITestCase):
    def setUp(self):
        cache.clear()

    def tearDown(self):
        cache.clear()

    def test_login_is_limited_by_client_ip_and_uses_documented_error(self):
        for _ in range(5):
            response = self.client.post(
                "/api/v1/auth/login",
                {"email": "missing@example.com", "password": "StrongPass123!"},
                format="json",
                REMOTE_ADDR="203.0.113.10",
            )
            self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

        response = self.client.post(
            "/api/v1/auth/login",
            {"email": "missing@example.com", "password": "StrongPass123!"},
            format="json",
            REMOTE_ADDR="203.0.113.10",
        )

        self.assertEqual(response.status_code, status.HTTP_429_TOO_MANY_REQUESTS)
        self.assertEqual(response.data["error"]["code"], "throttled")
        self.assertIn("Retry-After", response)

    def test_ai_regeneration_is_limited_per_authenticated_user(self):
        user = get_user_model().objects.create_user(
            email="user@example.com", password="StrongPass123!", full_name="Jane Doe"
        )
        record_consent(user=user, kind=ConsentRecord.Kind.AI_PROCESSING, granted=True)
        self.client.force_authenticate(user=user)
        queued_job = SimpleNamespace(id=uuid4())

        with patch("medical.views.enqueue_summary_regeneration", return_value=queued_job):
            for _ in range(10):
                response = self.client.post("/api/v1/summary/regenerate", {}, format="json")
                self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)

            response = self.client.post("/api/v1/summary/regenerate", {}, format="json")

        self.assertEqual(response.status_code, status.HTTP_429_TOO_MANY_REQUESTS)
        self.assertEqual(response.data["error"]["code"], "throttled")
