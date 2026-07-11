# MedStory Subprocessor Register

This optional register records external processors that handle MedStory personal data. It is an
operational reference, not a substitute for legal review. Do not record contracts, health
content, credentials, or other sensitive evidence in this repository.

## Operating rule

Real providers can be enabled in production without completing this register or executing a DPA.
Use the register when it is useful for the team's privacy and vendor-management process. Mock
providers do not receive personal data.

## Current register

| Processor | Service and purpose | Data categories | Trigger | DPA status | Evidence location | Owner / review |
|---|---|---|---|---|---|---|
| OpenAI | LLM, OCR, and optional STT processing through backend workers | Transient document/audio content and extracted text; minimal necessary health data | Any `AI_*_PROVIDER=openai` production setting | Optional review, not a launch gate | Legal contract repository / vendor account; reference ID only here | Privacy owner; at least annual review and before any material service change |

## Adding or changing a processor

1. Optionally complete the DPA checklist when vendor review is desired.
2. Add the provider, data flow, retention/transfer terms, review status, evidence reference, owner,
   and review date above.
3. Update the public privacy policy and the AI pipeline documentation with the subprocessor when
   applicable.
4. Review the entry annually and whenever the processor, model, data categories, retention, or
   subprocessor list changes.
