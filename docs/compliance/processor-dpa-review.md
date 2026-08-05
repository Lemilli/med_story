# Processor and DPA Self-Review

**Decision date:** 6 August 2026
**Decision owner:** MedStory operator  
**Scope:** OVHcloud VPS hosting, Resend transactional email, and OpenAI API processing  
**Review type:** founder/operator risk review based on the providers' published contracts and
MedStory's implemented data flows; this is not legal advice.

## Decision

The three processors are **approved for MedStory's intended limited use**, subject to the mandatory
configuration conditions below. This completes the project's processor/DPA review; it does not
claim that MedStory has received a bespoke legal opinion.

The online agreements are suitable for this limited MVP because each provider publishes a processor
addendum, security obligations, deletion/return terms, subprocessor controls, and a transfer
mechanism where relevant. The operator accepts the residual risks described below. A provider must
be disabled if an account-specific setting or purchased product does not match this record.

## Mandatory conditions

1. The OVHcloud VPS must be ordered in the EU/EEA. The exact region and applicable contract/DPA must
   be saved from the customer account before real users are enabled.
2. Resend may receive only an email address plus a verification or password-reset message. Medical
   content, names of conditions, document titles, and timeline content must never be emailed.
3. Resend open and click tracking must remain disabled. Its documented 30-day email-data retention
   is accepted for these security-only messages; MedStory does not claim zero retention.
4. OpenAI processing is an intrinsic MedStory service function disclosed in the required combined
   privacy notice. Only the backend may call OpenAI, and only the minimum content needed for OCR,
   transcription, organization, or explanation may be sent.
5. OpenAI Responses API calls must set `store=false`. MedStory accepts default abuse-monitoring
   retention of up to 30 days for eligible response content; it does not claim Zero Data Retention.
   Audio transcription currently has no abuse-monitoring or application-state retention in the
   provider's endpoint table.
6. OpenAI API data-sharing/training opt-in must remain off. The production key must belong to a
   dedicated MedStory project.
7. No provider may use MedStory data for advertising. No advertising or tracking SDK may be added
   without a new review and updated store disclosures.
8. Subscribe to or periodically review provider subprocessor changes. Re-review annually and before
   changing region, plan, endpoint, model family, retention controls, or data categories.

## Provider records

### OVHcloud — approved subject to EU/EEA order verification

- **Role/purpose:** processor providing the VPS on which the API, PostgreSQL, Redis, Garage,
  ClamAV, and workers run.
- **Data:** account identifiers, encrypted original documents, structured health history,
  privacy-notice acceptance records, and operational metadata. OVHcloud can necessarily access infrastructure-level data in
  support/security scenarios even though application originals are envelope-encrypted.
- **Location/transfer decision:** persistent production workloads must remain in the selected
  EU/EEA VPS region. Any remote support/subprocessor access is governed by the applicable DPA and
  transfer terms. The exact order region controls; marketing descriptions do not.
- **Retention/deletion:** MedStory controls live-server deletion. Provider snapshots or service
  removal cycles may delay physical erasure, so they must be documented after the VPS is ordered and
  disclosed to users. The app promises no guaranteed restore.
- **Contract evidence:** the applicable General Terms, VPS terms, and Data Processing Agreement in
  the OVHcloud customer account. Store a private copy/reference after ordering; do not commit it.
- **Residual risk accepted:** single-node availability and possible temporary deleted-byte
  persistence in provider snapshots. This is acceptable only with the existing explicit
  no-guaranteed-recovery notice.

### Resend / Plus Five Five, Inc. — approved for security email only

- **Role/purpose:** processor sending email verification and password-reset messages through SMTP.
- **Data:** recipient email address, sender address, security code/link, delivery metadata, and
  message body. No health data is intentionally sent.
- **Location/transfer decision:** Resend and many listed subprocessors are in the United States.
  Its DPA incorporates the EU and UK Standard Contractual Clauses. The operator accepts that
  transfer for minimal security-email data.
- **Retention/deletion:** Resend documents 30-day email-data retention across standard plans and
  deletion of customer data within 90 days after account termination. Message-storage disabling is
  a paid, eligibility-gated option and is not assumed.
- **Contract evidence:** Resend states its DPA becomes binding when the customer accepts the service
  agreement and makes the executed version available in the dashboard. Save the dashboard copy or
  its non-secret reference privately.
- **Residual risk accepted:** US processing and 30-day storage of addresses/security messages. The
  risk is reduced by short-lived, single-use codes and the prohibition on health content in email.

### OpenAI — approved for core organization/explanation features

- **Role/purpose:** processor for LLM structuring and explanations, image/PDF OCR, and speech-to-text.
- **Data:** user-selected document images/PDFs, extracted medical text, voice recordings,
  transcripts, timeline facts, and optional visit context. This can include special-category health
  data and incidental identifiers present in user documents.
- **Location/transfer decision:** the current DPA names OpenAI Ireland for customers based in the
  EEA/Switzerland and OpenAI OpCo for other customers, and incorporates SCCs for relevant transfers;
  its current subprocessor list is incorporated by reference. No EU data-residency claim is made
  for this MVP.
- **Training/retention:** API content is not used to train models unless the customer opts in.
  MedStory uses `/v1/responses` with `store=false` and `/v1/audio/transcriptions`. Default abuse
  monitoring for Responses may retain content for up to 30 days; the transcription endpoint is
  listed with no abuse-monitoring or application-state retention. ZDR/MAM are not claimed.
- **Contract evidence:** the OpenAI DPA states it is incorporated into the Services Agreement and
  accepted by agreeing to or using the Services. Save the current DPA, Services Agreement, account
  entity, and project data-control screenshot/reference privately.
- **Residual risk accepted:** transient cross-border processing and up-to-30-day abuse-monitoring
  retention of highly sensitive content. The operator accepts this for the MVP because mandatory
  processing is disclosed before registration, remains user-initiated and purpose-limited, sends
  minimum necessary content, and is protected by provider, quota, and emergency kill-switch
  controls.

## Evidence index (public, non-secret)

- OVHcloud: [contracts](https://www.ovhcloud.com/en-gb/terms-and-conditions/contracts/) and
  [GDPR FAQ](https://www.ovhcloud.com/en-ie/personal-data-protection/faq/)
- Resend: [DPA](https://resend.com/legal/dpa),
  [subprocessors](https://resend.com/legal/subprocessors), and
  [message-storage controls](https://resend.com/docs/knowledge-base/how-do-i-ensure-sensitive-data-isnt-stored-on-resend)
- OpenAI: [DPA](https://openai.com/policies/data-processing-addendum/),
  [subprocessors](https://platform.openai.com/subprocessors), and
  [API data controls](https://developers.openai.com/api/docs/guides/your-data)

## Account evidence to retain privately

These are evidence-collection steps, not unresolved processor decisions:

- legal name/entity operating MedStory and the account-holder identity for each provider;
- OVHcloud order number, EU/EEA region, contract/DPA versions, and snapshot behavior;
- Resend executed-DPA dashboard copy, sending region, tracking settings, and domain verification;
- OpenAI DPA/Services Agreement versions, dedicated project ID, training opt-out, and retention
  control screenshot; and
- the next review date: **5 August 2027**, or earlier after a material provider change.
