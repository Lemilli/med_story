from django.db import transaction
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken

from medical.models import AuditLog, DocumentAsset
from medical.original_storage import release_assets
from medical.services import log_audit_event
from medical.tasks import purge_storage_deletions_task
from config.throttling import ClientIPScopedRateThrottle
from users.serializers import LogoutSerializer, RegisterSerializer, UserSerializer


class RegisterView(generics.CreateAPIView):
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer
    throttle_classes = (ClientIPScopedRateThrottle,)
    throttle_scope = "auth_register"

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response(
            {
                "user": UserSerializer(user).data,
                "access": str(refresh.access_token),
                "refresh": str(refresh),
            },
            status=status.HTTP_201_CREATED,
        )


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
            return Response(
                {"error": {"code": "validation_error", "message": "Invalid refresh token."}},
                status=status.HTTP_400_BAD_REQUEST,
            )

        return Response(status=status.HTTP_205_RESET_CONTENT)


class ThrottledTokenRefreshView(TokenRefreshView):
    throttle_classes = (ClientIPScopedRateThrottle,)
    throttle_scope = "auth_session"
