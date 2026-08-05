from rest_framework.throttling import ScopedRateThrottle

from config.client_ip import get_client_ip


class ClientIPScopedRateThrottle(ScopedRateThrottle):
    """Apply a scoped throttle by client IP, including authenticated requests."""

    def get_cache_key(self, request, view):
        if not getattr(self, "scope", None):
            return None
        ident = get_client_ip(request) or "invalid-client-address"
        return self.cache_format % {"scope": self.scope, "ident": ident}
