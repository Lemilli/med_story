from django.contrib import admin

from medical.models import AuditLog, Document, DocumentExplanation, MedicalEvent, MedicalSummary, ProcessingJob, Subject, Tag


@admin.register(Subject)
class SubjectAdmin(admin.ModelAdmin):
    list_display = ("display_name", "user", "relationship", "is_default", "created_at")
    list_filter = ("relationship", "is_default")
    search_fields = ("display_name", "user__email")
    readonly_fields = ("created_at", "updated_at")


@admin.register(MedicalEvent)
class MedicalEventAdmin(admin.ModelAdmin):
    list_display = ("title", "event_type", "subject", "user", "event_date", "source")
    list_filter = ("event_type", "source", "deleted_at")
    search_fields = ("title", "description", "user__email", "subject__display_name")
    readonly_fields = ("created_at", "updated_at", "deleted_at")


@admin.register(Document)
class DocumentAdmin(admin.ModelAdmin):
    list_display = ("title", "doc_type", "status", "subject", "user", "document_date", "created_at")
    list_filter = ("doc_type", "status", "deleted_at")
    search_fields = ("title", "mime_type", "user__email", "subject__display_name")
    readonly_fields = ("created_at", "updated_at", "deleted_at")


@admin.register(DocumentExplanation)
class DocumentExplanationAdmin(admin.ModelAdmin):
    list_display = ("document", "language", "model_name", "created_at")
    list_filter = ("language", "model_name")
    search_fields = ("document__title", "summary_text", "document__user__email")
    readonly_fields = ("created_at",)


@admin.register(MedicalSummary)
class MedicalSummaryAdmin(admin.ModelAdmin):
    list_display = ("subject", "user", "version", "is_current", "language", "generated_from_event_count", "created_at")
    list_filter = ("is_current", "language", "model_name")
    search_fields = ("subject__display_name", "narrative_text", "user__email")
    readonly_fields = ("created_at",)


@admin.register(ProcessingJob)
class ProcessingJobAdmin(admin.ModelAdmin):
    list_display = ("document", "summary", "job_type", "status", "user", "attempts", "created_at", "finished_at")
    list_filter = ("job_type", "status")
    search_fields = ("document__title", "task_id", "user__email")
    readonly_fields = ("created_at", "updated_at", "started_at", "finished_at")


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ("name", "user", "color")
    search_fields = ("name", "user__email")


@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ("action", "user", "ip_address", "created_at")
    list_filter = ("action", "created_at")
    search_fields = ("user__email", "action")
    readonly_fields = ("created_at",)
