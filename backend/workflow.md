# MedStory Backend

This backend is a standalone Django project. Run commands from this folder:

```bash
cd backend
```

## Local Development

Local development uses Docker Compose, so you do not need a Python `.venv` for the backend.

First provision the private-storage secret files described in
[`secrets/README.md`](./secrets/README.md). Then start PostgreSQL, Redis, API/worker/beat, Garage,
the internal TLS proxy, and ClamAV:

```bash
docker compose up --build
```

The Compose stack builds a small Alpine wrapper around the official Garage binary so its secret-fed
bootstrap script works on both ARM64 and amd64 hosts. ClamAV uses its multi-architecture Debian
image; no `DOCKER_DEFAULT_PLATFORM` override or emulation is required.

Run migrations:

```bash
docker compose run --rm api python manage.py migrate
```

Run tests:

```bash
docker compose run --rm api python manage.py test
```

Useful URLs:

- API: `http://localhost:8000/api/v1/`
- OpenAPI schema: `http://localhost:8000/api/schema/`
- Swagger UI: `http://localhost:8000/api/docs/`
- Django admin: `http://localhost:8000/admin/`

Optional local environment overrides can go in `.env`. Secret files are always required for the
Garage-backed Compose stack and are ignored by Git.

To use real OpenAI-backed document processing locally, set these values in `backend/.env` before
starting Compose. Add the STT values when testing voice capture:

```bash
AI_LLM_PROVIDER=openai
AI_OCR_PROVIDER=openai
AI_STT_PROVIDER=openai
AI_OPENAI_API_KEY=<your-openai-api-key>
AI_OPENAI_MODEL=<your-model>
AI_OPENAI_SUMMARY_MODEL=<stronger-summary-model>
AI_OPENAI_OCR_MODEL=<your-model>
AI_OPENAI_STT_MODEL=gpt-4o-mini-transcribe
```

`AI_STT_PROVIDER` defaults to `mock` for deterministic local tests. The API and Celery worker both
need the same AI settings because ingestion is queued from the API and processed by the worker.

## Public Demonstration: OVHcloud VPS

Use the hardened production Compose file and the complete
[`deploy/ovh/README.md`](./deploy/ovh/README.md) runbook. It covers the selected low-cost server,
domain/TLS/email setup, host firewall and SSH hardening, secret provisioning, deployment,
verification, updates, rollback, cost controls, and the intentional no-recovery posture.

The short path after the VPS prerequisites are complete is:

```bash
./deploy/ovh/provision-secrets.sh
./deploy/ovh/prepare-env.sh api.example.com no-reply@example.com
sudoedit .env.production
./deploy/ovh/deploy.sh
```

Do not run the development Compose file publicly. Do not expose PostgreSQL, Redis, Garage, ClamAV,
or port 8000. The demonstration is a single-node environment with no application-managed backup or
availability guarantee; accepting real health data additionally requires the documented legal and
subprocessor approvals.
