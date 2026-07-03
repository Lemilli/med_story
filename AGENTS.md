# Agent Notes

## Project Basics
- Repo root: `/Users/alibekkapan/Documents/Flutter Projects/med_story`.
- Product: **MedStory**, a personal medical memory app for chronic/long-term health history.
- Stack: Flutter mobile client, Django + DRF backend, PostgreSQL, Redis/Celery, Docker Compose, JWT auth, provider-abstracted AI/OCR/STT.
- Main backend app normally runs through Docker on `http://0.0.0.0:8000`.
- API docs are at `http://0.0.0.0:8000/api/docs/`; OpenAPI schema is at `http://0.0.0.0:8000/api/schema/`.
- Backend virtualenv exists at `backend/.venv`; use backend Python as `backend/.venv/bin/python` for host-side commands.

## Product Guardrails
- MedStory is **not** a diagnostic tool, AI doctor, treatment recommender, prescription generator, telemedicine platform, appointment system, or provider messaging system.
- Keep AI behavior explanatory and organizational only: simplify, structure, summarize, and surface uncertainty.
- Do not add flows that infer diagnoses, recommend treatments, rank medical options, or provide clinical advice.
- Users remain in control: AI-extracted events are suggestions until reviewed/confirmed.
- Minimize data-entry burden. Prefer capture-first, voice-first, AI-assisted workflows when in scope.
- Present medical information in plain language suitable for non-medical users.

## Current Roadmap State
- Phase 0 foundations are implemented: Django/DRF, Docker Compose, Celery/Redis/Postgres skeleton, JWT auth, `/me`, OpenAPI, Flutter auth shell.
- Phase 1 manual medical history is implemented: subjects, events, tags, timeline, per-user isolation, Flutter timeline/manual event flows, Drift cache.
- Phase 2 documents and ingestion are implemented with pluggable providers: document metadata, transient ingest, OCR/LLM structuring, AI-suggested events.
- Phase 3 document explanations are implemented.
- Phase 4 medical summary/doctor export, Phase 5 voice-first STT capture, and Phase 6 privacy hardening are still planned unless code shows newer progress.
- Keep `docs/mvp-roadmap.md` updated after major milestones or major scope additions.

## Backend Commands
- Local Docker workflow is documented in `backend/workflow.md`.
- Start local backend stack from `backend/`:
  `docker compose up --build`
- Run Docker migrations from `backend/`:
  `docker compose run --rm api python manage.py migrate`
- Run all backend tests in Docker from `backend/`:
  `docker compose run --rm api python manage.py test`
- Run focused backend tests from repo root with deterministic mock AI:
  `DATABASE_URL=sqlite:////private/tmp/med_story_test.sqlite3 AI_LLM_PROVIDER=mock AI_OCR_PROVIDER=mock AI_STT_PROVIDER=mock backend/.venv/bin/python backend/manage.py test medical.tests`
- Run Django system checks from repo root with host Python:
  `DATABASE_URL=sqlite:////private/tmp/med_story_test.sqlite3 AI_LLM_PROVIDER=mock AI_OCR_PROVIDER=mock AI_STT_PROVIDER=mock backend/.venv/bin/python backend/manage.py check`
- The repo/backend `.env` is Docker-oriented and points Postgres at host `db`; host-side test runs should override `DATABASE_URL`.
- If testing inside Docker, remember Compose mounts `backend/` as `/app`; root-level `test_assets/` may not be visible there.

## Frontend Commands
- Frontend root: `frontend/`.
- Run Flutter code generation after model/DTO/Drift/l10n changes:
  `cd frontend && flutter pub run build_runner build --delete-conflicting-outputs`
- Run localization generation when ARB files change:
  `cd frontend && flutter gen-l10n`
- Analyze:
  `cd frontend && flutter analyze`
- Test:
  `cd frontend && flutter test`
- The app uses Riverpod, go_router, dio, freezed/json_serializable, flutter_secure_storage, Drift, and Flutter localization.

## Local API Verification
- Prefer the existing backend on port `8000`; do not start a second backend on `8001` just for manual verification.
- Use `http://0.0.0.0:8000/api/docs/` or `/api/schema/` to confirm endpoint shapes before manual API calls.
- It is acceptable to upload files from `test_assets/` into the local backend for testing.
- It is also acceptable to upload other project sample fixtures when they are clearly test/demo data.
- Document ingest upload limit is 5 MB.
- Ingested raw files are transient server-side; the backend stores metadata, extracted text, statuses, events, explanations, and summaries, not original binaries.

## Backend Architecture Notes
- API routes are versioned under `/api/v1/`.
- Auth uses email/password and JWT through `djangorestframework-simplejwt`; refresh token logout/blacklist is part of the intended flow.
- User-owned medical data must always be scoped by `request.user` at the queryset level.
- Core models from docs: `Subject`, `Document`, `MedicalEvent`, `DocumentExplanation`, `MedicalSummary`, `Tag`, `ProcessingJob`, `AuditLog`.
- `MedicalEvent` is the unified timeline item. Type-specific fields belong in validated JSON attributes unless there is a strong query/sort reason to promote them.
- Soft delete uses `deleted_at` where supported; hard delete/export are GDPR-oriented flows.
- Timeline is the hot path. Preserve cursor pagination and indexes/filter behavior when changing events.

## AI Pipeline Notes
- AI/OCR/STT providers are selected by env vars: `AI_LLM_PROVIDER`, `AI_OCR_PROVIDER`, `AI_STT_PROVIDER`.
- Use mock providers for deterministic tests.
- Real OpenAI-backed document processing expects `AI_LLM_PROVIDER=openai`, `AI_OCR_PROVIDER=openai`, and `AI_OPENAI_API_KEY`; `AI_STT_PROVIDER` remains mock until voice capture is implemented.
- AI work should run asynchronously through Celery tasks where practical; keep request/response endpoints fast.
- Do not persist raw upload bytes on the backend. Process bytes transiently, save extracted text/results, and discard the binary.
- LLM structured output should be schema-validated. On invalid output, fail gracefully or retry once rather than silently creating bad medical data.
- Store provider/model/prompt metadata where the code already supports it, but do not log raw health content.

## API Conventions
- JSON API except multipart transient ingestion endpoints.
- Authenticated requests use `Authorization: Bearer <access_token>`.
- IDs are UUIDs; timestamps are ISO 8601 UTC.
- List endpoints should use cursor pagination where already established.
- Error responses should use the documented envelope:
  `{ "error": { "code": "...", "message": "...", "details": {}, "request_id": "..." } }`
- Medical endpoints usually accept `subject_id`; if omitted, default to the user's default self-subject where implemented.

## Frontend Architecture Notes
- Keep the feature-first layered structure: widgets/screens -> Riverpod controllers -> repositories -> API/local data sources -> models.
- Widgets should render state and dispatch intents; controllers own presentation state; repositories coordinate remote/local data.
- Store JWTs only in `flutter_secure_storage`.
- Local timeline/summary caches live in Drift and should be cleared on logout/account deletion.
- Document/audio binaries belong in app-sandboxed local storage; MVP has no cross-device file sync/backup.
- No hardcoded visible UI strings. Put user-facing text in `frontend/lib/l10n/*.arb` and access it through generated localization helpers.
- Supported locales are English and Russian unless docs/code say otherwise.
- Respect accessibility basics: OS text scaling, semantic labels on controls, and 48dp minimum tap targets.

## Security & Privacy Rules
- Treat all medical data as highly sensitive.
- Never log raw health content, extracted text, document contents, audio transcripts, tokens, passwords, or secrets.
- Keep secrets in environment variables or secret managers; never commit credentials.
- Enforce per-user resource isolation in backend querysets and tests.
- External AI providers must be called only from backend workers/services, never directly from the client.
- Send minimum necessary content to AI providers and redact identifiers where feasible.
- Non-prod environments should use synthetic/demo data only.
- GDPR-oriented behavior matters: export, rectification, deletion, token revocation, audit logging, and short-lived export bundles.

## Documentation Map
- Start with `docs/technical-architecture.md` for system design and data flow.
- Use `docs/data-model.md` and `docs/api-specification.md` for backend contracts.
- Use `docs/frontend-architecture.md` for Flutter structure, state, navigation, caching, and localization rules.
- Use `docs/ai-pipeline.md` for provider abstraction, transient ingestion, prompt guardrails, and AI quality rules.
- Use `docs/security-privacy.md` before changing auth, storage, logging, AI provider data handling, export, or deletion.
- Use `docs/mvp-roadmap.md` for phase scope and status.
- `PRODUCT.md` and `DESIGN.md` may contain additional product/design context outside the docs folder.

## Editing Hygiene
- Keep changes scoped; do not revert unrelated dirty work.
- Use `apply_patch` for manual file edits.
- Avoid committing, staging, or destructive git commands unless the user explicitly asks.
- Update docs when changing API contracts, data model, AI behavior, frontend architecture, security/privacy behavior, or roadmap status.
- Prefer existing project patterns over new abstractions.
- Add tests proportional to risk, especially for auth, tenancy isolation, ingestion, AI result handling, timeline behavior, and privacy flows.
