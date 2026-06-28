import logging

from django.conf import settings
from django.db import transaction
from django.utils import timezone

from ai.providers.factory import get_llm_provider, get_ocr_provider
from ai.schemas import EVENT_EXTRACTION_JSON_SCHEMA, SchemaValidationError, validate_event_extraction
from medical.models import Subject


STRUCTURING_SYSTEM_PROMPT = (
    "You are MedStory's assistant. You organize medical information for a non-medical reader. "
    "Do not diagnose, recommend treatments, or invent values that are not present in the source."
)

logger = logging.getLogger(__name__)


def get_or_create_default_subject(user):
    default_subject = Subject.objects.filter(user=user, is_default=True).first()
    if default_subject:
        return default_subject

    display_name = user.full_name or "Myself"
    return Subject.objects.create(
        user=user,
        display_name=display_name,
        relationship=Subject.Relationship.SELF,
        is_default=True,
    )


def process_document_ingestion(*, document, file_bytes, mime_type, job=None):
    from medical.models import Document, MedicalEvent, ProcessingJob

    job_id = getattr(job, "id", None)
    logger.info(
        "Document ingestion phase=start document_id=%s job_id=%s mime_type=%s size_bytes=%s ocr_provider=%s llm_provider=%s ocr_model=%s llm_model=%s",
        document.id,
        job_id,
        mime_type,
        len(file_bytes),
        settings.AI_OCR_PROVIDER,
        settings.AI_LLM_PROVIDER,
        settings.AI_OPENAI_OCR_MODEL,
        settings.AI_OPENAI_MODEL,
    )

    now = timezone.now()
    if job is not None:
        job.status = ProcessingJob.Status.RUNNING
        job.attempts += 1
        job.started_at = now
        job.finished_at = None
        job.error_message = ""
        job.save(update_fields=("status", "attempts", "started_at", "finished_at", "error_message", "updated_at"))

    try:
        ocr_result = get_ocr_provider().extract_text(file_bytes=file_bytes, mime=mime_type)
        logger.info(
            "Document ingestion phase=ocr_complete document_id=%s job_id=%s extracted_text_length=%s language=%s",
            document.id,
            job_id,
            len(ocr_result.text or ""),
            ocr_result.language or "",
        )
        structured_payload = get_llm_provider().complete_json(
            system=STRUCTURING_SYSTEM_PROMPT,
            user=ocr_result.text,
            schema=EVENT_EXTRACTION_JSON_SCHEMA,
        )
        logger.info(
            "Document ingestion phase=structured_output_complete document_id=%s job_id=%s top_level_keys=%s",
            document.id,
            job_id,
            sorted(structured_payload.keys()) if isinstance(structured_payload, dict) else type(structured_payload).__name__,
        )
        extraction = validate_event_extraction(structured_payload, default_date=timezone.localdate())
        logger.info(
            "Document ingestion phase=validation_complete document_id=%s job_id=%s event_count=%s document_date=%s",
            document.id,
            job_id,
            len(extraction["events"]),
            extraction["document_date"],
        )

        with transaction.atomic():
            document.extracted_text = ocr_result.text
            document.language = ocr_result.language or ""
            if extraction["document_date"] is not None:
                document.document_date = extraction["document_date"]
            if extraction["suggested_title"]:
                document.title = extraction["suggested_title"][:255]
            document.status = Document.Status.PROCESSED
            document.error_message = ""
            document.save(
                update_fields=(
                    "extracted_text",
                    "language",
                    "document_date",
                    "title",
                    "status",
                    "error_message",
                    "updated_at",
                )
            )

            document.medical_events.filter(
                source=MedicalEvent.Source.AI_DOCUMENT,
                is_confirmed=False,
                deleted_at__isnull=True,
            ).update(deleted_at=timezone.now())

            for event_data in extraction["events"]:
                event_date = event_data["event_date"] or extraction["document_date"] or document.document_date
                if event_date is None:
                    continue
                MedicalEvent.objects.create(
                    user=document.user,
                    subject=document.subject,
                    source_document=document,
                    event_type=event_data["event_type"],
                    title=event_data["title"],
                    description=event_data["description"],
                    event_date=event_date,
                    attributes=event_data["attributes"],
                    source=MedicalEvent.Source.AI_DOCUMENT,
                    confidence=event_data["confidence"],
                    is_confirmed=False,
                )

            if job is not None:
                job.status = ProcessingJob.Status.SUCCEEDED
                job.finished_at = timezone.now()
                job.error_message = ""
                job.save(update_fields=("status", "finished_at", "error_message", "updated_at"))
        logger.info(
            "Document ingestion phase=complete document_id=%s job_id=%s event_count=%s",
            document.id,
            job_id,
            len(extraction["events"]),
        )
    except (SchemaValidationError, ValueError) as exc:
        logger.exception(
            "Document ingestion phase=failed document_id=%s job_id=%s exception_type=%s error=%s",
            document.id,
            job_id,
            exc.__class__.__name__,
            exc,
        )
        _mark_ingestion_failed(document=document, job=job, message=str(exc) or "Document processing failed.")
        raise
    except Exception as exc:
        logger.exception(
            "Document ingestion phase=failed document_id=%s job_id=%s exception_type=%s",
            document.id,
            job_id,
            exc.__class__.__name__,
        )
        _mark_ingestion_failed(document=document, job=job, message="Document processing failed.")
        raise exc


def _mark_ingestion_failed(*, document, job, message):
    from medical.models import Document, ProcessingJob

    sanitized_message = message[:500]
    with transaction.atomic():
        document.status = Document.Status.FAILED
        document.error_message = sanitized_message
        document.save(update_fields=("status", "error_message", "updated_at"))
        if job is not None:
            job.status = ProcessingJob.Status.FAILED
            job.error_message = sanitized_message
            job.finished_at = timezone.now()
            job.save(update_fields=("status", "error_message", "finished_at", "updated_at"))
