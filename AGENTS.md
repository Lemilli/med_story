# Agent Notes

## Project Basics
- Repo root: `/Users/alibekkapan/Documents/Flutter Projects/med_story`
- Backend virtualenv: `backend/.venv`
- Use backend Python as `backend/.venv/bin/python`.
- Main backend app runs through Docker on `http://0.0.0.0:8000`.
- API docs are at `http://0.0.0.0:8000/api/docs/`.

## Backend Commands
- Run backend tests from repo root with deterministic mock AI:
  `DATABASE_URL=sqlite:////private/tmp/med_story_test.sqlite3 AI_LLM_PROVIDER=mock AI_OCR_PROVIDER=mock AI_STT_PROVIDER=mock backend/.venv/bin/python backend/manage.py test medical.tests`
- The repo `.env` is Docker-oriented and points Postgres at host `db`; host-side test runs should override `DATABASE_URL`.
- If testing inside Docker, remember the compose setup mounts `backend/` as `/app`; root-level `test_assets/` may not be visible there.

## Local API Verification
- Prefer the existing backend on port `8000`; do not start a second backend on `8001` just for manual verification.
- It is acceptable to upload files from `test_assets/` into the local backend for testing.
- It is also acceptable to upload other project sample fixtures when they are clearly test/demo data.
- Use `http://0.0.0.0:8000/api/docs/` or `/api/schema/` to confirm endpoint shapes before manual API calls.

## Editing Hygiene
- Keep changes scoped; do not revert unrelated dirty work.
- Use `apply_patch` for manual file edits.
- Avoid committing, staging, or destructive git commands unless the user explicitly asks.
