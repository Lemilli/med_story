import logging
from io import BytesIO
from textwrap import wrap

from django.conf import settings
from django.db.models import Max
from django.db import transaction
from django.utils import timezone

from ai.providers.factory import get_llm_provider, get_ocr_provider, get_stt_provider
from ai.schemas import (
    DOCUMENT_EXPLANATION_JSON_SCHEMA,
    EVENT_EXTRACTION_JSON_SCHEMA,
    MEDICAL_SUMMARY_JSON_SCHEMA,
    SUMMARY_CONTENT_SECTIONS,
    SchemaValidationError,
    validate_document_explanation,
    validate_event_extraction,
    validate_medical_summary,
)
from medical.models import AuditLog, Document, DocumentExplanation, MedicalEvent, MedicalSummary, ProcessingJob, Subject, Tag


STRUCTURING_SYSTEM_PROMPT = (
    "You are MedStory's assistant. You organize medical information for a non-medical reader. "
    "Do not diagnose, recommend treatments, or invent values that are not present in the source."
)

EXPLANATION_SYSTEM_PROMPT = (
    "You are MedStory's assistant. You summarize medical documents in plain language for a "
    "non-medical reader. Be brief and focus only on source-supported details a doctor would "
    "probably need to pay attention to. Do not diagnose, recommend treatments, prescribe, "
    "or invent facts."
)

EXPLANATION_USER_PROMPT = """Explain this medical document in {language}.

Return JSON using the provided schema:
- summary_text: 1-2 short sentences. If lab results appear within the document's provided
  reference ranges, simply say the listed results appear within range. If any values are outside
  the provided reference ranges or explicitly marked high, low, or abnormal, mention only the most
  important abnormal values with value, unit, and reference range when available.
- key_points: up to 3 short bullets for details a patient should notice. For prescriptions, use
  these bullets to explain what each medicine is generally used for. If a prescription lists more
  than 3 distinct medicines, include one bullet per medicine.
- glossary: leave empty unless 1-2 terms are essential for understanding the summary.

Do not give medical advice, interpret risk, recommend actions, or draw conclusions beyond the
source text."""

SUMMARY_SYSTEM_PROMPT = (
    "You are MedStory's assistant. You organize confirmed medical timeline events into a concise "
    "doctor-ready summary. Do not diagnose, recommend treatments, rank options, prescribe, or infer "
    "facts that are not present in the provided events."
)

SUMMARY_USER_PROMPT = """Create a concise medical history summary in {language}.

Use only the confirmed timeline events below. Return JSON using the provided schema:
- content.key_symptoms: important symptoms explicitly recorded
- content.major_diagnoses: diagnoses explicitly recorded
- content.treatment_history: treatments/procedures/outcomes explicitly recorded
- content.important_examinations: tests, imaging, labs, and notable results explicitly recorded
- content.relevant_medications: medications, doses, dates, and duration when explicitly recorded
- narrative_text: short doctor-ready prose that states this is based on confirmed MedStory events

Do not give medical advice, interpret risk, recommend actions, or draw conclusions beyond the events."""

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


def process_document_ingestion(*, document, file_bytes, mime_type, job=None, language=None):
    from medical.models import Document, MedicalEvent, ProcessingJob

    job_id = getattr(job, "id", None)
    is_audio = document.doc_type == Document.DocumentType.AUDIO
    logger.info(
        "Document ingestion phase=start document_id=%s job_id=%s mime_type=%s size_bytes=%s ocr_provider=%s stt_provider=%s llm_provider=%s ocr_model=%s stt_model=%s llm_model=%s",
        document.id,
        job_id,
        mime_type,
        len(file_bytes),
        settings.AI_OCR_PROVIDER,
        settings.AI_STT_PROVIDER,
        settings.AI_LLM_PROVIDER,
        settings.AI_OPENAI_OCR_MODEL,
        settings.AI_OPENAI_STT_MODEL,
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
        if is_audio:
            source_language = _resolve_audio_language(document=document, requested_language=language)
            extracted_text = get_stt_provider().transcribe(
                audio_bytes=file_bytes,
                mime=mime_type,
                lang=source_language,
            )
            extracted_language = source_language
            event_source = MedicalEvent.Source.AI_VOICE
            logger.info(
                "Document ingestion phase=stt_complete document_id=%s job_id=%s extracted_text_length=%s language=%s",
                document.id,
                job_id,
                len(extracted_text or ""),
                extracted_language or "",
            )
        else:
            ocr_result = get_ocr_provider().extract_text(file_bytes=file_bytes, mime=mime_type)
            extracted_text = ocr_result.text
            extracted_language = ocr_result.language or ""
            event_source = MedicalEvent.Source.AI_DOCUMENT
            logger.info(
                "Document ingestion phase=ocr_complete document_id=%s job_id=%s extracted_text_length=%s language=%s",
                document.id,
                job_id,
                len(extracted_text or ""),
                extracted_language,
            )
        structured_payload = get_llm_provider().complete_json(
            system=STRUCTURING_SYSTEM_PROMPT,
            user=extracted_text,
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
        explanation = None
        if not is_audio:
            explanation = _build_document_explanation(
                document=document,
                extracted_text=extracted_text,
                language=_resolve_explanation_language(document=document),
            )

        with transaction.atomic():
            document.extracted_text = extracted_text
            document.language = extracted_language
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
                source=event_source,
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
                    source=event_source,
                    confidence=event_data["confidence"],
                    is_confirmed=False,
                )

            if explanation is not None:
                document.explanations.create(**explanation)

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


def process_document_explanation(*, document, language=None, job=None):
    from medical.models import ProcessingJob

    job_id = getattr(job, "id", None)
    now = timezone.now()
    if job is not None:
        job.status = ProcessingJob.Status.RUNNING
        job.attempts += 1
        job.started_at = now
        job.finished_at = None
        job.error_message = ""
        job.save(update_fields=("status", "attempts", "started_at", "finished_at", "error_message", "updated_at"))

    try:
        if not document.extracted_text:
            raise ValueError("Document text is not available for explanation.")

        explanation = _build_document_explanation(
            document=document,
            extracted_text=document.extracted_text,
            language=_resolve_explanation_language(document=document, requested_language=language),
        )
        with transaction.atomic():
            document.explanations.create(**explanation)
            if job is not None:
                job.status = ProcessingJob.Status.SUCCEEDED
                job.finished_at = timezone.now()
                job.error_message = ""
                job.save(update_fields=("status", "finished_at", "error_message", "updated_at"))
    except (SchemaValidationError, ValueError) as exc:
        _mark_explanation_failed(job=job, message=str(exc) or "Document explanation failed.")
        raise
    except Exception as exc:
        _mark_explanation_failed(job=job, message="Document explanation failed.")
        raise exc


def enqueue_summary_regeneration(*, user, subject, reason="manual", language=None):
    from medical.models import ProcessingJob
    from medical.tasks import generate_summary_task

    job = ProcessingJob.objects.create(
        user=user,
        job_type=ProcessingJob.JobType.SUMMARY,
        status=ProcessingJob.Status.QUEUED,
    )
    try:
        result = generate_summary_task.delay(str(subject.id), str(job.id), language)
        job.task_id = result.id or ""
        job.save(update_fields=("task_id", "updated_at"))
    except Exception as exc:
        logger.warning(
            "Summary regeneration dispatch failed subject_id=%s job_id=%s exception_type=%s",
            subject.id,
            job.id,
            exc.__class__.__name__,
        )
    logger.info(
        "Summary regeneration enqueued subject_id=%s job_id=%s reason=%s",
        subject.id,
        job.id,
        reason,
    )
    return job


def process_medical_summary(*, subject, job=None, language=None):
    from medical.models import MedicalSummary, ProcessingJob

    job_id = getattr(job, "id", None)
    now = timezone.now()
    if job is not None:
        job.status = ProcessingJob.Status.RUNNING
        job.attempts += 1
        job.started_at = now
        job.finished_at = None
        job.error_message = ""
        job.save(update_fields=("status", "attempts", "started_at", "finished_at", "error_message", "updated_at"))

    try:
        events = list(
            MedicalEvent.objects.filter(
                user=subject.user,
                subject=subject,
                deleted_at__isnull=True,
                is_confirmed=True,
            )
            .select_related("source_document")
            .prefetch_related("tags")
            .order_by("event_date", "created_at")
        )
        summary_language = _resolve_summary_language(subject=subject, requested_language=language)
        if events:
            summary_payload = _build_medical_summary(events=events, language=summary_language)
        else:
            summary_payload = _empty_medical_summary(language=summary_language)

        with transaction.atomic():
            latest_version = (
                MedicalSummary.objects.select_for_update()
                .filter(subject=subject)
                .aggregate(value=Max("version"))["value"]
                or 0
            )
            MedicalSummary.objects.filter(subject=subject, is_current=True).update(is_current=False)
            summary = MedicalSummary.objects.create(
                user=subject.user,
                subject=subject,
                version=latest_version + 1,
                is_current=True,
                content=summary_payload["content"],
                narrative_text=summary_payload["narrative_text"],
                generated_from_event_count=len(events),
                model_name=summary_payload["model_name"],
                language=summary_language,
            )
            if job is not None:
                job.summary = summary
                job.status = ProcessingJob.Status.SUCCEEDED
                job.finished_at = timezone.now()
                job.error_message = ""
                job.save(update_fields=("summary", "status", "finished_at", "error_message", "updated_at"))
        logger.info(
            "Summary generation complete subject_id=%s job_id=%s event_count=%s version=%s",
            subject.id,
            job_id,
            len(events),
            summary.version,
        )
        return summary
    except (SchemaValidationError, ValueError) as exc:
        _mark_summary_failed(job=job, message=str(exc) or "Summary generation failed.")
        raise
    except Exception as exc:
        _mark_summary_failed(job=job, message="Summary generation failed.")
        raise exc


def build_summary_export_pdf(summary):
    try:
        from reportlab.lib.pagesizes import letter
        from reportlab.lib.styles import getSampleStyleSheet
        from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer

        buffer = BytesIO()
        document = SimpleDocTemplate(buffer, pagesize=letter, title="MedStory Doctor Summary")
        styles = getSampleStyleSheet()
        story = [
            Paragraph("MedStory Doctor Summary", styles["Title"]),
            Paragraph(f"Subject: {summary.subject.display_name}", styles["Normal"]),
            Paragraph(f"Generated: {summary.created_at:%Y-%m-%d}", styles["Normal"]),
            Spacer(1, 12),
            Paragraph(summary.narrative_text, styles["BodyText"]),
        ]
        for section in SUMMARY_CONTENT_SECTIONS:
            story.append(Spacer(1, 10))
            story.append(Paragraph(_humanize_summary_section(section), styles["Heading2"]))
            items = summary.content.get(section, [])
            if items:
                for item in items:
                    story.append(Paragraph(f"- {item}", styles["BodyText"]))
            else:
                story.append(Paragraph("No confirmed events recorded.", styles["BodyText"]))
        document.build(story)
        return buffer.getvalue()
    except ImportError:
        return _build_minimal_pdf(summary)


def summary_export_json(summary):
    return {
        "id": str(summary.id),
        "subject_id": str(summary.subject_id),
        "version": summary.version,
        "is_current": summary.is_current,
        "content": summary.content,
        "narrative_text": summary.narrative_text,
        "language": summary.language,
        "generated_from_event_count": summary.generated_from_event_count,
        "created_at": summary.created_at.isoformat().replace("+00:00", "Z"),
    }


def log_audit_event(*, user, action, request=None, metadata=None):
    return AuditLog.objects.create(
        user=user,
        action=action,
        metadata=metadata or {},
        ip_address=get_client_ip(request) if request is not None else None,
    )


def get_client_ip(request):
    forwarded_for = request.META.get("HTTP_X_FORWARDED_FOR", "") if request is not None else ""
    if forwarded_for:
        return forwarded_for.split(",", 1)[0].strip() or None
    return request.META.get("REMOTE_ADDR") if request is not None else None


def build_privacy_export(user):
    subjects = list(Subject.objects.filter(user=user).order_by("-is_default", "display_name", "created_at"))
    tags = list(Tag.objects.filter(user=user).order_by("name", "id"))
    documents = list(Document.objects.filter(user=user).select_related("subject").order_by("-created_at", "id"))
    explanations = list(
        DocumentExplanation.objects.filter(document__user=user)
        .select_related("document")
        .order_by("-created_at", "id")
    )
    events = list(
        MedicalEvent.objects.filter(user=user)
        .select_related("subject", "source_document")
        .prefetch_related("tags")
        .order_by("-event_date", "-created_at", "id")
    )
    summaries = list(
        MedicalSummary.objects.filter(user=user)
        .select_related("subject")
        .order_by("subject_id", "-version", "id")
    )
    jobs = list(
        ProcessingJob.objects.filter(user=user)
        .select_related("document", "summary")
        .order_by("-created_at", "id")
    )
    audit_logs = list(AuditLog.objects.filter(user=user).order_by("-created_at", "id"))

    return {
        "schema_version": "2026-07-10",
        "exported_at": _json_timestamp(timezone.now()),
        "user": {
            "id": str(user.id),
            "email": user.email,
            "full_name": user.full_name,
            "locale": user.locale,
            "is_active": user.is_active,
            "date_joined": _json_timestamp(user.date_joined),
            "updated_at": _json_timestamp(user.updated_at),
        },
        "subjects": [_subject_export(subject) for subject in subjects],
        "tags": [_tag_export(tag) for tag in tags],
        "documents": [_document_export(document) for document in documents],
        "document_explanations": [_document_explanation_export(explanation) for explanation in explanations],
        "medical_events": [_medical_event_export(event) for event in events],
        "medical_summaries": [_medical_summary_export(summary) for summary in summaries],
        "processing_jobs": [_processing_job_export(job) for job in jobs],
        "audit_logs": [_audit_log_export(audit_log) for audit_log in audit_logs],
    }


def _json_timestamp(value):
    if value is None:
        return None
    return value.isoformat().replace("+00:00", "Z")


def _subject_export(subject):
    return {
        "id": str(subject.id),
        "display_name": subject.display_name,
        "relationship": subject.relationship,
        "date_of_birth": _json_timestamp(subject.date_of_birth),
        "biological_sex": subject.biological_sex,
        "is_default": subject.is_default,
        "created_at": _json_timestamp(subject.created_at),
        "updated_at": _json_timestamp(subject.updated_at),
    }


def _tag_export(tag):
    return {
        "id": str(tag.id),
        "name": tag.name,
        "color": tag.color,
    }


def _document_export(document):
    return {
        "id": str(document.id),
        "subject_id": str(document.subject_id),
        "title": document.title,
        "doc_type": document.doc_type,
        "mime_type": document.mime_type,
        "local_uri_hint": document.local_uri_hint,
        "size_bytes": document.size_bytes,
        "status": document.status,
        "extracted_text": document.extracted_text,
        "language": document.language,
        "document_date": _json_timestamp(document.document_date),
        "error_message": document.error_message,
        "created_at": _json_timestamp(document.created_at),
        "updated_at": _json_timestamp(document.updated_at),
        "deleted_at": _json_timestamp(document.deleted_at),
    }


def _document_explanation_export(explanation):
    return {
        "id": str(explanation.id),
        "document_id": str(explanation.document_id),
        "summary_text": explanation.summary_text,
        "key_points": explanation.key_points,
        "glossary": explanation.glossary,
        "language": explanation.language,
        "created_at": _json_timestamp(explanation.created_at),
    }


def _medical_event_export(event):
    return {
        "id": str(event.id),
        "subject_id": str(event.subject_id),
        "source_document_id": str(event.source_document_id) if event.source_document_id else None,
        "event_type": event.event_type,
        "title": event.title,
        "description": event.description,
        "event_date": _json_timestamp(event.event_date),
        "event_end_date": _json_timestamp(event.event_end_date),
        "attributes": event.attributes,
        "source": event.source,
        "confidence": event.confidence,
        "is_confirmed": event.is_confirmed,
        "tags": [tag.name for tag in event.tags.all()],
        "created_at": _json_timestamp(event.created_at),
        "updated_at": _json_timestamp(event.updated_at),
        "deleted_at": _json_timestamp(event.deleted_at),
    }


def _medical_summary_export(summary):
    return {
        "id": str(summary.id),
        "subject_id": str(summary.subject_id),
        "version": summary.version,
        "is_current": summary.is_current,
        "content": summary.content,
        "narrative_text": summary.narrative_text,
        "generated_from_event_count": summary.generated_from_event_count,
        "language": summary.language,
        "created_at": _json_timestamp(summary.created_at),
    }


def _processing_job_export(job):
    return {
        "id": str(job.id),
        "document_id": str(job.document_id) if job.document_id else None,
        "summary_id": str(job.summary_id) if job.summary_id else None,
        "job_type": job.job_type,
        "status": job.status,
        "attempts": job.attempts,
        "error_message": job.error_message,
        "started_at": _json_timestamp(job.started_at),
        "finished_at": _json_timestamp(job.finished_at),
        "created_at": _json_timestamp(job.created_at),
        "updated_at": _json_timestamp(job.updated_at),
    }


def _audit_log_export(audit_log):
    return {
        "id": str(audit_log.id),
        "action": audit_log.action,
        "metadata": audit_log.metadata,
        "ip_address": audit_log.ip_address,
        "created_at": _json_timestamp(audit_log.created_at),
    }


def _build_document_explanation(*, document, extracted_text, language):
    provider = get_llm_provider()
    payload = provider.complete_json(
        system=EXPLANATION_SYSTEM_PROMPT,
        user=extracted_text,
        schema=DOCUMENT_EXPLANATION_JSON_SCHEMA,
        user_prompt=EXPLANATION_USER_PROMPT.format(language=language),
        schema_name="document_explanation",
    )
    explanation = validate_document_explanation(payload)
    explanation["language"] = language
    explanation["model_name"] = getattr(provider, "model", settings.AI_LLM_PROVIDER)
    return explanation


def _build_medical_summary(*, events, language):
    provider = get_llm_provider()
    payload = provider.complete_json(
        system=SUMMARY_SYSTEM_PROMPT,
        user=_serialize_events_for_summary(events),
        schema=MEDICAL_SUMMARY_JSON_SCHEMA,
        user_prompt=SUMMARY_USER_PROMPT.format(language=language),
        schema_name="medical_summary",
    )
    summary = validate_medical_summary(payload)
    summary["model_name"] = getattr(provider, "model", settings.AI_LLM_PROVIDER)
    return summary


def _empty_medical_summary(*, language):
    return {
        "content": {section: [] for section in SUMMARY_CONTENT_SECTIONS},
        "narrative_text": (
            "No confirmed MedStory timeline events are available for this subject yet. "
            "This summary is an organizer view and does not provide medical advice."
        ),
        "model_name": "none",
    }


def _serialize_events_for_summary(events):
    lines = []
    for event in events:
        attributes = {
            key: value
            for key, value in (event.attributes or {}).items()
            if value not in (None, "", [], {})
        }
        tags = [tag.name for tag in event.tags.all()]
        lines.append(
            "\n".join(
                [
                    f"date: {event.event_date.isoformat()}",
                    f"type: {event.event_type}",
                    f"title: {event.title}",
                    f"description: {event.description or ''}",
                    f"attributes: {attributes}",
                    f"tags: {tags}",
                ]
            )
        )
    return "\n\n---\n\n".join(lines)


def _resolve_explanation_language(*, document, requested_language=None):
    for value in (requested_language, getattr(document.user, "locale", None), document.language, "en"):
        if isinstance(value, str) and value.strip():
            return value.strip()[:10]
    return "en"


def _resolve_audio_language(*, document, requested_language=None):
    for value in (requested_language, getattr(document.user, "locale", None), document.language, "en"):
        if isinstance(value, str) and value.strip():
            return value.strip()[:10]
    return "en"


def _resolve_summary_language(*, subject, requested_language=None):
    for value in (requested_language, getattr(subject.user, "locale", None), "en"):
        if isinstance(value, str) and value.strip():
            return value.strip()[:10]
    return "en"


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


def _mark_explanation_failed(*, job, message):
    from medical.models import ProcessingJob

    if job is None:
        return

    sanitized_message = message[:500]
    job.status = ProcessingJob.Status.FAILED
    job.error_message = sanitized_message
    job.finished_at = timezone.now()
    job.save(update_fields=("status", "error_message", "finished_at", "updated_at"))


def _mark_summary_failed(*, job, message):
    from medical.models import ProcessingJob

    if job is None:
        return

    sanitized_message = message[:500]
    job.status = ProcessingJob.Status.FAILED
    job.error_message = sanitized_message
    job.finished_at = timezone.now()
    job.save(update_fields=("status", "error_message", "finished_at", "updated_at"))


def _humanize_summary_section(section):
    return section.replace("_", " ").title()


def _build_minimal_pdf(summary):
    lines = [
        "MedStory Doctor Summary",
        f"Subject: {summary.subject.display_name}",
        f"Generated: {summary.created_at:%Y-%m-%d}",
        "",
        summary.narrative_text,
        "",
    ]
    for section in SUMMARY_CONTENT_SECTIONS:
        lines.append(_humanize_summary_section(section))
        items = summary.content.get(section, [])
        lines.extend([f"- {item}" for item in items] or ["No confirmed events recorded."])
        lines.append("")
    return _simple_pdf(lines)


def _simple_pdf(lines):
    escaped_lines = []
    for line in lines:
        for wrapped in wrap(str(line), width=88) or [""]:
            escaped_lines.append(wrapped.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)"))

    text_commands = ["BT", "/F1 11 Tf", "50 750 Td", "14 TL"]
    for index, line in enumerate(escaped_lines[:50]):
        if index:
            text_commands.append("T*")
        text_commands.append(f"({line}) Tj")
    text_commands.append("ET")
    stream = "\n".join(text_commands).encode("latin-1", errors="replace")

    objects = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>",
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
        b"<< /Length " + str(len(stream)).encode("ascii") + b" >>\nstream\n" + stream + b"\nendstream",
    ]
    pdf = bytearray(b"%PDF-1.4\n")
    offsets = [0]
    for number, obj in enumerate(objects, start=1):
        offsets.append(len(pdf))
        pdf.extend(f"{number} 0 obj\n".encode("ascii"))
        pdf.extend(obj)
        pdf.extend(b"\nendobj\n")
    xref_offset = len(pdf)
    pdf.extend(f"xref\n0 {len(objects) + 1}\n".encode("ascii"))
    pdf.extend(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        pdf.extend(f"{offset:010d} 00000 n \n".encode("ascii"))
    pdf.extend(
        f"trailer\n<< /Size {len(objects) + 1} /Root 1 0 R >>\nstartxref\n{xref_offset}\n%%EOF\n".encode("ascii")
    )
    return bytes(pdf)
