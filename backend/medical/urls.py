from django.urls import path

from medical.views import (
    ConfirmEventView,
    DocumentDetailView,
    DocumentExplanationRegenerateView,
    DocumentExplanationView,
    DocumentIngestView,
    DocumentListCreateView,
    EventDetailView,
    EventListCreateView,
    SubjectDetailView,
    SubjectListCreateView,
    TimelineView,
)

urlpatterns = [
    path("subjects", SubjectListCreateView.as_view(), name="subject-list"),
    path("subjects/<uuid:id>", SubjectDetailView.as_view(), name="subject-detail"),
    path("documents", DocumentListCreateView.as_view(), name="document-list"),
    path("documents/<uuid:id>", DocumentDetailView.as_view(), name="document-detail"),
    path("documents/<uuid:id>/ingest", DocumentIngestView.as_view(), name="document-ingest"),
    path("documents/<uuid:id>/explanation", DocumentExplanationView.as_view(), name="document-explanation"),
    path(
        "documents/<uuid:id>/explanation/regenerate",
        DocumentExplanationRegenerateView.as_view(),
        name="document-explanation-regenerate",
    ),
    path("events", EventListCreateView.as_view(), name="event-list"),
    path("events/<uuid:id>", EventDetailView.as_view(), name="event-detail"),
    path("events/<uuid:id>/confirm", ConfirmEventView.as_view(), name="event-confirm"),
    path("timeline", TimelineView.as_view(), name="timeline"),
]
