from rest_framework.throttling import ScopedRateThrottle


class ClientIPScopedRateThrottle(ScopedRateThrottle):
    """Apply a scoped throttle by client IP, including authenticated requests."""

    def get_cache_key(self, request, view):
        if not getattr(self, "scope", None):
            return None
        return self.cache_format % {"scope": self.scope, "ident": self.get_ident(request)}
