from django.conf import settings

from ai.providers.mock import MockLLMProvider, MockOCRProvider, MockSTTProvider


def get_llm_provider():
    if settings.AI_LLM_PROVIDER == "mock":
        return MockLLMProvider()
    raise ValueError(f"Unsupported LLM provider: {settings.AI_LLM_PROVIDER}")


def get_ocr_provider():
    if settings.AI_OCR_PROVIDER == "mock":
        return MockOCRProvider()
    raise ValueError(f"Unsupported OCR provider: {settings.AI_OCR_PROVIDER}")


def get_stt_provider():
    if settings.AI_STT_PROVIDER == "mock":
        return MockSTTProvider()
    raise ValueError(f"Unsupported STT provider: {settings.AI_STT_PROVIDER}")
