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
        ]

    def __str__(self):
        return self.title


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
    is_confirmed = models.BooleanField(default=True)
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

    def __str__(self):
        return self.title


class AuditLog(models.Model):
    class Action(models.TextChoices):
        LOGIN = "login", "Login"
        DATA_EXPORT = "data_export", "Data export"
        ACCOUNT_DELETE = "account_delete", "Account delete"

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
