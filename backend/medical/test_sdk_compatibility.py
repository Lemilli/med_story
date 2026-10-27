"""Exercise the installed SDK through its HTTP transport without provider calls."""

import json
from unittest.mock import patch

import httpx2
from django.test import SimpleTestCase, override_settings
from openai import OpenAI

from ai.providers.openai import (
    OpenAILLMProvider,
    OpenAIOCRProvider,
    OpenAIProviderError,
    OpenAISTTProvider,
)
from medical.test_fixtures import PNG_BYTES


@override_settings(
    AI_OPENAI_API_KEY="synthetic-test-key",
    AI_OPENAI_MODEL="synthetic-llm",
    AI_OPENAI_OCR_MODEL="synthetic-ocr",
    AI_OPENAI_STT_MODEL="synthetic-stt",
    AI_OPENAI_TIMEOUT_SECONDS=12,
)
class OpenAISDKCompatibilityTests(SimpleTestCase):
    def sdk_client(self, handler):
        client = OpenAI(
            api_key="synthetic-test-key",
            max_retries=0,
            http_client=httpx2.Client(transport=httpx2.MockTransport(handler)),
        )
        self.addCleanup(client.close)
        return client

    def response(self, payload):
        return httpx2.Response(
            200,
            json={
                "id": "resp_synthetic",
                "object": "response",
                "output": [{
                    "id": "msg_synthetic",
                    "type": "message",
                    "role": "assistant",
                    "status": "completed",
                    "content": [{
                        "type": "output_text",
                        "text": json.dumps(payload),
                        "annotations": [],
                    }],
                }],
            },
        )

    def test_structured_output_round_trip_with_installed_sdk(self):
        def handler(request):
            self.assertEqual(request.url.path, "/v1/responses")
            payload = json.loads(request.content)
            self.assertIs(payload["store"], False)
            self.assertEqual(payload["text"]["format"]["type"], "json_schema")
            self.assertTrue(payload["text"]["format"]["strict"])
            return self.response({"event": None})

        client = self.sdk_client(handler)
        with patch("ai.providers.openai._build_client", return_value=client):
            result = OpenAILLMProvider().complete_json(
                system="Organize synthetic information.",
                user="Synthetic document.",
                schema={"type": "object", "properties": {"event": {"type": "null"}}},
            )
        self.assertEqual(result, {"event": None})

    def test_image_ocr_round_trip_with_installed_sdk(self):
        def handler(request):
            payload = json.loads(request.content)
            self.assertIs(payload["store"], False)
            image = payload["input"][1]["content"][1]
            self.assertEqual(image["type"], "input_image")
            self.assertTrue(image["image_url"].startswith("data:image/png;base64,"))
            return self.response({"text": " Synthetic document. ", "language": "en"})

        client = self.sdk_client(handler)
        with patch("ai.providers.openai._build_client", return_value=client):
            result = OpenAIOCRProvider().extract_text(file_bytes=PNG_BYTES, mime="image/png")
        self.assertEqual(result.text, "Synthetic document.")
        self.assertEqual(result.language, "en")

    def test_audio_round_trip_with_installed_sdk(self):
        def handler(request):
            self.assertEqual(request.url.path, "/v1/audio/transcriptions")
            self.assertIn("multipart/form-data", request.headers["content-type"])
            payload = request.read()
            self.assertIn(b'filename="voice-note.wav"', payload)
            self.assertIn(b'synthetic-stt', payload)
            self.assertIn(b'name="language"', payload)
            return httpx2.Response(200, json={"text": " Synthetic transcription. "})

        client = self.sdk_client(handler)
        with patch("ai.providers.openai._build_client", return_value=client):
            result = OpenAISTTProvider().transcribe(
                audio_bytes=b"synthetic-audio", mime="audio/wav", lang="en"
            )
        self.assertEqual(result, "Synthetic transcription.")

    def test_actual_sdk_error_does_not_expose_provider_body(self):
        def handler(request):
            return httpx2.Response(400, json={"error": {"message": "synthetic-private-body"}})

        client = self.sdk_client(handler)
        with patch("ai.providers.openai._build_client", return_value=client):
            with self.assertLogs("ai.providers.openai", level="ERROR") as logs:
                with self.assertRaises(OpenAIProviderError) as raised:
                    OpenAISTTProvider().transcribe(audio_bytes=b"synthetic", mime="audio/wav")
        self.assertEqual(str(raised.exception), "AI provider request failed.")
        self.assertNotIn("synthetic-private-body", "\n".join(logs.output))
        self.assertIsNone(raised.exception.__cause__)
