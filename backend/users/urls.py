from django.urls import path
from users.views import (
    AuditedTokenObtainPairView, ConsentListView, CurrentLegalNoticeView,
    LogoutView, MeView, PasswordResetConfirmView, PasswordResetRequestView, RegisterView,
    ResendVerificationView, ThrottledTokenRefreshView, UsageView, VerifyEmailView,
)

urlpatterns = [
    path("auth/register", RegisterView.as_view(), name="auth-register"),
    path("auth/verify-email", VerifyEmailView.as_view(), name="auth-verify-email"),
    path("auth/resend-verification", ResendVerificationView.as_view(), name="auth-resend-verification"),
    path("auth/password-reset/request", PasswordResetRequestView.as_view(), name="auth-password-reset-request"),
    path("auth/password-reset/confirm", PasswordResetConfirmView.as_view(), name="auth-password-reset-confirm"),
    path("auth/login", AuditedTokenObtainPairView.as_view(), name="token-obtain-pair"),
    path("auth/refresh", ThrottledTokenRefreshView.as_view(), name="token-refresh"),
    path("auth/logout", LogoutView.as_view(), name="auth-logout"),
    path("me", MeView.as_view(), name="me"),
    path("me/consents", ConsentListView.as_view(), name="me-consents"),
    path("me/usage", UsageView.as_view(), name="me-usage"),
    path("legal/notices/current", CurrentLegalNoticeView.as_view(), name="legal-notices-current"),
]
