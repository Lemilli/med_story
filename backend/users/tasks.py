from datetime import timedelta

from celery import shared_task
from django.utils import timezone

from users.models import User


@shared_task
def cleanup_unverified_accounts_task(max_age_hours=24):
    cutoff = timezone.now() - timedelta(hours=max_age_hours)
    queryset = User.objects.filter(is_active=False, is_staff=False, date_joined__lt=cutoff)
    deleted, _ = queryset.delete()
    return {"deleted": deleted}
