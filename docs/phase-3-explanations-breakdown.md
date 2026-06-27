# MedStory — Phase 3 Explanations Breakdown

> Parallel implementation plan for Phase 3 from [MVP Roadmap](./mvp-roadmap.md): plain-language
> document explanations for Scenario B. This plan assumes Phase 2 document ingestion is implemented.

## Scope Decisions

- Phase 3 is limited to Scenario B: the user opens a processed document and reads a clear,
  plain-language explanation.
- Phase 2 document ingestion, document metadata, extracted text, polling, and document detail
  entry points are assumed to exist.
- Explanations are generated automatically after successful document ingestion and can be manually
  regenerated later.
- Explanation language defaults to the user/app locale and supports regeneration in English and
  Russian.
- AI integration is mock-first: implement deterministic providers, schemas, prompts, and tests
  before wiring real LLM vendors.
- The frontend scope is a focused document explanation experience: summary, key points, glossary,
  loading/error/empty states, language regeneration, accessibility, and localization.
- Phase 3 must preserve MedStory's positioning: organizer and explainer, not diagnosis, medical
  advice, treatment recommendation, prescription, or AI doctor.

## Target Exit Path

1. User uploads a document through the Phase 2 ingestion flow.
2. Backend extracts text and creates AI-suggested events as before.
3. Backend also generates a `DocumentExplanation` in the user's locale using the explanation task.
4. Document detail reports `explanation_available=true` after the explanation exists.
5. User opens the document detail screen and sees:
   - a plain-language summary;
   - key points;
   - glossary terms with simple definitions;
   - non-diagnostic trust framing.
6. User can regenerate the explanation in English or Russian.
7. The app handles processing, not-ready, failed, and regenerated states without exposing raw
   provider errors or health content in logs.

## Parallel Workstreams

### Agent A — Backend Explanation Model & API

**Goal:** Add the persistence and REST surface for document explanations.

**Can start immediately if Phase 2 `Document` APIs are merged.**

Tasks:
- Add `DocumentExplanation` model to `backend/medical/models.py` with fields from
  [data-model.md](./data-model.md): document FK, summary text, key points, glossary, model name,
  language, and created timestamp.
- Decide whether repeated regenerations create multiple rows or replace the latest row per
  `(document, language)`. Prefer retaining rows for provenance unless existing model patterns favor
  a single latest record.
- Add migrations and admin registration.
- Add serializers for explanation detail responses.
- Add endpoint:
  - `GET /api/v1/documents/{id}/explanation`
- Add endpoint:
  - `POST /api/v1/documents/{id}/explanation/regenerate`
- Return `404` with the existing error envelope and a stable `not_ready` or `not_found` code when
  a processed document has no explanation yet.
- Validate requested regeneration language against supported locales (`en`, `ru`) and default to
  the user's locale when omitted.
- Enforce per-user and per-subject isolation through the parent document queryset.
- Ensure `GET /api/v1/documents/{id}` exposes `explanation_available`.
- Keep OpenAPI schema output aligned with [api-specification.md](./api-specification.md).

Acceptance criteria:
- Users can retrieve only explanations for their own documents.
- Regeneration enqueues work and returns quickly with `202`.
- Unsupported languages fail with a localized-safe validation error.
- Document detail accurately reports explanation availability.
- OpenAPI includes explanation endpoints and response schemas.

Suggested tests:
- Explanation retrieve ownership isolation.
- `404 not_ready` before an explanation exists.
- Regenerate language validation and default locale behavior.
- `explanation_available` true/false on document detail.
- Serializer validation for `key_points` and `glossary` shapes.

Handoff:
- Publish exact response fields and error codes for Agent C and Agent D.
- Confirm whether the frontend should display only the latest explanation or language-specific
  explanation history.

### Agent B — Explanation Task, Prompt & Mock LLM Provider

**Goal:** Generate deterministic, schema-validated plain-language explanations from extracted text.

**Can start immediately using the Phase 2 provider abstraction and fixtures.**

Tasks:
- Add or extend the LLM provider contract for explanation generation using structured JSON output.
- Add an explanation output schema with:
  - `summary_text`;
  - `key_points` as an ordered list of short strings;
  - `glossary` as term/definition pairs;
  - optional metadata for model and prompt version.
- Add versioned explanation prompt files or constants using the guardrails from
  [ai-pipeline.md](./ai-pipeline.md):
  - explain in plain language;
  - define jargon;
  - use only source text;
  - do not diagnose;
  - do not recommend treatment;
  - do not interpret user-specific health status beyond what the document states.
- Implement deterministic mock explanation behavior for fixture documents in English and Russian.
- Add the Celery explanation task:
  - load the document through an ownership-safe path;
  - require `Document.extracted_text`;
  - call the mock LLM provider;
  - validate output schema;
  - store `DocumentExplanation`;
  - update a `ProcessingJob` if Phase 2 includes one.
- Add repair/retry behavior for invalid provider JSON, matching the Phase 2 AI validation pattern.
- Ensure task logs contain IDs, statuses, model metadata, and costs only; never extracted text or
  health content.

Acceptance criteria:
- A deterministic fixture document produces a stable explanation.
- Invalid provider output fails gracefully without saving partial invalid content.
- Missing extracted text produces a clear failure state.
- English and Russian fixture outputs are generated through the same contract.
- Prompt/model metadata is stored where the current models allow it.

Suggested tests:
- Schema validation for valid and invalid explanation payloads.
- Mock provider outputs for English and Russian.
- Celery task success, missing text, invalid output, and retry paths.
- No-advice guardrail tests for unsafe provider phrasing.
- No raw health content in task logs.

Handoff:
- Share fixture payloads and expected explanation JSON with Agent E.
- Share task invocation contract with Agent C.

### Agent C — Ingestion Integration & Regeneration Flow

**Goal:** Wire explanation generation into document ingestion and manual regeneration.

**Can start after Agents A and B define model, endpoint, and task contracts.**

Tasks:
- Update the Phase 2 ingestion pipeline so successful text extraction and event structuring also
  enqueue or run the explanation step.
- Generate the first explanation in the user's current locale.
- Keep ingestion idempotent: retrying the same document must not create duplicate active
  explanations for the same language unless the selected model intentionally versions results.
- Make explanation failure isolated where possible:
  - preserve extracted text and AI-suggested events if explanation fails;
  - expose explanation as unavailable or failed without incorrectly failing the whole document
    when ingestion otherwise succeeded.
- Implement `POST /documents/{id}/explanation/regenerate` by enqueuing the explanation task with
  the requested language.
- Return `202` with a stable response body, preferably including a `job_id` when `ProcessingJob`
  exists.
- Update document status or job status semantics so the frontend can distinguish:
  - document still processing;
  - explanation not ready;
  - explanation generation failed;
  - explanation ready.
- Rate-limit AI-triggering regenerate calls according to [api-specification.md](./api-specification.md)
  and [security-privacy.md](./security-privacy.md).

Acceptance criteria:
- A processed document normally has an explanation available.
- Manual regeneration creates or replaces the latest explanation in the requested language.
- Repeated ingestion/regeneration is deterministic and does not create accidental duplicates.
- Explanation failures do not erase extracted events or extracted text.
- AI-triggering endpoints respect auth, ownership, validation, and throttling.

Suggested tests:
- Ingestion happy path includes explanation creation.
- Explanation task failure leaves document/events intact.
- Regeneration happy path for `en` and `ru`.
- Idempotent repeated regenerate calls for the same language.
- Throttle and ownership tests for regenerate endpoint.

Handoff:
- Provide final status/error semantics for Agent F.
- Provide polling and `job_id` behavior to Agent D.

### Agent D — Frontend Explanation Domain, API & Controller

**Goal:** Add Flutter models, API calls, repository methods, and state management for explanations.

**Can start once Agent A publishes response shapes, or work from this document and
[api-specification.md](./api-specification.md).**

Tasks:
- Add explanation domain/DTO models with `freezed` and `json_serializable`.
- Add document explanation API methods:
  - `GET /documents/{id}/explanation`;
  - `POST /documents/{id}/explanation/regenerate`.
- Add repository methods that map backend responses and error envelopes into existing
  `AppFailure` patterns.
- Add an `AsyncNotifier` or document-detail controller extension for:
  - load explanation;
  - refresh explanation;
  - regenerate explanation by language;
  - expose not-ready, failed, and validation states.
- Decide whether explanation content should be cached in Drift. Prefer remote-first for Phase 3
  unless existing document detail caching already exists.
- Ensure locale defaults come from the app/user locale and match backend language values.
- Keep all visible strings in `lib/l10n/` ARB files and regenerate localizations.

Acceptance criteria:
- Document detail can load an explanation, show not-ready, and retry.
- Regenerate sends a supported language and refreshes the visible explanation after completion.
- Backend validation and throttling errors map to user-safe UI messages.
- DTO serialization tests cover summary, key points, glossary, language, and timestamps.
- No user-facing text is hardcoded.

Suggested tests:
- DTO serialization/deserialization.
- Repository success and error mapping.
- Controller load, not-ready, failed, and regenerate states.
- Locale-to-language request behavior.

Handoff:
- Provide controller state shape to Agent E.
- Confirm localization keys added for Agent E UI.

### Agent E — Frontend Explanation View UX

**Goal:** Build the document explanation screen section with summary, key points, glossary, states,
and regeneration controls.

**Can start after Agent D defines controller APIs; wire to real data when backend contracts land.**

Tasks:
- Update document detail or explanation screen route at `/documents/:id`.
- Display a non-diagnostic framing message, e.g. "This explanation helps you understand the
  document. It is not medical advice."
- Render:
  - summary text;
  - key points as readable bullets/cards;
  - glossary terms with plain definitions;
  - language and generated timestamp metadata.
- Add states for:
  - document still processing;
  - explanation not ready;
  - explanation generation failed;
  - empty explanation;
  - loaded explanation;
  - regeneration in progress.
- Add language regeneration action for English and Russian.
- Use calm, accessible presentation: large text support, semantic labels, high contrast, and
  minimum 48dp tap targets.
- Keep copy concise for users with low medical or technical literacy.
- Ensure all strings are localized in English and Russian.

Acceptance criteria:
- User can open a processed document and read summary, key points, and glossary.
- User can regenerate the explanation in English or Russian.
- Loading/error/not-ready states are understandable and actionable.
- Trust framing is visible without being alarmist or repetitive.
- UI passes `flutter analyze` and focused widget tests.

Suggested tests:
- Widget tests for loaded summary/key-points/glossary view.
- Widget tests for processing, not-ready, failed, and regenerating states.
- Widget test for language regeneration action.
- Localization smoke tests for English and Russian strings.
- Accessibility checks for semantics on major controls.

Handoff:
- Share any copy changes with Agent F for docs and QA.
- Confirm UI screenshots or manual QA notes for the exit path.

### Agent F — Safety, Contract QA & Documentation

**Goal:** Keep parallel branches aligned, verify safety constraints, and prove the Phase 3 exit
scenario.

**Can start immediately with docs and update as other agents land work.**

Tasks:
- Update [api-specification.md](./api-specification.md) if implementation response bodies,
  `job_id`, error codes, or regeneration request shape differ from current docs.
- Update [data-model.md](./data-model.md) if explanation versioning or language uniqueness differs
  from the planned model.
- Update [ai-pipeline.md](./ai-pipeline.md) if the explanation step is isolated from the ingestion
  success path or has new retry semantics.
- Create a small de-identified golden set for explanation testing:
  - one lab-result-like document;
  - one prescription-like document;
  - one procedure/report-like document;
  - one fixture with jargon for glossary coverage;
  - one fixture containing tempting advice language for safety checks.
- Define a manual QA script for the target exit path.
- Verify privacy constraints from [security-privacy.md](./security-privacy.md):
  - no raw files persisted on the backend;
  - no health content in logs;
  - provider calls happen only from backend workers;
  - AI provider metadata is recorded without raw content.
- Verify copy and prompts preserve product positioning from the BRD:
  - no diagnosis;
  - no treatment recommendation;
  - no prescription generation;
  - no AI doctor framing.
- Keep [mvp-roadmap.md](./mvp-roadmap.md) updated once Phase 3 is implemented and verified.

Acceptance criteria:
- Docs and OpenAPI match implemented endpoints and schemas.
- Golden-set tests or manual checks show readable explanations.
- Safety tests catch diagnostic or recommendation-style output.
- Phase 3 exit criteria can be demonstrated with mock providers.
- Known gaps are explicit and assigned to Phase 4, Phase 6, or post-MVP.

Suggested tests/checks:
- Backend test suite.
- Migration drift check.
- OpenAPI schema generation/validation.
- Flutter `flutter analyze` and `flutter test`.
- Manual app run: upload document, wait for processing, open document explanation, regenerate in
  another language.

## Recommended Parallelization Plan

Start together:
- Agent A: backend explanation model/API.
- Agent B: prompt, schema, mock provider, and explanation task internals.
- Agent D: frontend DTO/API/controller from documented contracts.
- Agent F: golden fixtures, safety checks, QA plan, and doc alignment.

Start once contracts stabilize:
- Agent C: ingestion integration and regenerate endpoint/task wiring.
- Agent E: explanation screen UX wired to Agent D controller states.

Integration order:
1. Merge Agent A before endpoint consumers depend on the exact serializer shape.
2. Merge Agent B task tests before connecting explanations to ingestion.
3. Merge Agent C once auto-generation and regeneration work with mock providers.
4. Merge Agent D before Agent E connects the UI to live state.
5. Merge Agent E with Agent F's QA script and safety checks.

## Shared Contracts Agents Must Not Break

- Backend never persists raw document files.
- Explanations are plain-language, source-grounded, and non-diagnostic.
- AI must not recommend treatment, prescribe medication, or present itself as a doctor.
- All explanation records are scoped through user-owned documents and subjects.
- Regeneration supports English and Russian.
- User-facing text is localized in English and Russian.
- Logs, errors, analytics, and task metadata must not include raw health content.
- Real LLM vendor integration is out of scope for the first Phase 3 implementation pass unless a
  separate follow-up explicitly adds it.
- OpenAPI, docs, backend serializers, and frontend DTOs must stay aligned.

## Open Implementation Notes

- [technical-architecture.md](./technical-architecture.md) describes explanation generation as part
  of the asynchronous AI pipeline, while [mvp-roadmap.md](./mvp-roadmap.md) scopes it to Phase 3.
  Implement it now as an extension of the Phase 2 ingestion pipeline.
- [ai-pipeline.md](./ai-pipeline.md) says the standard "not medical advice" framing belongs in UI,
  not baked into stored explanation text. Keep stored content clean and reusable.
- [data-model.md](./data-model.md) allows `Document 1-N DocumentExplanation`, which supports
  regeneration/versioning. If the product only needs the latest explanation per language, enforce
  that deliberately and document the decision.
- If Phase 2 did not implement `ProcessingJob`, keep regeneration responses simple but document how
  the frontend should poll for readiness.
- If Phase 2 document detail is minimal, Agent E may need to add the first substantial
  `/documents/:id` screen while staying focused on the explanation experience.
