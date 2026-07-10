# MedStory — MVP Roadmap & Milestones

## Important Note: Update this doc after major milestones and major additions to the project

> Delivery plan for the MVP defined in the [BRD](../business_requirements.md). Companion to all
> docs in this folder. Phases are sequenced to deliver user value early and de-risk the
> AI-heavy parts.

## 1. Guiding Principles

- Ship the **capture → understand → review** loop end-to-end before polishing.
- De-risk **AI structuring/explanation** early (highest uncertainty).
- Keep scope tight to BRD §10 (no diagnosis, telemedicine, integrations).
- Privacy/security is built-in per phase, not bolted on.

## 2. Success Metrics (from BRD §11)

The MVP is successful if a user can:
1. Store their medical history in one place.
2. Understand their medical information more easily.
3. Review years of treatment history quickly.
4. Prepare for doctor visits with less effort.
5. Stop reconstructing their history from memory.

Tracked via: # documents ingested, # confirmed events, explanation usage, summary/export
generation, and retention over time.

## 3. Phases

### Phase 0 — Foundations (Setup & Skeleton)
**Status:** Implemented.
**Goal:** running skeleton, both ends talking, CI in place.
- Backend: Django + DRF project, PostgreSQL, Redis, Celery, Docker Compose (api, worker, db,
  redis), settings via env, OpenAPI (`drf-spectacular`).
- Frontend: add Riverpod, go_router, dio, freezed, secure storage; app shell + theme + flavors.
- Auth end-to-end: register/login/refresh (JWT); auth guard on the client.
- CI: lint, test, build images.
- **Exit:** user can register, log in, and hit an authenticated `/me` from the app.
- **Implemented:** backend custom user + JWT auth endpoints, `/me`, OpenAPI routes, Docker Compose,
  Celery/Redis/Postgres skeleton; Flutter Riverpod/go_router/dio auth stack, secure JWT storage,
  auth guard, login/register UI, settings `/me` panel; CI for backend checks/tests/image build and
  Flutter analyze/test/debug APK build.
- **Verified locally:** Flutter analyze/test, Django check/test, backend Docker image build. Android
  debug APK build remains to be confirmed in CI or a healthy local Gradle run.

### Phase 1 — Medical History Core (Manual)
**Status:** Implemented.
**Goal:** the timeline works without AI (proves the data model + UX).
- Backend: `Subject`, `MedicalEvent` models; events CRUD; `/timeline` with filters + pagination.
- Frontend: timeline screen (infinite scroll, filters), manual add/edit event, event detail,
  subject switcher; local cache (Drift).
- **Exit:** user can manually build and browse a chronological medical history (Scenarios A & E
  without AI).
- **Implemented:** backend `medical` app with `Subject`, `MedicalEvent`, and `Tag` models; default
  self-subject creation/resolution; subject CRUD; event CRUD with soft delete; `/timeline` with
  cursor pagination and filters (`subject_id`, `types`, `from`, `to`, `tag`, `q`); OpenAPI schema
  coverage; per-user queryset isolation tests. Flutter Phase 1 frontend with Drift-backed subject
  and event cache, typed medical models, subject/event/timeline API clients and repositories,
  selected-subject and timeline pagination controllers, localized timeline screen, manual
  create/edit event form, event detail/delete flow, authenticated `/timeline` landing route, and
  logout cache clearing.
- **Verified locally:** Django check/test, migration drift check, OpenAPI validation, Flutter
  code generation, `flutter analyze`, and `flutter test` with focused model, pagination, and local
  cache coverage.

### Phase 2 — Documents & Ingestion Pipeline
**Status:** Implemented with pluggable providers; OpenAI LLM/OCR wiring added, mock providers
remain for deterministic local tests.
**Goal:** upload documents and extract text + structured events automatically.
- Backend: `Document` model (metadata only), `/documents/{id}/ingest`, status polling;
  transient ingestion path (no file persistence); Celery ingestion task; **OCR** + **LLM
  structuring** via provider abstraction; events created as AI-suggested (`is_confirmed=false`).
- Frontend: capture flow (scan/photo/file), local file persistence, ingest state machine,
  document list/detail,
  "confirm AI event" UX.
- **Exit:** upload a document → see extracted, confirmable events on the timeline (Scenario A).
- **Provider notes:** set `AI_LLM_PROVIDER=openai`, `AI_OCR_PROVIDER=openai`, and
  `AI_OPENAI_API_KEY` for real document extraction. Set `AI_STT_PROVIDER=openai` and
  `AI_OPENAI_STT_MODEL` for real Phase 5 voice transcription.

### Phase 3 — Understanding (Explanations)
**Status:** Implemented.
**Goal:** plain-language explanations of documents (Scenario B).
- Backend: `DocumentExplanation`, explanation task + endpoints, regenerate (language).
- Frontend: explanation view (summary, key points, glossary), localization wiring.
- **Exit:** user opens a document and reads a clear explanation (Scenario B).

### Phase 4 — Medical Memory & Doctor Summary
**Status:** Backend and frontend implemented.
**Goal:** continuously-updated summary + doctor-ready export (Scenarios C & D).
- Backend: `MedicalSummary` (versioned), summary task, immediate regen on confirmed event changes,
  `/summary`, `/summary/regenerate`, `/summary/versions`, `/summary/export` (PDF/JSON).
- Frontend: subject-aware summary screen, version history, "Prepare for visit" PDF share,
  cached current summary, and timeline-backed history search.
- **Exit:** user generates a concise doctor summary and reviews treatment history (C & D).

### Phase 5 — Voice-First Capture
**Status:** Implemented.
**Goal:** low-friction voice input (BRD §9 NFR).
- Backend: audio document type, **STT** provider, STT→structuring task. **Implemented.**
- Frontend: voice recording + local audio persistence + transient ingest reusing the same state
  machine. **Implemented.**
- **Exit:** backend supports recording upload to structured, confirmable events; frontend voice
  capture records locally, reviews before upload, and sends audio through the transient ingest flow.

### Phase 6 — Privacy, Hardening & Launch Prep
**Status:** Frontend GDPR/settings flows implemented; launch hardening still in progress.
**Goal:** GDPR flows, security checklist, store readiness.
- Backend: `/privacy/export`, `DELETE /me` (hard delete of backend records), `AuditLog`,
  backend tests implemented; throttling, dependency/secret scanning, and DPAs remain planned.
- Frontend: settings (export, delete account, locale), onboarding disclaimer ("organizer, not
  a doctor"), accessibility pass. **Implemented.**
- Ops: backend metadata backups, monitoring/error tracking, cost alerts; complete the security checklist
  (`security-privacy.md` §14).
- **Exit:** GDPR export/erasure work; security checklist green; app store builds ready.

## 4. Dependency Order

```
Phase 0 ─▶ Phase 1 ─▶ Phase 2 ─▶ Phase 3
                       │            │
                       └────▶ Phase 4 ◀┘
Phase 2 ─▶ Phase 5
All ─▶ Phase 6 (hardening) ─▶ Launch
```
- Phase 4 depends on having events (Phase 1) and ideally AI structuring (Phase 2).
- Phase 5 reuses the Phase 2 pipeline.
- Phase 6 runs partly in parallel (security is incremental) but gates launch.

## 5. Cross-Cutting (every phase)

- Tests at the level appropriate to the phase (unit/widget/integration/contract).
- Keep OpenAPI schema and these docs in sync with code.
- Track AI cost per feature from Phase 2 onward.
- Privacy review for any new data flow.

## 6. Definition of Done (MVP)

- All BRD §7 scenarios (A–E) work end-to-end.
- All BRD §8 functional requirements implemented.
- Non-functional requirements (§9) met: usable, accessible, low data-entry (voice + AI),
  trust framing, privacy controls.
- Security checklist complete; GDPR export + erasure verified.
- iOS + Android builds pass; monitoring and backend metadata backups live.

## 7. Explicitly Deferred (post-MVP)

Per BRD §10 and the architecture's future-extensions: diagnosis/recommendations, telemedicine,
appointment booking, provider communication, wearables/insurance/hospital integrations,
multi-agent systems. Also deferred: push/WebSocket updates, semantic/vector search,
self-hosted models, field-level encryption, web/desktop clients, offline writes.

## 8. Key Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| AI extraction quality on messy/scanned docs | Golden-set eval, confidence flags, human confirmation |
| AI cost unpredictability | Chunk caps, debounced summaries, per-job cost tracking + alerts |
| Privacy/compliance gaps | Build GDPR flows in Phase 6, DPAs, security checklist, legal review |
| Vendor lock-in | Provider abstraction for LLM/OCR/STT and cloud-agnostic backend stack |
| Scope creep into "AI doctor" territory | Hard guardrails in prompts + product framing (BRD §12) |
| Long-document context limits | Map-reduce chunking + period-wise summarization |
