from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("medical", "0007_visitpreparation"),
    ]

    operations = [
        migrations.RemoveField(
            model_name="medicalevent",
            name="is_confirmed",
        ),
    ]
