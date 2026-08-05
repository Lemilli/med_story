import django.db.models.deletion
import uuid
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("medical", "0016_private_original_storage"), migrations.swappable_dependency(settings.AUTH_USER_MODEL)]

    operations = [
        migrations.CreateModel(
            name="AIQuotaBucket",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("scope", models.CharField(choices=[("user_day", "User day"), ("global_day", "Global day"), ("global_month", "Global month")], max_length=20)),
                ("period_start", models.DateField()),
                ("units_used", models.PositiveIntegerField(default=0)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("user", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name="ai_quota_buckets", to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name="AIQuotaReservation",
            fields=[
                ("id", models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ("operation", models.CharField(max_length=50)),
                ("units", models.PositiveSmallIntegerField()),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("user", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="ai_quota_reservations", to=settings.AUTH_USER_MODEL)),
            ],
            options={"ordering": ("-created_at",)},
        ),
        migrations.AddConstraint(model_name="aiquotabucket", constraint=models.UniqueConstraint(condition=models.Q(("user__isnull", False)), fields=("scope", "user", "period_start"), name="unique_user_ai_quota_bucket")),
        migrations.AddConstraint(model_name="aiquotabucket", constraint=models.UniqueConstraint(condition=models.Q(("user__isnull", True)), fields=("scope", "period_start"), name="unique_global_ai_quota_bucket")),
        migrations.AddIndex(model_name="aiquotareservation", index=models.Index(fields=["user", "-created_at"], name="ai_reservation_user_idx")),
    ]
