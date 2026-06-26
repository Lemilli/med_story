from django.contrib import admin

from medical.models import MedicalEvent, Subject, Tag


@admin.register(Subject)
class SubjectAdmin(admin.ModelAdmin):
    list_display = ("display_name", "user", "relationship", "is_default", "created_at")
    list_filter = ("relationship", "is_default")
    search_fields = ("display_name", "user__email")
    readonly_fields = ("created_at", "updated_at")


@admin.register(MedicalEvent)
class MedicalEventAdmin(admin.ModelAdmin):
    list_display = ("title", "event_type", "subject", "user", "event_date", "source", "is_confirmed")
    list_filter = ("event_type", "source", "is_confirmed", "deleted_at")
    search_fields = ("title", "description", "user__email", "subject__display_name")
    readonly_fields = ("created_at", "updated_at", "deleted_at")


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ("name", "user", "color")
    search_fields = ("name", "user__email")
