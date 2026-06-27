# MedStory — Phase 2 Ingestion Breakdown

> Parallel implementation plan for Phase 2 from [MVP Roadmap](./mvp-roadmap.md): documents,
> transient ingestion, OCR/text extraction, LLM structuring, and confirmable AI events.

## Scope Decisions

- Phase 2 is limited to Scenario A: upload/capture a document and see extracted,
  confirmable events on the timeline.
- Plain-language document explanations stay deferred to Phase 3. Do not build explanation
  generation or explanation UI in this phase.
- OCR and LLM integrations are mock-first: implement provider interfaces and deterministic
  local/mock providers before wiring real vendors.
- Frontend capture covers file picking plus photo/image capture. Voice capture remains Phase 5.
- Raw files remain local-only on device. Backend receives bytes transiently and stores metadata,
  extracted text, processing status, and AI-suggested events.

## Target Exit Path

1. User selects a PDF/image or takes a photo in the Flutter app.
2. App saves the file locally, creates backend document metadata, and uploads bytes once for
   transient ingestion.
3. Backend validates ownership, type, and size, then enqueues a Celery task.
4. Worker extracts text through the OCR/text provider and structures events through the LLM
   provider.
5. Backend stores `Document` metadata/status and creates `MedicalEvent` rows with
   `source=ai_document`, `is_confirmed=false`, `confidence`, and `source_document`.
6. App polls document status, refreshes timeline, and shows AI-suggested events with a confirm
   action.

## Parallel Workstreams

### Agent A — Backend Document Model & API

**Goal:** Add the document metadata surface and ownership-safe REST API.

**Can start immediately.**

Tasks:
- Add `Document` model to `backend/medical/models.py` with the fields from
  [data-model.md](./data-model.md): owner, subject, title, doc type, MIME type, local URI hint,
  size, status, extracted text, language, document date, error message, timestamps, and soft delete.
- Add `source_document` FK to `MedicalEvent`.
- Add migrations and admin registration.
- Add serializers for create/list/detail responses.
- Add endpoints:
  - `POST /api/v1/documents`
  - `GET /api/v1/documents`
  - `GET /api/v1/documents/{id}`
  - `DELETE /api/v1/documents/{id}`
- Enforce per-user and per-subject isolation using the same queryset pattern as Phase 1.
- Keep API responses aligned with [api-specification.md](./api-specification.md), excluding
  explanation fields for now or returning `explanation_available=false`.

Acceptance criteria:
- Users can create, list, retrieve, and soft-delete only their own documents.
- Creating a document without `subject_id` assigns the default subject.
- Deleting a document hides it from lists and hides or soft-deletes derived events.
- OpenAPI schema includes document endpoints.

Suggested tests:
- Document CRUD ownership isolation.
- Default subject resolution.
- Soft delete behavior for documents and derived events.
- Serializer validation for document type, MIME type, size, and status.

Handoff:
- Publish serializer field names and response examples for Agent E.
- `source_document` must be ready before Agent C creates AI-derived events.

### Agent B — Backend Ingest Endpoint & Job Tracking

**Goal:** Accept transient uploads, validate them, and hand work to Celery without persisting raw
files.

**Can start after Agent A has the `Document` model shape, or work against a short-lived branch
stub.**

Tasks:
- Add `ProcessingJob` model or a minimal Phase 2 job/status implementation if the full model is
  too large for this phase.
- Add `POST /api/v1/documents/{id}/ingest` multipart endpoint.
- Enforce max upload size of 5 MB.
- Allow PDF and image MIME types for Phase 2. Reject audio until Phase 5.
- Set document status transitions:
  - `pending_ingest` -> `processing`
  - `processing` -> `processed`
  - `processing` -> `failed`
- Enqueue Celery ingestion task with `document_id`, user/subject context, MIME type, and transient
  bytes or a short-lived broker-safe payload.
- Make ingest retry-safe by document ID and prevent duplicate event creation on repeated calls.

Acceptance criteria:
- Ingest returns `202` quickly and never writes raw upload bytes to durable backend storage.
- Oversized or unsupported files return the documented error envelope.
- Re-ingesting an already processing/processed document is deterministic and does not duplicate
  events.
- Failed tasks leave `Document.error_message` populated without health content in logs.

Suggested tests:
- Multipart ingest happy path with mocked Celery task enqueue.
- 413 for files above 5 MB.
- 400/415-style validation for unsupported MIME types.
- 403/404 isolation when ingesting another user's document.
- Idempotency and duplicate-event prevention.

Handoff:
- Provide polling semantics and status/error examples for Agent E.
- Provide task invocation contract for Agent C.

### Agent C — AI Pipeline, Mock Providers & Event Creation

**Goal:** Implement deterministic mock-first ingestion pipeline that creates AI-suggested events.

**Can start immediately using existing `backend/ai/providers` skeleton, then integrate with Agent B.**

Tasks:
- Add structured output schema validation for event extraction.
- Improve mock OCR provider so tests can extract predictable text from simple text-like uploads or
  fixture bytes.
- Improve mock LLM provider so known fixture text produces deterministic candidate events.
- Add prompt files or prompt constants for structuring, with the guardrails from
  [ai-pipeline.md](./ai-pipeline.md).
- Implement Celery task orchestration:
  - validate document is owned by the requesting user;
  - extract text;
  - store `Document.extracted_text` and language;
  - call LLM structuring provider;
  - validate structured output;
  - create `MedicalEvent` rows as unconfirmed AI suggestions;
  - mark document processed or failed.
- Store provider/model/prompt metadata where the current models allow it; if not, document the
  gap for Phase 3/provider hardening.
- Add no-advice/no-diagnosis guardrails to prompts and tests for obviously unsafe output.

Acceptance criteria:
- A deterministic fixture document creates at least one unconfirmed `MedicalEvent`.
- Events link back to `source_document`, include confidence, and appear in `/timeline`.
- Invalid provider output fails gracefully without creating partial invalid events.
- Re-running ingestion for the same document does not duplicate events.

Suggested tests:
- Unit tests for schema validation.
- Unit tests for mock provider outputs.
- Celery task tests for processed, failed, and idempotent paths.
- Timeline test proving AI-suggested events are visible and unconfirmed.

Handoff:
- Share fixture text and expected event JSON with Agent F for end-to-end tests.
- Share confidence and status semantics with Agent E for UI states.

### Agent D — Frontend Document Domain, API & Local File Handling

**Goal:** Add Flutter document models, API client methods, repositories, and local file persistence.

**Can start once Agent A publishes the document response fields; otherwise use documented API
contracts.**

Tasks:
- Add `file_picker` and `image_picker` dependencies through the package manager.
- Add document domain models and DTOs using `freezed`/`json_serializable`.
- Add `DocumentApi` methods:
  - create metadata;
  - ingest multipart file;
  - list documents;
  - retrieve document detail;
  - delete document.
- Add repository that saves selected files/images into app-sandboxed local storage before upload.
- Persist local URI hints only as client-owned references; do not rely on backend as a file store.
- Add Drift tables/cache only if needed for Phase 2 UX; otherwise keep document list remote-first
  and avoid unnecessary local schema churn.
- Map backend errors to existing `AppFailure` patterns.

Acceptance criteria:
- Repository can save a local file/image, create document metadata, upload bytes, and poll status.
- Auth interceptor works for multipart requests.
- No visible strings are hardcoded; new UI strings are in English and Russian ARB files.
- Logout clears any Phase 2 local metadata/cache that belongs to the authenticated session.

Suggested tests:
- DTO serialization tests.
- Repository tests with mocked API and local file abstraction.
- Error mapping tests for file too large, unsupported MIME, auth, and failed processing.

Handoff:
- Expose a stable controller API for Agent E.
- Confirm dependency additions and required platform permissions for file/photo picking.

### Agent E — Frontend Capture, Polling & Confirm UX

**Goal:** Turn the placeholder capture screen into a working document ingestion flow and surface
AI suggestions on the timeline.

**Can start after Agent D defines repository/controller APIs and Agent A/B confirm response fields.**

Tasks:
- Build `documentUploadControllerProvider` state machine:
  - `idle`
  - `selecting`
  - `savingLocal`
  - `creating`
  - `ingesting`
  - `processing`
  - `done`
  - `failed`
- Update capture screen actions:
  - file picker for PDFs/images;
  - image/photo capture;
  - voice remains visible as planned/later or hidden until Phase 5, depending on UX preference.
- Add progress and retry UI for failed ingestion.
- Poll `GET /documents/{id}` until `processed` or `failed`.
- Refresh timeline when processing completes.
- Ensure AI-suggested timeline cards are visually distinct and expose a confirm action using
  existing `POST /events/{id}/confirm`.
- Add document list/detail only to the extent needed to observe ingestion history in Phase 2.

Acceptance criteria:
- User can complete file/image capture from the app and return to the timeline.
- Processing state survives leaving the capture tab during the current app session.
- Timeline clearly marks unconfirmed AI events and lets the user confirm them.
- Errors explain what happened without exposing backend internals or medical content.
- UI remains localized and accessible with semantic labels and 48dp tap targets.

Suggested tests:
- Controller state-machine unit tests.
- Widget tests for capture idle/progress/error/done states.
- Widget test for AI-suggested event badge and confirm action.
- Timeline refresh test after ingestion completion.

Handoff:
- Coordinate with Agent F on the happy-path scenario test.
- Feed UX copy additions back to docs if behavior differs from the plan.

### Agent F — Contract, QA & Documentation

**Goal:** Keep the parallel branches aligned and verify the end-to-end exit scenario.

**Can start immediately with docs and update as other agents land work.**

Tasks:
- Update [api-specification.md](./api-specification.md) if implementation details differ from the
  current contract.
- Update [data-model.md](./data-model.md) if `ProcessingJob`, document status, or metadata fields
  are scoped down for Phase 2.
- Add/update OpenAPI validation in CI if existing checks support it.
- Create a small golden fixture set:
  - one lab-result-like text fixture;
  - one prescription-like text fixture;
  - one unsupported/invalid file fixture.
- Define manual QA script for the target exit path.
- Verify privacy constraints from [security-privacy.md](./security-privacy.md): no raw files in
  backend storage, no health content in logs, provider calls backend-only.
- Keep [mvp-roadmap.md](./mvp-roadmap.md) updated once Phase 2 is implemented and verified.

Acceptance criteria:
- Docs and OpenAPI match implemented endpoints.
- End-to-end happy path is covered by automated tests where practical and a manual QA script.
- The Phase 2 exit criteria can be demonstrated with mock providers.
- Known gaps are explicit and assigned to Phase 3, Phase 5, or Phase 6.

Suggested tests/checks:
- Backend test suite.
- Migration drift check.
- OpenAPI schema generation/validation.
- Flutter `flutter analyze` and `flutter test`.
- Manual app run through file/image capture to timeline confirmation.

## Recommended Parallelization Plan

Start together:
- Agent A: document model/API.
- Agent C: mock provider and structuring pipeline internals.
- Agent F: contract fixtures, QA plan, and doc alignment.

Start once contracts stabilize:
- Agent B: ingest endpoint and Celery task integration.
- Agent D: frontend document API/repository/local files.

Start after backend/frontend contracts are usable:
- Agent E: capture UX, polling, timeline refresh, and confirm flow.

Integration order:
1. Merge Agent A before Agent B/C integration.
2. Merge Agent C pipeline tests before connecting real ingest.
3. Merge Agent B once `POST /documents/{id}/ingest` works with mock providers.
4. Merge Agent D before Agent E UI work.
5. Merge Agent E with Agent F's end-to-end scenario checks.

## Shared Contracts Agents Must Not Break

- Backend does not persist raw files.
- AI-derived events are suggestions until confirmed.
- `source=ai_document`, `is_confirmed=false`, and `confidence` are required for extracted events.
- All medical records are scoped by `user_id` and `subject_id`.
- Client-visible text is localized in English and Russian.
- No diagnosis, treatment recommendations, prescription generation, or "AI doctor" framing.
- Logs and errors must not include raw health content.
- Real OCR/LLM vendors are out of scope for the first Phase 2 implementation pass.

## Open Implementation Notes

- The current backend already has an `ai/providers` skeleton with mock provider classes.
- The current frontend already has a `capture` feature placeholder, timeline/event flows, Drift,
  and the confirm event endpoint wired at the API level.
- The roadmap defers document explanations to Phase 3, even though the AI pipeline doc describes
  explanations as part of the longer ingestion pipeline. Treat explanation work as a future
  extension unless this plan is revised.
- If task payload size makes transient bytes through Celery impractical, use a short-lived,
  non-durable handoff mechanism and document the security/privacy trade-off before implementation.
