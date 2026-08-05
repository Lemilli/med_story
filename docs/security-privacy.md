# MedStory — Security & Privacy

> Target for the MVP: **GDPR alignment + strong security best practices, HIPAA-ready later.**
> Companion to [Technical Architecture](./technical-architecture.md),
> [Data Model](./data-model.md), [AI Pipeline](./ai-pipeline.md).

MedStory stores sensitive personal health data. Per the BRD's **Privacy** and **Trust**
non-functional requirements, the user must feel confident their information stays under their
control. This document defines the controls to achieve that.

> Note: This is engineering guidance, not legal advice. The operator owns the production decision
> and should seek jurisdiction-specific specialist advice when a material risk cannot be understood
> or accepted; outside legal sign-off is not an engineering launch prerequisite.

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
- Public registration creates an inactive account. Six-digit email verification/reset challenges
  expire after 15 minutes, allow five attempts, invalidate on resend/use, and are persisted only as
  HMAC-SHA256 digests keyed by the deployment secret and challenge UUID. Unverified accounts are
  removed after 24 hours.

## 3. Authorization & Tenant Isolation

- Every medical resource is scoped to `user_id` (and `subject_id`).
- DRF object-level permissions: a user can only read/write their own data; ownership is
  enforced at the queryset level (filtered by `request.user`), not just per-object checks.
- No cross-user references; every backend record is strictly scoped by `user_id`.
- Admin/staff access to user health data is disabled by default and audited if ever enabled.

## 4. Encryption

- **In transit**: TLS 1.2+ everywhere (client↔API, API↔DB/Redis, API↔AI providers).
- **At rest**:
  - PDF/image originals use framed AWS Encryption SDK encryption with key commitment before
    Garage receives them. A unique wrapping key and SDK data key are generated per blob.
  - Only the versioned deployment-master-key-wrapped blob key is stored in PostgreSQL. The
    256-bit master key is mounted read-only and never appears in Git, DB, Garage metadata,
    Compose environment output, or logs. Data-key caching is disabled.
  - Database encryption at rest (managed disk/volume encryption).
  - The Garage volume uses full-disk encryption. V1 deliberately has no object backup.
- **Secrets**: managed via environment/secret manager; never committed; rotated periodically.
- **Roadmap**: application-level field encryption and per-user keys for highest-sensitivity
  fields (post-MVP, toward HIPAA-readiness).

## 5. Private Original Storage

- Garage runs single-node on a dedicated encrypted EU/EEA volume. S3, admin, and RPC ports are
  absent from public networks; API/workers reach S3 through a verified private TLS proxy.
- ClamAV exposes no host port. It joins the application network for outbound signature refreshes
  and the private storage network for API/worker scan requests.
- Upload, authenticated user read, processing read, and deletion use independent bucket-scoped
  credentials. Garage 2.3 bucket ACLs expose `read`, `write`, and `owner` rather than action-level
  policies, so upload and deletion are separately rotated identities but both necessarily have the
  bucket `write` capability (put/delete); read-only identities cannot put or delete. Flutter
  receives no Garage credential, address, or presigned URL.
- Ciphertext keys are random opaque identifiers. Garage sees no user IDs, filenames, MIME types,
  medical terms, plaintext hashes, or health metadata.
- Plaintext staging uses a size-limited `tmpfs`. PDF/JPEG/PNG/HEIC/HEIF magic bytes must match the
  declared MIME type. Self-hosted ClamAV is fail-closed: positive files are rejected and scanner
  outages return `503`.
- The logical document limit is 25 MB and distinct per-account originals are limited to 100 MiB in
  the low-cost single-VPS launch.
  Keyed fingerprints enable reference-counted deduplication only within one account.
- Django scopes both document and asset IDs to `request.user`, decrypts and streams the response,
  and sets `private, no-store`/`nosniff`. Ciphertext tampering, context mismatch, or missing keys
  fails closed.
- Flutter stores original metadata only. Picker/camera and viewer files are temporary and cleaned
  after acknowledgement/use and on startup/logout. Explicit Download/Share creates a user-controlled
  copy. Originals require online authenticated access from any signed-in device.
- Voice objects are encrypted transient staging only. Successful transcription deletes local and
  server recordings; failures retain the local recording for retry, with scheduled server cleanup.

## 6. AI Provider Data Handling

- Health content is sent to external AI providers **only from backend workers**, over TLS.
- Send the **minimum necessary** content; redact identifiers where feasible.
- Prefer providers offering **no-training-on-customer-data / zero or minimal retention**.
- Record provider + model + prompt version per output for traceability (metadata only).
- Document all sub-processors (AI, OCR, STT) in the privacy policy.
- Every health-data subprocessor requires a signed DPA, EU region/transfer review, no-training
  controls, and minimal-retention verification before production.
- Provider exception bodies are never returned or logged. Public API responses are `no-store`, and
  production admin/schema/docs endpoints are disabled.

## 7. GDPR Alignment

| Principle | Implementation |
|-----------|----------------|
| Lawful basis & consent | Explicit consent at signup; clear privacy policy; consent for AI processing of health data |
| Data minimization | Only collect what serves the feature; redact for AI where possible |
| Purpose limitation | Health data used only to organize/explain the user's own history |
| Right to erasure | Wrapped keys are destroyed first; opaque object-deletion jobs survive account removal |
| Right to rectification | Users edit/confirm/delete events and documents |
| Storage limitation | Retention policy + deletion of orphaned/temp data |
| Records of processing | Sub-processor list + data-flow documentation maintained |
| Breach notification | Incident response process (§10) with 72-hour notification readiness |

### Erasure mechanics
- Soft delete (`deleted_at`) for in-app UX; `DELETE /me` immediately hard-deletes the
  account and cascaded backend records, making existing access tokens unusable because the
  user no longer exists. A provided refresh token is blacklisted best-effort before deletion.
- Document deletion hides derived events and destroys the wrapped blob key when the final
  per-account reference disappears. The independent deletion job retries physical Garage cleanup.
  Account deletion destroys all wrapped keys before removing the user. Garage version retention is
  disabled. Deleting only an event does not delete its source document.
- The saved visit reason is sensitive, user-authored data. During an explicit summary refresh it may
  be sent to the configured AI provider as delimited, untrusted, prioritization-only context. It is
  length-limited, cannot add medical facts or alter system instructions, and is never logged.

## 8. Application Security Practices

- **Input validation** via DRF serializers; reject unexpected fields.
- **Summary provenance validation** accepts only source event UUIDs that were supplied to the model
  and belong to the authenticated user and selected subject; provenance labels and page metadata are
  added authoritatively by the backend rather than trusted from model output.
- **Output**: consistent error envelope; never leak stack traces or internal IDs to clients.
- **Rate limiting / throttling**: login/registration are limited to 5 requests/IP/hour;
  verification and password-reset routes have stricter per-IP/per-email limits; refresh/logout are
  limited to 20/IP/hour; AI routes are also throttled to 10/user/hour; other traffic to 120/minute.
  Production throttle state is shared through Redis. Caddy replaces `X-Forwarded-For`, and exactly
  one trusted proxy is required in production.
- **Cost/abuse controls**: registration and AI have operator kill switches; verified accounts are
  capped at 100; AI quota reservations are atomic and charged before queue/provider work. Defaults
  are 10 units/user/day, 20 globally/day, and 150 globally/month.
- **Dependency hygiene**: automated `pip-audit` and OSV scans cover Python and Flutter
  dependencies, and Dependabot proposes weekly updates for supported manifests and CI actions.
- **Secrets scanning**: Gitleaks scans full committed history in CI.
- **CORS** locked to known clients; security headers (HSTS, no-sniff, etc.) at the proxy.
- **CSRF**: API is token-based (JWT in header), not cookie-session, reducing CSRF surface.
- **SQL injection / XSS**: ORM-parameterized queries; no raw SQL with user input.

## 9. Logging, Monitoring & Auditing

The Flutter debug HTTP logger records request method/URL/status only. Authorization headers,
request/response bodies, extracted text, transcripts, and other medical content are disabled.

- **No health content in logs**; logs carry IDs/metadata only.
- **AuditLog** records login, original open/download, and deletion using IDs/metadata only.
- Error tracking (e.g. Sentry) with PII scrubbing enabled.
- Alerts on auth anomalies, elevated error rates, and AI cost spikes.

## 10. Incident Response (outline)

1. Detect (alerts/monitoring) → 2. Contain (revoke tokens/keys, isolate) →
3. Assess scope (which users/data) → 4. Notify (users + authorities within GDPR 72h if
required) → 5. Remediate → 6. Post-mortem + control improvements.

## 11. Client-Side Security

- JWTs only in `flutter_secure_storage`; never in logs or plaintext prefs.
- Local cache (Drift) lives in the app sandbox; cleared on logout/deletion.
- Persistent upload metadata is account-scoped, and authentication changes cancel local
  continuation of upload/polling workflows so one account cannot inherit another account's queue.
- Planned post-MVP: biometric app-lock, certificate pinning, jailbreak/root awareness.

## 12. Environments & Access Control

- Separate dev/staging/prod credentials; **no real user data in non-prod**.
- Least-privilege IAM for DB/secret access; per-service credentials.
- Production access restricted, MFA-protected, and logged.

### Low-cost single-VPS production deployment

The repository includes a hardened, single-node OVHcloud deployment. Django fails closed on an
unsafe production secret, wildcard/placeholder hosts, non-PostgreSQL database, missing Redis
throttle cache, or an unexpected proxy count. Containers use resource/PID limits, rotated local
logs, least-privilege storage credentials, read-only filesystems where supported, dropped
capabilities, and a non-root API/worker/beat user. Only Caddy is public; `/healthz` is liveness and
`/readyz` checks required dependencies without naming the failed dependency to clients.

There is no application-managed database/object backup. The selected OVHcloud Standard Automated
Backup provides one daily full-VPS restore point on a 24-hour rotation, so up to approximately 24
hours of changes may be lost and no older point is available. It is not treated as a recovery
guarantee until the QEMU guest agent is active and a full synthetic restore has recovered both a
PostgreSQL marker and an application-encrypted Garage object. Backup copies may retain deleted bytes
until rotation. Users must see and accept the current versioned notice before registration, while
AI processing remains a separate optional consent.

## 13. Compliance Posture & Roadmap

| Status | Item |
|--------|------|
| MVP | GDPR alignment, TLS, encryption at rest, isolation, erasure |
| Hardening | Pen-test, hardware/remote key management, biometric lock, cert pinning |
| HIPAA-ready (later) | BAAs with vendors, expanded audit controls, formal risk assessments, access reviews |

## 14. Security Checklist (pre-launch)

- [ ] TLS enforced end-to-end; HSTS on.
- [x] Passwords Argon2; login throttled; reset hardened.
- [x] JWT rotation + blacklist working.
- [x] Originals encrypted before private object storage; no durable automatic device copies.
- [x] Per-user queryset isolation verified by tests.
- [x] Document/account cryptographic-erasure and durable deletion-job flows covered by tests.
- [ ] No health data in logs; PII scrubbing on.
- [ ] Garage AGPLv3 use approved for proprietary MedStory.
- [ ] Ordered production hosting is verified as EU/EEA and its account contract evidence retained.
- [x] Processor DPA/transfer/no-training/retention self-review approved and recorded.
- [ ] Offline sealed recovery copy of the master key verified.
- [x] One-daily-point/no-application-backup data-loss notice and explicit signup acceptance implemented.
- [ ] QEMU guest agent verified; full OVHcloud restore drill recovers PostgreSQL, encrypted Garage,
  readiness, decryption, and Celery before registration is enabled.
- [x] Dependency + secret scanning in CI; no secrets in repo.
- [ ] Incident response runbook in place.
