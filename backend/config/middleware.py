import uuid


class RequestIDMiddleware:
    """Attach a correlation ID and complete API error envelopes."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request.request_id = str(uuid.uuid4())
        response = self.get_response(request)
        response["X-Request-ID"] = request.request_id

        if request.path.startswith("/api/"):
            # Authenticated medical responses must never be stored by browsers,
            # reverse proxies, or intermediary caches.
            response["Cache-Control"] = "private, no-store"
            response["Pragma"] = "no-cache"

        if (
            request.path.startswith("/api/")
            and response.status_code >= 400
            and hasattr(response, "data")
        ):
            from config.exceptions import normalize_error_data

            response.data = normalize_error_data(
                response.data,
                status_code=response.status_code,
                request_id=request.request_id,
            )
        return response
