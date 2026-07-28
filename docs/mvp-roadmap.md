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

Tracked via: # documents ingested, # timeline events, explanation usage, summary/export
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
- Backend: `Document` plus encrypted blob/assets, `/documents/{id}/ingest`, authenticated original
  content, retained-source processing retry, status polling, and Celery **OCR** + **LLM structuring**.
  Garage stores MedStory-encrypted ciphertext only.
- Frontend: capture flow (scan/photo/file), temporary source ownership, a persistent metadata Add-tab
  processing queue with retry and duplicate-file protection, document list/detail,
  "confirm AI event" UX.
- **Exit:** upload a document → see extracted, confirmable events on the timeline (Scenario A).
- **Provider notes:** set `AI_LLM_PROVIDER=openai`, `AI_OCR_PROVIDER=openai`, and
  `AI_OPENAI_API_KEY` for real document extraction. Set `AI_STT_PROVIDER=openai` and
  `AI_OPENAI_STT_MODEL` for real Phase 5 voice transcription.
- **Single-source milestone:** implemented one logical capture bundle → one active event, ordered
  multi-photo pages, explicit gallery grouping, online original navigation, preserved source
  text, and non-destructive AI event revisions.

### Phase 3 — Understanding (Explanations)
**Status:** Implemented.
**Goal:** plain-language explanations of documents (Scenario B).
- Backend: `DocumentExplanation`, explanation task + endpoints, regenerate (language).
- Frontend: explanation view (summary, key points, glossary), localization wiring.
- **Exit:** user opens a document and reads a clear explanation (Scenario B).

### Phase 4 — Medical Memory & Doctor Summary
**Status:** Backend and frontend implemented.
**Goal:** a source-linked visit briefing that a doctor or patient can scan in about 60 seconds (Scenarios C & D).
- Backend: `MedicalSummary` (versioned), manual-only summary task,
  `/summary`, `/summary/regenerate`, `/summary/versions`, `/summary/export` (PDF/JSON).
- Frontend: seven concise structured sections, saved free-text visit reason, in-app event source
  links, cached current summary, and timeline-backed history search.
- Source traceability: summary items cite validated event IDs; the backend adds event/document/page
  provenance. The phone flow is summary → event → authenticated server-retained original. Known one-based positions
  address uploaded image assets/pages; a single PDF has no separately addressable internal-page
  provenance in the MVP and opens at the file start, as do older sources without asset metadata.
- Selection rules: current/unresolved information first; identical repeated analyses use the newest
  result; meaningful changes and genuine conflicts are shown compactly; safety-critical recorded
  facts remain visible regardless of visit reason.
- **Exit:** user generates a concise doctor summary and reviews treatment history (C & D).

### Phase 5 — Voice-First Capture
**Status:** Implemented.
**Goal:** low-friction voice input (BRD §9 NFR).
- Backend: transient STT endpoint plus asynchronous final-text structuring. Raw audio is never
  persisted. **Implemented.**
- Frontend: stopping a recording uploads it immediately for transcription; the returned text is
  editable and later recordings append to it. **Implemented.**
- **Exit:** users submit one final edited text draft for processing. Empty or non-medical drafts
  fail without creating timeline events.

### Phase 6 — Privacy, Hardening & Launch Prep
**Status:** Server-retained private originals, GDPR/settings flows, API throttling, and CI
dependency/secret scanning implemented; legal/operations launch approval remains in progress.
**Goal:** GDPR flows, security checklist, store readiness.
- Backend: private single-node Garage behind internal TLS, ClamAV fail-closed scanning, framed
  envelope encryption with key commitment, same-user keyed dedupe, 2 GB quota, cryptographic
  erasure, durable opaque deletion jobs, `DELETE /me`, audit logging, and isolation/lifecycle tests.
- CI: blocking dependency and full-history secret scans plus weekly Dependabot updates.
- Compliance launch gates: Garage AGPLv3 approval; EU/EEA hosting; external-AI DPA,
  cross-border/no-training/minimal-retention review; sealed offline master-key recovery copy; and
  explicit acceptance that the single disk/no object backup can permanently lose originals.
- Frontend: settings (delete account, locale), onboarding disclaimer ("organizer, not
  a doctor"), accessibility pass. **Implemented.**
- Ops: one encrypted production disk, no original backup by explicit V1 decision, monitoring/error
  tracking, cost alerts, and the remaining security checklist (`security-privacy.md` §14).
- **Exit:** account-erasure work; security checklist green; app store builds ready.

This milestone is a breaking MVP reset. Migration `0016_private_original_storage` creates the new
schema without legacy binary migration; development PostgreSQL, Garage volumes, and Drift state are
reset instead of converted.

### Core UX Release — Capture, Review & Visit Preparation
**Status:** Implemented; launch hardening remains separate.
- Capture navigation starts the selected scan, photo, file, voice, note, or manual-event flow directly.
- AI suggestions have a dedicated review inbox with confirm, edit, and dismiss actions.
- Timeline has year filtering and history search.
- A per-subject free-text visit reason is saved until changed and used only to prioritize existing
  events during an explicit refresh; it is treated as untrusted input.
- First-use onboarding reinforces the organizer-only boundary; reminders, caregiver mode, bulk import, and semantic search remain deferred.

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
- Security checklist complete; account erasure verified.
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
