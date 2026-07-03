import base64

from celery import shared_task
from celery.utils.log import get_task_logger

from medical.models import Document, ProcessingJob, Subject
from medical.services import process_document_explanation, process_document_ingestion, process_medical_summary


logger = get_task_logger(__name__)


@shared_task
def ingest_document_task(document_id, job_id, file_bytes_b64, mime_type, language=None):
    document = Document.objects.select_related("user", "subject").get(id=document_id, deleted_at__isnull=True)
    job = ProcessingJob.objects.filter(id=job_id, document=document).first()
    file_bytes = base64.b64decode(file_bytes_b64.encode("ascii"))

    logger.info(
        "Starting document ingestion document_id=%s job_id=%s mime_type=%s size_bytes=%s language=%s",
        document.id,
        job_id,
        mime_type,
        len(file_bytes),
        language or "",
    )
    try:
        process_document_ingestion(
            document=document,
            file_bytes=file_bytes,
            mime_type=mime_type,
            job=job,
            language=language,
        )
    except Exception as exc:
        document.refresh_from_db(fields=("status", "error_message"))
        logger.exception(
            "Document ingestion failed document_id=%s job_id=%s status=%s saved_error=%r exception_type=%s",
            document.id,
            job_id,
            document.status,
            document.error_message,
            exc.__class__.__name__,
        )
        return {
            "status": "failed",
            "document_id": str(document.id),
            "error": document.error_message,
        }

    logger.info("Document ingestion processed document_id=%s job_id=%s", document.id, job_id)
    return {"status": "processed", "document_id": str(document.id)}


@shared_task
def explain_document_task(document_id, job_id, language=None):
    document = Document.objects.select_related("user", "subject").get(id=document_id, deleted_at__isnull=True)
    job = ProcessingJob.objects.filter(id=job_id, document=document).first()

    logger.info(
        "Starting document explanation document_id=%s job_id=%s language=%s",
        document.id,
        job_id,
        language or "",
    )
    try:
        process_document_explanation(document=document, language=language, job=job)
    except Exception as exc:
        logger.exception(
            "Document explanation failed document_id=%s job_id=%s exception_type=%s",
            document.id,
            job_id,
            exc.__class__.__name__,
        )
        return {
            "status": "failed",
            "document_id": str(document.id),
            "error": getattr(job, "error_message", ""),
        }

    logger.info("Document explanation processed document_id=%s job_id=%s", document.id, job_id)
    return {"status": "processed", "document_id": str(document.id)}


@shared_task
def generate_summary_task(subject_id, job_id, language=None):
    subject = Subject.objects.select_related("user").get(id=subject_id)
    job = ProcessingJob.objects.filter(id=job_id, user=subject.user).first()

    logger.info(
        "Starting summary generation subject_id=%s job_id=%s language=%s",
        subject.id,
        job_id,
        language or "",
    )
    try:
        summary = process_medical_summary(subject=subject, job=job, language=language)
    except Exception as exc:
        logger.exception(
            "Summary generation failed subject_id=%s job_id=%s exception_type=%s",
            subject.id,
            job_id,
            exc.__class__.__name__,
        )
        return {
            "status": "failed",
            "subject_id": str(subject.id),
            "error": getattr(job, "error_message", ""),
        }

    logger.info("Summary generation processed subject_id=%s job_id=%s", subject.id, job_id)
    return {"status": "processed", "summary_id": str(summary.id)}
