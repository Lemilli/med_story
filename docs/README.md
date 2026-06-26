# MedStory — Documentation Index

This folder contains the technical documentation for the **MedStory** MVP, derived from the
[Business Requirements Document](business_requirements.md).

MedStory is a personal medical memory application that transforms scattered medical documents,
prescriptions, test results, procedures, and notes into a structured, searchable, and
understandable health story.

## Stack at a Glance

| Layer      | Technology |
|------------|-----------|
| Frontend   | Flutter (iOS + Android) |
| Backend    | Django + Django REST Framework (Python) |
| Database   | PostgreSQL |
| Async      | Celery + Redis |
| Storage    | On-device local file storage (backend keeps metadata only) |
| AI         | Cloud LLM API (provider-agnostic) + cloud OCR + cloud STT |
| Auth       | Email/password, JWT |
| Deployment | Docker (cloud-agnostic) |
| Compliance | GDPR + strong security best practices (HIPAA-ready later) |

## Documents

| Document | Purpose |
|----------|---------|
| [technical-architecture.md](./technical-architecture.md) | System design, components, data flow, deployment topology |
| [data-model.md](./data-model.md) | Database schema, entities, relationships |
| [api-specification.md](./api-specification.md) | REST API endpoints, request/response contracts |
| [frontend-architecture.md](./frontend-architecture.md) | Flutter app structure, state management, navigation |
| [ai-pipeline.md](./ai-pipeline.md) | Document ingestion, OCR, LLM processing, prompt design |
| [security-privacy.md](./security-privacy.md) | Security controls, privacy, GDPR alignment |
| [mvp-roadmap.md](./mvp-roadmap.md) | Milestones, phases, scope, success metrics |

## Reading Order

1. Start with **technical-architecture.md** for the big picture.
2. Read **data-model.md** and **api-specification.md** for the backend contract.
3. Read **frontend-architecture.md** for the client.
4. Read **ai-pipeline.md** for the AI-heavy features.
5. Read **security-privacy.md** before handling real medical data.
6. Use **mvp-roadmap.md** to plan delivery.

## Guiding Constraints (from the BRD)

- MedStory is **not** a diagnostic tool, telemedicine platform, or AI doctor.
- Minimize data-entry burden; prioritize voice-first and AI-assisted interactions.
- Value should compound over time; the medical story is continuously updated.
- Information must be understandable to non-medical users.
- The user is always in control of their data.
- MVP document/audio binaries are local-only (no cross-device sync/backup).
