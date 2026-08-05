import logging
import socket
import uuid

from django.conf import settings
from django.core.cache import cache
from django.db import connections
from django.http import JsonResponse


logger = logging.getLogger(__name__)


def healthz(request):
    """Dependency-free liveness signal for the process supervisor."""
    return _status_response("ok")


def readyz(request):
    """Report whether required production dependencies can serve requests."""
    checks = (_check_database, _check_cache, _check_original_storage, _check_malware_scanner)
    for check in checks:
        try:
            check()
        except Exception as exc:
            # Exception messages and tracebacks may contain credentials or
            # provider response bodies. Log only the dependency and type.
            logger.warning(
                "Readiness check failed dependency=%s error_type=%s",
                getattr(check, "__name__", "dependency"),
                type(exc).__name__,
            )
            return _status_response("unavailable", status=503)
    return _status_response("ok")


def _status_response(value, *, status=200):
    response = JsonResponse({"status": value}, status=status)
    response["Cache-Control"] = "no-store"
    return response


def _check_database():
    with connections["default"].cursor() as cursor:
        cursor.execute("SELECT 1")
        cursor.fetchone()


def _check_cache():
    key = f"readiness:{uuid.uuid4()}"
    value = uuid.uuid4().hex
    cache.set(key, value, timeout=10)
    try:
        if cache.get(key) != value:
            raise RuntimeError("Cache readiness probe failed.")
    finally:
        cache.delete(key)


def _check_original_storage():
    if settings.ORIGINAL_STORAGE_BACKEND != "s3":
        return
    from medical.original_storage import get_object_store

    store = get_object_store("read")
    store.client.head_bucket(Bucket=store.bucket)


def _check_malware_scanner():
    if settings.ORIGINAL_MALWARE_SCANNER != "clamav":
        return
    with socket.create_connection(
        (settings.CLAMAV_HOST, settings.CLAMAV_PORT),
        timeout=min(settings.CLAMAV_TIMEOUT_SECONDS, 5),
    ) as connection:
        connection.sendall(b"zPING\0")
        response = connection.recv(64)
    if not response.startswith(b"PONG"):
        raise RuntimeError("Malware scanner readiness probe failed.")
