from ai.providers.base import OCRResult


class MockLLMProvider:
    model = "mock"

    def complete_json(
        self,
        *,
        system: str,
        user: str,
        schema: dict,
        user_prompt: str | None = None,
        schema_name: str = "medical_event_extraction",
    ) -> dict:
        if "summary_text" in schema.get("properties", {}):
            return {
                "summary_text": "The document lists a CRP result of 12 mg/L, which is above the shown reference of < 5 mg/L.",
                "key_points": [
                    "CRP is commonly used as a marker related to inflammation.",
                ],
                "glossary": {},
            }

        normalized = user.casefold()
        if "c-reactive protein" in normalized or "crp" in normalized:
            return {
                "document_date": "2026-05-12",
                "suggested_title": "CBC and CRP lab results",
                "events": [
                    {
                        "event_type": "examination",
                        "title": "CBC and CRP lab results",
                        "description": "Blood count and inflammation marker results from the document.",
                        "event_date": "2026-05-12",
                        "attributes": {
                            "name": "CBC and inflammation markers",
                            "measurements": [
                                {
                                    "label": "CRP",
                                    "value": 12,
                                    "unit": "mg/L",
                                    "ref": "< 5",
                                }
                            ],
                        },
                        "confidence": 0.92,
                    }
                ],
            }
        if "mesalazine" in normalized:
            return {
                "document_date": "2026-05-13",
                "suggested_title": "Gastroenterology prescription",
                "events": [
                    {
                        "event_type": "medication",
                        "title": "Started Mesalazine",
                        "description": "Prescription for Mesalazine 800 mg tablet three times daily for 30 days.",
                        "event_date": "2026-05-13",
                        "attributes": {
                            "name": "Mesalazine",
                            "dose": "800 mg",
                            "frequency": "three times daily",
                            "route": "oral",
                            "duration": "30 days",
                            "prescriber": "Dr. Example",
                        },
                        "confidence": 0.94,
                    }
                ],
            }
        return {
            "document_date": None,
            "suggested_title": None,
            "events": [],
        }


class MockOCRProvider:
    def extract_text(self, *, file_bytes: bytes, mime: str) -> OCRResult:
        return OCRResult(text=file_bytes.decode("utf-8", errors="ignore"), language="en")


class MockSTTProvider:
    def transcribe(self, *, audio_bytes: bytes, mime: str, lang: str | None = None) -> str:
        return ""
