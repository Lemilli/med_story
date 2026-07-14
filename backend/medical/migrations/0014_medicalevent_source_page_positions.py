from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [("medical", "0013_single_event_sources")]

    operations = [
        migrations.AddField(
            model_name="medicalevent",
            name="source_page_positions",
            field=models.JSONField(blank=True, default=list),
        ),
    ]
