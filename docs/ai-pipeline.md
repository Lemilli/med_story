# MedStory — AI / ML Pipeline & Prompt Design

> How raw medical input becomes structured, explained, and summarized history.
> Companion to [Technical Architecture](./technical-architecture.md),
> [Data Model](./data-model.md), [Security & Privacy](./security-privacy.md).

## 1. Scope & Principles

The AI features serve BRD §8: **Document Explanation**, **Structuring into events**, and
**Summary Generation**, plus voice-first capture (§9).

**Hard constraints (BRD §10, §12):**
- The AI is **explanatory and organizational only**. It must **not** diagnose, recommend
  treatments, or generate prescriptions.
- Output must be understandable by non-medical users (plain language).
- Users stay in control: AI-extracted events remain editable and removable from their timeline.
  The event view keeps the user-facing content concise; internal structured extraction remains
  available to the summary/export pipeline rather than being exposed as editable JSON.

All AI work runs **asynchronously in Celery workers** and calls external providers through a
**provider-abstraction layer**, so vendors (LLM/OCR/STT) can be swapped freely.

## 2. Provider Abstraction

```
ai/
├── providers/
│   ├── base.py          # LLMProvider, OCRProvider, STTProvider (interfaces)
│   ├── llm_openai.py    # example LLM impl
│   ├── ocr_cloud.py     # example OCR impl
│   └── stt_cloud.py     # example STT impl
├── prompts/             # versioned prompt templates
├── schemas.py           # Pydantic/JSON schemas for structured outputs
└── tasks.py             # Celery tasks orchestrating the steps
```

Interfaces (conceptual):
```python
class LLMProvider(Protocol):
    def complete_json(self, *, system: str, user: str, schema: dict) -> dict: ...

class OCRProvider(Protocol):
    def extract_text(self, *, file_bytes: bytes, mime: str) -> OCRResult: ...

class STTProvider(Protocol):
    def transcribe(self, *, audio_bytes: bytes, mime: str, lang: str | None) -> str: ...
```

Selection is config-driven (`AI_LLM_PROVIDER`, `AI_OCR_PROVIDER`, `AI_STT_PROVIDER` env vars).

## 3. Pipelines

### 3.1 Document Ingestion Pipeline
Triggered by `POST /documents/{id}/ingest` (transient multipart upload, max 5 MB).
Before OCR or LLM work, the backend calculates a SHA-256 fingerprint of the transient bytes. A
matching live document for the same account that has already generated active events is returned
as a duplicate rather than processed again; deleted documents do not block re-uploading.

```
[Document bytes received transiently]
   │
   ▼
(1) Pre-process: detect MIME, page count, basic validation
   │
   ▼
(2) Text extraction
     • PDF with text layer → extract directly
     • Scanned PDF / image  → OCR provider
     → Document.extracted_text, Document.language
   │
   ▼
(3) LLM Structuring  (structured JSON output, schema-validated)
     input: extracted_text (chunked if large)
     output: exactly one candidate MedicalEvent + document_date + suggested title
     → create one MedicalEvent (source=ai_document, confidence)
   │
   ▼
(4) LLM Explanation  (parallel to or after structuring)
     output: summary_text, key_points, glossary
     → DocumentExplanation row
   │
   ▼
(5) Finish ingestion without regenerating the visit summary; the user refreshes it explicitly
   │
   ▼
[Document.status = processed only after one event exists]
   (no event or any step failure → status=failed + error_message; retriable)
```

For photographed multi-page sources, OCR runs once per ordered image and joins the extracted page
text before structuring. AI does not silently group unrelated gallery photos; the client asks the
user whether a multi-selection is one document or separate documents.

### 3.2 Voice Capture Pipeline
```
[Audio bytes received transiently] → (1) STT transcribe → (2) LLM structuring → events
```
Implemented in the backend through `POST /documents/upload-audio` and `doc_type=audio`
ingestion. Voice-derived events use `source=ai_voice` and can be edited or removed by the user,
and store only the transcript/extracted text, not the raw audio.

### 3.3 On-Demand Explanation
`POST /documents/{id}/explanation/regenerate` re-runs step (4) in the user's currently selected
profile locale. The profile locale is authoritative for every generated title, event description,
structured readable attribute, explanation, and medical summary; request payloads and the source
document's detected language cannot override it. Original documents and `Document.extracted_text`
remain in their source language.

Event regeneration creates an `EventRevision` draft from the immutable source. It never overwrites
the active event. Users compare the draft and explicitly apply selected fields.

### 3.4 Summary (Medical Memory) Pipeline
Triggered only when the user requests `POST /summary/regenerate`.
```
input: all active MedicalEvents for the subject + an optional untrusted saved visit reason
process: LLM selects and consolidates concise, source-linked items for a 60-second briefing
output: new MedicalSummary version (is_current=true; previous → is_current=false)
sections: current_concerns, important_diagnoses_and_findings, allergies,
          current_medications, important_test_results, previous_treatments_and_outcomes,
          procedures_and_hospitalizations
```
The prior current summary remains available during generation and after any failed attempt. Each
transient model-produced item cites only supplied `source_event_ids`; the backend rejects unknown or
cross-user/cross-subject IDs, replaces them with authoritative `sources`, and persists/API-returns
only `text`, `detail`, and those enriched sources for each item.

## 4. Handling Large / Long Documents

- **Chunking**: split `extracted_text` into token-bounded chunks with overlap.
- **Map-reduce**: extract candidate events per chunk (map), then deduplicate/merge (reduce).
- **Summary scaling**: when events are numerous, summarize per-period first, then consolidate,
  to stay within context limits and keep cost predictable.

## 5. Structured Output & Validation

LLM calls that produce data use **JSON-schema-constrained output** validated server-side
(Pydantic). Invalid output → one repair retry → otherwise the step fails gracefully and the
document is marked for manual review (no silent bad data).

Example structuring schema (abridged):
```jsonc
{ "document_date": "YYYY-MM-DD | null",
  "events": [
    { "event_type": "medication|symptom|diagnosis|examination|procedure|hospitalization|treatment_outcome|note",
      "title": "string",
      "description": "string | null",
      "event_date": "YYYY-MM-DD | null",
      "attributes": { /* type-specific, see data-model.md §4 */ },
      "confidence": 0.0 } ] }
```

## 6. Prompt Design

Prompts are **versioned files** in `ai/prompts/` (e.g. `structuring.v1.txt`); the version is
stored on outputs (`model_name` + prompt version) for reproducibility.

### 6.1 Shared System Guardrails (prepended to every prompt)
```
You are MedStory's assistant. You ORGANIZE and EXPLAIN medical information for a
non-medical reader. You DO NOT diagnose, do not recommend treatments, and do not
give medical advice. If information is unclear, mark it as uncertain rather than guessing.
Use plain, simple language. Never invent values that are not present in the source.
```

### 6.2 Structuring Prompt (intent)
- Input: document text. Output: schema-valid JSON of candidate events.
- The source can be in any language, but all user-facing generated fields, including medical labels
  and units, must be translated into the user's selected profile locale. Underlying facts and
  quantitative values must remain accurate.
- Rules: extract only what is present; set low `confidence` when unsure; normalize dates;
  do not infer diagnoses not stated in the text. The event description is a plain-language
  analysis of at most two or three sentences: say when shown results appear within their stated
  ranges, or surface only material out-of-range results that may be worth discussing with a
  clinician. For infection-related panels, surface named positive/detected results first and
  useful named negative/not-detected results next. A test result is never rewritten as a diagnosis
  unless the source explicitly contains that diagnosis. Dates shown in this user-facing description
  use `DD.MM.YYYY`; structured event date fields remain ISO `YYYY-MM-DD`. Do not list every
  measurement, diagnose, or recommend treatment.

### 6.3 Explanation Prompt (intent)
- Input: document text. Output: `summary_text` (plain language), `key_points`, `glossary`.
- All generated explanation fields use the user's selected profile locale, independent of the
  document's source language.
- Rules: define jargon; explain what a test/value generally means **without** interpreting
  the user's specific health status as good/bad beyond what's written; add the standard
  "this is not medical advice" framing in UI (not baked into stored text).

### 6.4 Summary Prompt (intent)
- Input: structured active events plus an optional saved visit reason, explicitly delimited as
  untrusted text. Output: seven structured sections with concise items and source event UUIDs.
- Target: a doctor or patient can scan the result in about 60 seconds. Prefer one line per item; use
  a short second line only when omission would mislead. Hide empty sections and avoid duplication.
- Prioritization: current and unresolved matters first; always retain recorded allergies, current
  medications, major active diagnoses, significant procedures, and important recent abnormal
  results. The visit reason may rank provided events only and cannot introduce facts or instructions.
- Repeated results: for the same analysis use only the newest result; show a compact direction of
  change when it matters; show a conflict with all relevant sources when results are not equivalent.
  Omit normal results unless they explain an important change or conflict.
- Detail: retain compact abnormal value, unit, and stated reference range; retain medication dose
  and schedule when known; simplify technical names without losing a medically meaningful test name.
  Dates appear only when they affect interpretation (tests, changes, procedures, hospitalizations,
  and historical items).
- Language and safety: a source-explicit diagnosis or classification may be restated; a value alone
  remains a finding. Use `reported` for patient-originated uncertainty and `possible` for uncertainty
  in a medical source. Never infer a diagnosis, urgency, treatment, or recommendation.
- Provenance: every transient AI item cites supplied event IDs only. The model does not invent
  document names, page positions, or source labels; the backend supplies those after validation and
  stores each source with its event ID, `title`, date, document name, and known local-asset positions.

## 7. Safety, Quality & Disclaimers

- **No-advice filter**: post-process to strip/forbid recommendation phrasing.
- **Uncertainty surfaced**: uncertain source information is represented in the extracted data;
  users can edit the event's plain-language fields, remove it, and open the original document.
- **Disclaimers**: the app consistently frames output as organizational, per BRD trust NFR.
- **Source traceability**: all active events are eligible, including AI-derived events; summary
  claims link back to their underlying event and original document when locally available.
- **Hallucination guardrails**: schema validation + "never invent values" instruction +
  source-grounding (only use provided text).

## 8. Privacy of AI Processing

- Only the **minimum necessary** text is sent to providers; identifiers are not required for
  explanation/structuring and can be redacted where feasible.
- Providers are accessed only from backend workers, never the client.
- Prefer providers with **no-training-on-data / zero-retention** terms; record this in the DPA.
- Raw file bytes are processed transiently and not persisted on backend storage.
- Per-request data sent to AI providers is logged as metadata only (no raw content) for cost
  and debugging. See [security-privacy.md](./security-privacy.md).

## 9. Cost, Performance & Reliability

| Concern | Approach |
|--------|----------|
| Latency | Async pipeline; client polls; user is never blocked |
| Cost control | Chunk caps, manual-only summary regeneration, per-job `cost_estimate` tracking |
| Retries | Celery retry with backoff; idempotent by `document_id` to avoid dup events |
| Failure isolation | Each step independent; partial success preserved (e.g. text saved even if structuring fails) |
| Caching | Reuse extracted_text across re-runs (don't re-OCR) |
| Observability | ProcessingJob rows + structured logs + error tracking |

## 10. Evaluation (lightweight, MVP)

- A small **golden set** of de-identified sample documents with expected structured output.
- Track: extraction precision/recall on key fields, explanation readability (manual review),
  and summary completeness against the seven visit-summary sections.
- Prompt changes are versioned and re-run against the golden set before rollout.

## 11. Post-MVP Directions

- Semantic/vector search over history (embeddings) for richer retrieval.
- On-device or self-hosted models for stronger privacy.
- Multilingual document handling improvements.
- Confidence-calibrated auto-confirmation for very high-confidence extractions.
