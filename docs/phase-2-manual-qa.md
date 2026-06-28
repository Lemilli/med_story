# MedStory Phase 2 Manual QA Script

This script verifies the Phase 2 exit path with mock providers:
upload a PDF/image document, process it transiently, create AI-suggested events, and confirm one
on the timeline.

## Preconditions

- Backend and worker run with `AI_OCR_PROVIDER=mock`, `AI_LLM_PROVIDER=mock`, and
  `AI_STT_PROVIDER=mock`.
- A test user can register/login and has a default subject.
- Document endpoints are integrated in the router:
  `POST /api/v1/documents`, `POST /api/v1/documents/{id}/ingest`,
  `GET /api/v1/documents/{id}`, and `GET /api/v1/timeline`.
- The mock providers recognize the fixture content in
  `backend/medical/fixtures/phase2/lab_result_basic.txt` and
  `backend/medical/fixtures/phase2/prescription_basic.txt`.

## Happy Path

1. Register or log in as a synthetic QA user.
2. Create document metadata with `doc_type=lab_result`, `mime_type=application/pdf`,
   `size_bytes` matching the test payload, and no `subject_id`.
3. Confirm the response is `201` with `status=pending_ingest` and a document `id`.
4. Upload the fixture-derived PDF/image bytes to `POST /api/v1/documents/{id}/ingest`.
5. Confirm the ingest response is `202` with `status=processing` and no raw file URL/path.
6. Poll `GET /api/v1/documents/{id}` until `status=processed`.
7. Confirm the document detail has `local_only=true`, `extracted_text_available=true`,
   `explanation_available=false`, and `event_count >= 1`.
8. Open `GET /api/v1/timeline` for the same subject.
9. Confirm at least one event has `source=ai_document`, `is_confirmed=false`,
   non-null `confidence`, and `source_document_id` equal to the uploaded document id.
10. Call `POST /api/v1/events/{id}/confirm` for the AI event.
11. Refresh the timeline and confirm the same event now has `is_confirmed=true`.

## Negative Checks

- Upload `backend/medical/fixtures/phase2/unsupported_invalid_file.bin` as
  `application/octet-stream` or `text/plain`; expect the documented validation error and no event.
- Try an audio MIME type such as `audio/mpeg`; expect rejection in Phase 2 because voice capture
  is deferred to Phase 5.
- Upload a file larger than 5 MB; expect `413 file_too_large`.
- Repeat ingest for the same processed document; expect deterministic behavior and no duplicate
  timeline events.
- Attempt to read or ingest another user's document id; expect `403` or `404`.

## Privacy Checks

- Inspect backend storage and responses: no raw upload file is persisted or returned.
- Inspect API and worker logs: logs contain request/document/job ids and status metadata only, not
  extracted text, lab values, medication names, or free-form health content.
- Confirm OCR/LLM/STT provider calls originate from backend worker code only; the Flutter client
  never calls AI providers directly.

## Current Integration Status

As of this documentation update, the repo has Phase 2 model/serializer work in progress, but the
document API routes and ingest task must still be integrated before this script can be executed
end-to-end. Use this script as the final main-branch verification checklist once Agents A-E land.
