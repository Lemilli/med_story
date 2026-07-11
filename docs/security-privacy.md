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
- Prefer providers offering **no-training-on-customer-data / zero or minimal retention**.
- Record provider + model + prompt version per output for traceability (metadata only).
- Document all sub-processors (AI, OCR, STT) in the privacy policy.
- The [subprocessor register](./compliance/subprocessor-register.md) and
  [DPA checklist](./compliance/dpa-execution-checklist.md) are optional compliance references;
  they do not block provider configuration or production startup.

## 7. GDPR Alignment

| Principle | Implementation |
|-----------|----------------|
| Lawful basis & consent | Explicit consent at signup; clear privacy policy; consent for AI processing of health data |
| Data minimization | Only collect what serves the feature; redact for AI where possible |
| Purpose limitation | Health data used only to organize/explain the user's own history |
| Right of access / portability | `POST /privacy/export` → backend data bundle (JSON metadata/history) |
| Right to erasure | `DELETE /me` purges DB rows (incl. backups per policy) |
| Right to rectification | Users edit/confirm/delete events and documents |
| Storage limitation | Retention policy + deletion of orphaned/temp data; no server-side export bundle retention in MVP |
| Records of processing | Sub-processor list + data-flow documentation maintained |
| Breach notification | Incident response process (§10) with 72-hour notification readiness |

### Erasure mechanics
- Soft delete (`deleted_at`) for in-app UX; `DELETE /me` immediately hard-deletes the
  account and cascaded backend records, making existing access tokens unusable because the
  user no longer exists. A provided refresh token is blacklisted best-effort before deletion.
- `POST /privacy/export` returns immediate JSON and does not persist a server-side export bundle.
- Visit-preparation notes are user-authored sensitive data: they are included in the privacy export and in a doctor PDF only when the user explicitly requests that PDF. They are never sent to an AI provider.

## 8. Application Security Practices

- **Input validation** via DRF serializers; reject unexpected fields.
- **Output**: consistent error envelope; never leak stack traces or internal IDs to clients.
- **Rate limiting / throttling**: login/registration are limited to 5 requests/IP/hour;
  refresh/logout to 20/IP/hour; ingestion and AI regenerations to 10/user/hour; other traffic
  to 120 requests/minute. Production throttle state is shared through Redis. The reverse proxy
  must replace `X-Forwarded-For`; `THROTTLE_TRUSTED_PROXY_COUNT=1` enables that trusted address.
- **Dependency hygiene**: automated `pip-audit` and OSV scans cover Python and Flutter
  dependencies, and Dependabot proposes weekly updates for supported manifests and CI actions.
- **Secrets scanning**: Gitleaks scans full committed history in CI.
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
| MVP | GDPR alignment, TLS, encryption at rest, isolation, export/erasure |
| Hardening | Malware scanning, field-level encryption, pen-test, biometric lock, cert pinning |
| HIPAA-ready (later) | BAAs with vendors, expanded audit controls, formal risk assessments, access reviews |

## 14. Security Checklist (pre-launch)

- [ ] TLS enforced end-to-end; HSTS on.
- [ ] Passwords Argon2; login throttled; reset hardened.
- [ ] JWT rotation + blacklist working.
- [ ] On-device file storage is sandboxed/encrypted by platform defaults.
- [ ] Per-user queryset isolation verified by tests.
- [x] Backend export + delete flows verified by tests; backups policy still requires ops/legal review.
- [ ] No health data in logs; PII scrubbing on.
- [ ] Optional: review DPAs and maintain the subprocessor register where applicable.
- [x] Dependency + secret scanning in CI; no secrets in repo.
- [ ] Incident response runbook in place.
