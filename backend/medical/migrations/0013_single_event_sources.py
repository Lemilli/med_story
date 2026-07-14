import uuid

from django.db import migrations, models
import django.db.models.deletion
from django.utils import timezone


def consolidate_document_events(apps, schema_editor):
    MedicalEvent = apps.get_model("medical", "MedicalEvent")
    document_ids = (
        MedicalEvent.objects.filter(source_document_id__isnull=False, deleted_at__isnull=True)
        .values_list("source_document_id", flat=True)
        .distinct()
    )
    for document_id in document_ids.iterator():
        active = MedicalEvent.objects.filter(
            source_document_id=document_id,
            deleted_at__isnull=True,
        ).order_by("-created_at", "-id")
        keep = active.first()
        if keep is not None:
            active.exclude(id=keep.id).update(deleted_at=timezone.now())


class Migration(migrations.Migration):
    dependencies = [("medical", "0012_alter_auditlog_action")]

    operations = [
        migrations.AlterField(
            model_name="medicalevent",
            name="event_type",
            field=models.CharField(
                choices=[
                    ("symptom", "Symptom"),
                    ("diagnosis", "Diagnosis"),
                    ("medication", "Medication"),
                    ("examination", "Examination"),
                    ("procedure", "Procedure"),
                    ("hospitalization", "Hospitalization"),
                    ("treatment_outcome", "Treatment outcome"),
                    ("medical_record", "Medical record"),
                    ("note", "Note"),
                ],
                max_length=30,
            ),
            preserve_default=False,
        ),
        migrations.CreateModel(
            name="DocumentAsset",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("position", models.PositiveIntegerField()),
                ("file_name", models.CharField(max_length=255)),
                ("mime_type", models.CharField(max_length=255)),
                ("size_bytes", models.BigIntegerField()),
                ("content_hash", models.CharField(max_length=64)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("document", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="assets", to="medical.document")),
            ],
            options={"ordering": ("position",)},
        ),
        migrations.CreateModel(
            name="EventRevision",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("current_snapshot", models.JSONField(default=dict)),
                ("suggested_changes", models.JSONField(default=dict)),
                ("status", models.CharField(choices=[("pending", "Pending"), ("applied", "Applied"), ("discarded", "Discarded")], default="pending", max_length=20)),
                ("model_name", models.CharField(max_length=255)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("resolved_at", models.DateTimeField(blank=True, null=True)),
                ("event", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="revisions", to="medical.medicalevent")),
            ],
            options={"ordering": ("-created_at",)},
        ),
        migrations.AddConstraint(
            model_name="documentasset",
            constraint=models.UniqueConstraint(fields=("document", "position"), name="unique_document_asset_position"),
        ),
        migrations.AddIndex(
            model_name="eventrevision",
            index=models.Index(fields=["event", "status", "-created_at"], name="revision_event_status_idx"),
        ),
        migrations.RunPython(consolidate_document_events, migrations.RunPython.noop),
        migrations.AddConstraint(
            model_name="medicalevent",
            constraint=models.UniqueConstraint(
                condition=models.Q(("deleted_at__isnull", True), ("source_document__isnull", False)),
                fields=("source_document",),
                name="unique_active_event_per_document",
            ),
        ),
    ]
