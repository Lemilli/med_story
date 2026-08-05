import os
import subprocess
import sys
from io import StringIO
from unittest.mock import patch

from django.conf import settings
from django.core.management import call_command
from django.test import SimpleTestCase, TestCase, override_settings

from config.client_ip import get_client_ip


class ResponseSecurityTests(SimpleTestCase):
    def test_api_responses_are_never_cacheable(self):
        response = self.client.get("/api/v1/me")

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.headers["Cache-Control"], "private, no-store")
        self.assertEqual(response.headers["Pragma"], "no-cache")

    def test_healthz_is_dependency_free(self):
        response = self.client.get("/healthz")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok"})
        self.assertEqual(response.headers["Cache-Control"], "no-store")

    @override_settings(
        DEBUG=False,
        SECURE_SSL_REDIRECT=True,
        ALLOWED_HOSTS=["api.example.test", "127.0.0.1"],
    )
    def test_local_health_probe_is_exempt_from_https_redirect(self):
        response = self.client.get("/healthz", HTTP_HOST="127.0.0.1")

        self.assertEqual(response.status_code, 200)

    @patch("config.health._check_database")
    @patch("config.health._check_cache")
    @patch("config.health._check_original_storage")
    @patch("config.health._check_malware_scanner")
    def test_readyz_returns_no_dependency_details(
        self,
        malware_check,
        storage_check,
        cache_check,
        database_check,
    ):
        storage_check.side_effect = RuntimeError("secret health details")

        with self.assertLogs("config.health", level="WARNING") as captured_logs:
            response = self.client.get("/readyz")

        self.assertEqual(response.status_code, 503)
        self.assertEqual(response.json(), {"status": "unavailable"})
        self.assertNotIn(b"secret health details", response.content)
        self.assertNotIn("secret health details", "\n".join(captured_logs.output))
        database_check.assert_called_once_with()
        cache_check.assert_called_once_with()
        storage_check.assert_called_once_with()
        malware_check.assert_not_called()


class ClientIPTests(SimpleTestCase):
    @override_settings(THROTTLE_TRUSTED_PROXY_COUNT=0)
    def test_forwarded_header_is_ignored_without_a_trusted_proxy(self):
        request = type(
            "Request",
            (),
            {"META": {"REMOTE_ADDR": "192.0.2.10", "HTTP_X_FORWARDED_FOR": "203.0.113.20"}},
        )()

        self.assertEqual(get_client_ip(request), "192.0.2.10")

    @override_settings(THROTTLE_TRUSTED_PROXY_COUNT=1)
    def test_only_the_rightmost_address_from_the_trusted_proxy_is_used(self):
        request = type(
            "Request",
            (),
            {
                "META": {
                    "REMOTE_ADDR": "172.18.0.2",
                    "HTTP_X_FORWARDED_FOR": "198.51.100.99, 203.0.113.20",
                }
            },
        )()

        self.assertEqual(get_client_ip(request), "203.0.113.20")

    @override_settings(THROTTLE_TRUSTED_PROXY_COUNT=1)
    def test_invalid_forwarded_address_falls_back_to_proxy_peer(self):
        request = type(
            "Request",
            (),
            {"META": {"REMOTE_ADDR": "172.18.0.2", "HTTP_X_FORWARDED_FOR": "not-an-ip"}},
        )()

        self.assertEqual(get_client_ip(request), "172.18.0.2")


class ProductionChecksTests(TestCase):
    def test_unsafe_production_settings_fail_closed(self):
        environment = {
            **os.environ,
            "DEBUG": "False",
            "SECRET_KEY": "short",
            "ALLOWED_HOSTS": "api.example.test",
            "DATABASE_URL": "postgres://user:password@db:5432/medstory",
            "THROTTLE_CACHE_URL": "redis://redis:6379/1",
            "THROTTLE_TRUSTED_PROXY_COUNT": "1",
        }

        result = subprocess.run(
            [sys.executable, str(settings.BASE_DIR / "manage.py"), "check", "--tag", "security"],
            capture_output=True,
            check=False,
            env=environment,
            text=True,
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("SECRET_KEY must be a unique production secret", result.stderr)

    @override_settings(
        DEBUG=False,
        SECRET_KEY="a-production-secret-with-more-than-fifty-characters-1234567890",
        ALLOWED_HOSTS=["api.example.test"],
        SECURE_SSL_REDIRECT=True,
        SESSION_COOKIE_SECURE=True,
        CSRF_COOKIE_SECURE=True,
        SECURE_HSTS_SECONDS=3600,
        SECURE_HSTS_INCLUDE_SUBDOMAINS=False,
        SECURE_HSTS_PRELOAD=False,
        ORIGINAL_STORAGE_REQUIRE_S3=False,
    )
    def test_django_deploy_checks_have_no_security_warnings(self):
        output = StringIO()

        call_command(
            "check",
            "--deploy",
            "--tag",
            "security",
            fail_level="WARNING",
            stdout=output,
            stderr=output,
        )
