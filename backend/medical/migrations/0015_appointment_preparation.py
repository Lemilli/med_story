import django.db.models.deletion
import uuid

from django.conf import settings
from django.db import migrations, models
from django.db.models import Q
from django.utils import timezone


def mark_existing_summaries_approved(apps, schema_editor):
    MedicalSummary = apps.get_model("medical", "MedicalSummary")
    MedicalSummary.objects.all().update(
        approval_status="approved",
        approved_at=timezone.now(),
    )


class Migration(migrations.Migration):
    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ("medical", "0014_medicalevent_source_page_positions"),
    ]

    operations = [
        migrations.AddField(
            model_name="processingjob",
            name="subject",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name="processing_jobs",
                to="medical.subject",
            ),
        ),
        migrations.AddField(
            model_name="processingjob",
            name="input_fingerprint",
            field=models.CharField(blank=True, max_length=64),
        ),
        migrations.AddIndex(
            model_name="processingjob",
            index=models.Index(fields=["user", "input_fingerprint"], name="job_user_input_idx"),
        ),
        migrations.AddConstraint(
            model_name="processingjob",
            constraint=models.UniqueConstraint(
                condition=Q(
                    job_type="summary",
                    status__in=("queued", "running", "retrying"),
                ),
                fields=("user", "input_fingerprint"),
                name="unique_active_summary_input",
            ),
        ),
        migrations.AddField(
            model_name="medicalsummary",
            name="approval_status",
            field=models.CharField(
                choices=[("draft", "Draft"), ("approved", "Approved")],
                default="approved",
                max_length=20,
            ),
        ),
        migrations.AddField(
            model_name="medicalsummary",
            name="approved_at",
            field=models.DateTimeField(blank=True, null=True),
        ),
        migrations.RunPython(mark_existing_summaries_approved, migrations.RunPython.noop),
        migrations.AlterField(
            model_name="auditlog",
            name="action",
            field=models.CharField(
                choices=[
                    ("login", "Login"),
                    ("account_delete", "Account delete"),
                    ("ai_summary_consent_granted", "AI summary consent granted"),
                    ("ai_summary_consent_revoked", "AI summary consent revoked"),
                    ("summary_export_requested", "Summary export requested"),
                ],
                max_length=50,
            ),
        ),
        migrations.CreateModel(
            name="ConsentDecision",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("purpose", models.CharField(choices=[("appointment_summary_ai", "Appointment summary AI")], max_length=50)),
                ("granted", models.BooleanField()),
                ("policy_version", models.CharField(max_length=40)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="consent_decisions", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ("-created_at",)},
        ),
        migrations.AddIndex(
            model_name="consentdecision",
            index=models.Index(fields=["user", "purpose", "-created_at"], name="consent_user_purpose_idx"),
        ),
        migrations.CreateModel(
            name="ProductAnalyticsEvent",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("name", models.CharField(max_length=80)),
                ("properties", models.JSONField(blank=True, default=dict)),
                ("occurred_at", models.DateTimeField()),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="product_analytics_events", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ("-occurred_at",)},
        ),
        migrations.AddIndex(
            model_name="productanalyticsevent",
            index=models.Index(fields=["name", "-occurred_at"], name="analytics_name_time_idx"),
        ),
        migrations.AddIndex(
            model_name="productanalyticsevent",
            index=models.Index(fields=["user", "-occurred_at"], name="analytics_user_time_idx"),
        ),
    ]