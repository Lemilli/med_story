from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field

from medical.models import MedicalEvent, Subject, Tag
from medical.services import get_or_create_default_subject


@extend_schema_field(serializers.ListField(child=serializers.CharField()))
class TagNamesField(serializers.Field):
    def to_representation(self, value):
        return [tag.name for tag in value.all()]

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
        return None

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
        event.tags.set(tags)

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
