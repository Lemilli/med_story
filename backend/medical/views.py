import hashlib
from pathlib import Path

from celery import current_app
from django.http import HttpResponse, StreamingHttpResponse
from django.db.models import Q
from django.db import transaction
from django.utils import timezone
from django.utils.http import content_disposition_header
from rest_framework import generics, status
from rest_framework.exceptions import ValidationError
from rest_framework.pagination import CursorPagination
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import extend_schema

from medical.models import AuditLog, Document, DocumentAsset, EventRevision, MedicalEvent, MedicalSummary, ProcessingJob, Subject, VisitPreparation
from medical.original_storage import (
    InvalidOriginalType,
    MalwareDetected,
    MalwareScannerUnavailable,
    OriginalIntegrityError,
    OriginalQuotaExceeded,
    OriginalStorageError,
    load_asset_bytes,
    purge_storage_deletions,
    release_blob_reference,
    release_assets,
    scan_for_malware,
    store_upload,
    validate_original_signature,
)
from medical.pagination import TimelineCursorPagination
from medical.serializers import (
    MAX_DOCUMENT_SIZE_BYTES,
    MAX_AUDIO_SIZE_BYTES,
    SUPPORTED_AUDIO_MIME_TYPES,
    SUPPORTED_DOCUMENT_MIME_PREFIXES,
    SUPPORTED_DOCUMENT_MIME_TYPES,
    DocumentSerializer,
    DocumentExplanationSerializer,
    EventRevisionSerializer,
    MedicalEventSerializer,
    MedicalSummarySerializer,
    ProcessingJobSerializer,
    SubjectSerializer,
    VisitPreparationSerializer,
)
from medical.services import (
    build_summary_export_pdf,
    apply_event_revision,
    create_event_revision,
    enqueue_summary_regeneration,
    get_or_create_default_subject,
    log_audit_event,
    summary_export_json,
)
from medical.tasks import (
    explain_document_task,
    ingest_document_task,
    ingest_note_task,
    purge_storage_deletions_task,
)
from ai.providers import get_stt_provider

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
            .select_related("subject", "source_document")
            .prefetch_related("tags", "source_document__assets")
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
            queryset = queryset.filter(
                Q(title__icontains=query)
                | Q(description__icontains=query)
                | Q(tags__name__icontains=query)
            )

        return queryset.distinct()


class EventListCreateView(MedicalEventQuerysetMixin, generics.ListCreateAPIView):
    serializer_class = MedicalEventSerializer
    pagination_class = TimelineCursorPagination

    def get_queryset(self):
        return self.get_base_queryset()

    def perform_create(self, serializer):
        serializer.save()


class EventDetailView(MedicalEventQuerysetMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = MedicalEventSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return self.get_base_queryset()

    def perform_update(self, serializer):
        serializer.save()

    def perform_destroy(self, instance):
        instance.deleted_at = timezone.now()
        instance.save(update_fields=("deleted_at", "updated_at"))


class EventRevisionListCreateView(MedicalEventQuerysetMixin, generics.GenericAPIView):
    serializer_class = EventRevisionSerializer
    throttle_classes = (ScopedRateThrottle,)
    throttle_scope = "ai"

    def _event(self):
        return self.get_base_queryset().select_related("source_document").get(id=self.kwargs["id"])

    def get(self, request, *args, **kwargs):
        revisions = self._event().revisions.all()[:20]
        return Response(self.get_serializer(revisions, many=True).data)

    @extend_schema(operation_id="event_revision_create", responses=EventRevisionSerializer)
    def post(self, request, *args, **kwargs):
        try:
            revision = create_event_revision(event=self._event())
        except ValueError as exc:
            return Response(
                {"error": {"code": str(exc), "message": "We could not create a suggested revision."}},
                status=status.HTTP_422_UNPROCESSABLE_ENTITY,
            )
        return Response(self.get_serializer(revision).data, status=status.HTTP_201_CREATED)


class EventRevisionDetailView(MedicalEventQuerysetMixin, generics.GenericAPIView):
    serializer_class = EventRevisionSerializer

    def _revision(self):
        return EventRevision.objects.select_related("event").get(
            id=self.kwargs["revision_id"],
            event_id=self.kwargs["id"],
            event__user=self.request.user,
            event__deleted_at__isnull=True,
        )

    @extend_schema(operation_id="event_revision_apply", responses=MedicalEventSerializer)
    def post(self, request, *args, **kwargs):
        fields = request.data.get("fields")
        if not isinstance(fields, list):
            raise ValidationError({"fields": ["Select at least one suggested field."]})
        try:
            event = apply_event_revision(revision=self._revision(), fields=fields)
        except ValueError as exc:
            raise ValidationError({"revision": [str(exc)]}) from exc
        return Response(MedicalEventSerializer(event, context={"request": request}).data)

    def delete(self, request, *args, **kwargs):
        revision = self._revision()
        if revision.status == EventRevision.Status.PENDING:
            revision.status = EventRevision.Status.DISCARDED
            revision.resolved_at = timezone.now()
            revision.save(update_fields=("status", "resolved_at"))
        return Response(status=status.HTTP_204_NO_CONTENT)


class TimelineView(MedicalEventQuerysetMixin, generics.ListAPIView):
    serializer_class = MedicalEventSerializer
    pagination_class = TimelineCursorPagination

    def get_queryset(self):
        return self.apply_timeline_filters(self.get_base_queryset())


class EventSearchView(TimelineView):
    pass


class DocumentQuerysetMixin:
    def get_base_queryset(self):
        return (
            Document.objects.filter(user=self.request.user, deleted_at__isnull=True)
            .select_related("subject")
            .prefetch_related("assets__blob")
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

        query = self.request.query_params.get("q")
        if query:
            queryset = queryset.filter(
                Q(title__icontains=query.strip()) | Q(extracted_text__icontains=query.strip())
            )

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

    def retrieve(self, request, *args, **kwargs):
        document = self.get_object()
        _reconcile_failed_ingestion_task(document)
        return Response(self.get_serializer(document).data)

    def perform_destroy(self, instance):
        deleted_at = timezone.now()
        with transaction.atomic():
            instance.deleted_at = deleted_at
            instance.save(update_fields=("deleted_at", "updated_at"))
            instance.medical_events.filter(deleted_at__isnull=True).update(deleted_at=deleted_at)
            release_assets(instance.assets.select_related("blob"))
            log_audit_event(
                user=self.request.user,
                action=AuditLog.Action.ORIGINAL_DELETE,
                request=self.request,
                metadata={"document_id": str(instance.id)},
            )
        transaction.on_commit(lambda: purge_storage_deletions_task.delay())


def _reconcile_failed_ingestion_task(document):
    """Turn a broker-reported task failure into a visible document failure.

    A task can fail before its body starts (for example, if a worker has not
    been restarted after a task signature change). In that case the task cannot
    update the document itself, so the client would otherwise poll forever.
    """
    if document.status != Document.Status.PROCESSING:
        return

    job = (
        document.processing_jobs.filter(
            job_type=ProcessingJob.JobType.INGESTION,
            status__in=(
                ProcessingJob.Status.QUEUED,
                ProcessingJob.Status.RUNNING,
                ProcessingJob.Status.RETRYING,
            ),
        )
        .exclude(task_id="")
        .order_by("-created_at")
        .first()
    )
    if job is None:
        return

    try:
        task_failed = current_app.AsyncResult(job.task_id).failed()
    except Exception:
        # A temporary broker/result-backend problem must not break document
        # reads or turn a potentially running task into a false failure.
        return
    if not task_failed:
        return

    now = timezone.now()
    with transaction.atomic():
        changed = ProcessingJob.objects.filter(
            id=job.id,
            status__in=(
                ProcessingJob.Status.QUEUED,
                ProcessingJob.Status.RUNNING,
                ProcessingJob.Status.RETRYING,
            ),
        ).update(
            status=ProcessingJob.Status.FAILED,
            error_message="Document processing failed.",
            finished_at=now,
            updated_at=now,
        )
        if not changed:
            return
        Document.objects.filter(
            id=document.id,
            status=Document.Status.PROCESSING,
        ).update(
            status=Document.Status.FAILED,
            error_message="document_processing_failed",
            updated_at=now,
        )

    document.status = Document.Status.FAILED
    document.error_message = "document_processing_failed"
    document.updated_at = now


class DocumentIngestView(DocumentQuerysetMixin, generics.GenericAPIView):
    serializer_class = DocumentSerializer
    lookup_url_kwarg = "id"
    parser_classes = (MultiPartParser, FormParser)
    throttle_classes = (ScopedRateThrottle,)
    throttle_scope = "ai"

    def get_queryset(self):
        return self.get_base_queryset()

    def post(self, request, *args, **kwargs):
        document = self.get_object()
        if document.status in (Document.Status.PROCESSING, Document.Status.PROCESSED):
            return Response(DocumentSerializer(document, context={"request": request}).data, status=status.HTTP_202_ACCEPTED)
        if document.assets.exists():
            return self._error_response(
                code="original_already_stored",
                message="The original is already stored. Retry processing without uploading it again.",
                http_status=status.HTTP_409_CONFLICT,
            )

        uploads = request.FILES.getlist("files") or request.FILES.getlist("file")
        if not uploads:
            return self._error_response(
                code="validation_error",
                message="file is required.",
                http_status=status.HTTP_400_BAD_REQUEST,
                details={"file": ["This field is required."]},
            )

        total_size = sum(upload.size for upload in uploads)
        if total_size > MAX_DOCUMENT_SIZE_BYTES:
            return self._error_response(
                code="file_too_large",
                message="Files must total 25 MB or less.",
                http_status=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            )

        mime_types = [self._resolve_mime_type(request, upload, document) for upload in uploads]
        if len(uploads) > 1 and any(not mime_type.startswith("image/") for mime_type in mime_types):
            return self._error_response(
                code="unsupported_mime_type",
                message="Multi-page uploads must contain images only.",
                http_status=status.HTTP_400_BAD_REQUEST,
            )
        if any(not self._is_supported_mime_type(document, mime_type) for mime_type in mime_types):
            return self._error_response(
                code="unsupported_mime_type",
                message="Unsupported MIME type.",
                http_status=status.HTTP_400_BAD_REQUEST,
                details={"mime_type": [self._unsupported_mime_type_message(document)]},
            )

        try:
            content_hash = self._persist_uploads(
                document=document,
                uploads=uploads,
                mime_types=mime_types,
            )
        except InvalidOriginalType:
            return self._error_response(
                code="invalid_original_type",
                message="File contents do not match the selected PDF or image type.",
                http_status=status.HTTP_400_BAD_REQUEST,
            )
        except MalwareDetected:
            return self._error_response(
                code="malware_detected",
                message="This file was rejected by the security scanner.",
                http_status=status.HTTP_422_UNPROCESSABLE_ENTITY,
            )
        except MalwareScannerUnavailable:
            return self._error_response(
                code="malware_scanner_unavailable",
                message="File scanning is temporarily unavailable. Try again later.",
                http_status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        except OriginalQuotaExceeded:
            return self._error_response(
                code="original_storage_quota_exceeded",
                message="Your 2 GB original-file storage limit has been reached.",
                http_status=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            )
        except OriginalStorageError:
            return self._error_response(
                code="original_storage_unavailable",
                message="Private file storage is temporarily unavailable.",
                http_status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        job = self._mark_processing_and_create_job(
            document=document,
            uploads=uploads,
            mime_types=mime_types,
            content_hash=content_hash,
        )
        self._dispatch_ingestion(
            document=document,
            job=job,
            language=self._resolve_language(request),
        )
        document.refresh_from_db()

        return Response(DocumentSerializer(document, context={"request": request}).data, status=status.HTTP_202_ACCEPTED)

    def _persist_uploads(self, *, document, uploads, mime_types, is_transient=False):
        created_assets = []
        pending_blob_ids = []
        fingerprints = []
        try:
            for position, (upload, mime_type) in enumerate(
                zip(uploads, mime_types),
                start=1,
            ):
                payload = upload.read()
                if document.doc_type != Document.DocumentType.AUDIO:
                    validate_original_signature(payload, mime_type)
                scan_for_malware(payload)
                stored = store_upload(
                    user=document.user,
                    payload=payload,
                    is_transient=is_transient,
                )
                pending_blob_ids.append(stored.blob.id)
                fingerprints.append(stored.blob.fingerprint)
                created_assets.append(
                    DocumentAsset.objects.create(
                        document=document,
                        blob=stored.blob,
                        position=position,
                        file_name=Path(upload.name).name[:255],
                        mime_type=mime_type,
                        size_bytes=upload.size,
                        is_transient=is_transient,
                    )
                )
                pending_blob_ids.remove(stored.blob.id)
        except Exception:
            release_assets(
                DocumentAsset.objects.filter(id__in=[asset.id for asset in created_assets])
                .select_related("blob")
            )
            for blob_id in pending_blob_ids:
                release_blob_reference(blob_id)
            purge_storage_deletions()
            raise
        bundle = hashlib.sha256()
        for fingerprint in fingerprints:
            bundle.update(fingerprint.encode("ascii"))
        return bundle.hexdigest()

    def _mark_processing_and_create_job(
        self, *, document, content_hash, upload=None, mime_type=None,
        uploads=None, mime_types=None
    ):
        uploads = uploads or [upload]
        mime_types = mime_types or [mime_type]
        with transaction.atomic():
            document.status = Document.Status.PROCESSING
            document.error_message = ""
            document.mime_type = mime_types[0]
            document.size_bytes = sum(item.size for item in uploads)
            document.content_hash = content_hash
            document.save(update_fields=("status", "error_message", "mime_type", "size_bytes", "content_hash", "updated_at"))
            return ProcessingJob.objects.create(
                user=document.user,
                document=document,
                status=ProcessingJob.Status.QUEUED,
            )

    def _dispatch_ingestion(self, *, document, job, language=None):
        try:
            result = ingest_document_task.delay(
                str(document.id),
                str(job.id),
                language,
            )
        except Exception:
            # The original is already durably stored at this point. A broker
            # outage must expose Retry/Delete instead of encouraging the client
            # to upload another copy or silently deleting the only original.
            with transaction.atomic():
                ProcessingJob.objects.filter(id=job.id).update(
                    status=ProcessingJob.Status.FAILED,
                    error_message="processing_dispatch_failed",
                    finished_at=timezone.now(),
                )
                Document.objects.filter(id=document.id).update(
                    status=Document.Status.FAILED,
                    error_message="processing_dispatch_failed",
                )
            return
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
        return mime_type in SUPPORTED_DOCUMENT_MIME_TYPES

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

        if upload.size > MAX_AUDIO_SIZE_BYTES:
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

        try:
            content_hash = self._persist_uploads(
                document=document,
                uploads=[upload],
                mime_types=[mime_type],
                is_transient=True,
            )
        except MalwareDetected:
            document.delete()
            return self._error_response(
                code="malware_detected",
                message="This recording was rejected by the security scanner.",
                http_status=status.HTTP_422_UNPROCESSABLE_ENTITY,
            )
        except MalwareScannerUnavailable:
            document.delete()
            return self._error_response(
                code="malware_scanner_unavailable",
                message="File scanning is temporarily unavailable. Try again later.",
                http_status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        except OriginalStorageError:
            document.delete()
            return self._error_response(
                code="original_storage_unavailable",
                message="Private temporary storage is unavailable.",
                http_status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        job = self._mark_processing_and_create_job(
            document=document,
            upload=upload,
            mime_type=mime_type,
            content_hash=content_hash,
        )
        self._dispatch_ingestion(document=document, job=job, language=language)
        document.refresh_from_db()

        return Response(DocumentSerializer(document, context={"request": request}).data, status=status.HTTP_202_ACCEPTED)


class DocumentRetryProcessingView(DocumentIngestView):
    parser_classes = (JSONParser, FormParser)

    def post(self, request, *args, **kwargs):
        document = self.get_object()
        if document.status == Document.Status.PROCESSED:
            return Response(
                DocumentSerializer(document, context={"request": request}).data,
                status=status.HTTP_202_ACCEPTED,
            )
        if document.status == Document.Status.PROCESSING:
            return Response(
                DocumentSerializer(document, context={"request": request}).data,
                status=status.HTTP_202_ACCEPTED,
            )
        if document.doc_type == Document.DocumentType.AUDIO or not document.assets.exists():
            return self._error_response(
                code="original_unavailable",
                message="The original must be uploaded again before processing can be retried.",
                http_status=status.HTTP_409_CONFLICT,
            )
        with transaction.atomic():
            document.status = Document.Status.PROCESSING
            document.error_message = ""
            document.save(update_fields=("status", "error_message", "updated_at"))
            job = ProcessingJob.objects.create(
                user=document.user,
                document=document,
                status=ProcessingJob.Status.QUEUED,
            )
        self._dispatch_ingestion(
            document=document,
            job=job,
            language=self._resolve_language(request),
        )
        document.refresh_from_db()
        return Response(
            DocumentSerializer(document, context={"request": request}).data,
            status=status.HTTP_202_ACCEPTED,
        )


class DocumentAssetContentView(APIView):
    throttle_classes = (ScopedRateThrottle,)
    throttle_scope = "user"

    @extend_schema(responses={(200, "application/octet-stream"): OpenApiTypes.BINARY})
    def get(self, request, *args, **kwargs):
        asset = (
            DocumentAsset.objects.select_related("document", "blob")
            .filter(
                id=kwargs["asset_id"],
                document_id=kwargs["id"],
                document__user=request.user,
                document__deleted_at__isnull=True,
                is_transient=False,
            )
            .first()
        )
        if asset is None:
            return Response(status=status.HTTP_404_NOT_FOUND)
        disposition = request.query_params.get("disposition", "inline")
        if disposition not in {"inline", "attachment"}:
            return Response(
                {
                    "error": {
                        "code": "validation_error",
                        "message": "disposition must be inline or attachment.",
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            payload = load_asset_bytes(asset)
        except OriginalIntegrityError:
            return Response(
                {
                    "error": {
                        "code": "original_integrity_error",
                        "message": "The stored original failed integrity verification.",
                    }
                },
                status=status.HTTP_422_UNPROCESSABLE_ENTITY,
            )
        except OriginalStorageError:
            return Response(
                {
                    "error": {
                        "code": "original_storage_unavailable",
                        "message": "The stored original is temporarily unavailable.",
                    }
                },
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        as_attachment = disposition == "attachment"
        response = StreamingHttpResponse(
            iter((payload,)),
            content_type=asset.mime_type,
        )
        response["Content-Length"] = str(len(payload))
        response["Content-Disposition"] = content_disposition_header(
            as_attachment,
            asset.file_name,
        )
        response["Cache-Control"] = "private, no-store"
        response["Pragma"] = "no-cache"
        response["X-Content-Type-Options"] = "nosniff"
        log_audit_event(
            user=request.user,
            action=(
                AuditLog.Action.ORIGINAL_DOWNLOAD
                if as_attachment
                else AuditLog.Action.ORIGINAL_OPEN
            ),
            request=request,
            metadata={
                "document_id": str(asset.document_id),
                "asset_id": str(asset.id),
            },
        )
        return response


class CaptureTranscriptionView(DocumentIngestView):
    """Transient voice-to-text endpoint. Audio is never persisted."""

    lookup_url_kwarg = None

    def post(self, request, *args, **kwargs):
        upload = request.FILES.get("file")
        if upload is None:
            return self._error_response(code="validation_error", message="file is required.", http_status=status.HTTP_400_BAD_REQUEST)
        if upload.size > MAX_AUDIO_SIZE_BYTES:
            return self._error_response(code="file_too_large", message="File must be 5 MB or smaller.", http_status=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE)
        mime_type = self._normalize_mime_type(request.data.get("mime_type") or getattr(upload, "content_type", None), upload)
        if mime_type not in SUPPORTED_AUDIO_MIME_TYPES:
            return self._error_response(code="unsupported_mime_type", message="Unsupported MIME type.", http_status=status.HTTP_400_BAD_REQUEST)
        payload = upload.read()
        try:
            scan_for_malware(payload)
        except MalwareDetected:
            return self._error_response(
                code="malware_detected",
                message="This recording was rejected by the security scanner.",
                http_status=status.HTTP_422_UNPROCESSABLE_ENTITY,
            )
        except MalwareScannerUnavailable:
            return self._error_response(
                code="malware_scanner_unavailable",
                message="File scanning is temporarily unavailable. Try again later.",
                http_status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        try:
            transcript = get_stt_provider().transcribe(
                audio_bytes=payload, mime=mime_type, lang=self._resolve_language(request)
            )
        except Exception:
            return self._error_response(code="audio_unreadable", message="We could not understand this recording.", http_status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        if not transcript or not transcript.strip():
            return self._error_response(code="audio_unreadable", message="We could not understand this recording.", http_status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        return Response({"transcript": transcript.strip()})


class NoteProcessView(generics.GenericAPIView):
    serializer_class = DocumentSerializer
    throttle_classes = (ScopedRateThrottle,)
    throttle_scope = "ai"

    def post(self, request, *args, **kwargs):
        text = request.data.get("text")
        if not isinstance(text, str) or not text.strip():
            return Response({"error": {"code": "note_empty", "message": "Enter a note to process."}}, status=status.HTTP_400_BAD_REQUEST)
        subject_id = request.data.get("subject_id")
        subject = Subject.objects.filter(id=subject_id, user=request.user).first() if subject_id else get_or_create_default_subject(request.user)
        if subject is None:
            raise ValidationError({"subject_id": ["Subject not found."]})
        clean_text = text.strip()
        document = Document.objects.create(
            user=request.user, subject=subject, title=clean_text.splitlines()[0][:255] or "Note",
            doc_type=Document.DocumentType.NOTE, mime_type="text/plain", size_bytes=len(clean_text.encode("utf-8")),
            status=Document.Status.PROCESSING,
        )
        job = ProcessingJob.objects.create(user=request.user, document=document, status=ProcessingJob.Status.QUEUED)
        result = ingest_note_task.delay(str(document.id), str(job.id), clean_text, request.data.get("language"))
        job.task_id = result.id or ""
        job.save(update_fields=("task_id", "updated_at"))
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
    throttle_classes = (ScopedRateThrottle,)
    throttle_scope = "ai"

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
    throttle_classes = (ScopedRateThrottle,)
    throttle_scope = "ai"

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
            visit_preparation = VisitPreparation.objects.filter(
                user=request.user,
                subject=summary.subject,
            ).first()
            payload = build_summary_export_pdf(summary, visit_note=visit_preparation.note if visit_preparation else "")
            response = HttpResponse(payload, content_type="application/pdf")
            response["Content-Disposition"] = 'attachment; filename="medstory-summary.pdf"'
            return response
        raise ValidationError({"format": ["Unsupported export format. Use json or pdf."]})


class VisitPreparationView(generics.GenericAPIView):
    serializer_class = VisitPreparationSerializer

    def _subject(self):
        subject_id = self.request.query_params.get("subject_id")
        if not subject_id:
            return get_or_create_default_subject(self.request.user)
        subject = Subject.objects.filter(id=subject_id, user=self.request.user).first()
        if not subject:
            raise ValidationError({"subject_id": ["Subject not found."]})
        return subject

    def get(self, request, *args, **kwargs):
        preparation, _ = VisitPreparation.objects.get_or_create(
            user=request.user,
            subject=self._subject(),
        )
        return Response(self.get_serializer(preparation).data)

    def put(self, request, *args, **kwargs):
        preparation, _ = VisitPreparation.objects.get_or_create(
            user=request.user,
            subject=self._subject(),
        )
        serializer = self.get_serializer(preparation, data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class JobDetailView(generics.RetrieveAPIView):
    serializer_class = ProcessingJobSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return ProcessingJob.objects.filter(user=self.request.user).select_related("document", "summary")
