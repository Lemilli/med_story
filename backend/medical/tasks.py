import base64

from celery import shared_task
from celery.utils.log import get_task_logger

from medical.models import Document, ProcessingJob
from medical.services import process_document_ingestion


logger = get_task_logger(__name__)


@shared_task
def ingest_document_task(document_id, job_id, file_bytes_b64, mime_type):
    document = Document.objects.select_related("user", "subject").get(id=document_id, deleted_at__isnull=True)
    job = ProcessingJob.objects.filter(id=job_id, document=document).first()
    file_bytes = base64.b64decode(file_bytes_b64.encode("ascii"))

    logger.info(
        "Starting document ingestion document_id=%s job_id=%s mime_type=%s size_bytes=%s",
        document.id,
        job_id,
        mime_type,
        len(file_bytes),
    )
    try:
        process_document_ingestion(
            document=document,
            file_bytes=file_bytes,
            mime_type=mime_type,
            job=job,
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
