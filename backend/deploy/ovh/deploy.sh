#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
backend_dir="$(cd -- "${script_dir}/../.." && pwd)"
compose_file="${backend_dir}/docker-compose.prod.yml"
environment_file="${backend_dir}/.env.production"
compose=(sudo docker compose --env-file "${environment_file}" -f "${compose_file}")

if [[ ! -f "${environment_file}" ]]; then
  echo "Missing ${environment_file}; run prepare-env.sh first." >&2
  exit 1
fi
if grep -Eq 'CHANGE_ME|<[^>]+>' "${environment_file}"; then
  echo "Production environment still contains placeholder values." >&2
  exit 1
fi

cd "${backend_dir}"
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Refusing to deploy a checkout with tracked local changes." >&2
  exit 1
fi

"${compose[@]}" config --quiet
"${compose[@]}" build --pull
"${compose[@]}" run --rm api python manage.py check --deploy --fail-level WARNING
"${compose[@]}" run --rm api python manage.py migrate --noinput
"${compose[@]}" up -d --remove-orphans

for attempt in {1..60}; do
  if curl --fail --silent --show-error --max-time 5 http://127.0.0.1:8000/readyz >/dev/null; then
    "${compose[@]}" ps
    echo "MedStory is live locally and all required dependencies passed readiness checks."
    exit 0
  fi
  sleep 5
done

"${compose[@]}" ps
"${compose[@]}" logs --tail=100 api
echo "Deployment did not become ready within 300 seconds." >&2
exit 1
