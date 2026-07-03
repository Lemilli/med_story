import base64
from pathlib import Path

from django.http import HttpResponse
from django.db.models import Q
from django.db import transaction
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.exceptions import ValidationError
from rest_framework.pagination import CursorPagination
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response

from medical.models import Document, MedicalEvent, MedicalSummary, ProcessingJob, Subject
from medical.pagination import TimelineCursorPagination
from medical.serializers import (
    MAX_DOCUMENT_SIZE_BYTES,
    SUPPORTED_AUDIO_MIME_TYPES,
    SUPPORTED_DOCUMENT_MIME_PREFIXES,
    SUPPORTED_DOCUMENT_MIME_TYPES,
    DocumentSerializer,
    DocumentExplanationSerializer,
    MedicalEventSerializer,
    MedicalSummarySerializer,
    ProcessingJobSerializer,
    SubjectSerializer,
)
from medical.services import (
    build_summary_export_pdf,
    enqueue_summary_regeneration,
    get_or_create_default_subject,
    summary_export_json,
)
from medical.tasks import explain_document_task, ingest_document_task

AUDIO_MIME_BY_EXTENSION = {
    ".mp3": "audio/mpeg",
    ".mp4": "audio/mp4",
    ".mpeg": "audio/mpeg",
    ".mpga": "audio/mpga",
    ".m4a": "audio/m4a",
    ".wav": "audio/wav",
    ".webm": "audio/webm",
}


class DocumentCursorPagination(CursorPagination):
    page_size = 20
    page_size_query_param = "limit"
    max_page_size = 100
    ordering = ("-created_at",)

    def get_paginated_response(self, data):
        return Response(
            {
                "results": data,
                "next": self.get_next_link(),
                "previous": self.get_previous_link(),
            }
        )


class SubjectListCreateView(generics.ListCreateAPIView):
    serializer_class = SubjectSerializer

    def get_queryset(self):
        get_or_create_default_subject(self.request.user)
        return Subject.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, is_default=False)


class SubjectDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = SubjectSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return Subject.objects.filter(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        subject = self.get_object()
        if subject.is_default:
            raise ValidationError({"is_default": ["The default subject cannot be deleted."]})
        return super().destroy(request, *args, **kwargs)


class MedicalEventQuerysetMixin:
    def get_base_queryset(self):
        return (
            MedicalEvent.objects.filter(user=self.request.user, deleted_at__isnull=True)
            .select_related("subject")
            .prefetch_related("tags")
        )

    def resolve_subject(self):
        subject_id = self.request.query_params.get("subject_id")
        if not subject_id:
            return get_or_create_default_subject(self.request.user)

        subject = Subject.objects.filter(id=subject_id, user=self.request.user).first()
        if not subject:
            raise ValidationError({"subject_id": ["Subject not found."]})
        return subject

    def apply_timeline_filters(self, queryset):
        subject = self.resolve_subject()
        queryset = queryset.filter(subject=subject)

        types = self.request.query_params.get("types")
        if types:
            event_types = [event_type.strip() for event_type in types.split(",") if event_type.strip()]
            if event_types:
                queryset = queryset.filter(event_type__in=event_types)

        date_from = self.request.query_params.get("from")
        if date_from:
            queryset = queryset.filter(event_date__gte=date_from)

        date_to = self.request.query_params.get("to")
        if date_to:
            queryset = queryset.filter(event_date__lte=date_to)

        tag = self.request.query_params.get("tag")
        if tag:
            queryset = queryset.filter(tags__name__iexact=tag.strip())

        query = self.request.query_params.get("q")
        if query:
            queryset = queryset.filter(Q(title__icontains=query) | Q(description__icontains=query))

        return queryset.distinct()


class EventListCreateView(MedicalEventQuerysetMixin, generics.ListCreateAPIView):
    serializer_class = MedicalEventSerializer
    pagination_class = TimelineCursorPagination

    def get_queryset(self):
        return self.get_base_queryset()

    def perform_create(self, serializer):
        event = serializer.save()
        if event.is_confirmed:
            enqueue_summary_regeneration(user=event.user, subject=event.subject, reason="event_created")


class EventDetailView(MedicalEventQuerysetMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = MedicalEventSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return self.get_base_queryset()

    def perform_update(self, serializer):
        event = serializer.save()
        if event.is_confirmed:
            enqueue_summary_regeneration(user=event.user, subject=event.subject, reason="event_updated")

    def perform_destroy(self, instance):
        should_refresh_summary = instance.is_confirmed
        instance.deleted_at = timezone.now()
        instance.save(update_fields=("deleted_at", "updated_at"))
        if should_refresh_summary:
            enqueue_summary_regeneration(user=instance.user, subject=instance.subject, reason="event_deleted")


class TimelineView(MedicalEventQuerysetMixin, generics.ListAPIView):
    serializer_class = MedicalEventSerializer
    pagination_class = TimelineCursorPagination

    def get_queryset(self):
        return self.apply_timeline_filters(self.get_base_queryset())


class EventSearchView(TimelineView):
    pass


class ConfirmEventView(MedicalEventQuerysetMixin, generics.GenericAPIView):
    serializer_class = MedicalEventSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return self.get_base_queryset()

    def post(self, request, *args, **kwargs):
        event = self.get_object()
        event.is_confirmed = True
        event.save(update_fields=("is_confirmed", "updated_at"))
        enqueue_summary_regeneration(user=event.user, subject=event.subject, reason="event_confirmed")
        return Response(MedicalEventSerializer(event, context={"request": request}).data, status=status.HTTP_200_OK)


class DocumentQuerysetMixin:
    def get_base_queryset(self):
        return (
            Document.objects.filter(user=self.request.user, deleted_at__isnull=True)
            .select_related("subject")
        )

    def resolve_subject(self):
        subject_id = self.request.query_params.get("subject_id")
        if not subject_id:
            return get_or_create_default_subject(self.request.user)

        subject = Subject.objects.filter(id=subject_id, user=self.request.user).first()
        if not subject:
            raise ValidationError({"subject_id": ["Subject not found."]})
        return subject

    def apply_document_filters(self, queryset):
        queryset = queryset.filter(subject=self.resolve_subject())

        doc_type = self.request.query_params.get("doc_type")
        if doc_type:
            valid_doc_types = {choice for choice, _ in Document.DocumentType.choices}
            if doc_type not in valid_doc_types:
                raise ValidationError({"doc_type": ["Unsupported document type."]})
            queryset = queryset.filter(doc_type=doc_type)

        status_value = self.request.query_params.get("status")
        if status_value:
            valid_statuses = {choice for choice, _ in Document.Status.choices}
            if status_value not in valid_statuses:
                raise ValidationError({"status": ["Unsupported document status."]})
            queryset = queryset.filter(status=status_value)

        return queryset


class DocumentListCreateView(DocumentQuerysetMixin, generics.ListCreateAPIView):
    serializer_class = DocumentSerializer
    pagination_class = DocumentCursorPagination

    def get_queryset(self):
        return self.apply_document_filters(self.get_base_queryset())


class DocumentDetailView(DocumentQuerysetMixin, generics.RetrieveDestroyAPIView):
    serializer_class = DocumentSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return self.get_base_queryset()

    def perform_destroy(self, instance):
        deleted_at = timezone.now()
        with transaction.atomic():
            instance.deleted_at = deleted_at
            instance.save(update_fields=("deleted_at", "updated_at"))
            instance.medical_events.filter(deleted_at__isnull=True).update(deleted_at=deleted_at)


class DocumentIngestView(DocumentQuerysetMixin, generics.GenericAPIView):
    serializer_class = DocumentSerializer
    lookup_url_kwarg = "id"
    parser_classes = (MultiPartParser, FormParser)

    def get_queryset(self):
        return self.get_base_queryset()

    def post(self, request, *args, **kwargs):
        document = self.get_object()
        if document.status in (Document.Status.PROCESSING, Document.Status.PROCESSED):
            return Response(DocumentSerializer(document, context={"request": request}).data, status=status.HTTP_202_ACCEPTED)

        upload = request.FILES.get("file")
        if upload is None:
            return self._error_response(
                code="validation_error",
                message="file is required.",
                http_status=status.HTTP_400_BAD_REQUEST,
                details={"file": ["This field is required."]},
            )

        if upload.size > MAX_DOCUMENT_SIZE_BYTES:
            return self._error_response(
                code="file_too_large",
                message="File must be 5 MB or smaller.",
                http_status=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            )

        mime_type = self._resolve_mime_type(request, upload, document)
        if not self._is_supported_mime_type(document, mime_type):
            return self._error_response(
                code="unsupported_mime_type",
                message="Unsupported MIME type.",
                http_status=status.HTTP_400_BAD_REQUEST,
                details={"mime_type": [self._unsupported_mime_type_message(document)]},
            )

        file_bytes = upload.read()
        job = self._mark_processing_and_create_job(document=document, upload=upload, mime_type=mime_type)
        self._dispatch_ingestion(
            document=document,
            job=job,
            file_bytes=file_bytes,
            mime_type=mime_type,
            language=self._resolve_language(request),
        )
        document.refresh_from_db()

        return Response(DocumentSerializer(document, context={"request": request}).data, status=status.HTTP_202_ACCEPTED)

    def _mark_processing_and_create_job(self, *, document, upload, mime_type):
        with transaction.atomic():
            document.status = Document.Status.PROCESSING
            document.error_message = ""
            document.mime_type = mime_type
            document.size_bytes = upload.size
            document.save(update_fields=("status", "error_message", "mime_type", "size_bytes", "updated_at"))
            return ProcessingJob.objects.create(
                user=document.user,
                document=document,
                status=ProcessingJob.Status.QUEUED,
            )

    def _dispatch_ingestion(self, *, document, job, file_bytes, mime_type, language=None):
        result = ingest_document_task.delay(
            str(document.id),
            str(job.id),
            base64.b64encode(file_bytes).decode("ascii"),
            mime_type,
            language,
        )
        job.task_id = result.id or ""
        job.save(update_fields=("task_id", "updated_at"))

    def _resolve_mime_type(self, request, upload, document):
        mime_type = request.data.get("mime_type") or getattr(upload, "content_type", None) or document.mime_type
        return self._normalize_mime_type(mime_type, upload)

    def _normalize_mime_type(self, mime_type, upload):
        normalized = (mime_type or "").strip().lower()
        if normalized in SUPPORTED_AUDIO_MIME_TYPES:
            return normalized
        if normalized.startswith("audio/"):
            return AUDIO_MIME_BY_EXTENSION.get(Path(getattr(upload, "name", "")).suffix.lower(), normalized)
        return normalized

    def _is_supported_mime_type(self, document, mime_type):
        if document.doc_type == Document.DocumentType.AUDIO:
            return mime_type in SUPPORTED_AUDIO_MIME_TYPES
        if mime_type in SUPPORTED_AUDIO_MIME_TYPES:
            return False
        if mime_type in SUPPORTED_DOCUMENT_MIME_TYPES:
            return True
        return any(mime_type.startswith(prefix) for prefix in SUPPORTED_DOCUMENT_MIME_PREFIXES)

    def _unsupported_mime_type_message(self, document):
        if document.doc_type == Document.DocumentType.AUDIO:
            return "Only supported audio files are allowed: mp3, mp4, mpeg, mpga, m4a, wav, or webm."
        return "Only PDF and image files are supported for non-audio documents."

    def _resolve_language(self, request):
        language = request.data.get("language") if hasattr(request.data, "get") else None
        if language is None:
            return None
        if not isinstance(language, str) or not language.strip():
            raise ValidationError({"language": ["language must be a non-empty string."]})
        return language.strip()[:10]

    def _error_response(self, *, code, message, http_status, details=None):
        payload = {"error": {"code": code, "message": message}}
        if details is not None:
            payload["error"]["details"] = details
        return Response(payload, status=http_status)


class DocumentAudioUploadView(DocumentIngestView):
    lookup_url_kwarg = None

    def post(self, request, *args, **kwargs):
        upload = request.FILES.get("file")
        if upload is None:
            return self._error_response(
                code="validation_error",
                message="file is required.",
                http_status=status.HTTP_400_BAD_REQUEST,
                details={"file": ["This field is required."]},
            )

        if upload.size > MAX_DOCUMENT_SIZE_BYTES:
            return self._error_response(
                code="file_too_large",
                message="File must be 5 MB or smaller.",
                http_status=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            )

        mime_type = self._normalize_mime_type(request.data.get("mime_type") or getattr(upload, "content_type", None), upload)
        if mime_type not in SUPPORTED_AUDIO_MIME_TYPES:
            return self._error_response(
                code="unsupported_mime_type",
                message="Unsupported MIME type.",
                http_status=status.HTTP_400_BAD_REQUEST,
                details={"mime_type": ["Only supported audio files are allowed: mp3, mp4, mpeg, mpga, m4a, wav, or webm."]},
            )

        language = self._resolve_language(request)
        document_data = {
            "title": request.data.get("title") or "Voice note",
            "doc_type": Document.DocumentType.AUDIO,
            "mime_type": mime_type,
            "local_uri_hint": request.data.get("local_uri_hint", ""),
            "size_bytes": upload.size,
        }
        if request.data.get("document_date"):
            document_data["document_date"] = request.data.get("document_date")
        if request.data.get("subject_id"):
            document_data["subject_id"] = request.data.get("subject_id")

        serializer = DocumentSerializer(data=document_data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        document = serializer.save()

        file_bytes = upload.read()
        job = self._mark_processing_and_create_job(document=document, upload=upload, mime_type=mime_type)
        self._dispatch_ingestion(
            document=document,
            job=job,
            file_bytes=file_bytes,
            mime_type=mime_type,
            language=language,
        )
        document.refresh_from_db()

        return Response(DocumentSerializer(document, context={"request": request}).data, status=status.HTTP_202_ACCEPTED)


class DocumentExplanationView(DocumentQuerysetMixin, generics.GenericAPIView):
    serializer_class = DocumentExplanationSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return self.get_base_queryset().prefetch_related("explanations")

    def get(self, request, *args, **kwargs):
        document = self.get_object()
        explanation = document.explanations.order_by("-created_at").first()
        if explanation is None:
            return Response(
                {
                    "error": {
                        "code": "not_ready",
                        "message": "Document explanation is not ready yet.",
                        "details": {"status": document.status},
                    }
                },
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(self.get_serializer(explanation).data, status=status.HTTP_200_OK)


class DocumentExplanationRegenerateView(DocumentQuerysetMixin, generics.GenericAPIView):
    serializer_class = DocumentExplanationSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return self.get_base_queryset()

    def post(self, request, *args, **kwargs):
        document = self.get_object()
        if not document.extracted_text:
            return Response(
                {
                    "error": {
                        "code": "not_ready",
                        "message": "Document text is not available for explanation.",
                        "details": {"status": document.status},
                    }
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        language = request.data.get("language") if isinstance(request.data, dict) else None
        if language is not None and (not isinstance(language, str) or not language.strip()):
            raise ValidationError({"language": ["language must be a non-empty string."]})

        job = ProcessingJob.objects.create(
            user=document.user,
            document=document,
            job_type=ProcessingJob.JobType.EXPLANATION,
            status=ProcessingJob.Status.QUEUED,
        )
        result = explain_document_task.delay(str(document.id), str(job.id), language.strip() if isinstance(language, str) else None)
        job.task_id = result.id or ""
        job.save(update_fields=("task_id", "updated_at"))

        return Response({"job_id": str(job.id), "status": ProcessingJob.Status.QUEUED}, status=status.HTTP_202_ACCEPTED)


class SummaryQuerysetMixin:
    def resolve_subject(self):
        subject_id = self.request.query_params.get("subject_id")
        if not subject_id and self.request.method not in ("GET", "HEAD", "OPTIONS"):
            subject_id = self.request.data.get("subject_id")
        if not subject_id:
            return get_or_create_default_subject(self.request.user)

        subject = Subject.objects.filter(id=subject_id, user=self.request.user).first()
        if not subject:
            raise ValidationError({"subject_id": ["Subject not found."]})
        return subject

    def get_current_summary(self):
        subject = self.resolve_subject()
        return (
            MedicalSummary.objects.select_related("subject")
            .filter(user=self.request.user, subject=subject, is_current=True)
            .first()
        )

    def not_ready_response(self):
        return Response(
            {
                "error": {
                    "code": "not_ready",
                    "message": "Medical summary is not ready yet.",
                }
            },
            status=status.HTTP_404_NOT_FOUND,
        )


class SummaryCurrentView(SummaryQuerysetMixin, generics.GenericAPIView):
    serializer_class = MedicalSummarySerializer

    def get(self, request, *args, **kwargs):
        summary = self.get_current_summary()
        if summary is None:
            return self.not_ready_response()
        return Response(self.get_serializer(summary).data, status=status.HTTP_200_OK)


class SummaryRegenerateView(SummaryQuerysetMixin, generics.GenericAPIView):
    serializer_class = MedicalSummarySerializer

    def post(self, request, *args, **kwargs):
        subject = self.resolve_subject()
        language = request.data.get("language") if isinstance(request.data, dict) else None
        if language is not None and (not isinstance(language, str) or not language.strip()):
            raise ValidationError({"language": ["language must be a non-empty string."]})
        job = enqueue_summary_regeneration(
            user=request.user,
            subject=subject,
            reason="manual",
            language=language.strip() if isinstance(language, str) else None,
        )
        return Response({"job_id": str(job.id), "status": ProcessingJob.Status.QUEUED}, status=status.HTTP_202_ACCEPTED)


class SummaryVersionsView(SummaryQuerysetMixin, generics.ListAPIView):
    serializer_class = MedicalSummarySerializer

    def get_queryset(self):
        subject = self.resolve_subject()
        return MedicalSummary.objects.filter(user=self.request.user, subject=subject).order_by("-version")


class SummaryExportView(SummaryQuerysetMixin, generics.GenericAPIView):
    serializer_class = MedicalSummarySerializer

    def get(self, request, *args, **kwargs):
        summary = self.get_current_summary()
        if summary is None:
            return self.not_ready_response()

        export_format = request.query_params.get("format", "json").strip().lower()
        if export_format == "json":
            return Response(summary_export_json(summary), status=status.HTTP_200_OK)
        if export_format == "pdf":
            payload = build_summary_export_pdf(summary)
            response = HttpResponse(payload, content_type="application/pdf")
            response["Content-Disposition"] = 'attachment; filename="medstory-summary.pdf"'
            return response
        raise ValidationError({"format": ["Unsupported export format. Use json or pdf."]})


class JobDetailView(generics.RetrieveAPIView):
    serializer_class = ProcessingJobSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return ProcessingJob.objects.filter(user=self.request.user).select_related("document", "summary")
