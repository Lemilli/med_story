# MedStory Backend

This backend is a standalone Django project. Run commands from this folder:

```bash
cd backend
```

## Local Development

Local development uses Docker Compose, so you do not need a Python `.venv` for the backend.

Start the database, Redis, API, and worker:

```bash
docker compose up --build
```

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

Optional local environment overrides can go in `.env`. The Compose file already provides safe
development defaults, so `.env` is not required to start.

To use real OpenAI-backed document processing locally, set these values in `backend/.env` before
starting Compose. Add the STT values when testing voice capture:

```bash
AI_LLM_PROVIDER=openai
AI_OCR_PROVIDER=openai
AI_STT_PROVIDER=openai
AI_OPENAI_API_KEY=<your-openai-api-key>
AI_OPENAI_MODEL=<your-model>
AI_OPENAI_OCR_MODEL=<your-model>
AI_OPENAI_STT_MODEL=gpt-4o-mini-transcribe
```

`AI_STT_PROVIDER` defaults to `mock` for deterministic local tests. The API and Celery worker both
need the same AI settings because ingestion is queued from the API and processed by the worker.

## Production Flow: VPS

Production on a VPS uses `docker-compose.prod.yml`, not the local development Compose file.

The production Compose file runs:

- API with Gunicorn
- Celery worker
- PostgreSQL with a persistent Docker volume
- Redis with a persistent Docker volume

On the VPS:

1. Install Docker and Docker Compose.
2. Clone or pull the project.
3. Create `.env.production` in the `backend` folder:

```bash
cp .env.production.example .env.production
```

Then edit `.env.production` with real VPS values.

Required production values:

```bash
DEBUG=False
SECRET_KEY=<strong-secret>
ALLOWED_HOSTS=<your-domain-or-server-ip>
CORS_ALLOWED_ORIGINS=

POSTGRES_DB=medstory
POSTGRES_USER=medstory
POSTGRES_PASSWORD=<strong-db-password>
DATABASE_URL=postgres://medstory:<strong-db-password>@db:5432/medstory

CELERY_BROKER_URL=redis://redis:6379/0
CELERY_RESULT_BACKEND=redis://redis:6379/0

AI_LLM_PROVIDER=openai
AI_OCR_PROVIDER=openai
AI_STT_PROVIDER=openai
AI_OPENAI_API_KEY=<your-openai-api-key>
AI_OPENAI_MODEL=<your-model>
AI_OPENAI_OCR_MODEL=<your-model>
AI_OPENAI_STT_MODEL=gpt-4o-mini-transcribe
AI_OPENAI_TIMEOUT_SECONDS=60
```

Build and start production services:

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

Run migrations:

```bash
docker compose -f docker-compose.prod.yml run --rm api python manage.py migrate
```

View logs:

```bash
docker compose -f docker-compose.prod.yml logs -f
```

Stop services:

```bash
docker compose -f docker-compose.prod.yml down
```

The API is bound to `127.0.0.1:8000` on the VPS. Put Nginx or Caddy in front of it for HTTPS and
public traffic.
