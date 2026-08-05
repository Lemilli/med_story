#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
backend_dir="$(cd -- "${script_dir}/../.." && pwd)"
compose_file="${backend_dir}/docker-compose.prod.yml"
environment_file="${backend_dir}/.env.production"
api_host_port="${API_HOST_PORT:-8000}"

if [[ ! "${api_host_port}" =~ ^[0-9]+$ ]] \
  || ((api_host_port < 1 || api_host_port > 65535)); then
  echo "API_HOST_PORT must be an integer from 1 through 65535." >&2
  exit 1
fi

if [[ ! -f "${environment_file}" ]]; then
  echo "Missing ${environment_file}; run prepare-env.sh first." >&2
  exit 1
fi
if grep -Eq 'CHANGE_ME|<[^>]+>' "${environment_file}"; then
  echo "Production environment still contains placeholder values." >&2
  exit 1
fi

cd "${backend_dir}"
if ! git rev-parse --verify --quiet 'HEAD^{commit}' >/dev/null; then
  echo "Refusing to deploy a checkout without a valid Git commit." >&2
  exit 1
fi
if [[ -n "$(git status --porcelain=v1 --untracked-files=all --ignore-submodules=none)" ]]; then
  echo "Refusing to deploy a checkout with tracked or non-ignored untracked local changes." >&2
  exit 1
fi

docker_command=(docker)
if ! docker info >/dev/null 2>&1; then
  if ! command -v sudo >/dev/null 2>&1 || ! sudo -n docker info >/dev/null 2>&1; then
    echo "Docker is not accessible. Grant direct access or run 'sudo -v' before deploying." >&2
    exit 1
  fi
  docker_command=(sudo -n docker)
fi
compose=("${docker_command[@]}" compose --env-file "${environment_file}" -f "${compose_file}")

"${compose[@]}" config --quiet
"${compose[@]}" pull db redis garage-proxy clamav
"${compose[@]}" build --pull api worker beat migrate garage
"${compose[@]}" run --rm api python manage.py check --deploy --fail-level WARNING
"${compose[@]}" run --rm migrate
"${compose[@]}" up -d --remove-orphans

for attempt in {1..60}; do
  if curl --fail --silent --show-error --max-time 5 \
    "http://127.0.0.1:${api_host_port}/readyz" >/dev/null; then
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
