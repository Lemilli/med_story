import base64

from celery import shared_task

from medical.models import Document, ProcessingJob
from medical.services import process_document_ingestion


@shared_task
def ingest_document_task(document_id, job_id, file_bytes_b64, mime_type):
    document = Document.objects.select_related("user", "subject").get(id=document_id, deleted_at__isnull=True)
    job = ProcessingJob.objects.filter(id=job_id, document=document).first()
    file_bytes = base64.b64decode(file_bytes_b64.encode("ascii"))

    try:
        process_document_ingestion(
            document=document,
            file_bytes=file_bytes,
            mime_type=mime_type,
            job=job,
        )
    except Exception:
        return {"status": "failed", "document_id": str(document.id)}

    return {"status": "processed", "document_id": str(document.id)}
