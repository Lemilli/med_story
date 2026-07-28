import base64
import hashlib
import hmac
import io
import os
import socket
import struct
import uuid
from dataclasses import dataclass
from pathlib import Path
from threading import Lock

from django.conf import settings
from django.core.exceptions import ImproperlyConfigured
from django.db import transaction
from django.db.models import Sum
from django.utils import timezone

from medical.models import DocumentAsset, EncryptedBlob, StorageDeletionJob


class OriginalStorageError(Exception):
    code = "original_storage_error"


class OriginalStorageUnavailable(OriginalStorageError):
    code = "original_storage_unavailable"


class OriginalIntegrityError(OriginalStorageError):
    code = "original_integrity_error"


class MalwareScannerUnavailable(OriginalStorageError):
    code = "malware_scanner_unavailable"


class MalwareDetected(OriginalStorageError):
    code = "malware_detected"


class OriginalQuotaExceeded(OriginalStorageError):
    code = "original_storage_quota_exceeded"


class InvalidOriginalType(OriginalStorageError):
    code = "invalid_original_type"


@dataclass(frozen=True)
class StoredUpload:
    blob: EncryptedBlob
    was_created: bool


class MemoryObjectStore:
    _objects = {}
    _lock = Lock()

    def put(self, object_key, payload):
        with self._lock:
            self._objects[object_key] = bytes(payload)

    def get(self, object_key):
        with self._lock:
            try:
                return self._objects[object_key]
            except KeyError as exc:
                raise OriginalStorageUnavailable("Stored original is unavailable.") from exc

    def delete(self, object_key):
        with self._lock:
            self._objects.pop(object_key, None)

    @classmethod
    def clear(cls):
        with cls._lock:
            cls._objects.clear()


class S3ObjectStore:
    def __init__(self, role):
        try:
            import boto3
            from botocore.config import Config
        except ImportError as exc:
            raise ImproperlyConfigured("boto3 is required for S3-compatible original storage.") from exc

        credentials = {
            "upload": (
                settings.ORIGINAL_STORAGE_UPLOAD_ACCESS_KEY_FILE,
                settings.ORIGINAL_STORAGE_UPLOAD_SECRET_KEY_FILE,
                settings.ORIGINAL_STORAGE_UPLOAD_ACCESS_KEY,
                settings.ORIGINAL_STORAGE_UPLOAD_SECRET_KEY,
            ),
            "read": (
                settings.ORIGINAL_STORAGE_READ_ACCESS_KEY_FILE,
                settings.ORIGINAL_STORAGE_READ_SECRET_KEY_FILE,
                settings.ORIGINAL_STORAGE_READ_ACCESS_KEY,
                settings.ORIGINAL_STORAGE_READ_SECRET_KEY,
            ),
            "processing": (
                settings.ORIGINAL_STORAGE_PROCESSING_ACCESS_KEY_FILE,
                settings.ORIGINAL_STORAGE_PROCESSING_SECRET_KEY_FILE,
                settings.ORIGINAL_STORAGE_PROCESSING_ACCESS_KEY,
                settings.ORIGINAL_STORAGE_PROCESSING_SECRET_KEY,
            ),
            "deletion": (
                settings.ORIGINAL_STORAGE_DELETION_ACCESS_KEY_FILE,
                settings.ORIGINAL_STORAGE_DELETION_SECRET_KEY_FILE,
                settings.ORIGINAL_STORAGE_DELETION_ACCESS_KEY,
                settings.ORIGINAL_STORAGE_DELETION_SECRET_KEY,
            ),
        }
        try:
            access_file, secret_file, access_fallback, secret_fallback = credentials[role]
        except KeyError as exc:
            raise ImproperlyConfigured("Unsupported original-storage credential role.") from exc
        self.bucket = settings.ORIGINAL_STORAGE_BUCKET
        self.client = boto3.client(
            "s3",
            endpoint_url=settings.ORIGINAL_STORAGE_ENDPOINT,
            region_name=settings.ORIGINAL_STORAGE_REGION,
            aws_access_key_id=_read_secret(access_file, access_fallback),
            aws_secret_access_key=_read_secret(secret_file, secret_fallback),
            verify=(
                settings.ORIGINAL_STORAGE_CA_BUNDLE
                or settings.ORIGINAL_STORAGE_VERIFY_TLS
            ),
            config=Config(signature_version="s3v4", s3={"addressing_style": "path"}),
        )

    def put(self, object_key, payload):
        try:
            self.client.put_object(
                Bucket=self.bucket,
                Key=object_key,
                Body=payload,
                ContentType="application/octet-stream",
            )
        except Exception as exc:
            raise OriginalStorageUnavailable("Could not store the encrypted original.") from exc

    def get(self, object_key):
        try:
            result = self.client.get_object(Bucket=self.bucket, Key=object_key)
            return result["Body"].read()
        except Exception as exc:
            raise OriginalStorageUnavailable("Stored original is unavailable.") from exc

    def delete(self, object_key):
        try:
            self.client.delete_object(Bucket=self.bucket, Key=object_key)
        except Exception as exc:
            raise OriginalStorageUnavailable("Could not delete the encrypted original.") from exc


def get_object_store(role):
    if settings.ORIGINAL_STORAGE_BACKEND == "memory":
        return MemoryObjectStore()
    if settings.ORIGINAL_STORAGE_BACKEND == "s3":
        return S3ObjectStore(role)
    raise ImproperlyConfigured("Unsupported ORIGINAL_STORAGE_BACKEND.")


def _read_secret(path_value, fallback=""):
    if path_value:
        try:
            return Path(path_value).read_text(encoding="utf-8").strip()
        except OSError as exc:
            raise ImproperlyConfigured(f"Could not read secret file {path_value}.") from exc
    return fallback


def _master_key():
    encoded = _read_secret(settings.ORIGINAL_MASTER_KEY_FILE, settings.ORIGINAL_MASTER_KEY)
    if encoded:
        try:
            key = base64.b64decode(encoded, validate=True)
        except ValueError as exc:
            raise ImproperlyConfigured("Original master key must be base64 encoded.") from exc
    elif settings.ORIGINAL_STORAGE_BACKEND == "memory":
        key = hashlib.sha256(settings.SECRET_KEY.encode("utf-8")).digest()
    else:
        raise ImproperlyConfigured("A 256-bit original storage master key is required.")
    if len(key) != 32:
        raise ImproperlyConfigured("Original storage master key must decode to exactly 32 bytes.")
    return key


class _StaticRawMasterKeyProvider:
    """Build an AWS Encryption SDK raw provider without exposing key metadata."""

    @staticmethod
    def create(key_bytes, key_id):
        try:
            import aws_encryption_sdk
            from aws_encryption_sdk.identifiers import EncryptionKeyType, WrappingAlgorithm
            from aws_encryption_sdk.internal.crypto.wrapping_keys import WrappingKey
            from aws_encryption_sdk.key_providers.raw import RawMasterKeyProvider
        except ImportError as exc:
            raise ImproperlyConfigured(
                "aws-encryption-sdk is required for original encryption."
            ) from exc

        class Provider(RawMasterKeyProvider):
            provider_id = "medstory-originals"

            def __new__(cls):
                instance = super().__new__(cls)
                instance._key = key_bytes
                return instance

            def _get_raw_key(self, requested_key_id):
                if bytes(requested_key_id) != bytes(key_id):
                    raise OriginalIntegrityError("Unexpected encrypted original key identifier.")
                return WrappingKey(
                    wrapping_algorithm=WrappingAlgorithm.AES_256_GCM_IV12_TAG16_NO_PADDING,
                    wrapping_key=self._key,
                    wrapping_key_type=EncryptionKeyType.SYMMETRIC,
                )

        provider = Provider()
        provider.add_master_key(key_id)
        return aws_encryption_sdk, provider


def _wrap_blob_key(blob_key, blob_id):
    try:
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    except ImportError as exc:
        raise ImproperlyConfigured("cryptography is required for original encryption.") from exc
    nonce = os.urandom(12)
    aad = f"medstory:blob-key:v1:{blob_id}".encode("ascii")
    return nonce + AESGCM(_master_key()).encrypt(nonce, blob_key, aad)


def _unwrap_blob_key(encrypted_key, blob_id):
    try:
        from cryptography.exceptions import InvalidTag
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    except ImportError as exc:
        raise ImproperlyConfigured("cryptography is required for original encryption.") from exc
    encrypted_key = bytes(encrypted_key)
    try:
        return AESGCM(_master_key()).decrypt(
            encrypted_key[:12],
            encrypted_key[12:],
            f"medstory:blob-key:v1:{blob_id}".encode("ascii"),
        )
    except (InvalidTag, ValueError) as exc:
        raise OriginalIntegrityError("The original encryption key could not be verified.") from exc


def encrypt_original(plaintext, blob_id):
    try:
        from aws_encryption_sdk.identifiers import CommitmentPolicy
    except ImportError as exc:
        raise ImproperlyConfigured("aws-encryption-sdk is required for original encryption.") from exc
    blob_key = os.urandom(32)
    key_id = blob_id.bytes
    sdk, provider = _StaticRawMasterKeyProvider.create(blob_key, key_id)
    client = sdk.EncryptionSDKClient(
        commitment_policy=CommitmentPolicy.REQUIRE_ENCRYPT_REQUIRE_DECRYPT,
    )
    ciphertext, _ = client.encrypt(
        source=plaintext,
        key_provider=provider,
        encryption_context={
            "blob_id": str(blob_id),
            "format": "medstory-original-v1",
        },
        frame_length=64 * 1024,
    )
    return ciphertext, _wrap_blob_key(blob_key, blob_id)


def decrypt_original(blob, ciphertext):
    try:
        from aws_encryption_sdk.identifiers import CommitmentPolicy
    except ImportError as exc:
        raise ImproperlyConfigured("aws-encryption-sdk is required for original encryption.") from exc
    if blob.state != EncryptedBlob.State.AVAILABLE or not blob.encrypted_key:
        raise OriginalStorageUnavailable("Stored original is no longer available.")
    blob_key = _unwrap_blob_key(blob.encrypted_key, blob.id)
    sdk, provider = _StaticRawMasterKeyProvider.create(blob_key, blob.id.bytes)
    client = sdk.EncryptionSDKClient(
        commitment_policy=CommitmentPolicy.REQUIRE_ENCRYPT_REQUIRE_DECRYPT,
    )
    try:
        plaintext, header = client.decrypt(source=ciphertext, key_provider=provider)
    except Exception as exc:
        raise OriginalIntegrityError("Stored original failed integrity verification.") from exc
    context = header.encryption_context
    if (
        context.get("blob_id") != str(blob.id)
        or context.get("format") != "medstory-original-v1"
    ):
        raise OriginalIntegrityError("Stored original context did not match.")
    if len(plaintext) != blob.plaintext_size:
        raise OriginalIntegrityError("Stored original size did not match.")
    return plaintext


def user_scoped_fingerprint(user_id, payload):
    dedupe_key = hmac.new(
        _master_key(),
        b"medstory:dedupe:v1:" + str(user_id).encode("ascii"),
        hashlib.sha256,
    ).digest()
    return hmac.new(dedupe_key, payload, hashlib.sha256).hexdigest()


def validate_original_signature(payload, declared_mime):
    if not settings.ORIGINAL_STRICT_FILE_VALIDATION:
        return
    detected = None
    if payload.startswith(b"%PDF-"):
        detected = "application/pdf"
    elif payload.startswith(b"\x89PNG\r\n\x1a\n"):
        detected = "image/png"
    elif payload.startswith(b"\xff\xd8\xff"):
        detected = "image/jpeg"
    elif len(payload) >= 12 and payload[4:8] == b"ftyp":
        brand = payload[8:12]
        if brand in {b"heic", b"heix", b"hevc", b"hevx"}:
            detected = "image/heic"
        elif brand in {b"mif1", b"msf1", b"heif"}:
            detected = "image/heif"
    if detected != declared_mime:
        raise InvalidOriginalType("File contents do not match the declared type.")


def scan_for_malware(payload):
    backend = settings.ORIGINAL_MALWARE_SCANNER
    if backend == "mock":
        if payload.startswith(b"EICAR-STANDARD-ANTIVIRUS-TEST-FILE"):
            raise MalwareDetected("The upload was rejected by the malware scanner.")
        return
    if backend != "clamav":
        raise ImproperlyConfigured("Unsupported ORIGINAL_MALWARE_SCANNER.")
    try:
        with socket.create_connection(
            (settings.CLAMAV_HOST, settings.CLAMAV_PORT),
            timeout=settings.CLAMAV_TIMEOUT_SECONDS,
        ) as connection:
            connection.sendall(b"zINSTREAM\0")
            stream = io.BytesIO(payload)
            while chunk := stream.read(64 * 1024):
                connection.sendall(struct.pack("!I", len(chunk)))
                connection.sendall(chunk)
            connection.sendall(struct.pack("!I", 0))
            response = connection.recv(4096).decode("utf-8", errors="replace")
    except OSError as exc:
        raise MalwareScannerUnavailable("The malware scanner is unavailable.") from exc
    if "FOUND" in response:
        raise MalwareDetected("The upload was rejected by the malware scanner.")
    if "OK" not in response:
        raise MalwareScannerUnavailable("The malware scanner returned an invalid response.")


def store_upload(*, user, payload, is_transient=False):
    fingerprint = user_scoped_fingerprint(user.id, payload)
    with transaction.atomic():
        type(user).objects.select_for_update().get(id=user.id)
        existing = EncryptedBlob.objects.filter(
            user=user,
            fingerprint=fingerprint,
            state=EncryptedBlob.State.AVAILABLE,
        ).first()
        if existing and not is_transient:
            existing.reference_count += 1
            existing.save(update_fields=("reference_count", "updated_at"))
            return StoredUpload(existing, False)

        used = (
            EncryptedBlob.objects.filter(
                user=user,
                state=EncryptedBlob.State.AVAILABLE,
            ).aggregate(total=Sum("plaintext_size"))["total"]
            or 0
        )
        if used + len(payload) > settings.ORIGINAL_STORAGE_QUOTA_BYTES:
            raise OriginalQuotaExceeded("Original storage quota exceeded.")

        blob_id = uuid.uuid4()
        object_key = f"v1/{uuid.uuid4().hex}"
        ciphertext, encrypted_key = encrypt_original(payload, blob_id)
        store = get_object_store("upload")
        store.put(object_key, ciphertext)
        try:
            blob = EncryptedBlob.objects.create(
                id=blob_id,
                user=user,
                object_key=object_key,
                encrypted_key=encrypted_key,
                master_key_version=settings.ORIGINAL_MASTER_KEY_VERSION,
                fingerprint=fingerprint,
                plaintext_size=len(payload),
                ciphertext_size=len(ciphertext),
            )
        except Exception:
            store.delete(object_key)
            raise
        return StoredUpload(blob, True)


def load_asset_bytes(asset, *, purpose="read"):
    if not asset.blob_id:
        raise OriginalStorageUnavailable("This original is unavailable.")
    ciphertext = get_object_store(purpose).get(asset.blob.object_key)
    return decrypt_original(asset.blob, ciphertext)


def release_assets(assets):
    object_keys = []
    with transaction.atomic():
        for asset in list(assets):
            if not asset.blob_id:
                asset.delete()
                continue
            blob = EncryptedBlob.objects.select_for_update().get(id=asset.blob_id)
            asset.delete()
            if blob.reference_count > 1:
                blob.reference_count -= 1
                blob.save(update_fields=("reference_count", "updated_at"))
                continue
            object_keys.append(blob.object_key)
            StorageDeletionJob.objects.create(object_key=blob.object_key)
            blob.encrypted_key = b""
            blob.state = EncryptedBlob.State.DELETION_PENDING
            blob.reference_count = 0
            blob.save(
                update_fields=(
                    "encrypted_key",
                    "state",
                    "reference_count",
                    "updated_at",
                )
            )
    return object_keys


def release_blob_reference(blob_id):
    """Undo a retained reference when asset persistence did not complete."""
    with transaction.atomic():
        blob = EncryptedBlob.objects.select_for_update().filter(id=blob_id).first()
        if blob is None or blob.state != EncryptedBlob.State.AVAILABLE:
            return
        if blob.reference_count > 1:
            blob.reference_count -= 1
            blob.save(update_fields=("reference_count", "updated_at"))
            return
        StorageDeletionJob.objects.create(object_key=blob.object_key)
        blob.encrypted_key = b""
        blob.state = EncryptedBlob.State.DELETION_PENDING
        blob.reference_count = 0
        blob.save(
            update_fields=(
                "encrypted_key",
                "state",
                "reference_count",
                "updated_at",
            )
        )


def purge_storage_deletions(limit=100):
    jobs = list(
        StorageDeletionJob.objects.filter(
            status__in=(
                StorageDeletionJob.Status.PENDING,
                StorageDeletionJob.Status.FAILED,
            )
        ).order_by("created_at")[:limit]
    )
    store = get_object_store("deletion")
    for job in jobs:
        try:
            store.delete(job.object_key)
        except OriginalStorageError as exc:
            job.status = StorageDeletionJob.Status.FAILED
            job.error_code = exc.code
            job.attempts += 1
            job.save(update_fields=("status", "error_code", "attempts", "updated_at"))
            continue
        job.status = StorageDeletionJob.Status.SUCCEEDED
        job.error_code = ""
        job.attempts += 1
        job.completed_at = timezone.now()
        job.save(
            update_fields=(
                "status",
                "error_code",
                "attempts",
                "completed_at",
                "updated_at",
            )
        )
        EncryptedBlob.objects.filter(
            object_key=job.object_key,
            state=EncryptedBlob.State.DELETION_PENDING,
        ).delete()
    return len(jobs)
