from __future__ import annotations

from datetime import date
from typing import Any


ALLOWED_EVENT_TYPES = {
    "symptom",
    "diagnosis",
    "medication",
    "examination",
    "procedure",
    "hospitalization",
    "treatment_outcome",
    "note",
}

EVENT_EXTRACTION_JSON_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["document_date", "events"],
    "properties": {
        "document_date": {"type": ["string", "null"], "format": "date"},
        "suggested_title": {"type": ["string", "null"]},
        "events": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": [
                    "event_type",
                    "title",
                    "description",
                    "event_date",
                    "attributes",
                    "confidence",
                ],
                "properties": {
                    "event_type": {"type": "string", "enum": sorted(ALLOWED_EVENT_TYPES)},
                    "title": {"type": "string", "minLength": 1, "maxLength": 255},
                    "description": {"type": ["string", "null"]},
                    "event_date": {"type": ["string", "null"], "format": "date"},
                    "attributes": {"type": "object"},
                    "confidence": {"type": "number", "minimum": 0, "maximum": 1},
                },
            },
        },
    },
}


class SchemaValidationError(ValueError):
    pass


def validate_event_extraction(payload: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(payload, dict):
        raise SchemaValidationError("Structured output must be an object.")

    document_date = _parse_nullable_date(payload.get("document_date"), "document_date")
    suggested_title = payload.get("suggested_title")
    if suggested_title is not None and not isinstance(suggested_title, str):
        raise SchemaValidationError("suggested_title must be a string or null.")

    raw_events = payload.get("events")
    if not isinstance(raw_events, list):
        raise SchemaValidationError("events must be a list.")

    events = [_validate_event(event, index) for index, event in enumerate(raw_events)]
    return {
        "document_date": document_date,
        "suggested_title": suggested_title.strip() if isinstance(suggested_title, str) else None,
        "events": events,
    }


def _validate_event(event: Any, index: int) -> dict[str, Any]:
    if not isinstance(event, dict):
        raise SchemaValidationError(f"events[{index}] must be an object.")

    event_type = event.get("event_type")
    if event_type not in ALLOWED_EVENT_TYPES:
        raise SchemaValidationError(f"events[{index}].event_type is unsupported.")

    title = event.get("title")
    if not isinstance(title, str) or not title.strip():
        raise SchemaValidationError(f"events[{index}].title is required.")
    title = title.strip()
    if len(title) > 255:
        raise SchemaValidationError(f"events[{index}].title is too long.")

    description = event.get("description")
    if description is not None and not isinstance(description, str):
        raise SchemaValidationError(f"events[{index}].description must be a string or null.")

    attributes = event.get("attributes")
    if not isinstance(attributes, dict):
        raise SchemaValidationError(f"events[{index}].attributes must be an object.")

    confidence = event.get("confidence")
    if not isinstance(confidence, (int, float)) or isinstance(confidence, bool):
        raise SchemaValidationError(f"events[{index}].confidence must be a number.")
    if confidence < 0 or confidence > 1:
        raise SchemaValidationError(f"events[{index}].confidence must be between 0 and 1.")

    return {
        "event_type": event_type,
        "title": title,
        "description": description.strip() if isinstance(description, str) else "",
        "event_date": _parse_nullable_date(event.get("event_date"), f"events[{index}].event_date"),
        "attributes": attributes,
        "confidence": float(confidence),
    }


def _parse_nullable_date(value: Any, field_name: str) -> date | None:
    if value in (None, ""):
        return None
    if not isinstance(value, str):
        raise SchemaValidationError(f"{field_name} must be an ISO date string or null.")
    try:
        return date.fromisoformat(value)
    except ValueError as exc:
        raise SchemaValidationError(f"{field_name} must be an ISO date string.") from exc
