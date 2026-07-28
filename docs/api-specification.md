# MedStory — API Specification (v1)

> REST API exposed by the Django + DRF backend. Companion to
> [Technical Architecture](./technical-architecture.md) and [Data Model](./data-model.md).
> The canonical machine-readable schema is auto-generated via `drf-spectacular` (OpenAPI) at
> `/api/schema/` with Swagger UI at `/api/docs/`.

## 1. Conventions

- **Base URL**: `https://<host>/api/v1`
- **Format**: JSON request/response; `Content-Type: application/json`.
- **Auth**: `Authorization: Bearer <access_token>` (JWT) on all endpoints except auth/registration.
- **IDs**: UUIDs.
- **Timestamps**: ISO 8601 UTC (e.g. `2026-06-25T14:30:00Z`).
- **Pagination**: cursor-based for lists → `?cursor=<opaque>&limit=<n>`; response includes
  `next` / `previous` cursors.
- **Filtering**: query params per endpoint (documented below).
- **Errors**: consistent envelope (see §8).
- **Idempotency**: mutating ingestion calls keyed by document ID; safe to retry. Exact-byte
  document and photo duplicates are also rejected per account once they have produced active events.
- **Rate limiting**: registration/login are 5/IP/hour, refresh/logout 20/IP/hour, and
  AI-triggering uploads/regenerations 10/user/hour; other traffic is 120/minute (HTTP 429).

## 2. Authentication

**Phase 0 status:** registration, login, refresh, logout, and authenticated `/me` are implemented.
Password reset endpoints are planned but not implemented yet.

### POST /auth/register
Create an account (email/password only).
```jsonc
// Request
{ "email": "user@example.com", "password": "••••••••", "full_name": "Jane Doe", "locale": "en" }
// 201 Response
{ "user": { "id": "uuid", "email": "user@example.com", "full_name": "Jane Doe",
    "locale": "en", "date_joined": "..." },
  "access": "jwt...", "refresh": "jwt..." }
```

### POST /auth/login
```jsonc
// Request
{ "email": "user@example.com", "password": "••••••••" }
// 200 Response
{ "access": "jwt...", "refresh": "jwt..." }
```

### POST /auth/refresh
```jsonc
{ "refresh": "jwt..." }  // → 200 { "access": "jwt...", "refresh": "jwt..."? }
```

### POST /auth/logout
Blacklists the refresh token. `{ "refresh": "jwt..." }` → `205`.

### POST /auth/password/reset/request
Planned.
`{ "email": "user@example.com" }` → `202` (always, to avoid email enumeration).

### POST /auth/password/reset/confirm
Planned.
`{ "token": "...", "new_password": "••••••••" }` → `200`.

## 3. Profile & Subjects

### GET /me
Returns the authenticated user.
```jsonc
{ "id": "uuid", "email": "...", "full_name": "...", "locale": "en", "date_joined": "..." }
```

### PATCH /me
Update `full_name`, `locale`. → `200` updated user.

### DELETE /me
Immediately hard-deletes the account and backend records. Optional body:
`{ "refresh": "jwt..." }` for best-effort refresh-token blacklist. → `204`.

### GET /subjects
List subjects (patient profiles). The default self-subject is always present.

### POST /subjects
```jsonc
{ "display_name": "Alex (son)", "relationship": "child", "date_of_birth": "2015-04-01" }
```

### GET /subjects/{id} · PATCH /subjects/{id} · DELETE /subjects/{id}
Standard retrieve/update/delete. The default subject cannot be deleted.

> All medical endpoints below accept `?subject_id=<uuid>`; if omitted, the default subject is used.

## 4. Documents

### POST /documents
Create a pending document metadata record. The original becomes server-authoritative only after a
successful ingest response.
```jsonc
// Request
{ "title": "Lab results May", "doc_type": "lab_result", "mime_type": "application/pdf",
  "size_bytes": 482113, "document_date": "2026-05-12", "subject_id": "uuid?",
  "local_uri_hint": "" }
// 201 Response
{ "id": "uuid", "status": "pending_ingest" }
```

### POST /documents/{id}/ingest
Validate, malware-scan, encrypt, and retain PDF/image originals, then enqueue processing. `202` is
returned only after Garage acknowledges ciphertext and the ordered assets are committed.

`Content-Type: multipart/form-data`
```
file=<binary>; mime_type=application/pdf|image/jpeg|image/png|image/heic|image/heif
# or, for pages of one photographed document:
files=<image page 1>; files=<image page 2>; ...
```

Constraints:
- Max PDF/image bundle size: **25 MB** (`413 file_too_large` beyond this limit).
- Allowed retained types are PDF, JPEG, PNG, HEIC, and HEIF. Declared MIME and magic bytes must
  match; scanner outage fails closed.
- Distinct retained plaintext is limited to **2 GB per account**. Same-user identical assets share
  a blob and count once; comparisons and deduplication never cross accounts.
- Multi-asset bundles accept images only and preserve multipart order as page order.
- Non-audio documents allow PDFs and image files.
- Audio documents (`doc_type=audio`) allow `audio/mpeg`, `audio/mp3`, `audio/mp4`,
  `audio/mpga`, `audio/m4a`, `audio/wav`, and `audio/webm`.

→ `202 { "id": "uuid", "status": "processing", "event_id": null, "assets": [...] }`

Processing succeeds only after exactly one active event is created atomically. A terminal document
therefore has either `status=processed` with one `event_id`, or `status=failed` with no event.

Identical assets can back multiple logical documents for the same account via reference-counted
blob reuse. The Celery message contains document/job/blob identifiers only—never raw bytes or base64.

If an image/PDF has no readable text, processing finishes with `status: "failed"` and
`error_message: "document_unreadable"`. If the extracted content is not a medical document,
it finishes with `error_message: "document_not_medical"`. Neither outcome creates timeline events.

### GET /documents
List documents. Filters: `subject_id`, `doc_type`, `status`, and `q`. `q` searches document
titles and extracted text while list responses continue to return metadata only. Cursor paginated.

### GET /documents/{id}
```jsonc
{ "id": "uuid", "title": "...", "doc_type": "lab_result", "status": "processed",
  "document_date": "2026-05-12", "language": "en",
  "local_only": false,
  "extracted_text_available": true,
  "explanation_available": true,
  "event_count": 1, "event_id": "uuid",
  "assets": [{ "id": "uuid", "position": 1, "file_name": "page-1.jpg",
    "mime_type": "image/jpeg", "size_bytes": 12345, "available": true }],
  "created_at": "...", "updated_at": "..." }
```
`status` is polled by the client until `processed` or `failed`.

### DELETE /documents/{id}
Immediately hides the document and derived events, decrements blob references, destroys the wrapped
blob key at the final reference, and records an opaque durable Garage deletion job. → `204`.
Deleting only a timeline event does not delete its document or original.

### POST /documents/{id}/retry-processing
Retries OCR/AI from an already retained PDF/image without another upload. Valid sessions may retry
only their own document. A missing original or audio source returns `409 original_unavailable`.
Processing/broker failures preserve Retry/Delete access.

→ `202 { "id": "uuid", "status": "processing" }`

### GET /documents/{id}/assets/{asset_id}/content
Authenticated online access to a retained original. Both path IDs are scoped to `request.user`;
unknown, guessed, cross-user, cross-document, deleted, and transient assets return `404`.

Query: `disposition=inline|attachment` (default `inline`). MedStory verifies/decrypts and streams the
content with `Cache-Control: private, no-store` and `X-Content-Type-Options: nosniff`. The response
never includes a Garage URL, key, credential, or presigned URL. Integrity/context/key failures fail
closed.

### POST /documents/upload-audio
Convenience endpoint for voice-first capture (`doc_type=audio`) with encrypted transient staging.
`multipart/form-data`, max file size **5 MB**. Creates the audio document and enqueues
STT → LLM structuring in one request. The server object is deleted after processing; abandoned
staging objects are removed by scheduled cleanup.

Fields:
- `file` required.
- `title`, `subject_id`, `mime_type`, `language`, `local_uri_hint`, and `document_date`
  optional. `language` is a source/transcription hint where applicable; the user's saved profile
  locale is authoritative for generated document titles, events, explanations, and summaries.
- `title` defaults to `"Voice note"`; subject defaults to the user's default self-subject.

Allowed audio types: `audio/mpeg`, `audio/mp3`, `audio/mp4`, `audio/mpga`, `audio/m4a`,
`audio/wav`, and `audio/webm`. Generic `audio/*` uploads are accepted only when the filename
extension maps safely to one of those types.

→ `202 { "id": "uuid", "doc_type": "audio", "status": "processing" }`

### POST /capture/transcribe
Transient voice transcription for the editable capture draft. `multipart/form-data` with required
`file` and optional `mime_type` and `language`; the 5 MB audio limit and supported types match
`/documents/upload-audio`. Audio bytes are discarded after transcription and no document, event,
or audio record is created.

→ `200 { "transcript": "..." }`; unreadable audio returns `422` with `audio_unreadable`.

### POST /capture/notes
Starts asynchronous extraction from final user-edited text.

```jsonc
{ "text": "...", "subject_id": "uuid?", "language": "en?" }
```

→ `202` with the processing note document. A non-medical or empty draft becomes `failed` and
creates no medical events. If no event date is supplied or deduced, extraction defaults to the
server's current local date (UTC in the current deployment configuration).

## 5. Document Explanations (Scenario B)

### GET /documents/{id}/explanation
```jsonc
{ "document_id": "uuid",
  "summary_text": "This is a blood test. Most values are normal; CRP is slightly high...",
  "key_points": ["CRP is mildly elevated, which can indicate inflammation", "..."],
  "glossary": { "CRP": "C-reactive protein, a marker of inflammation" },
  "language": "en", "created_at": "..." }
```
Returns `404` (with `processing` hint) until generated.

### POST /documents/{id}/explanation/regenerate
Re-runs the explanation in the user's currently selected profile locale. → `202`.

## 6. Medical Events & Timeline

### GET /timeline
The primary chronological read model (Scenario E).
Filters: `subject_id`, `types` (comma list), `from`, `to` (dates), `tag`, `q` (text search),
Cursor paginated, default newest-first.
```jsonc
{ "results": [
    { "id": "uuid", "event_type": "medication", "title": "Started Mesalazine",
      "description": "...", "event_date": "2025-03-10", "event_end_date": null,
      "attributes": { "name": "Mesalazine", "dose": "800mg", "frequency": "3x/day" },
      "source": "ai_document", "source_document_id": "uuid",
      "confidence": 0.92, "tags": ["IBS"] }
  ],
  "next": "cursor...", "previous": null }
```
For `ai_voice` and source-backed text events, the event detail response also includes `source_text`.
It also includes `source_asset_count` and the latest `pending_revision` when present.

### GET/POST /events/{id}/revisions
`POST` reprocesses the immutable source into a pending draft revision. The active event is not
changed. `GET` lists recent revisions.

### POST/DELETE /events/{id}/revisions/{revision_id}
`POST { "fields": ["title", "description"] }` applies only selected suggested fields. `DELETE`
discards a pending revision and keeps the current event unchanged.

### POST /events
Manually create an event.
```jsonc
{ "event_type": "symptom", "title": "Abdominal pain",
  "event_date": "2026-06-01", "attributes": { "severity": "moderate" },
  "subject_id": "uuid?" }
```

### GET /events/{id} · PATCH /events/{id} · DELETE /events/{id}
Retrieve / update / soft-delete a single event.

### GET /events/search
Full-text + attribute search across history. Params: `q`, `types`, `subject_id`.
(Backs Scenario C — "which medications/treatments were tried".)

## 7. Medical Summary (Medical Memory — Scenario D)

### GET /summary
Returns the current structured visit summary for the subject. If no summary exists yet,
returns `404 { "error": { "code": "not_ready", ... } }`.
```jsonc
{ "id": "uuid", "version": 7, "is_current": true,
  "content": {
    "current_concerns": [
      { "text": "Recurring abdominal pain", "detail": "",
        "sources": [{
          "event_id": "event-uuid", "title": "Abdominal pain", "event_date": "2026-06-01",
          "document_title": "Clinic note", "source_page_positions": [1] }] }
    ],
    "important_diagnoses_and_findings": [], "allergies": [], "current_medications": [],
    "important_test_results": [], "previous_treatments_and_outcomes": [],
    "procedures_and_hospitalizations": [] },
  "narrative_text": "",
  "language": "en", "generated_from_event_count": 42, "created_at": "..." }
```

### POST /summary/regenerate
Enqueues a fresh summary build from all active, non-deleted events for the subject. This endpoint
is the only summary-generation trigger; event creation, editing, revision, or deletion does not
regenerate automatically. The existing current summary remains readable while the job runs and
also remains current if generation fails.
→ `202 { "job_id": "uuid", "status": "queued" }`.

### GET /summary/versions
Lists historical summary versions (the story as it evolved over time).

### GET /summary/export
Doctor-ready export of the current summary. Param `format=pdf|json`.
Source actions are an in-app, phone-only experience and are not embedded as document links in an
export.
Returns `application/pdf` bytes for PDF or inline JSON.

### GET/PUT /visit-preparation
Gets or updates the authenticated user's saved free-text visit reason for a subject.
Pass `subject_id` as a query parameter (or omit it for the default subject). `PUT`
accepts `{ "reason": "Persistent abdominal pain" }`; an empty reason is valid and non-empty values
are limited to 300 characters. On refresh, this value is treated as untrusted prioritization-only
context: it cannot supply medical facts or alter the summary contract.
Responses expose the canonical `reason` field, for example
`{ "id": "uuid", "subject_id": "uuid", "reason": "Persistent abdominal pain", ... }`.

## 8. Jobs & Status

### GET /jobs/{id}
Poll an async job (used after regenerate / ingestions when a job_id is returned).
```jsonc
{ "id": "uuid", "job_type": "summary", "status": "running",
  "attempts": 1, "document_id": null, "summary_id": "uuid",
  "created_at": "...", "finished_at": null }
```

## 9. Privacy (GDPR)

`DELETE /me` revokes access, destroys all wrapped blob keys, records account-independent opaque
Garage deletion jobs, and removes the account data. Cleanup retries survive removal of the user row.
Garage object version retention is disabled so erasure does not leave hidden versions.

> See [security-privacy.md](./security-privacy.md) for retention, encryption, and erasure details.

## 10. Error Format

All errors share one envelope:
```jsonc
{ "error": {
    "code": "validation_error",          // machine-readable
    "message": "event_date is required.", // human-readable
    "details": { "event_date": ["This field is required."] }, // optional, field-level
    "request_id": "req_abc123" } }
```

| HTTP | code examples | Meaning |
|------|---------------|---------|
| 400 | validation_error | Malformed/invalid input |
| 401 | not_authenticated, token_expired | Missing/invalid JWT |
| 403 | permission_denied | Not the owner of the resource |
| 404 | not_found, not_ready | Missing, or AI result not yet generated |
| 409 | conflict | e.g. document already completed |
| 413 | file_too_large, original_storage_quota_exceeded | Upload or account quota exceeds limit |
| 422 | malware_detected, original_integrity_error | Content rejected or ciphertext verification failed |
| 429 | throttled | Rate limit hit |
| 503 | malware_scanner_unavailable, original_storage_unavailable | Required private-storage dependency unavailable |
| 500 | server_error | Unexpected |

Throttled responses include a `Retry-After` header and
`error.details.retry_after_seconds`.

## 11. Endpoint Summary

| Method | Path | Purpose |
|--------|------|---------|
| POST | /auth/register | Sign up |
| POST | /auth/login | Log in |
| POST | /auth/refresh | Refresh access token |
| POST | /auth/logout | Invalidate refresh token |
| POST | /auth/password/reset/request | Start password reset (planned) |
| POST | /auth/password/reset/confirm | Complete password reset (planned) |
| GET/PATCH/DELETE | /me | Profile / account deletion |
| GET/POST | /subjects | List/create patient profiles |
| GET/PATCH/DELETE | /subjects/{id} | Manage a profile |
| POST | /documents | Create document metadata |
| POST | /documents/{id}/ingest | Validate, encrypt, retain originals + trigger processing |
| GET | /documents | List documents |
| GET/DELETE | /documents/{id} | Read/delete document |
| POST | /documents/{id}/retry-processing | Retry from retained original |
| GET | /documents/{id}/assets/{asset_id}/content | Authenticated decrypted original stream |
| POST | /documents/upload-audio | Voice capture |
| POST | /capture/transcribe | Transcribe ephemeral voice draft |
| POST | /capture/notes | Process final edited note |
| GET | /documents/{id}/explanation | Plain-language explanation |
| POST | /documents/{id}/explanation/regenerate | Re-explain |
| GET | /timeline | Chronological events |
| POST | /events | Create event |
| GET/PATCH/DELETE | /events/{id} | Manage event |
| GET | /events/search | Search history |
| GET | /summary | Current medical memory |
| POST | /summary/regenerate | Rebuild summary |
| GET | /summary/versions | Summary history |
| GET | /summary/export | Doctor-ready export |
| GET/PUT | /visit-preparation | Saved per-subject reason for visit |
| GET | /jobs/{id} | Poll async job |
