import base64
import json
from datetime import date
from pathlib import Path
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.db import IntegrityError, transaction
from django.test import SimpleTestCase, override_settings
from django.core.files.uploadedfile import SimpleUploadedFile
from rest_framework import status
from rest_framework.test import APITestCase

from ai.providers.base import OCRResult
from ai.schemas import SchemaValidationError
from medical.models import Document, DocumentAsset, DocumentExplanation, EventRevision, MedicalEvent, MedicalSummary, ProcessingJob, Subject, VisitPreparation


TEST_ASSET_DIR = Path(__file__).resolve().parents[2] / "test_assets"


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

    def test_privacy_data_export_endpoint_is_not_exposed(self):
        response = self.client.post("/api/v1/privacy/export", {}, format="json")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_visit_preparation_is_subject_scoped_and_exported(self):
        subject = Subject.objects.create(
            user=self.user,
            display_name="Jane Doe",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        other_subject = Subject.objects.create(
            user=self.other_user,
            display_name="Other",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )

        get_response = self.client.get(f"/api/v1/visit-preparation?subject_id={subject.id}")
        self.assertEqual(get_response.status_code, status.HTTP_200_OK)
        self.assertEqual(get_response.data["note"], "")

        save_response = self.client.put(
            f"/api/v1/visit-preparation?subject_id={subject.id}",
            {"note": "Ask about the recent symptom pattern."},
            format="json",
        )
        self.assertEqual(save_response.status_code, status.HTTP_200_OK)
        self.assertEqual(save_response.data["note"], "Ask about the recent symptom pattern.")
        self.assertEqual(VisitPreparation.objects.get(subject=subject).user, self.user)

        forbidden_response = self.client.get(f"/api/v1/visit-preparation?subject_id={other_subject.id}")
        self.assertEqual(forbidden_response.status_code, status.HTTP_400_BAD_REQUEST)

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

        search_response = self.client.get("/api/v1/events/search?q=Mesalazine&types=medication")
        self.assertEqual(search_response.status_code, status.HTTP_200_OK)
        self.assertEqual(search_response.data["results"][0]["id"], str(older.id))

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

    def test_update_event_preserves_phase_1_edit_behavior(self):
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
            title="Original note",
            event_date=date(2026, 6, 1),
        )

        response = self.client.patch(
            f"/api/v1/events/{event.id}",
            {"title": "Updated note", "tags": ["follow-up"]},
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["title"], "Updated note")
        self.assertEqual(response.data["tags"], ["follow-up"])

    def test_document_crud_defaults_to_subject_and_soft_delete_hides_derived_events(self):
        create_response = self.client.post(
            "/api/v1/documents",
            {
                "title": "Lab results May",
                "doc_type": Document.DocumentType.LAB_RESULT,
                "mime_type": "application/pdf",
                "size_bytes": 128,
                "local_uri_hint": "app://documents/local-lab",
            },
            format="json",
        )

        self.assertEqual(create_response.status_code, status.HTTP_201_CREATED)
        document = Document.objects.get(id=create_response.data["id"])
        self.assertEqual(document.subject.display_name, "Jane Doe")
        self.assertEqual(create_response.data["status"], Document.Status.PENDING_INGEST)
        self.assertTrue(create_response.data["local_only"])
        self.assertFalse(create_response.data["extracted_text_available"])
        self.assertFalse(create_response.data["explanation_available"])

        event = MedicalEvent.objects.create(
            user=self.user,
            subject=document.subject,
            source_document=document,
            event_type=MedicalEvent.EventType.EXAMINATION,
            title="Derived lab",
            event_date=date(2026, 5, 12),
            source=MedicalEvent.Source.AI_DOCUMENT,
        )

        list_response = self.client.get("/api/v1/documents")
        self.assertEqual(list_response.status_code, status.HTTP_200_OK)
        self.assertEqual(list_response.data["results"][0]["id"], str(document.id))

        delete_response = self.client.delete(f"/api/v1/documents/{document.id}")
        self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)
        document.refresh_from_db()
        event.refresh_from_db()
        self.assertIsNotNone(document.deleted_at)
        self.assertIsNotNone(event.deleted_at)

    def test_document_create_rejects_cross_user_subject(self):
        other_subject = Subject.objects.create(
            user=self.other_user,
            display_name="Other User",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )

        response = self.client.post(
            "/api/v1/documents",
            {
                "title": "Invalid subject doc",
                "doc_type": Document.DocumentType.LAB_RESULT,
                "mime_type": "application/pdf",
                "size_bytes": 128,
                "subject_id": str(other_subject.id),
            },
            format="json",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_document_search_matches_title_and_extracted_text_for_subject(self):
        subject = Subject.objects.create(
            user=self.user, display_name="Jane Doe", relationship=Subject.Relationship.SELF, is_default=True,
        )
        Document.objects.create(
            user=self.user, subject=subject, title="MRI report", doc_type=Document.DocumentType.REPORT,
            mime_type="application/pdf", size_bytes=128, extracted_text="Finding: benign cyst",
        )
        response = self.client.get("/api/v1/documents?q=benign")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data["results"]), 1)
        self.assertEqual(response.data["results"][0]["title"], "MRI report")

    def test_document_detail_marks_broker_failed_ingestion_as_failed(self):
        document = self._create_document(Document.DocumentType.LAB_RESULT)
        document.status = Document.Status.PROCESSING
        document.save(update_fields=("status", "updated_at"))
        job = ProcessingJob.objects.create(
            user=self.user,
            document=document,
            status=ProcessingJob.Status.QUEUED,
            task_id="failed-task-id",
        )

        with patch("medical.views.current_app.AsyncResult") as async_result:
            async_result.return_value.failed.return_value = True
            response = self.client.get(f"/api/v1/documents/{document.id}")

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["status"], Document.Status.FAILED)
        self.assertEqual(response.data["error_message"], "document_processing_failed")
        document.refresh_from_db()
        job.refresh_from_db()
        self.assertEqual(document.status, Document.Status.FAILED)
        self.assertEqual(job.status, ProcessingJob.Status.FAILED)
        self.assertTrue(job.finished_at)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_ingest_lab_result_creates_ai_event(self):
        document = self._create_document(Document.DocumentType.LAB_RESULT)
        payload = (TEST_ASSET_DIR / "lab_result_basic.txt").read_bytes()

        response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("lab.pdf", payload, "application/pdf")},
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.PROCESSED)
        self.assertTrue(document.extracted_text)
        self.assertEqual(document.language, "en")
        self.assertEqual(document.document_date, date(2026, 5, 12))
        self.assertEqual(document.medical_events.count(), 1)
        self.assertEqual(document.explanations.count(), 1)
        self.assertTrue(document.explanations.get().summary_text)

        event = document.medical_events.get()
        self.assertEqual(event.event_type, MedicalEvent.EventType.EXAMINATION)
        self.assertEqual(event.source, MedicalEvent.Source.AI_DOCUMENT)
        self.assertEqual(event.attributes["measurements"][0]["label"], "CRP")
        self.assertIsNotNone(event.confidence)

        timeline_response = self.client.get("/api/v1/timeline")
        self.assertEqual(timeline_response.status_code, status.HTTP_200_OK)
        self.assertEqual(timeline_response.data["results"][0]["source_document_id"], str(document.id))

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_document_explanation_detail_and_availability(self):
        document = self._create_document(Document.DocumentType.LAB_RESULT)
        payload = (TEST_ASSET_DIR / "lab_result_basic.txt").read_bytes()

        ingest_response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("lab.pdf", payload, "application/pdf")},
            format="multipart",
        )
        detail_response = self.client.get(f"/api/v1/documents/{document.id}")
        explanation_response = self.client.get(f"/api/v1/documents/{document.id}/explanation")

        self.assertEqual(ingest_response.status_code, status.HTTP_202_ACCEPTED)
        self.assertTrue(detail_response.data["explanation_available"])
        self.assertEqual(explanation_response.status_code, status.HTTP_200_OK)
        self.assertEqual(explanation_response.data["document_id"], str(document.id))
        self.assertTrue(explanation_response.data["summary_text"])
        self.assertIsInstance(explanation_response.data["key_points"], list)
        self.assertIsInstance(explanation_response.data["glossary"], dict)

    def test_missing_document_explanation_returns_not_ready(self):
        document = self._create_document(Document.DocumentType.LAB_RESULT)

        response = self.client.get(f"/api/v1/documents/{document.id}/explanation")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(response.data["error"]["code"], "not_ready")

    def test_document_explanation_cross_user_is_hidden(self):
        other_subject = Subject.objects.create(
            user=self.other_user,
            display_name="Other User",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        other_document = Document.objects.create(
            user=self.other_user,
            subject=other_subject,
            title="Other lab",
            doc_type=Document.DocumentType.LAB_RESULT,
            mime_type="application/pdf",
            size_bytes=128,
            extracted_text="CRP 12 mg/L",
            status=Document.Status.PROCESSED,
        )
        DocumentExplanation.objects.create(
            document=other_document,
            summary_text="Other explanation",
            key_points=["Hidden"],
            glossary={},
            language="en",
            model_name="mock",
        )

        response = self.client.get(f"/api/v1/documents/{other_document.id}/explanation")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_regenerate_document_explanation_accepts_language_and_returns_latest(self):
        document = self._create_processed_document(extracted_text="CRP 12 mg/L")
        older = DocumentExplanation.objects.create(
            document=document,
            summary_text="Old explanation",
            key_points=["Old"],
            glossary={},
            language="en",
            model_name="mock",
        )

        response = self.client.post(
            f"/api/v1/documents/{document.id}/explanation/regenerate",
            {"language": "ru"},
            format="json",
        )
        detail_response = self.client.get(f"/api/v1/documents/{document.id}/explanation")

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(ProcessingJob.objects.get(id=response.data["job_id"]).status, ProcessingJob.Status.SUCCEEDED)
        self.assertEqual(document.explanations.count(), 2)
        self.assertEqual(detail_response.data["language"], "ru")
        self.assertNotEqual(detail_response.data["summary_text"], older.summary_text)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_regenerate_document_explanation_defaults_to_user_locale(self):
        self.user.locale = "ru"
        self.user.save(update_fields=("locale",))
        document = self._create_processed_document(extracted_text="CRP 12 mg/L", language="kk")

        response = self.client.post(f"/api/v1/documents/{document.id}/explanation/regenerate", {}, format="json")

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(document.explanations.latest("created_at").language, "ru")

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_regenerate_failure_marks_job_failed_and_preserves_existing_explanation(self):
        document = self._create_processed_document(extracted_text="CRP 12 mg/L")
        existing = DocumentExplanation.objects.create(
            document=document,
            summary_text="Existing explanation",
            key_points=["Keep"],
            glossary={},
            language="en",
            model_name="mock",
        )

        with patch(
            "medical.services.validate_document_explanation",
            side_effect=SchemaValidationError("invalid explanation"),
        ):
            response = self.client.post(f"/api/v1/documents/{document.id}/explanation/regenerate", {}, format="json")

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        job = ProcessingJob.objects.get(id=response.data["job_id"])
        self.assertEqual(job.status, ProcessingJob.Status.FAILED)
        self.assertEqual(list(document.explanations.values_list("id", flat=True)), [existing.id])

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_ingest_prescription_creates_medication_event(self):
        document = self._create_document(Document.DocumentType.PRESCRIPTION)
        payload = (TEST_ASSET_DIR / "prescription_basic.txt").read_bytes()

        response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("prescription.png", payload, "image/png")},
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        event = Document.objects.get(id=document.id).medical_events.get()
        self.assertEqual(event.event_type, MedicalEvent.EventType.MEDICATION)
        self.assertEqual(event.attributes["name"], "Mesalazine")
        self.assertEqual(event.attributes["dose"], "800 mg")

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_upload_audio_creates_document_and_voice_event(self):
        payload = b"Voice note: CRP was 12 mg/L on 2026-05-12."

        response = self.client.post(
            "/api/v1/documents/upload-audio",
            {
                "file": self._upload("voice-note.mp3", payload, "audio/mpeg"),
                "language": "en",
                "title": "Morning voice note",
            },
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document = Document.objects.get(id=response.data["id"])
        self.assertEqual(document.doc_type, Document.DocumentType.AUDIO)
        self.assertEqual(document.status, Document.Status.PROCESSED)
        self.assertEqual(document.mime_type, "audio/mpeg")
        self.assertEqual(document.title, "CBC and CRP lab results")
        self.assertEqual(document.extracted_text, payload.decode("utf-8"))
        self.assertEqual(document.language, "en")
        self.assertEqual(document.explanations.count(), 0)

        event = document.medical_events.get()
        self.assertEqual(event.source, MedicalEvent.Source.AI_VOICE)
        self.assertEqual(event.event_type, MedicalEvent.EventType.EXAMINATION)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_existing_audio_document_ingest_accepts_supported_audio(self):
        document = self._create_document(Document.DocumentType.AUDIO, mime_type="audio/m4a")
        payload = b"Voice note: started Mesalazine 800 mg three times daily."

        response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("voice.m4a", payload, "audio/x-m4a")},
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.PROCESSED)
        self.assertEqual(document.mime_type, "audio/m4a")
        event = document.medical_events.get()
        self.assertEqual(event.source, MedicalEvent.Source.AI_VOICE)
        self.assertEqual(event.event_type, MedicalEvent.EventType.MEDICATION)

    def test_upload_audio_rejects_oversized_file(self):
        response = self.client.post(
            "/api/v1/documents/upload-audio",
            {"file": self._upload("too-large.mp3", b"x" * (5 * 1024 * 1024 + 1), "audio/mpeg")},
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_413_REQUEST_ENTITY_TOO_LARGE)
        self.assertEqual(response.data["error"]["code"], "file_too_large")
        self.assertEqual(Document.objects.count(), 0)

    def test_upload_audio_rejects_cross_user_subject(self):
        other_subject = Subject.objects.create(
            user=self.other_user,
            display_name="Other User",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )

        response = self.client.post(
            "/api/v1/documents/upload-audio",
            {
                "file": self._upload("voice.mp3", b"audio", "audio/mpeg"),
                "subject_id": str(other_subject.id),
            },
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(Document.objects.count(), 0)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_ingest_real_png_asset_runs_ocr_and_structuring(self):
        document = self._create_document(Document.DocumentType.LAB_RESULT, mime_type="image/png")
        payload = (TEST_ASSET_DIR / "olymp_blood_test.png").read_bytes()
        captured = {}

        class AssetOCRProvider:
            def extract_text(self, *, file_bytes, mime):
                captured["ocr_file_bytes"] = file_bytes
                captured["ocr_mime"] = mime
                return OCRResult(
                    text=(
                        "Olymp clinical laboratory blood test. "
                        "Date: 2024-05-03. Hemoglobin 140 g/L. Platelets 458 10^9/L."
                    ),
                    language="ru",
                )

        class AssetLLMProvider:
            model = "asset-llm"

            def complete_json(self, *, system, user, schema, user_prompt=None, schema_name="medical_event_extraction"):
                captured["llm_user"] = user
                captured["llm_schema"] = schema
                if "summary_text" in schema.get("properties", {}):
                    captured["explanation_prompt"] = user_prompt
                    return {
                        "summary_text": "A plain-language explanation of the blood test.",
                        "key_points": ["Hemoglobin and platelets were listed."],
                        "glossary": {"Hemoglobin": "A protein in red blood cells."},
                    }
                return {
                    "document_date": "2024-05-03",
                    "suggested_title": "Olymp blood test results",
                    "events": [
                        {
                            "event_type": "examination",
                            "title": "Olymp blood test results",
                            "description": "Blood test results from the uploaded lab image.",
                            "event_date": "2024-05-03",
                            "attributes": {
                                "name": "Complete blood count",
                                "measurements": [
                                    {"label": "Hemoglobin", "value": 140, "unit": "g/L", "ref": "130-160"},
                                    {"label": "Platelets", "value": 458, "unit": "10^9/L", "ref": "180-320"},
                                ],
                            },
                            "confidence": 0.88,
                        }
                    ],
                }

        with patch("medical.services.get_ocr_provider", return_value=AssetOCRProvider()), patch(
            "medical.services.get_llm_provider",
            return_value=AssetLLMProvider(),
        ):
            response = self.client.post(
                f"/api/v1/documents/{document.id}/ingest",
                {"file": self._upload("olymp_blood_test.png", payload, "image/png")},
                format="multipart",
            )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(captured["ocr_file_bytes"], payload)
        self.assertEqual(captured["ocr_mime"], "image/png")
        self.assertIn("Hemoglobin 140 g/L", captured["llm_user"])
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.PROCESSED)
        self.assertEqual(document.language, "ru")
        self.assertEqual(document.document_date, date(2024, 5, 3))
        self.assertEqual(document.title, "Olymp blood test results")
        self.assertTrue(document.explanations.exists())
        explanation_prompt = captured["explanation_prompt"]
        self.assertIn("1-2 short sentences", explanation_prompt)
        self.assertIn("appear within the document's provided", explanation_prompt)
        self.assertIn("outside", explanation_prompt)
        self.assertIn("reference ranges", explanation_prompt)
        self.assertIn("prescriptions", explanation_prompt)
        self.assertIn("what each medicine is generally used for", explanation_prompt)
        self.assertIn("glossary: leave empty", explanation_prompt)
        self.assertIn("Do not give medical advice", explanation_prompt)

        event = document.medical_events.get()
        self.assertEqual(event.event_type, MedicalEvent.EventType.EXAMINATION)
        self.assertEqual(event.attributes["measurements"][1]["label"], "Platelets")

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_ingest_is_idempotent_for_processed_document(self):
        document = self._create_document(Document.DocumentType.LAB_RESULT)
        payload = (TEST_ASSET_DIR / "lab_result_basic.txt").read_bytes()

        first_response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("lab.pdf", payload, "application/pdf")},
            format="multipart",
        )
        second_response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("lab.pdf", payload, "application/pdf")},
            format="multipart",
        )

        self.assertEqual(first_response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(second_response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(Document.objects.get(id=document.id).medical_events.filter(deleted_at__isnull=True).count(), 1)
        self.assertEqual(ProcessingJob.objects.filter(document=document).count(), 1)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_ingest_rejects_exact_file_already_processed_for_same_user(self):
        original = self._create_document(Document.DocumentType.LAB_RESULT)
        duplicate = self._create_document(Document.DocumentType.LAB_RESULT)
        payload = (TEST_ASSET_DIR / "lab_result_basic.txt").read_bytes()

        first_response = self.client.post(
            f"/api/v1/documents/{original.id}/ingest",
            {"file": self._upload("original.pdf", payload, "application/pdf")},
            format="multipart",
        )
        duplicate_response = self.client.post(
            f"/api/v1/documents/{duplicate.id}/ingest",
            {"file": self._upload("renamed-copy.pdf", payload, "application/pdf")},
            format="multipart",
        )

        self.assertEqual(first_response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(duplicate_response.status_code, status.HTTP_409_CONFLICT)
        self.assertEqual(duplicate_response.data["error"]["code"], "document_already_processed")
        self.assertEqual(duplicate_response.data["error"]["details"]["document_id"], str(original.id))
        self.assertFalse(Document.objects.filter(id=duplicate.id).exists())
        self.assertEqual(ProcessingJob.objects.filter(document=original).count(), 1)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_ingest_allows_exact_file_after_original_document_is_deleted(self):
        original = self._create_document(Document.DocumentType.LAB_RESULT)
        replacement = self._create_document(Document.DocumentType.LAB_RESULT)
        payload = (TEST_ASSET_DIR / "lab_result_basic.txt").read_bytes()

        self.client.post(
            f"/api/v1/documents/{original.id}/ingest",
            {"file": self._upload("original.pdf", payload, "application/pdf")},
            format="multipart",
        )
        self.client.delete(f"/api/v1/documents/{original.id}")
        response = self.client.post(
            f"/api/v1/documents/{replacement.id}/ingest",
            {"file": self._upload("replacement.pdf", payload, "application/pdf")},
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(ProcessingJob.objects.filter(document=replacement).count(), 1)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_audio_ingest_is_idempotent_for_processed_document(self):
        document = self._create_document(Document.DocumentType.AUDIO, mime_type="audio/mpeg")
        payload = b"Voice note: CRP was 12 mg/L."

        first_response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("voice.mp3", payload, "audio/mpeg")},
            format="multipart",
        )
        second_response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("voice.mp3", payload, "audio/mpeg")},
            format="multipart",
        )

        self.assertEqual(first_response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(second_response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(document.medical_events.filter(deleted_at__isnull=True).count(), 1)
        self.assertEqual(ProcessingJob.objects.filter(document=document).count(), 1)

    def test_ingest_rejects_oversized_file_with_coded_error(self):
        document = self._create_document(Document.DocumentType.LAB_RESULT)

        response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {"file": self._upload("too-large.pdf", b"x" * (5 * 1024 * 1024 + 1), "application/pdf")},
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_413_REQUEST_ENTITY_TOO_LARGE)
        self.assertEqual(response.data["error"]["code"], "file_too_large")
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.PENDING_INGEST)

    def test_ingest_rejects_unsupported_and_audio_mime_types(self):
        text_document = self._create_document(Document.DocumentType.OTHER, mime_type="application/pdf")
        text_response = self.client.post(
            f"/api/v1/documents/{text_document.id}/ingest",
            {"file": self._upload("invalid.txt", b"not supported", "text/plain")},
            format="multipart",
        )

        audio_document = self._create_document(Document.DocumentType.OTHER, mime_type="application/pdf")
        audio_response = self.client.post(
            f"/api/v1/documents/{audio_document.id}/ingest",
            {"file": self._upload("voice.mp3", b"audio", "audio/mpeg")},
            format="multipart",
        )

        self.assertEqual(text_response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(text_response.data["error"]["code"], "unsupported_mime_type")
        self.assertEqual(audio_response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(audio_response.data["error"]["code"], "unsupported_mime_type")

    def test_ingest_cross_user_document_is_hidden(self):
        other_subject = Subject.objects.create(
            user=self.other_user,
            display_name="Other User",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        other_document = Document.objects.create(
            user=self.other_user,
            subject=other_subject,
            title="Other lab",
            doc_type=Document.DocumentType.LAB_RESULT,
            mime_type="application/pdf",
            size_bytes=128,
        )

        response = self.client.post(
            f"/api/v1/documents/{other_document.id}/ingest",
            {"file": self._upload("lab.pdf", b"content", "application/pdf")},
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_failed_provider_output_marks_document_and_job_failed_without_events(self):
        document = self._create_document(Document.DocumentType.LAB_RESULT)

        with patch(
            "medical.services.validate_event_extraction",
            side_effect=SchemaValidationError("invalid structured output"),
        ):
            response = self.client.post(
                f"/api/v1/documents/{document.id}/ingest",
                {"file": self._upload("lab.pdf", b"unstructured text", "application/pdf")},
                format="multipart",
            )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.FAILED)
        self.assertEqual(document.medical_events.count(), 0)
        job = ProcessingJob.objects.get(document=document)
        self.assertEqual(job.status, ProcessingJob.Status.FAILED)
        self.assertTrue(job.error_message)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_non_medical_upload_is_rejected_without_creating_events(self):
        document = self._create_document(Document.DocumentType.IMAGE, mime_type="image/jpeg")

        class NonMedicalLLMProvider:
            def complete_json(self, **_kwargs):
                return {
                    "is_medical_document": False,
                    "document_date": None,
                    "suggested_title": None,
                    "events": [],
                }

        with patch("medical.services.get_llm_provider", return_value=NonMedicalLLMProvider()):
            response = self.client.post(
                f"/api/v1/documents/{document.id}/ingest",
                {"file": self._upload("dog.jpg", b"a photo of a dog", "image/jpeg")},
                format="multipart",
            )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.FAILED)
        self.assertEqual(document.error_message, "document_not_medical")
        self.assertEqual(document.medical_events.count(), 0)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_unreadable_upload_is_rejected_without_creating_events(self):
        document = self._create_document(Document.DocumentType.IMAGE, mime_type="image/jpeg")

        class EmptyOCRProvider:
            def extract_text(self, **_kwargs):
                return OCRResult(text="", language="")

        with patch("medical.services.get_ocr_provider", return_value=EmptyOCRProvider()):
            response = self.client.post(
                f"/api/v1/documents/{document.id}/ingest",
                {"file": self._upload("blurry.jpg", b"", "image/jpeg")},
                format="multipart",
            )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.FAILED)
        self.assertEqual(document.error_message, "document_unreadable")
        self.assertEqual(document.medical_events.count(), 0)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_failed_stt_marks_audio_document_and_job_failed_without_events(self):
        document = self._create_document(Document.DocumentType.AUDIO, mime_type="audio/mpeg")

        class FailingSTTProvider:
            def transcribe(self, *, audio_bytes, mime, lang=None):
                raise ValueError("transcription failed")

        with patch("medical.services.get_stt_provider", return_value=FailingSTTProvider()):
            response = self.client.post(
                f"/api/v1/documents/{document.id}/ingest",
                {"file": self._upload("voice.mp3", b"audio", "audio/mpeg")},
                format="multipart",
            )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.FAILED)
        self.assertEqual(document.medical_events.count(), 0)
        job = ProcessingJob.objects.get(document=document)
        self.assertEqual(job.status, ProcessingJob.Status.FAILED)
        self.assertTrue(job.error_message)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_empty_audio_is_rejected_without_creating_events(self):
        document = self._create_document(Document.DocumentType.AUDIO, mime_type="audio/mpeg")

        class EmptySTTProvider:
            def transcribe(self, *, audio_bytes, mime, lang=None):
                return ""

        with patch("medical.services.get_stt_provider", return_value=EmptySTTProvider()):
            response = self.client.post(
                "/api/v1/documents/upload-audio",
                {
                    "title": "Voice note",
                    "file": self._upload("voice.mp3", b"audio", "audio/mpeg"),
                },
                format="multipart",
            )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document = Document.objects.get(title="Voice note")
        self.assertEqual(document.status, Document.Status.FAILED)
        self.assertEqual(document.error_message, "audio_unreadable")
        self.assertEqual(document.medical_events.count(), 0)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_non_medical_audio_is_rejected_without_creating_events(self):
        class NonMedicalLLMProvider:
            def complete_json(self, **_kwargs):
                return {
                    "is_medical_document": False,
                    "document_date": None,
                    "suggested_title": None,
                    "events": [],
                }

        with patch("medical.services.get_llm_provider", return_value=NonMedicalLLMProvider()):
            response = self.client.post(
                "/api/v1/documents/upload-audio",
                {
                    "title": "Voice note",
                    "file": self._upload("voice.mp3", b"unrelated audio", "audio/mpeg"),
                },
                format="multipart",
            )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document = Document.objects.get(title="Voice note")
        self.assertEqual(document.status, Document.Status.FAILED)
        self.assertEqual(document.error_message, "audio_not_medical")
        self.assertEqual(document.medical_events.count(), 0)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_zero_event_extraction_is_rejected_without_creating_events(self):
        document = self._create_document(Document.DocumentType.IMAGE, mime_type="image/jpeg")

        class NoEventsLLMProvider:
            def complete_json(self, **_kwargs):
                return {
                    "is_medical_document": True,
                    "document_date": None,
                    "suggested_title": "Medical image",
                    "events": [],
                }

        with patch("medical.services.get_llm_provider", return_value=NoEventsLLMProvider()):
            response = self.client.post(
                f"/api/v1/documents/{document.id}/ingest",
                {"file": self._upload("record.jpg", b"medical text", "image/jpeg")},
                format="multipart",
            )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.FAILED)
        self.assertEqual(document.error_message, "medical_events_not_found")
        self.assertEqual(document.medical_events.count(), 0)

    def test_get_missing_summary_returns_not_ready(self):
        response = self.client.get("/api/v1/summary")

        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(response.data["error"]["code"], "not_ready")

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_regenerate_summary_creates_current_version_from_events(self):
        subject = self._default_subject()
        MedicalEvent.objects.create(
            user=self.user,
            subject=subject,
            event_type=MedicalEvent.EventType.SYMPTOM,
            title="Abdominal pain",
            description="Moderate pain after meals",
            event_date=date(2026, 6, 1),
        )
        MedicalEvent.objects.create(
            user=self.user,
            subject=subject,
            event_type=MedicalEvent.EventType.EXAMINATION,
            title="Lab",
            event_date=date(2026, 6, 2),
            source=MedicalEvent.Source.AI_DOCUMENT,
        )

        response = self.client.post("/api/v1/summary/regenerate", {}, format="json")
        summary_response = self.client.get("/api/v1/summary")

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        job = ProcessingJob.objects.get(id=response.data["job_id"])
        self.assertEqual(job.status, ProcessingJob.Status.SUCCEEDED)
        self.assertIsNotNone(job.summary_id)
        self.assertEqual(summary_response.status_code, status.HTTP_200_OK)
        self.assertEqual(summary_response.data["version"], 1)
        self.assertTrue(summary_response.data["is_current"])
        self.assertEqual(summary_response.data["generated_from_event_count"], 2)
        self.assertIn("key_symptoms", summary_response.data["content"])

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_summary_versions_replace_current_summary(self):
        subject = self._default_subject()
        MedicalEvent.objects.create(
            user=self.user,
            subject=subject,
            event_type=MedicalEvent.EventType.MEDICATION,
            title="Started Mesalazine",
            event_date=date(2026, 5, 13),
        )

        first_response = self.client.post("/api/v1/summary/regenerate", {}, format="json")
        second_response = self.client.post("/api/v1/summary/regenerate", {}, format="json")
        versions_response = self.client.get("/api/v1/summary/versions")

        self.assertEqual(first_response.status_code, status.HTTP_202_ACCEPTED)
        self.assertEqual(second_response.status_code, status.HTTP_202_ACCEPTED)
        summaries = MedicalSummary.objects.filter(subject=subject).order_by("version")
        self.assertEqual([summary.version for summary in summaries], [1, 2])
        self.assertFalse(summaries[0].is_current)
        self.assertTrue(summaries[1].is_current)
        self.assertEqual(versions_response.status_code, status.HTTP_200_OK)
        self.assertEqual([item["version"] for item in versions_response.data], [2, 1])

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_summary_export_json_and_pdf(self):
        subject = self._default_subject()
        MedicalEvent.objects.create(
            user=self.user,
            subject=subject,
            event_type=MedicalEvent.EventType.NOTE,
            title="Visit note",
            event_date=date(2026, 6, 1),
        )
        self.client.post("/api/v1/summary/regenerate", {}, format="json")

        json_response = self.client.get("/api/v1/summary/export?format=json")
        pdf_response = self.client.get("/api/v1/summary/export?format=pdf")

        self.assertEqual(json_response.status_code, status.HTTP_200_OK)
        self.assertEqual(json_response.data["version"], 1)
        self.assertEqual(pdf_response.status_code, status.HTTP_200_OK)
        self.assertEqual(pdf_response["Content-Type"], "application/pdf")
        self.assertTrue(pdf_response.content.startswith(b"%PDF-"))
        self.assertGreater(len(pdf_response.content), 100)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_summary_job_detail_and_cross_user_isolation(self):
        subject = self._default_subject()
        other_subject = Subject.objects.create(
            user=self.other_user,
            display_name="Other User",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )
        other_job = ProcessingJob.objects.create(
            user=self.other_user,
            job_type=ProcessingJob.JobType.SUMMARY,
            status=ProcessingJob.Status.QUEUED,
        )
        MedicalEvent.objects.create(
            user=self.user,
            subject=subject,
            event_type=MedicalEvent.EventType.NOTE,
            title="Visit note",
            event_date=date(2026, 6, 1),
        )

        response = self.client.post("/api/v1/summary/regenerate", {}, format="json")
        detail_response = self.client.get(f"/api/v1/jobs/{response.data['job_id']}")
        hidden_response = self.client.get(f"/api/v1/jobs/{other_job.id}")
        other_summary_response = self.client.get(f"/api/v1/summary?subject_id={other_subject.id}")

        self.assertEqual(detail_response.status_code, status.HTTP_200_OK)
        self.assertEqual(detail_response.data["job_type"], ProcessingJob.JobType.SUMMARY)
        self.assertEqual(detail_response.data["status"], ProcessingJob.Status.SUCCEEDED)
        self.assertEqual(hidden_response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(other_summary_response.status_code, status.HTTP_400_BAD_REQUEST)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_summary_generation_failure_preserves_existing_current_summary(self):
        subject = self._default_subject()
        existing = MedicalSummary.objects.create(
            user=self.user,
            subject=subject,
            version=1,
            is_current=True,
            content={
                "key_symptoms": [],
                "major_diagnoses": [],
                "treatment_history": [],
                "important_examinations": [],
                "relevant_medications": [],
            },
            narrative_text="Existing summary",
            generated_from_event_count=0,
            model_name="mock",
            language="en",
        )
        MedicalEvent.objects.create(
            user=self.user,
            subject=subject,
            event_type=MedicalEvent.EventType.NOTE,
            title="Visit note",
            event_date=date(2026, 6, 1),
        )

        with patch(
            "medical.services.validate_medical_summary",
            side_effect=SchemaValidationError("invalid summary"),
        ):
            response = self.client.post("/api/v1/summary/regenerate", {}, format="json")

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        job = ProcessingJob.objects.get(id=response.data["job_id"])
        self.assertEqual(job.status, ProcessingJob.Status.FAILED)
        self.assertEqual(MedicalSummary.objects.filter(subject=subject).count(), 1)
        existing.refresh_from_db()
        self.assertTrue(existing.is_current)

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_event_changes_enqueue_summary_refresh(self):
        create_response = self.client.post(
            "/api/v1/events",
            {
                "event_type": MedicalEvent.EventType.NOTE,
                "title": "Manual note",
                "event_date": "2026-06-01",
            },
            format="json",
        )
        event_id = create_response.data["id"]
        update_response = self.client.patch(f"/api/v1/events/{event_id}", {"title": "Updated note"}, format="json")
        delete_response = self.client.delete(f"/api/v1/events/{event_id}")

        self.assertEqual(create_response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(update_response.status_code, status.HTTP_200_OK)
        self.assertEqual(delete_response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(ProcessingJob.objects.filter(job_type=ProcessingJob.JobType.SUMMARY).count(), 3)
        self.assertEqual(MedicalSummary.objects.filter(is_current=True).count(), 1)
        self.assertEqual(MedicalSummary.objects.get(is_current=True).generated_from_event_count, 0)

    def _create_document(self, doc_type, mime_type="application/pdf"):
        subject = self._default_subject()
        return Document.objects.create(
            user=self.user,
            subject=subject,
            title="Fixture document",
            doc_type=doc_type,
            mime_type=mime_type,
            size_bytes=128,
        )

    def _create_processed_document(self, *, extracted_text, language="en"):
        document = self._create_document(Document.DocumentType.LAB_RESULT)
        document.extracted_text = extracted_text
        document.language = language
        document.status = Document.Status.PROCESSED
        document.save(update_fields=("extracted_text", "language", "status", "updated_at"))
        return document

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_multi_page_upload_creates_one_document_event_and_ordered_assets(self):
        document = self._create_document(Document.DocumentType.MEDICAL_RECORD)
        response = self.client.post(
            f"/api/v1/documents/{document.id}/ingest",
            {
                "files": [
                    self._upload("page-1.png", b"CRP 12 mg/L", "image/png"),
                    self._upload("page-2.png", b"Reference < 5 mg/L", "image/png"),
                ]
            },
            format="multipart",
        )

        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document.refresh_from_db()
        self.assertEqual(document.status, Document.Status.PROCESSED)
        self.assertEqual(document.medical_events.filter(deleted_at__isnull=True).count(), 1)
        self.assertEqual(list(document.assets.values_list("position", flat=True)), [1, 2])
        self.assertEqual(response.data["event_count"], 1)
        self.assertIsNotNone(response.data["event_id"])

    def test_database_rejects_two_active_events_for_one_source(self):
        document = self._create_processed_document(extracted_text="CRP 12 mg/L")
        subject = document.subject
        MedicalEvent.objects.create(
            user=self.user, subject=subject, source_document=document,
            event_type=MedicalEvent.EventType.EXAMINATION, title="First",
            event_date=date(2026, 5, 12), source=MedicalEvent.Source.AI_DOCUMENT,
        )
        with self.assertRaises(IntegrityError), transaction.atomic():
            MedicalEvent.objects.create(
                user=self.user, subject=subject, source_document=document,
                event_type=MedicalEvent.EventType.NOTE, title="Second",
                event_date=date(2026, 5, 12), source=MedicalEvent.Source.AI_DOCUMENT,
            )

    @override_settings(CELERY_TASK_ALWAYS_EAGER=True)
    def test_text_capture_preserves_original_text_on_event_detail(self):
        original = "CRP 12 mg/L on 2026-05-12"
        response = self.client.post("/api/v1/capture/notes", {"text": original}, format="json")
        self.assertEqual(response.status_code, status.HTTP_202_ACCEPTED)
        document = Document.objects.get(id=response.data["id"])
        event = document.medical_events.get(deleted_at__isnull=True)

        detail = self.client.get(f"/api/v1/events/{event.id}")
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.data["source_text"], original)

    def test_event_regeneration_creates_draft_and_does_not_overwrite_edit(self):
        document = self._create_processed_document(extracted_text="CRP 12 mg/L on 2026-05-12")
        event = MedicalEvent.objects.create(
            user=self.user, subject=document.subject, source_document=document,
            event_type=MedicalEvent.EventType.EXAMINATION, title="My edited title",
            description="My edited description", event_date=date(2026, 5, 12),
            source=MedicalEvent.Source.AI_DOCUMENT,
        )

        response = self.client.post(f"/api/v1/events/{event.id}/revisions", {}, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        event.refresh_from_db()
        self.assertEqual(event.title, "My edited title")
        revision = EventRevision.objects.get(id=response.data["id"])
        self.assertEqual(revision.status, EventRevision.Status.PENDING)
        self.assertIn("title", revision.suggested_changes)

        applied = self.client.post(
            f"/api/v1/events/{event.id}/revisions/{revision.id}",
            {"fields": ["description"]},
            format="json",
        )
        self.assertEqual(applied.status_code, status.HTTP_200_OK)
        event.refresh_from_db()
        self.assertEqual(event.title, "My edited title")
        self.assertNotEqual(event.description, "My edited description")

    def _default_subject(self):
        subject = Subject.objects.filter(user=self.user, is_default=True).first()
        if subject is not None:
            return subject
        return Subject.objects.create(
            user=self.user,
            display_name="Jane Doe",
            relationship=Subject.Relationship.SELF,
            is_default=True,
        )

    def _upload(self, name, payload, content_type):
        return SimpleUploadedFile(name, payload, content_type=content_type)


class AIProviderTests(SimpleTestCase):
    def test_event_extraction_prompt_prioritizes_infection_panel_findings(self):
        from ai.providers.openai import EVENT_EXTRACTION_USER_PROMPT

        self.assertIn("positive, reactive, detected", EVENT_EXTRACTION_USER_PROMPT)
        self.assertIn("negative, non-reactive, or not-detected", EVENT_EXTRACTION_USER_PROMPT)
        self.assertIn("infer infection from a blood-count pattern", EVENT_EXTRACTION_USER_PROMPT)
        self.assertIn("DD.MM.YYYY", EVENT_EXTRACTION_USER_PROMPT)

    @override_settings(
        AI_OPENAI_API_KEY="test-key",
        AI_OPENAI_OCR_MODEL="gpt-test-ocr",
        AI_OPENAI_TIMEOUT_SECONDS=12,
    )
    def test_openai_ocr_provider_sends_png_asset_as_image_input(self):
        from ai.providers.openai import OpenAIOCRProvider

        payload = (TEST_ASSET_DIR / "olymp_blood_test.png").read_bytes()
        fake_client = FakeOpenAIClient(output_text=" Extracted blood test text \n")

        with patch("ai.providers.openai._build_client", return_value=fake_client):
            result = OpenAIOCRProvider().extract_text(file_bytes=payload, mime="image/png")

        self.assertEqual(result.text, "Extracted blood test text")
        call = fake_client.responses.calls[0]
        self.assertEqual(call["model"], "gpt-test-ocr")
        self.assertEqual(call["timeout"], 12)

        user_content = call["input"][1]["content"]
        image_part = next(part for part in user_content if part["type"] == "input_image")
        prefix = "data:image/png;base64,"
        self.assertTrue(image_part["image_url"].startswith(prefix))
        encoded_payload = image_part["image_url"][len(prefix):]
        self.assertEqual(base64.b64decode(encoded_payload), payload)

    @override_settings(
        AI_OPENAI_API_KEY="test-key",
        AI_OPENAI_STT_MODEL="gpt-test-stt",
        AI_OPENAI_TIMEOUT_SECONDS=12,
    )
    def test_openai_stt_provider_sends_audio_with_model_and_response_format(self):
        from ai.providers.openai import OpenAISTTProvider

        payload = b"fake audio bytes"
        fake_client = FakeOpenAIClient(output_text="")
        fake_client.audio.transcriptions.text = " Transcribed voice note \n"

        with patch("ai.providers.openai._build_client", return_value=fake_client):
            transcript = OpenAISTTProvider().transcribe(audio_bytes=payload, mime="audio/m4a", lang="en")

        self.assertEqual(transcript, "Transcribed voice note")
        call = fake_client.audio.transcriptions.calls[0]
        self.assertEqual(call["model"], "gpt-test-stt")
        self.assertEqual(call["response_format"], "json")
        self.assertEqual(call["language"], "en")
        self.assertEqual(call["timeout"], 12)
        self.assertEqual(call["file"].name, "voice-note.m4a")
        self.assertEqual(call["file"].getvalue(), payload)

    def test_event_extraction_schema_is_strict_for_openai_structured_outputs(self):
        from ai.schemas import EVENT_EXTRACTION_JSON_SCHEMA

        event_schema = EVENT_EXTRACTION_JSON_SCHEMA["properties"]["event"]
        attributes_schema = event_schema["properties"]["attributes"]
        measurement_schema = attributes_schema["properties"]["measurements"]["items"]
        medication_schema = attributes_schema["properties"]["medications"]["items"]

        self.assertFalse(EVENT_EXTRACTION_JSON_SCHEMA["additionalProperties"])
        self.assertFalse(event_schema["additionalProperties"])
        self.assertFalse(attributes_schema["additionalProperties"])
        self.assertFalse(measurement_schema["additionalProperties"])
        self.assertFalse(medication_schema["additionalProperties"])

    def test_event_extraction_normalizes_recoverable_model_output(self):
        from ai.schemas import validate_event_extraction

        long_title = "X" * 300
        extraction = validate_event_extraction(
            {
                "document_date": "03.05.2024",
                "suggested_title": long_title,
                "event": {
                        "event_type": "lab_result",
                        "title": long_title,
                        "description": 123,
                        "event_date": "04/05/2024",
                        "attributes": [],
                        "confidence": 1.7,
                    },
            },
            default_date=date(2026, 6, 28),
        )

        self.assertEqual(extraction["document_date"], date(2024, 5, 3))
        self.assertEqual(len(extraction["suggested_title"]), 255)
        first_event = extraction["event"]
        self.assertEqual(first_event["event_type"], "examination")
        self.assertEqual(first_event["event_date"], date(2024, 5, 4))
        self.assertEqual(len(first_event["title"]), 255)
        self.assertEqual(first_event["description"], "123")
        self.assertEqual(first_event["attributes"], {})
        self.assertEqual(first_event["confidence"], 1.0)

    def test_event_extraction_defaults_missing_dates_to_today(self):
        from ai.schemas import validate_event_extraction

        extraction = validate_event_extraction(
            {
                "document_date": None,
                "suggested_title": None,
                "event": {
                        "event_type": "note",
                        "title": "Undated note",
                        "description": None,
                        "event_date": None,
                        "attributes": {},
                        "confidence": None,
                    },
            },
            default_date=date(2026, 6, 28),
        )

        self.assertEqual(extraction["document_date"], date(2026, 6, 28))
        self.assertEqual(extraction["event"]["event_date"], date(2026, 6, 28))
        self.assertEqual(extraction["event"]["confidence"], 0.5)

    def test_document_explanation_validation_normalizes_recoverable_output(self):
        from ai.schemas import validate_document_explanation

        explanation = validate_document_explanation(
            {
                "summary_text": "  Plain explanation  ",
                "key_points": [" First point ", "", 123, "Second point"],
                "glossary": [
                    {"term": " CRP ", "definition": " Inflammation marker "},
                    {"term": "bad", "definition": 123},
                    {"term": "", "definition": "missing term"},
                ],
            }
        )

        self.assertEqual(explanation["summary_text"], "Plain explanation")
        self.assertEqual(explanation["key_points"], ["First point", "Second point"])
        self.assertEqual(explanation["glossary"], {"CRP": "Inflammation marker"})

    def test_document_explanation_validation_accepts_legacy_glossary_object(self):
        from ai.schemas import validate_document_explanation

        explanation = validate_document_explanation(
            {
                "summary_text": "Plain explanation",
                "key_points": ["Point"],
                "glossary": {" CRP ": " Inflammation marker ", "bad": 123},
            }
        )

        self.assertEqual(explanation["glossary"], {"CRP": "Inflammation marker"})

    def test_document_explanation_validation_rejects_unusable_output(self):
        from ai.schemas import SchemaValidationError, validate_document_explanation

        with self.assertRaises(SchemaValidationError):
            validate_document_explanation({"summary_text": "", "key_points": [], "glossary": {}})

        with self.assertRaises(SchemaValidationError):
            validate_document_explanation({"summary_text": "Summary", "key_points": {}, "glossary": {}})

    def test_medical_summary_validation_rejects_overlong_sections(self):
        from ai.schemas import SUMMARY_CONTENT_SECTIONS, validate_medical_summary

        content = {section: [] for section in SUMMARY_CONTENT_SECTIONS}
        content["key_symptoms"] = [f"Symptom {index}" for index in range(7)]

        with self.assertRaises(SchemaValidationError):
            validate_medical_summary(
                {
                    "content": content,
                    "narrative_text": "A concise timeline-based summary.",
                }
            )

    def test_mock_llm_provider_returns_document_explanation(self):
        from ai.providers.mock import MockLLMProvider
        from ai.schemas import DOCUMENT_EXPLANATION_JSON_SCHEMA

        payload = MockLLMProvider().complete_json(
            system="Explain",
            user="CRP 12 mg/L",
            schema=DOCUMENT_EXPLANATION_JSON_SCHEMA,
            user_prompt="Explain in en",
            schema_name="document_explanation",
        )

        self.assertIn("summary_text", payload)
        self.assertIsInstance(payload["key_points"], list)
        self.assertIsInstance(payload["glossary"], dict)

    @override_settings(
        AI_OPENAI_API_KEY="test-key",
        AI_OPENAI_MODEL="gpt-test-llm",
        AI_OPENAI_TIMEOUT_SECONDS=12,
    )
    def test_openai_llm_provider_removes_unsupported_json_schema_keywords(self):
        from ai.providers.openai import OpenAILLMProvider
        from ai.schemas import EVENT_EXTRACTION_JSON_SCHEMA

        fake_client = FakeOpenAIClient(output_text='{"document_date":null,"suggested_title":null,"events":[]}')

        with patch("ai.providers.openai._build_client", return_value=fake_client):
            result = OpenAILLMProvider().complete_json(
                system="System prompt",
                user="OCR text",
                schema=EVENT_EXTRACTION_JSON_SCHEMA,
            )

        self.assertEqual(result["events"], [])
        call = fake_client.responses.calls[0]
        self.assertEqual(call["model"], "gpt-test-llm")
        sent_schema = call["text"]["format"]["schema"]
        serialized_schema = json.dumps(sent_schema)
        self.assertNotIn('"format"', serialized_schema)
        self.assertNotIn('"minLength"', serialized_schema)
        self.assertNotIn('"maxLength"', serialized_schema)
        self.assertNotIn('"minimum"', serialized_schema)
        self.assertNotIn('"maximum"', serialized_schema)
        self.assertEqual(EVENT_EXTRACTION_JSON_SCHEMA["properties"]["document_date"]["format"], "date")

    @override_settings(
        AI_OPENAI_API_KEY="test-key",
        AI_OPENAI_MODEL="gpt-test-llm",
        AI_OPENAI_TIMEOUT_SECONDS=12,
    )
    def test_openai_llm_provider_uses_explanation_prompt_and_schema_name(self):
        from ai.providers.openai import EVENT_EXTRACTION_USER_PROMPT, OpenAILLMProvider
        from ai.schemas import DOCUMENT_EXPLANATION_JSON_SCHEMA

        fake_client = FakeOpenAIClient(
            output_text=(
                '{"summary_text":"Summary","key_points":["Point"],'
                '"glossary":[{"term":"CRP","definition":"Definition"}]}'
            )
        )

        with patch("ai.providers.openai._build_client", return_value=fake_client):
            result = OpenAILLMProvider().complete_json(
                system="Explanation system",
                user="OCR text",
                schema=DOCUMENT_EXPLANATION_JSON_SCHEMA,
                user_prompt="Explain this document in ru.",
                schema_name="document_explanation",
            )

        self.assertEqual(result["summary_text"], "Summary")
        call = fake_client.responses.calls[0]
        self.assertEqual(call["text"]["format"]["name"], "document_explanation")
        sent_schema = call["text"]["format"]["schema"]
        glossary_schema = sent_schema["properties"]["glossary"]
        self.assertEqual(glossary_schema["type"], "array")
        self.assertEqual(glossary_schema["items"]["additionalProperties"], False)
        self.assertEqual(glossary_schema["items"]["required"], ["term", "definition"])
        user_text = call["input"][1]["content"][0]["text"]
        self.assertIn("Explain this document in ru.", user_text)
        self.assertNotIn(EVENT_EXTRACTION_USER_PROMPT, user_text)

    @override_settings(AI_OPENAI_API_KEY="test-key", AI_OPENAI_MODEL="gpt-test-llm")
    def test_openai_llm_provider_includes_api_error_body(self):
        from ai.providers.openai import OpenAIProviderError, OpenAILLMProvider
        from ai.schemas import EVENT_EXTRACTION_JSON_SCHEMA

        fake_client = FakeOpenAIClient(output_text="")
        fake_client.responses.error = FakeOpenAIAPIError(
            status_code=400,
            body={"error": {"message": "Invalid schema for response_format"}},
        )

        with patch("ai.providers.openai._build_client", return_value=fake_client):
            with self.assertRaises(OpenAIProviderError) as raised:
                OpenAILLMProvider().complete_json(
                    system="System prompt",
                    user="OCR text",
                    schema=EVENT_EXTRACTION_JSON_SCHEMA,
                )

        message = str(raised.exception)
        self.assertIn("OpenAI structured output request failed status=400", message)
        self.assertIn("Invalid schema for response_format", message)


class FakeOpenAIClient:
    def __init__(self, *, output_text):
        self.responses = FakeOpenAIResponses(output_text=output_text)
        self.audio = FakeOpenAIAudio()


class FakeOpenAIResponses:
    def __init__(self, *, output_text):
        self.output_text = output_text
        self.calls = []
        self.error = None

    def create(self, **kwargs):
        self.calls.append(kwargs)
        if self.error is not None:
            raise self.error
        return type("OpenAIResponse", (), {"output_text": self.output_text})()


class FakeOpenAIAudio:
    def __init__(self):
        self.transcriptions = FakeOpenAITranscriptions()


class FakeOpenAITranscriptions:
    def __init__(self):
        self.calls = []
        self.text = ""
        self.error = None

    def create(self, **kwargs):
        self.calls.append(kwargs)
        if self.error is not None:
            raise self.error
        return type("OpenAITranscription", (), {"text": self.text})()


class FakeOpenAIAPIError(Exception):
    def __init__(self, *, status_code, body):
        super().__init__("Bad request")
        self.status_code = status_code
        self.body = body
