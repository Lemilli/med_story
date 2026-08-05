# MedStory Subprocessor Register

This register records external processors that handle MedStory personal data. It is an operational
reference, not a substitute for legal review. Do not record contracts, health
content, credentials, or other sensitive evidence in this repository.

## Operating rule

Do not accept real health data until every triggered processor has an approved entry, the required
DPA/addendum and transfer/retention/no-training review are complete, and the public privacy notice
matches the actual flow. Mock providers and synthetic-only validation do not trigger this gate.

## Current register

| Processor | Service and purpose | Data categories | Trigger | DPA status | Evidence location | Owner / review |
|---|---|---|---|---|---|---|
| OVHcloud | EU VPS hosting for the API and all persistent services | Account data, encrypted originals, structured health data, operational metadata | Public demo VPS | Required before real-data launch; pending | Legal contract repository / vendor account; reference ID only here | Privacy owner; before launch and annually |
| Resend | Transactional verification and reset email | Email address and security code only; never health content | SMTP enabled | Required before real-data launch; pending | Legal contract repository / vendor account; reference ID only here | Privacy owner; before launch and annually |
| OpenAI | LLM, OCR, and STT processing through backend workers | Transient document/audio content and extracted text; minimum necessary health data | Any `AI_*_PROVIDER=openai` setting | Required before real-data launch; pending | Legal contract repository / vendor account; reference ID only here | Privacy owner; before launch and any material service change |

## Adding or changing a processor

1. Complete the DPA checklist before the processor receives real personal or health data.
2. Add the provider, data flow, retention/transfer terms, review status, evidence reference, owner,
   and review date above.
3. Update the public privacy policy and the AI pipeline documentation with the subprocessor when
   applicable.
4. Review the entry annually and whenever the processor, model, data categories, retention, or
   subprocessor list changes.
