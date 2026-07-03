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
- **Idempotency**: mutating ingestion calls keyed by document ID; safe to retry.
- **Rate limiting**: stricter throttles on auth + AI-triggering endpoints (HTTP 429).

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
Initiates GDPR account + data deletion. → `202 { "status": "deletion_scheduled" }`.

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
Create a document metadata record (the binary stays on-device).
```jsonc
// Request
{ "title": "Lab results May", "doc_type": "lab_result", "mime_type": "application/pdf",
  "size_bytes": 482113, "document_date": "2026-05-12", "subject_id": "uuid?",
  "local_uri_hint": "app://documents/uuid-or-local-path" }
// 201 Response
{ "id": "uuid", "status": "pending_ingest" }
```

### POST /documents/{id}/ingest
Send file bytes for transient processing and enqueue the ingestion pipeline.
The backend does not persist the raw file.

`Content-Type: multipart/form-data`
```
file=<binary>; mime_type=application/pdf
```

Constraints:
- Max file size: **5 MB** (`413 file_too_large` beyond this limit).
- Allowed for images, PDFs, and audio types supported by the pipeline.

→ `202 { "id": "uuid", "status": "processing" }`

### GET /documents
List documents. Filters: `subject_id`, `doc_type`, `status`. Cursor paginated.

### GET /documents/{id}
```jsonc
{ "id": "uuid", "title": "...", "doc_type": "lab_result", "status": "processed",
  "document_date": "2026-05-12", "language": "en",
  "local_only": true,
  "extracted_text_available": true,
  "explanation_available": true,
  "event_count": 4,
  "created_at": "...", "updated_at": "..." }
```
`status` is polled by the client until `processed` or `failed`.

### DELETE /documents/{id}
Soft-deletes the document and its derived events (configurable). → `204`.

### POST /documents/upload-audio
Convenience endpoint for voice-first capture (`doc_type=audio`) with transient ingestion.
`multipart/form-data`, max file size **5 MB**.

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
Re-runs explanation (e.g. different language). → `202`.

## 6. Medical Events & Timeline

### GET /timeline
The primary chronological read model (Scenario E).
Filters: `subject_id`, `types` (comma list), `from`, `to` (dates), `tag`, `q` (text search).
Cursor paginated, default newest-first.
```jsonc
{ "results": [
    { "id": "uuid", "event_type": "medication", "title": "Started Mesalazine",
      "description": "...", "event_date": "2025-03-10", "event_end_date": null,
      "attributes": { "name": "Mesalazine", "dose": "800mg", "frequency": "3x/day" },
      "source": "ai_document", "source_document_id": "uuid",
      "confidence": 0.92, "is_confirmed": false, "tags": ["IBS"] }
  ],
  "next": "cursor...", "previous": null }
```

### POST /events
Manually create an event.
```jsonc
{ "event_type": "symptom", "title": "Abdominal pain",
  "event_date": "2026-06-01", "attributes": { "severity": "moderate" },
  "subject_id": "uuid?" }
```

### GET /events/{id} · PATCH /events/{id} · DELETE /events/{id}
Retrieve / update / soft-delete a single event.

### POST /events/{id}/confirm
Marks an AI-extracted event as reviewed/confirmed. → `200`.

### GET /events/search
Full-text + attribute search across history. Params: `q`, `types`, `subject_id`.
(Backs Scenario C — "which medications/treatments were tried".)

## 7. Medical Summary (Medical Memory — Scenario D)

### GET /summary
Returns the current consolidated summary for the subject. If no summary exists yet,
returns `404 { "error": { "code": "not_ready", ... } }`.
```jsonc
{ "id": "uuid", "version": 7, "is_current": true,
  "content": {
    "key_symptoms": [...], "major_diagnoses": [...], "treatment_history": [...],
    "important_examinations": [...], "relevant_medications": [...] },
  "narrative_text": "Patient is a 34-year-old with a 4-year history of ulcerative colitis...",
  "language": "en", "generated_from_event_count": 42, "created_at": "..." }
```

### POST /summary/regenerate
Enqueues a fresh summary build from confirmed current events.
→ `202 { "job_id": "uuid", "status": "queued" }`.

### GET /summary/versions
Lists historical summary versions (the story as it evolved over time).

### GET /summary/export
Doctor-ready export of the current summary. Param `format=pdf|json`.
Returns `application/pdf` bytes for PDF or inline JSON.

## 8. Jobs & Status

### GET /jobs/{id}
Poll an async job (used after regenerate / ingestions when a job_id is returned).
```jsonc
{ "id": "uuid", "job_type": "summary", "status": "running",
  "attempts": 1, "document_id": null, "summary_id": "uuid",
  "created_at": "...", "finished_at": null }
```

## 9. Data Export & Privacy (GDPR)

### POST /privacy/export
Requests a backend data export (events + document metadata + summaries + audit data).
→ `202 { "job_id": "uuid" }`; when ready, download via the job result URL.

### GET /privacy/export/{job_id}
Returns export status and, when ready, a short-lived bundle download URL.

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
| 413 | file_too_large | Upload exceeds limit |
| 429 | throttled | Rate limit hit |
| 500 | server_error | Unexpected |

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
| POST | /documents/{id}/ingest | Upload bytes transiently + trigger ingestion |
| GET | /documents | List documents |
| GET/DELETE | /documents/{id} | Read/delete document |
| POST | /documents/upload-audio | Voice capture |
| GET | /documents/{id}/explanation | Plain-language explanation |
| POST | /documents/{id}/explanation/regenerate | Re-explain |
| GET | /timeline | Chronological events |
| POST | /events | Create event |
| GET/PATCH/DELETE | /events/{id} | Manage event |
| POST | /events/{id}/confirm | Confirm AI event |
| GET | /events/search | Search history |
| GET | /summary | Current medical memory |
| POST | /summary/regenerate | Rebuild summary |
| GET | /summary/versions | Summary history |
| GET | /summary/export | Doctor-ready export |
| GET | /jobs/{id} | Poll async job |
| POST | /privacy/export | Request data export |
| GET | /privacy/export/{job_id} | Export status/download |
