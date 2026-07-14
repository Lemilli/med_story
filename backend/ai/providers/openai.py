import base64
import copy
import json
import logging
from io import BytesIO

from django.conf import settings

from ai.providers.base import OCRResult


EVENT_EXTRACTION_USER_PROMPT = """Create exactly one structured medical timeline event from this source text.

Return only facts explicitly present in the source. If a date is missing, use null. Prefer concise,
patient-readable titles. Write the description in the source's primary language as a high-signal,
plain-language analysis of one to three short sentences. It must help a person understand the report
without replacing the original document. When a date is included in the description, format it as
DD.MM.YYYY.

For laboratory and infection-related reports, use this priority order in the description:
1. First state any named positive, reactive, detected, or abnormal infection/pathogen test result.
   Name the test, virus, bacterium, or other condition exactly as the source identifies it.
2. State named negative, non-reactive, or not-detected infection/pathogen results when they provide
   useful contrast (for example, a panel testing several viruses).
3. Then mention at most three other results explicitly outside their provided reference range or
   marked high, low, or abnormal. Do not list every measurement or its raw numbers.
4. Say that listed results appear within their stated reference ranges only when there are no
   positive/detected results and no material abnormal findings to report.

Describe the report's result, not a diagnosis: never say that the person has, is ill with, or is
"most likely" to have an infection unless the source itself explicitly records that diagnosis. Do
not infer infection from a blood-count pattern, combine test markers into a diagnosis, recommend
treatment, or add risk assessment. If the source itself gives a clinical conclusion, attribute it
clearly to the source (for example, "The report records ...").

Put complete lab values, medications, dosages, clinicians, facilities, and other source details in
attributes when present. When a source contains several kinds of medical facts, use event_type
medical_record and organize all supported facts within the single event. Return every date as ISO
8601 YYYY-MM-DD in the structured date fields; convert visible dates like 03.05.2024 to 2024-05-03.
Return event as null when the source cannot create a medical-history event."""

OCR_SYSTEM_PROMPT = (
    "You extract readable text from medical documents for the user's private medical organizer. "
    "Transcribe all visible text faithfully. Do not summarize, diagnose, or add information."
)

logger = logging.getLogger(__name__)

OPENAI_UNSUPPORTED_SCHEMA_KEYWORDS = {
    "format",
    "maxLength",
    "maximum",
    "minLength",
    "minimum",
}


class OpenAIProviderError(ValueError):
    pass


class OpenAILLMProvider:
    def __init__(self):
        self.client = _build_client()
        self.model = settings.AI_OPENAI_MODEL

    def complete_json(
        self,
        *,
        system: str,
        user: str,
        schema: dict,
        user_prompt: str | None = None,
        schema_name: str = "medical_event_extraction",
    ) -> dict:
        prompt = user_prompt or EVENT_EXTRACTION_USER_PROMPT
        try:
            response = self.client.responses.create(
                model=self.model,
                input=[
                    {
                        "role": "system",
                        "content": [{"type": "input_text", "text": system}],
                    },
                    {
                        "role": "user",
                        "content": [{"type": "input_text", "text": f"{prompt}\n\n{user}"}],
                    },
                ],
                text={
                    "format": {
                        "type": "json_schema",
                        "name": schema_name,
                        "schema": _openai_structured_output_schema(schema),
                        "strict": True,
                    }
                },
                timeout=settings.AI_OPENAI_TIMEOUT_SECONDS,
            )
        except Exception as exc:
            raise _provider_error("structured output request", exc) from exc

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

        try:
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
        except Exception as exc:
            raise _provider_error("OCR request", exc) from exc

        return OCRResult(text=response.output_text.strip(), language=None)


class OpenAISTTProvider:
    _AUDIO_EXTENSIONS_BY_MIME = {
        "audio/mpeg": "mp3",
        "audio/mp3": "mp3",
        "audio/mp4": "mp4",
        "audio/mpga": "mpga",
        "audio/m4a": "m4a",
        "audio/wav": "wav",
        "audio/webm": "webm",
    }

    def __init__(self):
        self.client = _build_client()
        self.model = settings.AI_OPENAI_STT_MODEL

    def transcribe(self, *, audio_bytes: bytes, mime: str, lang: str | None = None) -> str:
        extension = self._AUDIO_EXTENSIONS_BY_MIME.get(mime)
        if extension is None:
            raise OpenAIProviderError(f"Unsupported STT MIME type: {mime}")

        audio_file = BytesIO(audio_bytes)
        audio_file.name = f"voice-note.{extension}"

        kwargs = {
            "model": self.model,
            "file": audio_file,
            "response_format": "json",
            "timeout": settings.AI_OPENAI_TIMEOUT_SECONDS,
        }
        if lang:
            kwargs["language"] = lang

        try:
            response = self.client.audio.transcriptions.create(**kwargs)
        except Exception as exc:
            raise _provider_error("STT request", exc) from exc

        text = response.get("text") if isinstance(response, dict) else getattr(response, "text", None)
        if not isinstance(text, str):
            raise OpenAIProviderError("OpenAI returned an invalid transcription response.")
        return text.strip()


def _build_client():
    if not settings.AI_OPENAI_API_KEY:
        raise OpenAIProviderError("AI_OPENAI_API_KEY is required when using the OpenAI provider.")

    from openai import OpenAI

    return OpenAI(api_key=settings.AI_OPENAI_API_KEY)


def _openai_structured_output_schema(schema: dict) -> dict:
    openai_schema = copy.deepcopy(schema)
    _remove_unsupported_schema_keywords(openai_schema)
    return openai_schema


def _remove_unsupported_schema_keywords(value):
    if isinstance(value, dict):
        for keyword in OPENAI_UNSUPPORTED_SCHEMA_KEYWORDS:
            value.pop(keyword, None)
        for child in value.values():
            _remove_unsupported_schema_keywords(child)
    elif isinstance(value, list):
        for child in value:
            _remove_unsupported_schema_keywords(child)


def _provider_error(operation: str, exc: Exception) -> OpenAIProviderError:
    message = _format_openai_error(operation, exc)
    logger.exception(message)
    return OpenAIProviderError(message)


def _format_openai_error(operation: str, exc: Exception) -> str:
    status_code = getattr(exc, "status_code", None)
    response = getattr(exc, "response", None)
    if status_code is None and response is not None:
        status_code = getattr(response, "status_code", None)

    body = getattr(exc, "body", None)
    if body is None and response is not None:
        try:
            body = response.json()
        except Exception:
            body = getattr(response, "text", None)

    details = str(exc)
    if body:
        try:
            details = json.dumps(body, ensure_ascii=True)
        except TypeError:
            details = str(body)

    status_fragment = f" status={status_code}" if status_code is not None else ""
    return f"OpenAI {operation} failed{status_fragment}: {details}"
