from datetime import timedelta

from celery import shared_task
from celery.utils.log import get_task_logger
from django.utils import timezone

from medical.models import Document, DocumentAsset, ProcessingJob, Subject
from medical.original_storage import (
    load_asset_bytes,
    purge_storage_deletions,
    release_assets,
)
from medical.services import (
    DocumentProcessingCancelled,
    process_document_explanation,
    process_document_ingestion,
    process_medical_summary,
)


logger = get_task_logger(__name__)


@shared_task
def ingest_document_task(document_id, job_id, language=None):
    document = (
        Document.objects.select_related("user", "subject")
        .filter(id=document_id, deleted_at__isnull=True)
        .first()
    )
    if document is None:
        logger.info("Document ingestion cancelled before start document_id=%s job_id=%s", document_id, job_id)
        return {"status": "cancelled", "document_id": str(document_id)}

    job = ProcessingJob.objects.filter(id=job_id, document=document).first()
    try:
        assets = list(document.assets.select_related("blob").order_by("position"))
        decoded_parts = [
            (load_asset_bytes(asset, purpose="processing"), asset.mime_type)
            for asset in assets
        ]
        file_bytes = decoded_parts[0][0] if decoded_parts else b""
        mime_type = decoded_parts[0][1] if decoded_parts else document.mime_type
        logger.info(
            "Starting document ingestion document_id=%s job_id=%s mime_type=%s asset_count=%s size_bytes=%s language=%s",
            document.id,
            job_id,
            mime_type,
            len(decoded_parts),
            sum(len(part_bytes) for part_bytes, _ in decoded_parts),
            language or "",
        )
        event = process_document_ingestion(
            document=document,
            file_bytes=file_bytes,
            mime_type=mime_type,
            file_parts=decoded_parts,
            job=job,
            language=language,
        )
    except DocumentProcessingCancelled:
        result = {"status": "cancelled", "document_id": str(document.id)}
    except Exception as exc:
        current_document = Document.objects.filter(
            id=document.id,
            deleted_at__isnull=True,
        ).only("status", "error_message").first()
        if current_document is None:
            logger.info(
                "Document ingestion cancelled during cleanup document_id=%s job_id=%s",
                document.id,
                job_id,
            )
            return {"status": "cancelled", "document_id": str(document.id)}
        logger.exception(
            "Document ingestion failed document_id=%s job_id=%s status=%s saved_error=%r exception_type=%s",
            document.id,
            job_id,
            current_document.status,
            current_document.error_message,
            exc.__class__.__name__,
        )
        result = {
            "status": "failed",
            "document_id": str(document.id),
            "error": current_document.error_message,
        }
    else:
        logger.info("Document ingestion processed document_id=%s job_id=%s", document.id, job_id)
        result = {"status": "processed", "document_id": str(document.id), "event_id": str(event.id)}
    finally:
        if document.doc_type == Document.DocumentType.AUDIO:
            release_assets(
                DocumentAsset.objects.filter(document=document, is_transient=True).select_related("blob")
            )
            purge_storage_deletions()
    return result


@shared_task
def ingest_note_task(document_id, job_id, text, language=None):
    document = Document.objects.select_related("user", "subject").get(id=document_id, deleted_at__isnull=True)
    job = ProcessingJob.objects.filter(id=job_id, document=document).first()
    try:
        event = process_document_ingestion(
            document=document,
            file_bytes=b"",
            mime_type="text/plain",
            job=job,
            language=language,
            extracted_text_override=text,
        )
    except Exception:
        logger.exception("Note ingestion failed document_id=%s job_id=%s", document.id, job_id)
        return {"status": "failed", "document_id": str(document.id), "error": document.error_message}
    return {"status": "processed", "document_id": str(document.id), "event_id": str(event.id)}


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


@shared_task
def purge_storage_deletions_task():
    return {"processed": purge_storage_deletions()}


@shared_task
def cleanup_transient_originals_task(max_age_hours=24):
    cutoff = timezone.now() - timedelta(hours=max_age_hours)
    assets = DocumentAsset.objects.filter(
        is_transient=True,
        created_at__lt=cutoff,
    ).select_related("blob")
    released = assets.count()
    release_assets(assets)
    purge_storage_deletions()
    return {"released": released}
