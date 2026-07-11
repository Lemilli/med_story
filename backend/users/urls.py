from django.urls import path
from users.views import AuditedTokenObtainPairView, LogoutView, MeView, RegisterView, ThrottledTokenRefreshView

urlpatterns = [
    path("auth/register", RegisterView.as_view(), name="auth-register"),
    path("auth/login", AuditedTokenObtainPairView.as_view(), name="token-obtain-pair"),
    path("auth/refresh", ThrottledTokenRefreshView.as_view(), name="token-refresh"),
    path("auth/logout", LogoutView.as_view(), name="auth-logout"),
    path("me", MeView.as_view(), name="me"),
]
