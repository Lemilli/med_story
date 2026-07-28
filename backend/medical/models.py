import uuid

from django.conf import settings
from django.db import models
from django.db.models import Q


class Subject(models.Model):
    class Relationship(models.TextChoices):
        SELF = "self", "Self"
        CHILD = "child", "Child"
        DEPENDENT = "dependent", "Dependent"
        OTHER = "other", "Other"

    class BiologicalSex(models.TextChoices):
        FEMALE = "female", "Female"
        MALE = "male", "Male"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="subjects")
    display_name = models.CharField(max_length=255)
    relationship = models.CharField(max_length=20, choices=Relationship.choices, default=Relationship.SELF)
    date_of_birth = models.DateField(null=True, blank=True)
    biological_sex = models.CharField(
        max_length=20,
        choices=BiologicalSex.choices,
        null=True,
        blank=True,
    )
    is_default = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-is_default", "display_name")
        constraints = [
            models.UniqueConstraint(
                fields=("user",),
                condition=Q(is_default=True),
                name="unique_default_subject_per_user",
            ),
        ]

    def __str__(self):
        return self.display_name


class Tag(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="medical_tags")
    name = models.CharField(max_length=100)
    color = models.CharField(max_length=30, blank=True)

    class Meta:
        ordering = ("name",)
        constraints = [
            models.UniqueConstraint(fields=("user", "name"), name="unique_tag_name_per_user"),
        ]

    def __str__(self):
        return self.name


class Document(models.Model):
    class DocumentType(models.TextChoices):
        MEDICAL_RECORD = "medical_record", "Medical record"
        LAB_RESULT = "lab_result", "Lab result"
        REPORT = "report", "Report"
        PRESCRIPTION = "prescription", "Prescription"
        PROCEDURE_SUMMARY = "procedure_summary", "Procedure summary"
        NOTE = "note", "Note"
        IMAGE = "image", "Image"
        AUDIO = "audio", "Audio"
        OTHER = "other", "Other"

    class Status(models.TextChoices):
        PENDING_INGEST = "pending_ingest", "Pending ingest"
        PROCESSING = "processing", "Processing"
        PROCESSED = "processed", "Processed"
        FAILED = "failed", "Failed"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="documents")
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name="documents")
    title = models.CharField(max_length=255)
    doc_type = models.CharField(max_length=30, choices=DocumentType.choices)
    mime_type = models.CharField(max_length=255)
    local_uri_hint = models.CharField(max_length=1024, blank=True)
    size_bytes = models.BigIntegerField()
    status = models.CharField(max_length=30, choices=Status.choices, default=Status.PENDING_INGEST)
    extracted_text = models.TextField(blank=True)
    language = models.CharField(max_length=10, blank=True)
    document_date = models.DateField(null=True, blank=True)
    error_message = models.TextField(blank=True)
    # Bundle digest over user-scoped keyed asset fingerprints. This is not a
    # raw content hash and cannot be compared across accounts.
    content_hash = models.CharField(max_length=64, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ("-created_at",)
        indexes = [
            models.Index(fields=("user", "subject", "-created_at"), name="document_user_subject_idx"),
            models.Index(fields=("doc_type",), name="document_doc_type_idx"),
            models.Index(fields=("status",), name="document_status_idx"),
            models.Index(fields=("deleted_at",), name="document_deleted_at_idx"),
            models.Index(fields=("user", "content_hash"), name="document_user_hash_idx"),
        ]

    def __str__(self):
        return self.title


class EncryptedBlob(models.Model):
    """One user-owned encrypted object retained in private object storage."""

    class State(models.TextChoices):
        AVAILABLE = "available", "Available"
        DELETION_PENDING = "deletion_pending", "Deletion pending"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="encrypted_blobs",
    )
    object_key = models.CharField(max_length=255, unique=True)
    encrypted_key = models.BinaryField()
    master_key_version = models.PositiveIntegerField(default=1)
    encryption_format = models.CharField(max_length=50, default="aws-esdk-v1")
    fingerprint = models.CharField(max_length=64)
    plaintext_size = models.BigIntegerField()
    ciphertext_size = models.BigIntegerField()
    reference_count = models.PositiveIntegerField(default=1)
    state = models.CharField(max_length=30, choices=State.choices, default=State.AVAILABLE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=("user", "fingerprint"),
                condition=Q(state="available"),
                name="unique_encrypted_blob_fingerprint_per_user",
            ),
        ]
        indexes = [
            models.Index(fields=("user", "state"), name="blob_user_state_idx"),
        ]

    def __str__(self):
        return str(self.id)


class DocumentAsset(models.Model):
    """Metadata for one server-retained original within a logical document."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    document = models.ForeignKey(Document, on_delete=models.CASCADE, related_name="assets")
    blob = models.ForeignKey(
        EncryptedBlob,
        on_delete=models.RESTRICT,
        related_name="document_assets",
        null=True,
        blank=True,
    )
    position = models.PositiveIntegerField()
    file_name = models.CharField(max_length=255)
    mime_type = models.CharField(max_length=255)
    size_bytes = models.BigIntegerField()
    is_transient = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("position",)
        constraints = [
            models.UniqueConstraint(fields=("document", "position"), name="unique_document_asset_position"),
        ]

    def __str__(self):
        return f"{self.document_id}:{self.position}"


class StorageDeletionJob(models.Model):
    """Opaque, user-independent object deletion retry record."""

    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        SUCCEEDED = "succeeded", "Succeeded"
        FAILED = "failed", "Failed"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    object_key = models.CharField(max_length=255)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    attempts = models.PositiveIntegerField(default=0)
    error_code = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ("created_at",)
        indexes = [
            models.Index(fields=("status", "created_at"), name="storage_delete_status_idx"),
        ]

    def __str__(self):
        return f"{self.object_key}:{self.status}"


class ProcessingJob(models.Model):
    class JobType(models.TextChoices):
        INGESTION = "ingestion", "Ingestion"
        EXPLANATION = "explanation", "Explanation"
        SUMMARY = "summary", "Summary"

    class Status(models.TextChoices):
        QUEUED = "queued", "Queued"
        RUNNING = "running", "Running"
        SUCCEEDED = "succeeded", "Succeeded"
        FAILED = "failed", "Failed"
        RETRYING = "retrying", "Retrying"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="processing_jobs")
    document = models.ForeignKey(
        Document,
        on_delete=models.CASCADE,
        related_name="processing_jobs",
        null=True,
        blank=True,
    )
    summary = models.ForeignKey(
        "MedicalSummary",
        on_delete=models.SET_NULL,
        related_name="processing_jobs",
        null=True,
        blank=True,
    )
    job_type = models.CharField(max_length=30, choices=JobType.choices, default=JobType.INGESTION)
    status = models.CharField(max_length=30, choices=Status.choices, default=Status.QUEUED)
    attempts = models.PositiveIntegerField(default=0)
    task_id = models.CharField(max_length=255, blank=True)
    error_message = models.TextField(blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    finished_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ("-created_at",)
        indexes = [
            models.Index(fields=("user", "status"), name="job_user_status_idx"),
            models.Index(fields=("document", "job_type", "status"), name="job_document_type_status_idx"),
        ]

    def __str__(self):
        target_id = self.document_id or self.summary_id or self.user_id
        return f"{self.job_type}:{target_id}:{self.status}"


class DocumentExplanation(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    document = models.ForeignKey(Document, on_delete=models.CASCADE, related_name="explanations")
    summary_text = models.TextField()
    key_points = models.JSONField(default=list, blank=True)
    glossary = models.JSONField(default=dict, blank=True)
    model_name = models.CharField(max_length=255)
    language = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("-created_at",)
        indexes = [
            models.Index(fields=("document", "-created_at"), name="expl_doc_created_idx"),
            models.Index(fields=("language",), name="expl_language_idx"),
        ]

    def __str__(self):
        return f"{self.document_id}:{self.language}:{self.created_at:%Y-%m-%d}"


class MedicalSummary(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="medical_summaries")
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name="medical_summaries")
    version = models.PositiveIntegerField()
    is_current = models.BooleanField(default=True)
    content = models.JSONField(default=dict)
    narrative_text = models.TextField()
    generated_from_event_count = models.PositiveIntegerField(default=0)
    model_name = models.CharField(max_length=255)
    language = models.CharField(max_length=10)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("-created_at",)
        constraints = [
            models.UniqueConstraint(fields=("subject", "version"), name="unique_summary_version_per_subject"),
            models.UniqueConstraint(
                fields=("subject",),
                condition=Q(is_current=True),
                name="unique_current_summary_per_subject",
            ),
        ]
        indexes = [
            models.Index(fields=("user", "subject", "-created_at"), name="summary_user_subject_idx"),
            models.Index(fields=("is_current",), name="summary_is_current_idx"),
        ]

    def __str__(self):
        return f"{self.subject_id}:v{self.version}"


class VisitPreparation(models.Model):
    """A user-authored, per-subject note for an upcoming healthcare visit."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="visit_preparations",
    )
    subject = models.OneToOneField(
        Subject,
        on_delete=models.CASCADE,
        related_name="visit_preparation",
    )
    note = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [models.Index(fields=("user", "subject"), name="visit_prep_user_subject_idx")]

    def __str__(self):
        return f"{self.subject_id}:visit-preparation"


class MedicalEvent(models.Model):
    class EventType(models.TextChoices):
        SYMPTOM = "symptom", "Symptom"
        DIAGNOSIS = "diagnosis", "Diagnosis"
        MEDICATION = "medication", "Medication"
        EXAMINATION = "examination", "Examination"
        PROCEDURE = "procedure", "Procedure"
        HOSPITALIZATION = "hospitalization", "Hospitalization"
        TREATMENT_OUTCOME = "treatment_outcome", "Treatment outcome"
        MEDICAL_RECORD = "medical_record", "Medical record"
        NOTE = "note", "Note"

    class Source(models.TextChoices):
        USER_MANUAL = "user_manual", "User manual"
        AI_DOCUMENT = "ai_document", "AI document"
        AI_VOICE = "ai_voice", "AI voice"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="medical_events")
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name="medical_events")
    source_document = models.ForeignKey(
        Document,
        on_delete=models.SET_NULL,
        related_name="medical_events",
        null=True,
        blank=True,
    )
    event_type = models.CharField(max_length=30, choices=EventType.choices)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    event_date = models.DateField()
    event_end_date = models.DateField(null=True, blank=True)
    attributes = models.JSONField(default=dict, blank=True)
    source = models.CharField(max_length=30, choices=Source.choices, default=Source.USER_MANUAL)
    confidence = models.FloatField(null=True, blank=True)
    # One-based positions of the device-local document pages which support
    # this event. The original bytes remain exclusively on the user's device.
    source_page_positions = models.JSONField(default=list, blank=True)
    tags = models.ManyToManyField(Tag, related_name="medical_events", blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ("-event_date", "-created_at")
        indexes = [
            models.Index(fields=("user", "subject", "-event_date"), name="event_user_subject_date_idx"),
            models.Index(fields=("event_type",), name="event_type_idx"),
            models.Index(fields=("deleted_at",), name="event_deleted_at_idx"),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=("source_document",),
                condition=Q(source_document__isnull=False, deleted_at__isnull=True),
                name="unique_active_event_per_document",
            ),
        ]

    def __str__(self):
        return self.title


class EventRevision(models.Model):
    """A proposed AI revision which never mutates an event until applied."""

    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        APPLIED = "applied", "Applied"
        DISCARDED = "discarded", "Discarded"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    event = models.ForeignKey(MedicalEvent, on_delete=models.CASCADE, related_name="revisions")
    current_snapshot = models.JSONField(default=dict)
    suggested_changes = models.JSONField(default=dict)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    model_name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ("-created_at",)
        indexes = [models.Index(fields=("event", "status", "-created_at"), name="revision_event_status_idx")]

    def __str__(self):
        return f"{self.event_id}:{self.status}"


class AuditLog(models.Model):
    class Action(models.TextChoices):
        LOGIN = "login", "Login"
        ACCOUNT_DELETE = "account_delete", "Account delete"
        ORIGINAL_OPEN = "original_open", "Original open"
        ORIGINAL_DOWNLOAD = "original_download", "Original download"
        ORIGINAL_DELETE = "original_delete", "Original delete"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="audit_logs",
        null=True,
        blank=True,
    )
    action = models.CharField(max_length=50, choices=Action.choices)
    metadata = models.JSONField(default=dict, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("-created_at",)
        indexes = [
            models.Index(fields=("user", "-created_at"), name="audit_user_created_idx"),
            models.Index(fields=("action",), name="audit_action_idx"),
        ]

    def __str__(self):
        return f"{self.action}:{self.created_at:%Y-%m-%d %H:%M:%S}"
