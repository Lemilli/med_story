from django.urls import path

from medical.views import (
    ConfirmEventView,
    EventDetailView,
    EventListCreateView,
    SubjectDetailView,
    SubjectListCreateView,
    TimelineView,
)

urlpatterns = [
    path("subjects", SubjectListCreateView.as_view(), name="subject-list"),
    path("subjects/<uuid:id>", SubjectDetailView.as_view(), name="subject-detail"),
    path("events", EventListCreateView.as_view(), name="event-list"),
    path("events/<uuid:id>", EventDetailView.as_view(), name="event-detail"),
    path("events/<uuid:id>/confirm", ConfirmEventView.as_view(), name="event-confirm"),
    path("timeline", TimelineView.as_view(), name="timeline"),
]
