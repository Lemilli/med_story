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

EVENT_ATTRIBUTES_JSON_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": [
        "name",
        "dose",
        "frequency",
        "route",
        "duration",
        "prescriber",
        "clinician",
        "facility",
        "result",
        "diagnosis",
        "body_site",
        "severity",
        "outcome",
        "measurements",
        "medications",
        "notes",
    ],
    "properties": {
        "name": {"type": ["string", "null"]},
        "dose": {"type": ["string", "null"]},
        "frequency": {"type": ["string", "null"]},
        "route": {"type": ["string", "null"]},
        "duration": {"type": ["string", "null"]},
        "prescriber": {"type": ["string", "null"]},
        "clinician": {"type": ["string", "null"]},
        "facility": {"type": ["string", "null"]},
        "result": {"type": ["string", "null"]},
        "diagnosis": {"type": ["string", "null"]},
        "body_site": {"type": ["string", "null"]},
        "severity": {"type": ["string", "null"]},
        "outcome": {"type": ["string", "null"]},
        "measurements": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["label", "value", "unit", "ref"],
                "properties": {
                    "label": {"type": ["string", "null"]},
                    "value": {"type": ["string", "number", "null"]},
                    "unit": {"type": ["string", "null"]},
                    "ref": {"type": ["string", "null"]},
                },
            },
        },
        "medications": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["name", "dose", "frequency", "route", "duration"],
                "properties": {
                    "name": {"type": ["string", "null"]},
                    "dose": {"type": ["string", "null"]},
                    "frequency": {"type": ["string", "null"]},
                    "route": {"type": ["string", "null"]},
                    "duration": {"type": ["string", "null"]},
                },
            },
        },
        "notes": {"type": ["string", "null"]},
    },
}

EVENT_EXTRACTION_JSON_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["document_date", "suggested_title", "events"],
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
                    "attributes": EVENT_ATTRIBUTES_JSON_SCHEMA,
                    "confidence": {"type": "number", "minimum": 0, "maximum": 1},
                },
            },
        },
    },
}

DOCUMENT_EXPLANATION_JSON_SCHEMA = {
    "type": "object",
    "additionalProperties": False,
    "required": ["summary_text", "key_points", "glossary"],
    "properties": {
        "summary_text": {"type": "string", "minLength": 1},
        "key_points": {
            "type": "array",
            "items": {"type": "string", "minLength": 1},
        },
        "glossary": {
            "type": "object",
            "additionalProperties": {"type": "string", "minLength": 1},
        },
    },
}


class SchemaValidationError(ValueError):
    pass


def validate_event_extraction(payload: dict[str, Any], *, default_date: date | None = None) -> dict[str, Any]:
    if not isinstance(payload, dict):
        raise SchemaValidationError("Structured output must be an object.")

    fallback_date = default_date or date.today()
    document_date = _parse_nullable_date(payload.get("document_date")) or fallback_date
    suggested_title = payload.get("suggested_title")
    if not isinstance(suggested_title, str):
        suggested_title = None

    raw_events = payload.get("events")
    if not isinstance(raw_events, list):
        raise SchemaValidationError("events must be a list.")

    events = []
    for index, event in enumerate(raw_events):
        try:
            events.append(_validate_event(event, index, fallback_date=document_date))
        except SchemaValidationError:
            continue

    return {
        "document_date": document_date,
        "suggested_title": _truncate_text(suggested_title.strip(), 255) if isinstance(suggested_title, str) else None,
        "events": events,
    }


def validate_document_explanation(payload: dict[str, Any]) -> dict[str, Any]:
    if not isinstance(payload, dict):
        raise SchemaValidationError("Explanation output must be an object.")

    summary_text = payload.get("summary_text")
    if not isinstance(summary_text, str) or not summary_text.strip():
        raise SchemaValidationError("summary_text is required.")

    raw_key_points = payload.get("key_points")
    if not isinstance(raw_key_points, list):
        raise SchemaValidationError("key_points must be a list.")
    key_points = []
    for point in raw_key_points:
        if isinstance(point, str) and point.strip():
            key_points.append(point.strip())

    raw_glossary = payload.get("glossary")
    if not isinstance(raw_glossary, dict):
        raise SchemaValidationError("glossary must be an object.")
    glossary = {}
    for term, definition in raw_glossary.items():
        if isinstance(term, str) and term.strip() and isinstance(definition, str) and definition.strip():
            glossary[term.strip()] = definition.strip()

    return {
        "summary_text": summary_text.strip(),
        "key_points": key_points,
        "glossary": glossary,
    }


def _validate_event(event: Any, index: int, *, fallback_date: date) -> dict[str, Any]:
    if not isinstance(event, dict):
        raise SchemaValidationError(f"events[{index}] must be an object.")

    event_type = _normalize_event_type(event.get("event_type"))

    title = event.get("title")
    if not isinstance(title, str) or not title.strip():
        raise SchemaValidationError(f"events[{index}].title is required.")
    title = _truncate_text(title.strip(), 255)

    description = event.get("description")
    if description is not None and not isinstance(description, str):
        description = str(description)

    attributes = event.get("attributes")
    if not isinstance(attributes, dict):
        attributes = {}

    confidence = _normalize_confidence(event.get("confidence"))

    return {
        "event_type": event_type,
        "title": title,
        "description": description.strip() if isinstance(description, str) else "",
        "event_date": _parse_nullable_date(event.get("event_date")) or fallback_date,
        "attributes": attributes,
        "confidence": float(confidence),
    }


def _parse_nullable_date(value: Any) -> date | None:
    if value in (None, ""):
        return None
    if not isinstance(value, str):
        return None

    normalized = value.strip()
    if not normalized:
        return None

    for parser in (_parse_iso_date, _parse_year_first_date, _parse_day_first_date):
        parsed = parser(normalized)
        if parsed is not None:
            return parsed
    return None


def _parse_iso_date(value: str) -> date | None:
    try:
        return date.fromisoformat(value)
    except ValueError:
        return None


def _parse_year_first_date(value: str) -> date | None:
    for separator in (".", "/", "-"):
        parts = value.split(separator)
        if len(parts) != 3 or len(parts[0]) != 4:
            continue
        try:
            return date(int(parts[0]), int(parts[1]), int(parts[2]))
        except ValueError:
            return None
    return None


def _parse_day_first_date(value: str) -> date | None:
    for separator in (".", "/", "-"):
        parts = value.split(separator)
        if len(parts) != 3 or len(parts[2]) != 4:
            continue
        try:
            return date(int(parts[2]), int(parts[1]), int(parts[0]))
        except ValueError:
            return None
    return None


def _normalize_event_type(value: Any) -> str:
    if not isinstance(value, str):
        return "note"

    normalized = value.strip().lower().replace(" ", "_").replace("-", "_")
    aliases = {
        "lab": "examination",
        "lab_result": "examination",
        "laboratory": "examination",
        "test": "examination",
        "visit": "examination",
        "appointment": "examination",
        "drug": "medication",
        "medicine": "medication",
        "operation": "procedure",
        "surgery": "procedure",
        "admission": "hospitalization",
        "hospitalisation": "hospitalization",
        "outcome": "treatment_outcome",
    }
    return normalized if normalized in ALLOWED_EVENT_TYPES else aliases.get(normalized, "note")


def _normalize_confidence(value: Any) -> float:
    if isinstance(value, bool):
        return 0.5
    if isinstance(value, str):
        try:
            value = float(value.strip())
        except ValueError:
            return 0.5
    if not isinstance(value, (int, float)):
        return 0.5
    return min(1.0, max(0.0, float(value)))


def _truncate_text(value: str, max_length: int) -> str:
    return value[:max_length]
