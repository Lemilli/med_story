# MedStory Subprocessor Register

This register records external processors that handle MedStory personal data. It is the project's
operational self-review record, not legal advice. Do not record contracts, health
content, credentials, or other sensitive evidence in this repository.

## Operating rule

Do not accept real health data until every triggered processor has an approved entry, the required
DPA/addendum and transfer/retention/no-training review are complete, and the public privacy notice
matches the actual flow. Mock providers and synthetic-only validation do not trigger this gate.

## Current register

| Processor | Service and purpose | Data categories | Trigger | DPA status | Evidence location | Owner / review |
|---|---|---|---|---|---|---|
| OVHcloud | EU VPS hosting for the API and all persistent services | Account data, encrypted originals, structured health data, operational metadata | Public demo VPS | Self-review approved 2026-08-05; conditional on verifying the ordered VPS is in the EU/EEA and saving account contract evidence | `processor-dpa-review.md`; private vendor account after order | MedStory operator; 2027-08-05 or material change |
| Resend | Transactional verification and reset email | Email address, single-use security message, and delivery metadata only; never health content | SMTP enabled | Self-review approved 2026-08-05 for security email only; SCC transfer and documented 30-day email-data retention accepted | `processor-dpa-review.md`; executed dashboard DPA to be retained privately | MedStory operator; 2027-08-05 or material change |
| OpenAI | LLM, OCR, and STT processing through backend workers | Transient document/audio content and extracted text; minimum necessary health data | Any `AI_*_PROVIDER=openai` setting | Self-review approved 2026-08-05 for optional consented processing; no training opt-in, `store=false`, default abuse monitoring accepted, no ZDR claim | `processor-dpa-review.md`; account/project evidence to be retained privately | MedStory operator; 2027-08-05 or material service change |

## Adding or changing a processor

1. Complete the DPA checklist before the processor receives real personal or health data.
2. Add the provider, data flow, retention/transfer terms, review status, evidence reference, owner,
   and review date above.
3. Update the public privacy policy and the AI pipeline documentation with the subprocessor when
   applicable.
4. Review the entry annually and whenever the processor, model, data categories, retention, or
   subprocessor list changes.
