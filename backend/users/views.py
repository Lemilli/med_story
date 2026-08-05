from django.conf import settings
from django.contrib.auth import get_user_model
from django.db import models, transaction
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.token_blacklist.models import BlacklistedToken, OutstandingToken

from config.exceptions import api_error_response
from medical.models import AuditLog, DocumentAsset, EncryptedBlob
from medical.original_storage import release_assets
from medical.services import log_audit_event
from medical.tasks import purge_storage_deletions_task
from config.throttling import ClientIPScopedRateThrottle
from users.models import ConsentRecord, EmailChallenge
from users.serializers import (
    AIConsentSerializer,
    ConsentRecordSerializer,
    CurrentLegalNoticeSerializer,
    EmailCodeSerializer,
    EmailOnlySerializer,
    LogoutSerializer,
    PasswordResetConfirmSerializer,
    RegisterSerializer,
    UserSerializer,
    UsageSerializer,
)
from users.services import (
    PRIVACY_NOTICE_VERSION,
    consume_email_challenge,
    create_email_challenge,
    latest_consent,
    record_consent,
)

User = get_user_model()


class EmailScopedRateThrottle(ScopedRateThrottle):
    def get_cache_key(self, request, view):
        email = request.data.get("email") if isinstance(request.data, dict) else None
        if not email or not getattr(self, "scope", None):
            return None
        return self.cache_format % {"scope": self.scope, "ident": f"email:{email.strip().casefold()}"}


class RegisterView(generics.CreateAPIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer
    throttle_classes = (ClientIPScopedRateThrottle,)
    throttle_scope = "auth_register"

    def create(self, request, *args, **kwargs):
        if not getattr(settings, "REGISTRATION_ENABLED", True):
            return api_error_response(
                request,
                code="registration_disabled",
                message="Registration is temporarily closed.",
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        if User.objects.filter(is_active=True).count() >= getattr(settings, "DEMO_MAX_VERIFIED_USERS", 100):
            return api_error_response(
                request,
                code="demo_capacity_reached",
                message="This demo has reached its account capacity.",
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        create_email_challenge(user=user, purpose=EmailChallenge.Purpose.VERIFY_EMAIL)
        return Response(
            {
                "user": UserSerializer(user).data,
                "verification_required": True,
            },
            status=status.HTTP_202_ACCEPTED,
        )


class VerifyEmailView(generics.GenericAPIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = EmailCodeSerializer
    throttle_classes = (ClientIPScopedRateThrottle, EmailScopedRateThrottle)
    throttle_scope = "auth_verify"

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        if User.objects.filter(is_active=True).count() >= getattr(settings, "DEMO_MAX_VERIFIED_USERS", 100):
            return api_error_response(request, code="demo_capacity_reached", message="This demo has reached its account capacity.", status_code=status.HTTP_503_SERVICE_UNAVAILABLE)
        user = consume_email_challenge(
            email=serializer.validated_data["email"],
            purpose=EmailChallenge.Purpose.VERIFY_EMAIL,
            code=serializer.validated_data["code"],
        )
        if user is None:
            return api_error_response(request, code="invalid_verification_code", message="The code is invalid or expired.", status_code=status.HTTP_400_BAD_REQUEST)
        user.is_active = True
        user.save(update_fields=("is_active", "updated_at"))
        refresh = RefreshToken.for_user(user)
        return Response({"user": UserSerializer(user).data, "access": str(refresh.access_token), "refresh": str(refresh)})


class ResendVerificationView(generics.GenericAPIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = EmailOnlySerializer
    throttle_classes = (ClientIPScopedRateThrottle, EmailScopedRateThrottle)
    throttle_scope = "auth_verify"

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = User.objects.filter(email__iexact=serializer.validated_data["email"], is_active=False).first()
        if user:
            create_email_challenge(user=user, purpose=EmailChallenge.Purpose.VERIFY_EMAIL)
        return Response(status=status.HTTP_202_ACCEPTED)


class PasswordResetRequestView(generics.GenericAPIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = EmailOnlySerializer
    throttle_classes = (ClientIPScopedRateThrottle, EmailScopedRateThrottle)
    throttle_scope = "auth_password_reset"

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = User.objects.filter(email__iexact=serializer.validated_data["email"], is_active=True).first()
        if user:
            create_email_challenge(user=user, purpose=EmailChallenge.Purpose.RESET_PASSWORD)
        return Response(status=status.HTTP_202_ACCEPTED)


class PasswordResetConfirmView(generics.GenericAPIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = PasswordResetConfirmSerializer
    throttle_classes = (ClientIPScopedRateThrottle, EmailScopedRateThrottle)
    throttle_scope = "auth_password_reset"

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = consume_email_challenge(
            email=serializer.validated_data["email"],
            purpose=EmailChallenge.Purpose.RESET_PASSWORD,
            code=serializer.validated_data["code"],
        )
        if user is None:
            return api_error_response(request, code="invalid_reset_code", message="The code is invalid or expired.", status_code=status.HTTP_400_BAD_REQUEST)
        user.set_password(serializer.validated_data["new_password"])
        user.save(update_fields=("password", "updated_at"))
        for token in OutstandingToken.objects.filter(user=user):
            BlacklistedToken.objects.get_or_create(token=token)
        return Response(status=status.HTTP_204_NO_CONTENT)


class CurrentLegalNoticeView(generics.GenericAPIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = CurrentLegalNoticeSerializer

    def get(self, request):
        locale = request.query_params.get("locale", "en")
        if locale not in {"en", "ru"}:
            locale = "en"
        notices = {
            "en": {
                "privacy_notice": "MedStory is a demonstration service. Data is retained until you delete it or the demo infrastructure is lost; recovery is not guaranteed. Infrastructure-provider snapshots may retain deleted bytes temporarily.",
                "ai_processing": "If enabled, the health content needed for a requested AI feature is sent to the configured AI provider for explanatory and organizational processing. MedStory does not diagnose or recommend treatment.",
            },
            "ru": {
                "privacy_notice": "MedStory — демонстрационный сервис. Данные хранятся до их удаления вами или утраты инфраструктуры демо; восстановление не гарантируется. Снимки инфраструктурного провайдера могут временно сохранять удалённые данные.",
                "ai_processing": "Если функция включена, необходимые медицинские данные передаются настроенному ИИ-провайдеру для пояснения и организации. MedStory не ставит диагнозы и не рекомендует лечение.",
            },
        }
        return Response({"version": PRIVACY_NOTICE_VERSION, "locale": locale, **notices[locale]})


class ConsentListView(generics.GenericAPIView):
    serializer_class = ConsentRecordSerializer

    def get(self, request):
        records = [latest_consent(request.user, kind) for kind in ConsentRecord.Kind.values]
        return Response(self.get_serializer([record for record in records if record], many=True).data)


class AIConsentView(generics.GenericAPIView):
    serializer_class = AIConsentSerializer

    def put(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        record = record_consent(
            user=request.user,
            kind=ConsentRecord.Kind.AI_PROCESSING,
            granted=serializer.validated_data["granted"],
            notice_version=serializer.validated_data["notice_version"],
        )
        return Response(ConsentRecordSerializer(record).data)


class UsageView(generics.GenericAPIView):
    serializer_class = UsageSerializer

    def get(self, request):
        from medical.services import get_ai_usage

        storage_used = EncryptedBlob.objects.filter(
            user=request.user,
            state=EncryptedBlob.State.AVAILABLE,
        ).aggregate(total=models.Sum("plaintext_size"))["total"] or 0
        return Response({
            "ai": get_ai_usage(request.user),
            "storage": {
                "used_bytes": storage_used,
                "limit_bytes": getattr(settings, "ORIGINAL_STORAGE_QUOTA_BYTES", 100 * 1024 * 1024),
            },
        })


class AuditedTokenObtainPairView(TokenObtainPairView):
    throttle_classes = (ClientIPScopedRateThrottle,)
    throttle_scope = "auth_login"

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        log_audit_event(user=serializer.user, action=AuditLog.Action.LOGIN, request=request)
        return Response(serializer.validated_data, status=status.HTTP_200_OK)


class MeView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user

    def destroy(self, request, *args, **kwargs):
        user = request.user
        refresh_token = request.data.get("refresh") if isinstance(request.data, dict) else None
        if refresh_token:
            try:
                refresh = RefreshToken(refresh_token)
                if str(refresh.get("user_id")) == str(user.id):
                    refresh.blacklist()
            except TokenError:
                pass

        with transaction.atomic():
            log_audit_event(
                user=user,
                action=AuditLog.Action.ACCOUNT_DELETE,
                request=request,
                metadata={"refresh_token_blacklist_requested": bool(refresh_token)},
            )
            release_assets(
                DocumentAsset.objects.filter(document__user=user).select_related("blob")
            )
            user.delete()
        transaction.on_commit(lambda: purge_storage_deletions_task.delay())

        return Response(status=status.HTTP_204_NO_CONTENT)


class LogoutView(generics.GenericAPIView):
    serializer_class = LogoutSerializer
    throttle_classes = (ClientIPScopedRateThrottle,)
    throttle_scope = "auth_session"

    def post(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        refresh_token = serializer.validated_data["refresh"]

        try:
            RefreshToken(refresh_token).blacklist()
        except TokenError:
            return api_error_response(
                request,
                code="validation_error",
                message="Invalid refresh token.",
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        return Response(status=status.HTTP_205_RESET_CONTENT)


class ThrottledTokenRefreshView(TokenRefreshView):
    throttle_classes = (ClientIPScopedRateThrottle,)
    throttle_scope = "auth_session"
