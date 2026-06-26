# MedStory — Security & Privacy

> Target for the MVP: **GDPR alignment + strong security best practices, HIPAA-ready later.**
> Companion to [Technical Architecture](./technical-architecture.md),
> [Data Model](./data-model.md), [AI Pipeline](./ai-pipeline.md).

MedStory stores sensitive personal health data. Per the BRD's **Privacy** and **Trust**
non-functional requirements, the user must feel confident their information stays under their
control. This document defines the controls to achieve that.

> Note: This is engineering guidance, not legal advice. A qualified DPO/legal review is
> required before production launch with real user data.

## 1. Data Classification

| Class | Examples | Handling |
|-------|----------|----------|
| Special category (health) | Documents, events, summaries, extracted text, audio | Strongest controls: encryption, isolation, minimal sharing |
| Account / PII | Email, name, DOB | Encrypted at rest; access-controlled |
| Auth secrets | Password hashes, JWT secrets | Hashed/secret-managed; never logged |
| Operational metadata | Job status, cost, timestamps | No raw health content; used for ops |

## 2. Authentication & Session Security

- Email/password only (MVP). Passwords hashed with **Argon2** (or PBKDF2) via Django.
- Strong password policy + breached-password rejection; rate-limited login.
- **JWT** access tokens (short-lived, e.g. 15 min) + refresh tokens (longer, rotating).
- Refresh-token **rotation + blacklist** on logout/compromise.
- Tokens stored client-side only in **secure enclave** (Keychain/Keystore).
- Password reset via single-use, expiring tokens; responses avoid email enumeration.

## 3. Authorization & Tenant Isolation

- Every medical resource is scoped to `user_id` (and `subject_id`).
- DRF object-level permissions: a user can only read/write their own data; ownership is
  enforced at the queryset level (filtered by `request.user`), not just per-object checks.
- No cross-user references; every backend record is strictly scoped by `user_id`.
- Admin/staff access to user health data is disabled by default and audited if ever enabled.

## 4. Encryption

- **In transit**: TLS 1.2+ everywhere (client↔API, API↔DB/Redis, API↔AI providers).
- **At rest**:
  - On-device documents/audio rely on OS sandbox protections and device encryption.
  - Database encryption at rest (managed disk/volume encryption).
  - Backups encrypted.
- **Secrets**: managed via environment/secret manager; never committed; rotated periodically.
- **Roadmap**: application-level field encryption and per-user keys for highest-sensitivity
  fields (post-MVP, toward HIPAA-readiness).

## 5. Document & Local File Security

- Documents and audio are stored only in the app sandbox on the user's device.
- Backend accepts transient ingestion uploads only; raw files are discarded after processing.
- File-type/size validation enforced at API boundary; max upload size is **5 MB**.
- Antivirus/malware scan remains a post-MVP hardening item.

## 6. AI Provider Data Handling

- Health content is sent to external AI providers **only from backend workers**, over TLS.
- Send the **minimum necessary** content; redact identifiers where feasible.
- Use providers offering **no-training-on-customer-data / zero or minimal retention**, bound
  by a **Data Processing Agreement (DPA)**.
- Record provider + model + prompt version per output for traceability (metadata only).
- Document all sub-processors (AI, OCR, STT) in the privacy policy.

## 7. GDPR Alignment

| Principle | Implementation |
|-----------|----------------|
| Lawful basis & consent | Explicit consent at signup; clear privacy policy; consent for AI processing of health data |
| Data minimization | Only collect what serves the feature; redact for AI where possible |
| Purpose limitation | Health data used only to organize/explain the user's own history |
| Right of access / portability | `POST /privacy/export` → backend data bundle (JSON metadata/history) |
| Right to erasure | `DELETE /me` purges DB rows (incl. backups per policy) |
| Right to rectification | Users edit/confirm/delete events and documents |
| Storage limitation | Retention policy + deletion of orphaned/temp, expired exports |
| Records of processing | Sub-processor list + data-flow documentation maintained |
| Breach notification | Incident response process (§10) with 72-hour notification readiness |

### Erasure mechanics
- Soft delete (`deleted_at`) for in-app UX; **hard delete** job removes rows on account
  deletion, plus invalidates caches and revokes tokens.
- Export bundles are short-lived and auto-expire.

## 8. Application Security Practices

- **Input validation** via DRF serializers; reject unexpected fields.
- **Output**: consistent error envelope; never leak stack traces or internal IDs to clients.
- **Rate limiting / throttling** on auth and AI-triggering endpoints (cost + abuse control).
- **Dependency hygiene**: pinned dependencies; automated vulnerability scanning (e.g.
  `pip-audit`, Dependabot) in CI.
- **Secrets scanning** in CI to prevent committed credentials.
- **CORS** locked to known clients; security headers (HSTS, no-sniff, etc.) at the proxy.
- **CSRF**: API is token-based (JWT in header), not cookie-session, reducing CSRF surface.
- **SQL injection / XSS**: ORM-parameterized queries; no raw SQL with user input.

## 9. Logging, Monitoring & Auditing

- **No health content in logs**; logs carry IDs/metadata only.
- **AuditLog** table records sensitive actions (login, export, deletion) with IP + timestamp.
- Error tracking (e.g. Sentry) with PII scrubbing enabled.
- Alerts on auth anomalies, elevated error rates, and AI cost spikes.

## 10. Incident Response (outline)

1. Detect (alerts/monitoring) → 2. Contain (revoke tokens/keys, isolate) →
3. Assess scope (which users/data) → 4. Notify (users + authorities within GDPR 72h if
required) → 5. Remediate → 6. Post-mortem + control improvements.

## 11. Client-Side Security

- JWTs only in `flutter_secure_storage`; never in logs or plaintext prefs.
- Local cache (Drift) lives in the app sandbox; cleared on logout/deletion.
- Planned post-MVP: biometric app-lock, certificate pinning, jailbreak/root awareness.

## 12. Environments & Access Control

- Separate dev/staging/prod credentials; **no real user data in non-prod**.
- Least-privilege IAM for DB/secret access; per-service credentials.
- Production access restricted, MFA-protected, and logged.

## 13. Compliance Posture & Roadmap

| Status | Item |
|--------|------|
| MVP | GDPR alignment, TLS, encryption at rest, isolation, export/erasure, DPAs |
| Hardening | Malware scanning, field-level encryption, pen-test, biometric lock, cert pinning |
| HIPAA-ready (later) | BAAs with vendors, expanded audit controls, formal risk assessments, access reviews |

## 14. Security Checklist (pre-launch)

- [ ] TLS enforced end-to-end; HSTS on.
- [ ] Passwords Argon2; login throttled; reset hardened.
- [ ] JWT rotation + blacklist working.
- [ ] On-device file storage is sandboxed/encrypted by platform defaults.
- [ ] Per-user queryset isolation verified by tests.
- [ ] Export + delete flows verified (including backups policy).
- [ ] No health data in logs; PII scrubbing on.
- [ ] DPAs signed with all AI/OCR/STT sub-processors; privacy policy lists them.
- [ ] Dependency + secret scanning in CI; no secrets in repo.
- [ ] Incident response runbook in place.
