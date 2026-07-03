from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field

from medical.models import Document, DocumentExplanation, MedicalEvent, MedicalSummary, ProcessingJob, Subject, Tag
from medical.services import get_or_create_default_subject


MAX_DOCUMENT_SIZE_BYTES = 5 * 1024 * 1024
SUPPORTED_DOCUMENT_MIME_TYPES = {"application/pdf"}
SUPPORTED_DOCUMENT_MIME_PREFIXES = ("image/",)
SUPPORTED_AUDIO_MIME_TYPES = {
    "audio/mpeg",
    "audio/mp3",
    "audio/mp4",
    "audio/mpga",
    "audio/m4a",
    "audio/wav",
    "audio/webm",
}


@extend_schema_field(serializers.ListField(child=serializers.CharField()))
class TagNamesField(serializers.Field):
    def to_representation(self, value):
        event = value.instance
        if not event.pk:
            return []
        # Preserve the order tags were assigned (through-table insertion order).
        return list(
            value.through.objects.filter(medicalevent_id=event.pk)
            .order_by("id")
            .values_list("tag__name", flat=True)
        )

    def to_internal_value(self, data):
        if not isinstance(data, list):
            raise serializers.ValidationError("tags must be a list.")

        normalized = []
        seen = set()
        for tag in data:
            if not isinstance(tag, str):
                raise serializers.ValidationError("tags must contain strings.")
            name = tag.strip()
            if not name:
                raise serializers.ValidationError("tags cannot contain blank values.")
            key = name.casefold()
            if key not in seen:
                normalized.append(name)
                seen.add(key)
        return normalized


class SubjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subject
        fields = (
            "id",
            "display_name",
            "relationship",
            "date_of_birth",
            "biological_sex",
            "is_default",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("id", "is_default", "created_at", "updated_at")


class MedicalEventSerializer(serializers.ModelSerializer):
    subject_id = serializers.UUIDField(required=False, write_only=True)
    source_document_id = serializers.SerializerMethodField()
    tags = TagNamesField(required=False)

    class Meta:
        model = MedicalEvent
        fields = (
            "id",
            "event_type",
            "title",
            "description",
            "event_date",
            "event_end_date",
            "attributes",
            "source",
            "source_document_id",
            "confidence",
            "is_confirmed",
            "tags",
            "subject_id",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("id", "source_document_id", "created_at", "updated_at")

    @extend_schema_field(serializers.UUIDField(allow_null=True))
    def get_source_document_id(self, obj):
        if obj.source_document_id is None:
            return None
        return str(obj.source_document_id)

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data["subject_id"] = str(instance.subject_id)
        return data

    def validate_attributes(self, value):
        if not isinstance(value, dict):
            raise serializers.ValidationError("attributes must be an object.")
        return value

    def validate_subject_id(self, value):
        user = self.context["request"].user
        if not Subject.objects.filter(id=value, user=user).exists():
            raise serializers.ValidationError("Subject not found.")
        return value

    def _resolve_subject(self, validated_data):
        subject_id = validated_data.pop("subject_id", None)
        if subject_id:
            return Subject.objects.get(id=subject_id, user=self.context["request"].user)
        return get_or_create_default_subject(self.context["request"].user)

    def _set_tags(self, event, tag_names):
        tags = [
            Tag.objects.get_or_create(user=event.user, name=name)[0]
            for name in tag_names
        ]
        event.tags.clear()
        for tag in tags:
            event.tags.add(tag)

    def create(self, validated_data):
        tag_names = validated_data.pop("tags", [])
        user = self.context["request"].user
        event = MedicalEvent.objects.create(
            user=user,
            subject=self._resolve_subject(validated_data),
            **validated_data,
        )
        self._set_tags(event, tag_names)
        return event

    def update(self, instance, validated_data):
        tag_names = validated_data.pop("tags", None)
        if "subject_id" in validated_data:
            instance.subject = self._resolve_subject(validated_data)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if tag_names is not None:
            self._set_tags(instance, tag_names)
        return instance


class DocumentSerializer(serializers.ModelSerializer):
    subject_id = serializers.UUIDField(required=False, write_only=True)
    local_only = serializers.SerializerMethodField()
    extracted_text_available = serializers.SerializerMethodField()
    explanation_available = serializers.SerializerMethodField()
    event_count = serializers.SerializerMethodField()

    class Meta:
        model = Document
        fields = (
            "id",
            "subject_id",
            "title",
            "doc_type",
            "mime_type",
            "local_uri_hint",
            "size_bytes",
            "status",
            "extracted_text_available",
            "language",
            "document_date",
            "error_message",
            "local_only",
            "explanation_available",
            "event_count",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "extracted_text_available",
            "language",
            "error_message",
            "local_only",
            "explanation_available",
            "event_count",
            "created_at",
            "updated_at",
        )
        extra_kwargs = {
            "status": {"required": False},
            "local_uri_hint": {"required": False, "allow_blank": True},
            "document_date": {"required": False, "allow_null": True},
        }

    @extend_schema_field(serializers.BooleanField())
    def get_local_only(self, obj):
        return True

    @extend_schema_field(serializers.BooleanField())
    def get_extracted_text_available(self, obj):
        return bool(obj.extracted_text)

    @extend_schema_field(serializers.BooleanField())
    def get_explanation_available(self, obj):
        if not obj.pk:
            return False
        return obj.explanations.exists()

    @extend_schema_field(serializers.IntegerField())
    def get_event_count(self, obj):
        if not obj.pk:
            return 0
        return obj.medical_events.filter(deleted_at__isnull=True).count()

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data["subject_id"] = str(instance.subject_id)
        return data

    def validate_subject_id(self, value):
        user = self.context["request"].user
        if not Subject.objects.filter(id=value, user=user).exists():
            raise serializers.ValidationError("Subject not found.")
        return value

    def validate_mime_type(self, value):
        mime_type = value.strip().lower()
        if not mime_type:
            raise serializers.ValidationError("mime_type is required.")
        if self.initial_data.get("doc_type") == Document.DocumentType.AUDIO:
            if mime_type in SUPPORTED_AUDIO_MIME_TYPES:
                return mime_type
            raise serializers.ValidationError("Unsupported audio MIME type.")
        if mime_type in SUPPORTED_DOCUMENT_MIME_TYPES:
            return mime_type
        if any(mime_type.startswith(prefix) for prefix in SUPPORTED_DOCUMENT_MIME_PREFIXES):
            return mime_type
        raise serializers.ValidationError("Unsupported MIME type.")

    def validate_size_bytes(self, value):
        if value <= 0:
            raise serializers.ValidationError("size_bytes must be greater than zero.")
        if value > MAX_DOCUMENT_SIZE_BYTES:
            raise serializers.ValidationError("size_bytes must be 5 MB or smaller.")
        return value

    def validate_status(self, value):
        if self.instance is None and value != Document.Status.PENDING_INGEST:
            raise serializers.ValidationError("New documents must start as pending_ingest.")
        return value

    def _resolve_subject(self, validated_data):
        subject_id = validated_data.pop("subject_id", None)
        if subject_id:
            return Subject.objects.get(id=subject_id, user=self.context["request"].user)
        return get_or_create_default_subject(self.context["request"].user)

    def create(self, validated_data):
        user = self.context["request"].user
        validated_data.pop("status", None)
        return Document.objects.create(
            user=user,
            subject=self._resolve_subject(validated_data),
            **validated_data,
        )


class DocumentExplanationSerializer(serializers.ModelSerializer):
    document_id = serializers.SerializerMethodField()

    class Meta:
        model = DocumentExplanation
        fields = (
            "document_id",
            "summary_text",
            "key_points",
            "glossary",
            "language",
            "created_at",
        )
        read_only_fields = fields

    @extend_schema_field(serializers.UUIDField())
    def get_document_id(self, obj):
        return str(obj.document_id)


class MedicalSummarySerializer(serializers.ModelSerializer):
    subject_id = serializers.SerializerMethodField()

    class Meta:
        model = MedicalSummary
        fields = (
            "id",
            "subject_id",
            "version",
            "is_current",
            "content",
            "narrative_text",
            "language",
            "generated_from_event_count",
            "created_at",
        )
        read_only_fields = fields

    @extend_schema_field(serializers.UUIDField())
    def get_subject_id(self, obj):
        return str(obj.subject_id)


class ProcessingJobSerializer(serializers.ModelSerializer):
    document_id = serializers.SerializerMethodField()
    summary_id = serializers.SerializerMethodField()

    class Meta:
        model = ProcessingJob
        fields = (
            "id",
            "job_type",
            "status",
            "attempts",
            "document_id",
            "summary_id",
            "error_message",
            "created_at",
            "started_at",
            "finished_at",
        )
        read_only_fields = fields

    @extend_schema_field(serializers.UUIDField(allow_null=True))
    def get_document_id(self, obj):
        if obj.document_id is None:
            return None
        return str(obj.document_id)

    @extend_schema_field(serializers.UUIDField(allow_null=True))
    def get_summary_id(self, obj):
        if obj.summary_id is None:
            return None
        return str(obj.summary_id)
