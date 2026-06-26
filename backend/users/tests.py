from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase


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
