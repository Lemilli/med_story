from django.db import migrations, models


def delete_ai_processing_consents(apps, schema_editor):
    ConsentRecord = apps.get_model("users", "ConsentRecord")
    ConsentRecord.objects.filter(kind="ai_processing").delete()


class Migration(migrations.Migration):
    dependencies = [("users", "0002_emailchallenge_consentrecord")]

    operations = [
        migrations.RunPython(delete_ai_processing_consents, migrations.RunPython.noop),
        migrations.AlterField(
            model_name="consentrecord",
            name="kind",
            field=models.CharField(
                choices=[("privacy_notice", "Privacy notice")],
                max_length=30,
            ),
        ),
    ]
