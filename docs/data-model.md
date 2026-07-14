# MedStory — Data Model

> Companion to the [Technical Architecture](./technical-architecture.md) and
> [API Specification](./api-specification.md). Maps to Django models / PostgreSQL.

## 1. Overview

The data model captures the BRD's medical history domain (§8): symptoms, diagnoses,
medications, examinations, procedures, hospitalizations, treatment outcomes, plus the
documents they come from, a chronological timeline, and a continuously-updated summary
("Medical Memory").

Design choices:
- A **unified `MedicalEvent`** table powers the timeline; type-specific attributes live in a
  JSONB `attributes` column, with a few promoted columns for querying/sorting.
- **Document assets** remain on-device; the DB holds ordered asset metadata + extracted text.
- Every logical source (`Document`) produces **exactly one active `MedicalEvent`** or fails.
- **Processing state** is tracked explicitly so the client can poll and the pipeline can retry.
- Every row is **owned by a user** (and optionally a `Subject`) for strict data isolation.
- Soft-delete (`deleted_at`) + hard-delete support for GDPR erasure.

## 2. Entity-Relationship Diagram

```
                         ┌─────────────┐
                         │    User     │
                         └──────┬──────┘
                                │ 1
            ┌───────────────────┼───────────────────────────────┐
            │ N                 │ N                              │ N
      ┌─────▼──────┐     ┌──────▼───────┐                ┌───────▼────────┐
      │  Subject   │     │   Document   │                │ MedicalSummary │
      │ (patient   │     │              │                │  (versioned)   │
      │  profile)  │     └──────┬───────┘                └────────────────┘
      └─────┬──────┘            │ 1
            │                   │ N
            │            ┌──────▼────────────┐
            │            │ DocumentExplanation│
            │            └───────────────────┘
            │
            │ 1   N   ┌──────────────────┐  N        1  ┌──────────────┐
            └────────▶│   MedicalEvent   │◀─────────────│   Document   │
                      │ (timeline item)  │  source_doc  └──────────────┘
                      └────────┬─────────┘
                               │ N
                               │
                        ┌──────▼──────┐        ┌──────────────┐
                        │  EventTag   │───────▶│     Tag      │
                        └─────────────┘        └──────────────┘

      ┌────────────────┐
      │  ProcessingJob │  (tracks OCR/STT/LLM tasks; links to Document or Summary)
      └────────────────┘
```

## 3. Entities

### 3.1 User
Authentication + account ownership. Extends Django's auth user (email as username).

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| email | citext, unique | Login identifier |
| password | hashed | Django password hashing (Argon2/PBKDF2) |
| full_name | varchar | Optional display name |
| is_active | bool | |
| date_joined | timestamptz | |
| last_login | timestamptz | |
| locale | varchar(10) | For explanation/summary language |
| created_at / updated_at | timestamptz | |

### 3.2 Subject (Patient Profile)
Supports the secondary audience (e.g. a parent managing a child). Each user always has a
**default self-subject**; additional subjects are optional.

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| user_id | FK → User | Owner |
| display_name | varchar | e.g. "Myself", "Alex (son)" |
| relationship | enum | self, child, dependent, other |
| date_of_birth | date (nullable) | |
| biological_sex | enum: female, male (nullable) | For context only; not diagnostic |
| is_default | bool | The user's own profile |
| created_at / updated_at | timestamptz | |

### 3.3 Document
A medical file or audio note tracked by metadata. Binary lives on the user's device.

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| user_id | FK → User | |
| subject_id | FK → Subject | |
| title | varchar | User- or AI-derived |
| doc_type | enum | lab_result, report, prescription, procedure_summary, note, image, audio, other |
| mime_type | varchar | |
| local_uri_hint | varchar (nullable) | Client-supplied local identifier hint (not canonical for access) |
| size_bytes | bigint | |
| status | enum | pending_ingest, processing, processed, failed |
| extracted_text | text (nullable) | OCR/STT output |
| language | varchar(10) | Detected language |
| document_date | date (nullable) | Date on the document (for timeline placement) |
| error_message | text (nullable) | If status=failed |
| created_at / updated_at | timestamptz | |
| deleted_at | timestamptz (nullable) | Soft delete |

### 3.4 DocumentAsset
Ordered metadata for each original in a logical source bundle. A PDF/audio/text source normally has
one asset (text has none); a photographed multi-page document has multiple assets. Fields are
`document_id`, `position`, `file_name`, `mime_type`, `size_bytes`, and `content_hash`. Original bytes
and device paths are never stored by the backend.

### 3.5 MedicalEvent
The core timeline item. Source-backed captures have exactly one active event, enforced by a partial
unique constraint on `source_document_id`. Mixed-content sources use `medical_record` and retain
their supported facts inside structured attributes.

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| user_id | FK → User | |
| subject_id | FK → Subject | |
| source_document_id | FK → Document (nullable) | If derived from a document |
| event_type | enum | symptom, diagnosis, medication, examination, procedure, hospitalization, treatment_outcome, medical_record, note |
| title | varchar | Short label, e.g. "Started Mesalazine" |
| description | text (nullable) | Plain-language detail |
| event_date | date | Primary date (drives timeline ordering) |
| event_end_date | date (nullable) | For ranges (e.g. medication course, hospitalization) |
| attributes | JSONB | Type-specific structured fields (see §4) |
| source | enum | user_manual, ai_document, ai_voice |
| confidence | float (nullable) | AI extraction confidence (0–1) |
| created_at / updated_at | timestamptz | |
| deleted_at | timestamptz (nullable) | Soft delete |

Indexes: `(user_id, subject_id, event_date desc)`, `(event_type)`, GIN on `attributes`.

### 3.6 EventRevision
An AI-proposed revision stores `current_snapshot` and `suggested_changes` separately from the active
event. Its status is `pending`, `applied`, or `discarded`. Regeneration never overwrites user edits;
only explicitly selected fields are applied.

### 3.7 DocumentExplanation
LLM-produced plain-language explanation of a document (Scenario B).

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| document_id | FK → Document | |
| summary_text | text | Simplified explanation |
| key_points | JSONB | List of bullet points |
| glossary | JSONB | term → plain-language definition |
| model_name | varchar | Provider/model used |
| language | varchar(10) | |
| created_at | timestamptz | |

### 3.6 MedicalSummary (Medical Memory)
Versioned snapshot of the user's consolidated health story (Scenario D, BRD §8 Medical Memory
+ Summary Generation).

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| user_id | FK → User | |
| subject_id | FK → Subject | |
| version | int | Monotonic per subject |
| is_current | bool | Latest version flag |
| content | JSONB | Structured summary (sections below) |
| narrative_text | text | Doctor-ready prose summary |
| generated_from_event_count | int | Provenance |
| model_name | varchar | |
| language | varchar(10) | |
| created_at | timestamptz | |

`content` sections (per BRD §8 summary fields): `key_symptoms`, `major_diagnoses`,
`treatment_history`, `important_examinations`, `relevant_medications`.

### 3.7 VisitPreparation
One sensitive, user-authored note per subject for questions and concerns to discuss at a visit.
It is not AI input and is appended to a requested PDF export only when non-empty.

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| user_id | FK → User | Ownership isolation |
| subject_id | one-to-one FK → Subject | One note per subject |
| note | text | May be empty |
| created_at / updated_at | timestamptz | |

### 3.8 Tag & EventTag
Lightweight categorization / grouping (e.g. by condition).

| Tag field | Type | Notes |
|-----------|------|-------|
| id | UUID (PK) | |
| user_id | FK → User | |
| name | varchar | e.g. "IBS", "oncology" |
| color | varchar (nullable) | UI hint |

`EventTag` is a join table: `(event_id, tag_id)`.

### 3.9 ProcessingJob
Tracks async pipeline work for observability and retries.

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| user_id | FK → User | |
| job_type | enum | ingestion, explanation, summary |
| document_id | FK → Document (nullable) | Set for document ingestion/explanation jobs |
| summary_id | FK → MedicalSummary (nullable) | Set after a summary job succeeds |
| status | enum | queued, running, succeeded, failed, retrying |
| attempts | int | |
| error_message | text (nullable) | |
| started_at / finished_at | timestamptz (nullable) | |
| created_at / updated_at | timestamptz | |

### 3.9 AuditLog (privacy/compliance)
Append-only record of sensitive actions (delete, login). See
[security-privacy.md](./security-privacy.md).

| Field | Type | Notes |
|-------|------|-------|
| id | UUID (PK) | |
| user_id | FK → User (nullable, SET_NULL) | Cleared when an account is hard-deleted |
| action | varchar | e.g. account_delete, login |
| metadata | JSONB | Non-sensitive context; no raw health content/tokens |
| ip_address | inet (nullable) | |
| created_at | timestamptz | |

## 4. Type-Specific `attributes` (MedicalEvent.attributes JSONB)

Examples of structured fields per `event_type`. These are validated by serializers but stored
flexibly so the schema can evolve without migrations.

```jsonc
// medication
{ "name": "Mesalazine", "dose": "800mg", "frequency": "3x/day",
  "route": "oral", "outcome": "partial_relief", "prescriber": "Dr. X" }

// symptom
{ "name": "abdominal pain", "severity": "moderate", "location": "lower left",
  "frequency": "daily" }

// diagnosis
{ "name": "Ulcerative colitis", "icd10": "K51", "status": "active",
  "diagnosed_by": "gastroenterologist" }

// examination
{ "name": "Colonoscopy", "result_summary": "mild inflammation",
  "measurements": [{ "label": "CRP", "value": 12, "unit": "mg/L", "ref": "<5" }] }

// procedure
{ "name": "Biopsy", "location": "colon", "outcome": "benign" }

// hospitalization
{ "facility": "City Hospital", "reason": "flare-up", "nights": 3 }

// treatment_outcome
{ "treatment": "Mesalazine", "effectiveness": "ineffective", "notes": "switched therapy" }
```

## 5. Relationships Summary

- `User 1—N Subject`, `Document`, `MedicalEvent`, `MedicalSummary`, `Tag`, `ProcessingJob`.
- `Subject 1—N Document`, `MedicalEvent`, `MedicalSummary`.
- `Document 1—N MedicalEvent` (a document may yield several events).
- `Document 1—N DocumentExplanation` (typically 1; allows re-generation/versions).
- `MedicalEvent N—N Tag` via `EventTag`.
- `ProcessingJob` references a `Document` or `MedicalSummary`.

## 6. Data Lifecycle

- **Create**: events come from manual entry or the AI pipeline
  until the user reviews them).
- **Update**: users can edit AI-extracted events; summaries regenerate on change.
- **Soft delete**: `deleted_at` hides records while preserving referential history.
- **Hard delete (GDPR)**: account deletion purges DB rows. See
  [security-privacy.md](./security-privacy.md).

## 7. Indexing & Performance Notes

- Timeline query is the hottest path → composite index on `(user_id, subject_id, event_date)`.
- GIN index on `MedicalEvent.attributes` and on `extracted_text` (full-text) for search.
- `MedicalSummary.is_current` partial index for fast "latest summary" lookups.
- All large binaries are kept out of the DB and remain on-device.
