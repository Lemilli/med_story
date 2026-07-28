# MedStory — Technical Architecture

> Companion to the [Business Requirements Document](../business_requirements.md).
> See also: [Data Model](./data-model.md), [API Spec](./api-specification.md),
> [Frontend Architecture](./frontend-architecture.md), [AI Pipeline](./ai-pipeline.md),
> [Security & Privacy](./security-privacy.md).

## 1. Architectural Goals

The architecture is driven directly by the BRD's principles and non-functional requirements:

| BRD Driver | Architectural Implication |
|-----------|---------------------------|
| Simplicity & low data-entry burden | AI/OCR/STT ingestion pipeline that auto-structures raw input |
| Long-term value (years of data) | Server-retained encrypted originals, scalable timeline queries, manually refreshed visit summary |
| Clarity for non-medical users | Server-side LLM "explanation" + "summary" generation services |
| Privacy & user control | Per-user data isolation, encryption, and account deletion |
| Voice-first | Audio capture → transient upload → STT → structuring pipeline |
| Trust (organizer, not provider) | No diagnostic/recommendation logic; AI is explanatory only |

### Non-Goals (per BRD §10)

No diagnosis, treatment recommendations, prescription generation, telemedicine, appointment
booking, provider communication, wearables, insurance, or hospital integrations in the MVP.

## 2. System Overview

MedStory is a **mobile client + API backend + asynchronous AI pipeline**.

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         Flutter App (iOS / Android)                        │
│ UI · State (Riverpod) · Metadata cache · Temporary files · Secure tokens   │
└───────────────────────────────┬──────────────────────────────────────────┘
                                 │ HTTPS / REST (JSON) + JWT
                                 ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                          API Gateway (Nginx / TLS)                         │
└───────────────────────────────┬──────────────────────────────────────────┘
                                 ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                 Django + DRF (Gunicorn/Uvicorn workers)                    │
│  Auth · Documents · Events · Timeline · Summary · Explanations · Profile   │
└───────┬───────────────────────────────┬────────────────────────────────────┘
        │                               │
        ▼                               ▼
┌───────────────┐               ┌──────────────────┐
│  PostgreSQL   │               │      Redis        │
│ (structured)  │               │ (broker + cache)  │
└───────────────┘               └────────┬─────────┘
        │
        ▼
┌───────────────────────────────┐
│ Garage (private S3 API only)  │
│ MedStory-encrypted ciphertext │
└───────────────────────────────┘
                                          │ tasks
                                          ▼
                                          ┌───────────────────────────────┐
                                          │       Celery Workers          │
                                          │  OCR · STT · LLM structuring  │
                                          │  · explanation · summary      │
                                          └───────────────┬───────────────┘
                                                          │ outbound HTTPS
                                                          ▼
                                          ┌───────────────────────────────┐
                                          │   External AI Providers       │
                                          │  LLM API · OCR API · STT API  │
                                          │  (behind provider abstraction)│
                                          └───────────────────────────────┘
```

## 3. Components

### 3.1 Flutter Mobile Client
- Targets iOS and Android from a single codebase.
- Talks to the backend exclusively via the REST API over HTTPS.
- Stores JWTs in platform secure storage (Keychain / Keystore).
- Caches the timeline and summary locally with Drift for fast, partly-offline reads.
- Handles capture: document scan/photo, file upload, and voice recording.
- Keeps document/image capture files only until durable upload acknowledgement. Originals are
  online-only and fetched through authenticated MedStory endpoints; voice recordings remain
  temporary and are deleted after successful transcription.
- Details in [frontend-architecture.md](./frontend-architecture.md).

### 3.2 API Backend (Django + DRF)
The synchronous request/response surface. Responsibilities:
- **Auth**: registration, login, JWT issue/refresh; password reset is planned.
- **Documents**: metadata, validated encrypted-original ingestion, authenticated content streaming,
  retry, deletion, and status polling.
- **Medical Events**: CRUD for the structured medical history.
- **Timeline**: chronological, paginated read model.
- **Prepare for a Visit**: read the latest structured, source-linked summary; explicitly trigger regeneration.
- **Explanations**: request and retrieve simplified document explanations.
- **Profile**: user profile and (optionally) managed subjects (e.g. a child).

The backend is **stateless** behind the load balancer; server state lives in
PostgreSQL / Redis, enabling horizontal scaling.

### 3.3 Asynchronous AI Pipeline (Celery + Redis)
All long-running and external-AI work is offloaded to Celery so the API stays fast:
- **OCR**: extract text from scanned/photographed documents.
- **STT**: transcribe voice notes.
- **Structuring**: LLM converts raw text into structured medical events.
- **Explanation**: LLM produces plain-language explanations.
- **Summary regeneration**: LLM rebuilds the "Medical Memory" from current events.

Each step writes results back to PostgreSQL and updates a processing status that the
client polls. Full design in [ai-pipeline.md](./ai-pipeline.md).

### 3.4 Data Stores
- **PostgreSQL** — structured medical history, users, jobs, summaries. JSONB used for
  flexible, type-specific event attributes.
- **Garage on an encrypted production volume** — stores only opaque-keyed ciphertext. Garage has no
  public port and is reached through a verified internal TLS proxy with separate upload, read,
  processing, and deletion credentials.
- **PostgreSQL encrypted-blob records** — store wrapped per-blob keys, keyed user-scoped
  fingerprints, sizes, reference counts, and durable opaque deletion jobs.
- **Device temporary storage** — camera/gallery picker copies, PDF viewer files, and voice retry
  recordings only. Drift contains metadata, never original binaries.
- **Redis** — Celery broker/result backend and short-lived API caches.

### 3.5 External AI Providers
Reached only from Celery workers, never directly from the client. Wrapped by a
**provider-abstraction layer** (`LLMProvider`, `OCRProvider`, `STTProvider` interfaces) so a
vendor can be swapped without touching business logic. Default assumption: a cloud LLM API
plus a cloud OCR and STT service.

## 4. Core Data Flows

### 4.1 Document Ingestion (Scenario A + B)
```
1. App creates metadata record                               → POST /documents
2. App uploads PDF/image originals                           → POST /documents/{id}/ingest
3. API validates signatures, scans in tmpfs, fingerprints per user, encrypts, and stores ciphertext
4. API persists ordered assets and returns 202 only after Garage acknowledges durable storage
5. Celery receives document/blob IDs only, decrypts in the worker, and runs OCR/LLM structuring
6. Worker creates exactly one MedicalEvent + DocumentExplanation or marks processing failed
7. A failed processing job preserves the original for POST /documents/{id}/retry-processing
8. App removes only MedStory-owned capture temporaries and polls until terminal
```

### 4.2 Voice Capture (voice-first NFR)
```
Record audio → temporary encrypted server staging → STT → delete server object and local recording
on success → LLM structuring → one event. A failed transcription keeps the local recording for retry.
```

### 4.3 Prepare for a Visit (Scenario D)
```
User presses refresh:
  enqueue summary task → LLM selects concise items from all active subject events
  → validate source event IDs → enrich provenance → store MedicalSummary version
App keeps the previous summary visible while polling and reads GET /summary (latest)
Source icon → one Event (or source-selection sheet) → authenticated online original
```
The saved per-subject visit reason is passed as untrusted prioritization-only context. It cannot add
medical facts or change the prompt contract. Failed generation leaves the prior current summary
intact. Source links fetch originals through the MedStory API; Flutter never receives Garage
credentials, object addresses, or presigned URLs.
One-based provenance positions address uploaded assets such as pages of a multi-image scan. Internal
pages within one PDF are not separately represented in the MVP and open at the PDF/file start.

### 4.4 Timeline Review (Scenario E)
```
GET /timeline?cursor=...&types=...  → paginated chronological events (read from cache when fresh)
```

## 5. Technology Stack

### Backend
| Concern | Choice | Rationale |
|--------|--------|-----------|
| Framework | Django 5.x + DRF | Mature, batteries-included, fast to build CRUD + auth |
| Auth | `djangorestframework-simplejwt` | Stateless JWT, mobile-friendly |
| Async | Celery + Redis | Standard Django async task stack |
| DB | PostgreSQL 16 | Relational + JSONB + full-text search |
| Files | Garage 2.3 + AWS Encryption SDK framed encryption | Private self-hosted ciphertext storage with key commitment |
| Config | `django-environ` / 12-factor env vars | Cloud-agnostic deployment |
| Server | Gunicorn (or Uvicorn for ASGI) | Production WSGI/ASGI |
| Docs | `drf-spectacular` (OpenAPI) | Auto-generated API schema |

### Frontend
See [frontend-architecture.md](./frontend-architecture.md). Summary: Flutter, Riverpod,
go_router, dio, freezed, flutter_secure_storage, Drift.

### Infrastructure
| Concern | Choice |
|--------|--------|
| Packaging | Docker images per service (api, worker, beat) |
| Local dev | Multi-architecture docker-compose stack (api, worker, beat, postgres, redis, Garage wrapper, ClamAV, TLS proxy) |
| Reverse proxy / TLS | Nginx (or managed LB) |
| Prod orchestration | Cloud-agnostic containers (Compose → Kubernetes when needed) |
| CI/CD | Build, test, lint, image build, deploy |

## 6. Deployment Topology

```
Internet ──TLS──▶ Load Balancer / Nginx ──▶ [ Django API containers (N) ]
                                              │
                                              ├──▶ PostgreSQL (managed or container + backups)
                                              ├──▶ Redis (broker/cache; IDs only)
                                              ├──▶ internal TLS proxy ──▶ Garage ciphertext volume
                                              └──▶ [ Celery worker containers (M) ] ──▶ AI APIs
                                                   [ Celery beat (1) for scheduled jobs ]
```

- API and workers scale independently (workers scale with AI load).
- A single Celery **beat** instance schedules periodic jobs (e.g. retry stuck documents).
- V1 deliberately uses one encrypted EU/EEA disk and no object backup. Loss of that server/disk can
  permanently destroy every original. PostgreSQL backup policy does not restore object ciphertext.

### Environments
- **dev** — docker-compose private storage stack and mock AI providers.
- **staging** — production-like, real AI providers, synthetic data only.
- **production** — dedicated EU/EEA host, encrypted volume, private Garage, ClamAV, and reviewed AI
  subprocessors. Garage S3/admin/RPC ports are not internet-exposed.

## 7. Cross-Cutting Concerns

- **Observability**: structured JSON logs, request IDs, Celery task tracing, error tracking
  (e.g. Sentry), basic metrics (latency, task durations, AI cost per task).
- **Configuration**: all secrets via environment variables / secret manager; nothing in code.
- **Idempotency**: ingestion tasks keyed by document ID so retries don't duplicate events.
- **Rate limiting**: DRF throttling on auth and AI-triggering endpoints to control cost/abuse.
- **Versioning**: API is versioned under `/api/v1/`.
- **Security & Privacy**: see [security-privacy.md](./security-privacy.md).

## 8. Key Design Decisions (ADR summary)

| # | Decision | Why |
|---|----------|-----|
| 1 | Async AI pipeline (Celery) instead of inline | AI/OCR is slow & external; keep API responsive |
| 2 | Provider-abstraction layer for AI | Avoid vendor lock-in; swap LLM/OCR/STT freely |
| 3 | Server-authoritative, MedStory-encrypted private originals | Cross-device access without exposing Garage or retaining device copies |
| 4 | Unified `MedicalEvent` + typed JSONB attributes | One timeline model, flexible per event type |
| 5 | Versioned `MedicalSummary` snapshots | Auditable, lets summary evolve over time |
| 6 | JWT (stateless) auth | Simple, scalable, mobile-friendly |
| 7 | Cloud-agnostic Docker (DB/Redis/env config) | Not locked to one cloud for the MVP |
| 8 | Status-polling for processing | Simple MVP; can upgrade to push later |

## 9. Future Extensions (post-MVP)

- Push notifications / WebSockets instead of polling.
- On-device/self-hosted models for stronger privacy.
- Hardware-backed or remote master-key management and redundant encrypted object backups.
- Full-text & semantic (vector) search over history.
- Web client (architecture already API-first).
- Multi-subject households as a first-class feature.
