SUMMARY_CONTENT_SECTIONS = (
    "current_concerns",
    "important_diagnoses_and_findings",
    "allergies",
    "current_medications",
    "important_test_results",
    "previous_treatments_and_outcomes",
    "procedures_and_hospitalizations",
)

LEGACY_SUMMARY_SECTION_MAP = {
    "key_symptoms": "current_concerns",
    "major_diagnoses": "important_diagnoses_and_findings",
    "relevant_medications": "current_medications",
    "important_examinations": "important_test_results",
    "treatment_history": "previous_treatments_and_outcomes",
}


def normalize_summary_content(content):
    """Return the current API shape without rewriting stored summary versions."""
    source = content if isinstance(content, dict) else {}
    normalized = {section: [] for section in SUMMARY_CONTENT_SECTIONS}

    for section in SUMMARY_CONTENT_SECTIONS:
        normalized[section] = _normalize_items(source.get(section, []))

    for legacy_section, current_section in LEGACY_SUMMARY_SECTION_MAP.items():
        if not normalized[current_section]:
            normalized[current_section] = _normalize_items(source.get(legacy_section, []))
    return normalized


def _normalize_items(items):
    if not isinstance(items, list):
        return []
    normalized = []
    for item in items:
        if isinstance(item, str) and item.strip():
            normalized.append({"text": item.strip(), "detail": "", "sources": []})
            continue
        if not isinstance(item, dict):
            continue
        text = item.get("text")
        if not isinstance(text, str) or not text.strip():
            continue
        detail = item.get("detail", "")
        sources = item.get("sources", [])
        normalized.append({
            "text": text.strip(),
            "detail": detail.strip() if isinstance(detail, str) else "",
            "sources": sources if isinstance(sources, list) else [],
        })
    return normalized
