from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from medical.services import get_or_create_default_subject
from users.models import ConsentRecord
from users.services import PRIVACY_NOTICE_VERSION, record_consent

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    email_verified = serializers.BooleanField(source="is_active", read_only=True)

    class Meta:
        model = User
        fields = ("id", "email", "full_name", "locale", "email_verified", "date_joined")
        read_only_fields = ("id", "email", "email_verified", "date_joined")


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    privacy_notice_version = serializers.CharField(write_only=True)
    privacy_accepted = serializers.BooleanField(write_only=True)
    ai_processing_accepted = serializers.BooleanField(write_only=True, required=False, default=False)

    class Meta:
        model = User
        fields = (
            "email", "password", "full_name", "locale", "privacy_notice_version",
            "privacy_accepted", "ai_processing_accepted",
        )
        extra_kwargs = {
            "full_name": {"required": False, "allow_blank": True},
            "locale": {"required": False},
        }

    def create(self, validated_data):
        privacy_version = validated_data.pop("privacy_notice_version")
        privacy_accepted = validated_data.pop("privacy_accepted")
        ai_accepted = validated_data.pop("ai_processing_accepted", False)
        password = validated_data.pop("password")
        user = User.objects.create_user(password=password, is_active=False, **validated_data)
        get_or_create_default_subject(user)
        record_consent(
            user=user,
            kind=ConsentRecord.Kind.PRIVACY_NOTICE,
            granted=privacy_accepted,
            notice_version=privacy_version,
        )
        record_consent(
            user=user,
            kind=ConsentRecord.Kind.AI_PROCESSING,
            granted=ai_accepted,
        )
        return user

    def validate(self, attrs):
        if attrs.get("privacy_notice_version") != PRIVACY_NOTICE_VERSION:
            raise serializers.ValidationError({"privacy_notice_version": "The current privacy notice must be accepted."})
        if attrs.get("privacy_accepted") is not True:
            raise serializers.ValidationError({"privacy_accepted": "The privacy notice must be accepted."})
        return attrs


class EmailCodeSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.RegexField(r"^\d{6}$")


class EmailOnlySerializer(serializers.Serializer):
    email = serializers.EmailField()


class PasswordResetConfirmSerializer(EmailCodeSerializer):
    new_password = serializers.CharField(write_only=True, validators=[validate_password])


class AIConsentSerializer(serializers.Serializer):
    granted = serializers.BooleanField()
    notice_version = serializers.CharField(default=PRIVACY_NOTICE_VERSION)

    def validate_notice_version(self, value):
        if value != PRIVACY_NOTICE_VERSION:
            raise serializers.ValidationError("The current AI processing notice must be used.")
        return value


class ConsentRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = ConsentRecord
        fields = ("kind", "notice_version", "granted", "created_at")
        read_only_fields = fields


class CurrentLegalNoticeSerializer(serializers.Serializer):
    version = serializers.CharField()
    locale = serializers.ChoiceField(choices=("en", "ru"))
    privacy_notice = serializers.CharField()
    ai_processing = serializers.CharField()


class UsageSerializer(serializers.Serializer):
    ai = serializers.DictField()
    storage = serializers.DictField()


class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()
