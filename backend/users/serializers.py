from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from medical.services import get_or_create_default_subject

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "email", "full_name", "locale", "date_joined")
        read_only_fields = ("id", "email", "date_joined")


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])

    class Meta:
        model = User
        fields = ("email", "password", "full_name", "locale")
        extra_kwargs = {
            "full_name": {"required": False, "allow_blank": True},
            "locale": {"required": False},
        }

    def create(self, validated_data):
        password = validated_data.pop("password")
        user = User.objects.create_user(password=password, **validated_data)
        get_or_create_default_subject(user)
        return user


class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()
