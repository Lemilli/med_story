"""Synthetic payloads shared by ingestion tests; no private local assets needed."""

import base64


LAB_RESULT_BYTES = (
    b"Synthetic lab report. Date: 2026-05-12.\n"
    b"C-reactive protein (CRP): 12 mg/L. Reference range: < 5 mg/L.\n"
)

PRESCRIPTION_BYTES = (
    b"Synthetic prescription. Date: 2026-05-13.\n"
    b"Mesalazine 800 mg orally three times daily for 30 days.\n"
    b"Prescriber: Dr. Example.\n"
)

# A valid, transparent 1x1 PNG. OCR responses are mocked independently so tests
# exercise image transport without depending on a real patient's document.
PNG_BYTES = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk"
    "+A8AAQUBAScY42YAAAAASUVORK5CYII="
)
