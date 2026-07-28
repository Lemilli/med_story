from django.conf import settings
from django.core.checks import Error, register
from django.core.exceptions import ImproperlyConfigured


@register()
def private_original_storage_checks(app_configs, **kwargs):
    if settings.ORIGINAL_STORAGE_BACKEND != "s3":
        if settings.ORIGINAL_STORAGE_REQUIRE_S3:
            return [
                Error(
                    "Production must use S3-compatible private original storage.",
                    id="medical.E000",
                )
            ]
        return []

    errors = []
    try:
        from medical.original_storage import _master_key

        _master_key()
    except ImproperlyConfigured as exc:
        errors.append(
            Error(
                str(exc),
                id="medical.E001",
            )
        )

    if not settings.ORIGINAL_STORAGE_ENDPOINT.lower().startswith("https://"):
        errors.append(
            Error(
                "S3-compatible original storage must use a verified HTTPS endpoint.",
                id="medical.E002",
            )
        )
    if not settings.ORIGINAL_STORAGE_VERIFY_TLS:
        errors.append(
            Error(
                "TLS verification cannot be disabled for original storage.",
                id="medical.E003",
            )
        )

    credential_roles = {
        "upload": (
            settings.ORIGINAL_STORAGE_UPLOAD_ACCESS_KEY_FILE
            or settings.ORIGINAL_STORAGE_UPLOAD_ACCESS_KEY,
            settings.ORIGINAL_STORAGE_UPLOAD_SECRET_KEY_FILE
            or settings.ORIGINAL_STORAGE_UPLOAD_SECRET_KEY,
        ),
        "read": (
            settings.ORIGINAL_STORAGE_READ_ACCESS_KEY_FILE
            or settings.ORIGINAL_STORAGE_READ_ACCESS_KEY,
            settings.ORIGINAL_STORAGE_READ_SECRET_KEY_FILE
            or settings.ORIGINAL_STORAGE_READ_SECRET_KEY,
        ),
        "processing": (
            settings.ORIGINAL_STORAGE_PROCESSING_ACCESS_KEY_FILE
            or settings.ORIGINAL_STORAGE_PROCESSING_ACCESS_KEY,
            settings.ORIGINAL_STORAGE_PROCESSING_SECRET_KEY_FILE
            or settings.ORIGINAL_STORAGE_PROCESSING_SECRET_KEY,
        ),
        "deletion": (
            settings.ORIGINAL_STORAGE_DELETION_ACCESS_KEY_FILE
            or settings.ORIGINAL_STORAGE_DELETION_ACCESS_KEY,
            settings.ORIGINAL_STORAGE_DELETION_SECRET_KEY_FILE
            or settings.ORIGINAL_STORAGE_DELETION_SECRET_KEY,
        ),
    }
    required_roles = {
        "api": {"upload", "read", "deletion"},
        "worker": {"processing", "deletion"},
        "all": set(credential_roles),
    }.get(settings.ORIGINAL_STORAGE_SERVICE_ROLE)
    if required_roles is None:
        errors.append(
            Error(
                "Unsupported ORIGINAL_STORAGE_SERVICE_ROLE.",
                id="medical.E006",
            )
        )
        required_roles = set()
    for role in required_roles:
        access_key, secret_key = credential_roles[role]
        if not access_key or not secret_key:
            errors.append(
                Error(
                    f"Missing least-privilege Garage {role} credentials.",
                    id="medical.E004",
                )
            )

    if not settings.DEBUG and settings.ORIGINAL_MALWARE_SCANNER != "clamav":
        errors.append(
            Error(
                "Production original uploads require the fail-closed ClamAV scanner.",
                id="medical.E005",
            )
        )
    return errors
