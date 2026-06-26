from ai.providers.base import OCRResult


class MockLLMProvider:
    def complete_json(self, *, system: str, user: str, schema: dict) -> dict:
        return {
            "document_date": None,
            "events": [],
            "summary_text": "",
            "key_points": [],
            "glossary": {},
            "model_name": "mock-llm",
        }


class MockOCRProvider:
    def extract_text(self, *, file_bytes: bytes, mime: str) -> OCRResult:
        return OCRResult(text="", language=None)


class MockSTTProvider:
    def transcribe(self, *, audio_bytes: bytes, mime: str, lang: str | None = None) -> str:
        return ""
