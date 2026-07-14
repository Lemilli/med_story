from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class OCRResult:
    text: str
    language: str | None = None


class LLMProvider(Protocol):
    def complete_json(
        self,
        *,
        system: str,
        user: str,
        schema: dict,
        user_prompt: str | None = None,
        schema_name: str = "medical_event_extraction",
        model: str | None = None,
    ) -> dict:
        """Return schema-constrained JSON from an LLM provider."""


class OCRProvider(Protocol):
    def extract_text(self, *, file_bytes: bytes, mime: str) -> OCRResult:
        """Extract text from a document or image."""


class STTProvider(Protocol):
    def transcribe(self, *, audio_bytes: bytes, mime: str, lang: str | None = None) -> str:
        """Transcribe audio bytes into plain text."""
