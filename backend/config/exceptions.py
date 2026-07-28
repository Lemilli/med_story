from rest_framework.exceptions import (
    AuthenticationFailed,
    NotAuthenticated,
    NotFound,
    PermissionDenied,
    Throttled,
    ValidationError,
)
from rest_framework.views import exception_handler
from rest_framework.response import Response


def normalize_error_data(data, *, status_code, request_id):
    if isinstance(data, dict) and isinstance(data.get("error"), dict):
        error = dict(data["error"])
        error.setdefault("code", "request_failed")
        error.setdefault("message", "The request could not be completed.")
        error.setdefault("details", {})
        error["request_id"] = request_id
        return {"error": error}

    details = data if isinstance(data, (dict, list)) else {}
    return {
        "error": {
            "code": _default_error_code(status_code),
            "message": _default_error_message(status_code),
            "details": details,
            "request_id": request_id,
        }
    }


def api_error_response(request, *, code, message, status_code, details=None):
    return Response(
        {
            "error": {
                "code": code,
                "message": message,
                "details": details or {},
                "request_id": getattr(request, "request_id", ""),
            }
        },
        status=status_code,
    )


def _default_error_code(status_code):
    return {
        400: "validation_error",
        401: "authentication_required",
        403: "permission_denied",
        404: "not_found",
        405: "method_not_allowed",
        409: "conflict",
        413: "file_too_large",
        415: "unsupported_media_type",
        429: "throttled",
    }.get(status_code, "request_failed")


def _default_error_message(status_code):
    return {
        400: "Request validation failed.",
        401: "Authentication is required.",
        403: "You do not have permission to perform this action.",
        404: "The requested resource was not found.",
        405: "This method is not allowed.",
        409: "The request conflicts with the current resource state.",
        413: "The uploaded file is too large.",
        415: "The request media type is not supported.",
        429: "Request limit reached. Please try again later.",
    }.get(status_code, "The request could not be completed.")


def api_exception_handler(exc, context):
    """Return the documented error envelope for every DRF exception."""
    response = exception_handler(exc, context)
    if response is None:
        return None

    request = context.get("request")
    request_id = getattr(request, "request_id", "")
    details = response.data if isinstance(response.data, (dict, list)) else {}

    if isinstance(exc, Throttled):
        code = "throttled"
        message = "Request limit reached. Please try again later."
        details = {}
        if exc.wait is not None:
            details["retry_after_seconds"] = int(exc.wait)
    elif isinstance(exc, (NotAuthenticated, AuthenticationFailed)):
        code = "authentication_required"
        message = "Authentication is required."
    elif isinstance(exc, PermissionDenied):
        code = "permission_denied"
        message = "You do not have permission to perform this action."
    elif isinstance(exc, NotFound):
        code = "not_found"
        message = "The requested resource was not found."
    elif isinstance(exc, ValidationError):
        code = "validation_error"
        message = "Request validation failed."
    else:
        code = _default_error_code(response.status_code)
        message = _default_error_message(response.status_code)

    response.data = {
        "error": {
            "code": code,
            "message": message,
            "details": details,
            "request_id": request_id,
        }
    }
    return response
