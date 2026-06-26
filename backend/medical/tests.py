from datetime import date

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

from medical.models import MedicalEvent, Subject


class MedicalApiTests(APITestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user(
            email="user@example.com",
            password="StrongPass123!",
            full_name="Jane Doe",
        )
        self.other_user = get_user_model().objects.create_user(
            email="other@example.com",
            password="StrongPass123!",
            full_name="Other User",
        )
        self.client.force_authenticate(user=self.user)

    def test_subject_list_lazily_creates_default_subject(self):
        response = self.client.get("/api/v1/subjects")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["display_name"], "Jane Doe")
        self.assertTrue(response.data[0]["is_default"])

    def test_subject_crud_and_default_delete_guard(self):
        default_subject = Subject.objects.create(
            user=self.user,
            display_name="Jane Doe",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )

        create_response = self.client.post(
            "/api/v1/subjects",
            {
                "display_name": "Alex",
                "relationship": Subject.Relationship.CHILD,
                "date_of_birth": "2015-04-01",
            },
            format="json",
        )

        self.assertEqual(create_response.status_code, status.HTTP_201_CREATED)
        subject_id = create_response.data["id"]

        update_response = self.client.patch(
            f"/api/v1/subjects/{subject_id}",
            {"display_name": "Alex (son)"},
            format="json",
        )

        self.assertEqual(update_response.status_code, status.HTTP_200_OK)
        self.assertEqual(update_response.data["display_name"], "Alex (son)")

        delete_default_response = self.client.delete(f"/api/v1/subjects/{default_subject.id}")
        self.assertEqual(delete_default_response.status_code, status.HTTP_400_BAD_REQUEST)

        delete_response = self.client.delete(f"/api/v1/subjects/{subject_id}")
        self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)

    def test_create_event_defaults_to_default_subject_and_tags(self):
        response = self.client.post(
            "/api/v1/events",
            {
                "event_type": MedicalEvent.EventType.SYMPTOM,
                "title": "Abdominal pain",
                "description": "Moderate pain after meals",
                "event_date": "2026-06-01",
                "attributes": {"severity": "moderate"},
                "tags": ["IBS", "flare"],
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data["source"], MedicalEvent.Source.USER_MANUAL)
        self.assertTrue(response.data["is_confirmed"])
        self.assertEqual(response.data["tags"], ["IBS", "flare"])
        self.assertEqual(MedicalEvent.objects.get(id=response.data["id"]).subject.display_name, "Jane Doe")

    def test_timeline_filters_orders_and_paginates_events(self):
        default_subject = Subject.objects.create(
            user=self.user,
            display_name="Jane Doe",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        child_subject = Subject.objects.create(
            user=self.user,
            display_name="Alex",
            relationship=Subject.Relationship.CHILD,
        )
        older = MedicalEvent.objects.create(
            user=self.user,
            subject=default_subject,
            event_type=MedicalEvent.EventType.MEDICATION,
            title="Started Mesalazine",
            event_date=date(2025, 3, 10),
        )
        newer = MedicalEvent.objects.create(
            user=self.user,
            subject=default_subject,
            event_type=MedicalEvent.EventType.SYMPTOM,
            title="Abdominal pain",
            description="Moderate flare",
            event_date=date(2026, 6, 1),
        )
        child_event = MedicalEvent.objects.create(
            user=self.user,
            subject=child_subject,
            event_type=MedicalEvent.EventType.NOTE,
            title="Child note",
            event_date=date(2026, 6, 2),
        )
        ibs_tag = newer.tags.create(user=self.user, name="IBS")
        older.tags.add(ibs_tag)

        response = self.client.get("/api/v1/timeline?limit=1")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["results"][0]["id"], str(newer.id))
        self.assertIsNotNone(response.data["next"])

        filtered_response = self.client.get(
            "/api/v1/timeline?types=medication&from=2025-01-01&to=2025-12-31&tag=IBS&q=Mesalazine"
        )
        self.assertEqual(filtered_response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(filtered_response.data["results"]), 1)
        self.assertEqual(filtered_response.data["results"][0]["id"], str(older.id))

        subject_response = self.client.get(f"/api/v1/timeline?subject_id={child_subject.id}")
        self.assertEqual(subject_response.status_code, status.HTTP_200_OK)
        self.assertEqual(subject_response.data["results"][0]["id"], str(child_event.id))

    def test_soft_delete_hides_event_from_detail_and_timeline(self):
        subject = Subject.objects.create(
            user=self.user,
            display_name="Jane Doe",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        event = MedicalEvent.objects.create(
            user=self.user,
            subject=subject,
            event_type=MedicalEvent.EventType.NOTE,
            title="Manual note",
            event_date=date(2026, 6, 1),
        )

        delete_response = self.client.delete(f"/api/v1/events/{event.id}")
        self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)

        detail_response = self.client.get(f"/api/v1/events/{event.id}")
        self.assertEqual(detail_response.status_code, status.HTTP_404_NOT_FOUND)

        timeline_response = self.client.get("/api/v1/timeline")
        self.assertEqual(timeline_response.status_code, status.HTTP_200_OK)
        self.assertEqual(timeline_response.data["results"], [])

    def test_cross_user_subject_and_event_isolation(self):
        other_subject = Subject.objects.create(
            user=self.other_user,
            display_name="Other User",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        other_event = MedicalEvent.objects.create(
            user=self.other_user,
            subject=other_subject,
            event_type=MedicalEvent.EventType.NOTE,
            title="Other note",
            event_date=date(2026, 6, 1),
        )

        detail_response = self.client.get(f"/api/v1/events/{other_event.id}")
        self.assertEqual(detail_response.status_code, status.HTTP_404_NOT_FOUND)

        create_response = self.client.post(
            "/api/v1/events",
            {
                "event_type": MedicalEvent.EventType.NOTE,
                "title": "Invalid subject",
                "event_date": "2026-06-01",
                "subject_id": str(other_subject.id),
            },
            format="json",
        )
        self.assertEqual(create_response.status_code, status.HTTP_400_BAD_REQUEST)
