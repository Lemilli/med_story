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
- Users stay in control: AI-extracted events are **suggestions** until confirmed.

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
     output: list of candidate MedicalEvents + document_date + suggested title
     → create MedicalEvent rows (is_confirmed=false, source=ai_document, confidence)
   │
   ▼
(4) LLM Explanation  (parallel to or after structuring)
     output: summary_text, key_points, glossary
     → DocumentExplanation row
   │
   ▼
(5) Trigger summary refresh (debounced) → see 3.4
   │
   ▼
[Document.status = processed]   (any step failure → status=failed + error_message; retriable)
```

### 3.2 Voice Capture Pipeline
```
[Audio bytes received transiently] → (1) STT transcribe → (2) LLM structuring → events → (3) summary refresh
```

### 3.3 On-Demand Explanation
`POST /documents/{id}/explanation/regenerate` re-runs step (4), e.g. in another language.

### 3.4 Summary (Medical Memory) Pipeline
Triggered on meaningful change (debounced) or via `POST /summary/regenerate`.
```
input: current confirmed (+ optionally unconfirmed) MedicalEvents for the subject
process: LLM consolidates into structured sections + narrative
output: new MedicalSummary version (is_current=true; previous → is_current=false)
sections: key_symptoms, major_diagnoses, treatment_history,
          important_examinations, relevant_medications  (BRD §8)
```

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
- Rules: extract only what is present; set low `confidence` when unsure; normalize dates;
  do not infer diagnoses not stated in the text.

### 6.3 Explanation Prompt (intent)
- Input: document text. Output: `summary_text` (plain language), `key_points`, `glossary`.
- Rules: define jargon; explain what a test/value generally means **without** interpreting
  the user's specific health status as good/bad beyond what's written; add the standard
  "this is not medical advice" framing in UI (not baked into stored text).

### 6.4 Summary Prompt (intent)
- Input: structured events. Output: the five BRD sections + a concise doctor-ready narrative.
- Rules: chronological where relevant; concise; flag gaps ("no records between X and Y");
  no diagnostic conclusions.

## 7. Safety, Quality & Disclaimers

- **No-advice filter**: post-process to strip/forbid recommendation phrasing.
- **Uncertainty surfaced**: low-confidence events are visually flagged and require user
  confirmation before counting as "confirmed" history.
- **Disclaimers**: the app consistently frames output as organizational, per BRD trust NFR.
- **Human-in-the-loop**: nothing AI-derived is treated as authoritative without user review.
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
| Cost control | Chunk caps, debounced summary regen, per-job `cost_estimate` tracking |
| Retries | Celery retry with backoff; idempotent by `document_id` to avoid dup events |
| Failure isolation | Each step independent; partial success preserved (e.g. text saved even if structuring fails) |
| Caching | Reuse extracted_text across re-runs (don't re-OCR) |
| Observability | ProcessingJob rows + structured logs + error tracking |

## 10. Evaluation (lightweight, MVP)

- A small **golden set** of de-identified sample documents with expected structured output.
- Track: extraction precision/recall on key fields, explanation readability (manual review),
  and summary completeness against the five BRD sections.
- Prompt changes are versioned and re-run against the golden set before rollout.

## 11. Post-MVP Directions

- Semantic/vector search over history (embeddings) for richer retrieval.
- On-device or self-hosted models for stronger privacy.
- Multilingual document handling improvements.
- Confidence-calibrated auto-confirmation for very high-confidence extractions.
