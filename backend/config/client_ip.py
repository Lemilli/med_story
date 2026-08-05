from ipaddress import ip_address

from django.conf import settings


def get_client_ip(request):
    """Resolve a client IP while trusting only the configured proxy hops."""
    if request is None:
        return None

    remote_address = _canonical_ip(request.META.get("REMOTE_ADDR", ""))
    trusted_proxy_count = settings.THROTTLE_TRUSTED_PROXY_COUNT
    if trusted_proxy_count <= 0:
        return remote_address

    forwarded = [
        value.strip()
        for value in request.META.get("HTTP_X_FORWARDED_FOR", "").split(",")
        if value.strip()
    ]
    if len(forwarded) < trusted_proxy_count:
        return remote_address

    return _canonical_ip(forwarded[-trusted_proxy_count]) or remote_address


def _canonical_ip(value):
    try:
        return str(ip_address(value))
    except ValueError:
        return None
