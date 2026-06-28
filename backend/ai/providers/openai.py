import base64
import json

from django.conf import settings

from ai.providers.base import OCRResult


EVENT_EXTRACTION_USER_PROMPT = """Extract structured medical timeline events from this source text.

Return only facts that are explicitly present. If a date is missing, use null. Prefer concise,
patient-readable titles. Put lab values, medications, dosages, clinicians, facilities, and other
source details in attributes when present."""

OCR_SYSTEM_PROMPT = (
    "You extract readable text from medical documents for the user's private medical organizer. "
    "Transcribe all visible text faithfully. Do not summarize, diagnose, or add information."
)


class OpenAIProviderError(ValueError):
    pass


class OpenAILLMProvider:
    def __init__(self):
        self.client = _build_client()
        self.model = settings.AI_OPENAI_MODEL

    def complete_json(self, *, system: str, user: str, schema: dict) -> dict:
        response = self.client.responses.create(
            model=self.model,
            input=[
                {
                    "role": "system",
                    "content": [{"type": "input_text", "text": system}],
                },
                {
                    "role": "user",
                    "content": [{"type": "input_text", "text": f"{EVENT_EXTRACTION_USER_PROMPT}\n\n{user}"}],
                },
            ],
            text={
                "format": {
                    "type": "json_schema",
                    "name": "medical_event_extraction",
                    "schema": schema,
                    "strict": True,
                }
            },
            timeout=settings.AI_OPENAI_TIMEOUT_SECONDS,
        )
        try:
            return json.loads(response.output_text)
        except json.JSONDecodeError as exc:
            raise OpenAIProviderError("OpenAI returned invalid JSON.") from exc


class OpenAIOCRProvider:
    def __init__(self):
        self.client = _build_client()
        self.model = settings.AI_OPENAI_OCR_MODEL

    def extract_text(self, *, file_bytes: bytes, mime: str) -> OCRResult:
        content = [{"type": "input_text", "text": "Extract all readable text from this file."}]
        if mime.startswith("image/"):
            encoded = base64.b64encode(file_bytes).decode("ascii")
            content.append({"type": "input_image", "image_url": f"data:{mime};base64,{encoded}"})
        elif mime == "application/pdf":
            encoded = base64.b64encode(file_bytes).decode("ascii")
            content.append(
                {
                    "type": "input_file",
                    "filename": "medical-document.pdf",
                    "file_data": f"data:{mime};base64,{encoded}",
                }
            )
        else:
            raise OpenAIProviderError(f"Unsupported OCR MIME type: {mime}")

        response = self.client.responses.create(
            model=self.model,
            input=[
                {
                    "role": "system",
                    "content": [{"type": "input_text", "text": OCR_SYSTEM_PROMPT}],
                },
                {
                    "role": "user",
                    "content": content,
                },
            ],
            timeout=settings.AI_OPENAI_TIMEOUT_SECONDS,
        )
        return OCRResult(text=response.output_text.strip(), language=None)


def _build_client():
    if not settings.AI_OPENAI_API_KEY:
        raise OpenAIProviderError("AI_OPENAI_API_KEY is required when using the OpenAI provider.")

    from openai import OpenAI

    return OpenAI(api_key=settings.AI_OPENAI_API_KEY)
