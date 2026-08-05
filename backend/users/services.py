import hashlib
import hmac
import secrets
from datetime import timedelta

from django.conf import settings
from django.core.mail import send_mail
from django.db import transaction
from django.utils import timezone

from users.models import ConsentRecord, EmailChallenge


PRIVACY_NOTICE_VERSION = getattr(settings, "PRIVACY_NOTICE_VERSION", "2026-08-06")


def _challenge_ttl():
    return timedelta(seconds=getattr(settings, "EMAIL_CHALLENGE_TTL_SECONDS", 900))


def _max_challenge_attempts():
    return getattr(settings, "EMAIL_CHALLENGE_MAX_ATTEMPTS", 5)


def _challenge_digest(*, challenge_id, code):
    message = f"{challenge_id}:{code}".encode()
    return hmac.new(settings.SECRET_KEY.encode(), message, hashlib.sha256).hexdigest()


def create_email_challenge(*, user, purpose):
    code = f"{secrets.randbelow(1_000_000):06d}"
    now = timezone.now()
    with transaction.atomic():
        EmailChallenge.objects.filter(
            user=user,
            purpose=purpose,
            invalidated_at__isnull=True,
        ).update(invalidated_at=now)
        challenge = EmailChallenge.objects.create(
            user=user,
            purpose=purpose,
            code_digest="pending",
            expires_at=now + _challenge_ttl(),
        )
        challenge.code_digest = _challenge_digest(challenge_id=challenge.id, code=code)
        challenge.save(update_fields=("code_digest",))

    label = "verify your email" if purpose == EmailChallenge.Purpose.VERIFY_EMAIL else "reset your password"
    send_mail(
        subject=f"MedStory: {label}",
        message=f"Your MedStory code is {code}. It expires in 15 minutes.",
        from_email=getattr(settings, "DEFAULT_FROM_EMAIL", None),
        recipient_list=[user.email],
        fail_silently=False,
    )
    return challenge


def consume_email_challenge(*, email, purpose, code):
    normalized_email = email.strip().lower()
    now = timezone.now()
    with transaction.atomic():
        challenge = (
            EmailChallenge.objects.select_for_update()
            .select_related("user")
            .filter(
                user__email__iexact=normalized_email,
                purpose=purpose,
                invalidated_at__isnull=True,
            )
            .order_by("-created_at")
            .first()
        )
        if challenge is None or challenge.expires_at <= now or challenge.attempts >= _max_challenge_attempts():
            return None
        valid = hmac.compare_digest(
            challenge.code_digest,
            _challenge_digest(challenge_id=challenge.id, code=code),
        )
        challenge.attempts += 1
        if valid or challenge.attempts >= _max_challenge_attempts():
            challenge.invalidated_at = now
        challenge.save(update_fields=("attempts", "invalidated_at"))
        return challenge.user if valid else None


def record_consent(*, user, kind, granted, notice_version=PRIVACY_NOTICE_VERSION):
    return ConsentRecord.objects.create(
        user=user,
        kind=kind,
        notice_version=notice_version,
        granted=granted,
    )


def latest_consent(user, kind):
    return user.consent_records.filter(kind=kind).order_by("-created_at").first()
