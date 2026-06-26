from django.db.models import Q
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response

from medical.models import MedicalEvent, Subject
from medical.pagination import TimelineCursorPagination
from medical.serializers import MedicalEventSerializer, SubjectSerializer
from medical.services import get_or_create_default_subject


class SubjectListCreateView(generics.ListCreateAPIView):
    serializer_class = SubjectSerializer

    def get_queryset(self):
        get_or_create_default_subject(self.request.user)
        return Subject.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, is_default=False)


class SubjectDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = SubjectSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return Subject.objects.filter(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        subject = self.get_object()
        if subject.is_default:
            raise ValidationError({"is_default": ["The default subject cannot be deleted."]})
        return super().destroy(request, *args, **kwargs)


class MedicalEventQuerysetMixin:
    def get_base_queryset(self):
        return (
            MedicalEvent.objects.filter(user=self.request.user, deleted_at__isnull=True)
            .select_related("subject")
            .prefetch_related("tags")
        )

    def resolve_subject(self):
        subject_id = self.request.query_params.get("subject_id")
        if not subject_id:
            return get_or_create_default_subject(self.request.user)

        subject = Subject.objects.filter(id=subject_id, user=self.request.user).first()
        if not subject:
            raise ValidationError({"subject_id": ["Subject not found."]})
        return subject

    def apply_timeline_filters(self, queryset):
        subject = self.resolve_subject()
        queryset = queryset.filter(subject=subject)

        types = self.request.query_params.get("types")
        if types:
            event_types = [event_type.strip() for event_type in types.split(",") if event_type.strip()]
            if event_types:
                queryset = queryset.filter(event_type__in=event_types)

        date_from = self.request.query_params.get("from")
        if date_from:
            queryset = queryset.filter(event_date__gte=date_from)

        date_to = self.request.query_params.get("to")
        if date_to:
            queryset = queryset.filter(event_date__lte=date_to)

        tag = self.request.query_params.get("tag")
        if tag:
            queryset = queryset.filter(tags__name__iexact=tag.strip())

        query = self.request.query_params.get("q")
        if query:
            queryset = queryset.filter(Q(title__icontains=query) | Q(description__icontains=query))

        return queryset.distinct()


class EventListCreateView(MedicalEventQuerysetMixin, generics.ListCreateAPIView):
    serializer_class = MedicalEventSerializer
    pagination_class = TimelineCursorPagination

    def get_queryset(self):
        return self.get_base_queryset()


class EventDetailView(MedicalEventQuerysetMixin, generics.RetrieveUpdateDestroyAPIView):
    serializer_class = MedicalEventSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return self.get_base_queryset()

    def perform_destroy(self, instance):
        instance.deleted_at = timezone.now()
        instance.save(update_fields=("deleted_at", "updated_at"))


class TimelineView(MedicalEventQuerysetMixin, generics.ListAPIView):
    serializer_class = MedicalEventSerializer
    pagination_class = TimelineCursorPagination

    def get_queryset(self):
        return self.apply_timeline_filters(self.get_base_queryset())


class ConfirmEventView(MedicalEventQuerysetMixin, generics.GenericAPIView):
    serializer_class = MedicalEventSerializer
    lookup_url_kwarg = "id"

    def get_queryset(self):
        return self.get_base_queryset()

    def post(self, request, *args, **kwargs):
        event = self.get_object()
        event.is_confirmed = True
        event.save(update_fields=("is_confirmed", "updated_at"))
        return Response(MedicalEventSerializer(event, context={"request": request}).data, status=status.HTTP_200_OK)
