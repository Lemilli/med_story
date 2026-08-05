import django.db.models.deletion
import uuid
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("users", "0001_initial")]

    operations = [
        migrations.CreateModel(
            name="EmailChallenge",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("purpose", models.CharField(choices=[("verify_email", "Verify email"), ("reset_password", "Reset password")], max_length=30)),
                ("code_digest", models.CharField(max_length=64)),
                ("attempts", models.PositiveSmallIntegerField(default=0)),
                ("expires_at", models.DateTimeField()),
                ("invalidated_at", models.DateTimeField(blank=True, null=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="email_challenges", to="users.user")),
            ],
        ),
        migrations.CreateModel(
            name="ConsentRecord",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("kind", models.CharField(choices=[("privacy_notice", "Privacy notice"), ("ai_processing", "AI processing")], max_length=30)),
                ("notice_version", models.CharField(max_length=30)),
                ("granted", models.BooleanField()),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="consent_records", to="users.user")),
            ],
            options={"ordering": ("created_at",)},
        ),
        migrations.AddIndex(model_name="emailchallenge", index=models.Index(fields=["user", "purpose", "created_at"], name="challenge_user_purpose_idx")),
        migrations.AddIndex(model_name="consentrecord", index=models.Index(fields=["user", "kind", "-created_at"], name="consent_user_kind_idx")),
    ]
