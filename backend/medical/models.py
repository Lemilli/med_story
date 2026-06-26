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
