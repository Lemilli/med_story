from rest_framework.exceptions import Throttled
from rest_framework.views import exception_handler


def api_exception_handler(exc, context):
    """Keep throttling responses aligned with MedStory's documented error envelope."""
    response = exception_handler(exc, context)
    if response is not None and isinstance(exc, Throttled):
        details = {}
        if exc.wait is not None:
            details["retry_after_seconds"] = int(exc.wait)
        response.data = {
            "error": {
                "code": "throttled",
                "message": "Request limit reached. Please try again later.",
                "details": details,
            }
        }
    return response
