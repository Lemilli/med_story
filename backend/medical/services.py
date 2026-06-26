from medical.models import Subject


def get_or_create_default_subject(user):
    default_subject = Subject.objects.filter(user=user, is_default=True).first()
    if default_subject:
        return default_subject

    display_name = user.full_name or "Myself"
    return Subject.objects.create(
        user=user,
        display_name=display_name,
        relationship=Subject.Relationship.SELF,
        is_default=True,
    )
