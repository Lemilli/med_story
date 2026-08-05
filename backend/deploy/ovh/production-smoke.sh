#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "${script_dir}" rev-parse --show-toplevel)"
source_commit="$(git -C "${repo_root}" rev-parse --verify 'HEAD^{commit}')"
cold_start_cycles="${SMOKE_COLD_START_CYCLES:-2}"

if [[ ! "${cold_start_cycles}" =~ ^[12]$ ]]; then
  echo "SMOKE_COLD_START_CYCLES must be 1 or 2." >&2
  exit 1
fi

for command in git docker curl openssl awk grep sed mktemp python3; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Required smoke-test command is missing: ${command}" >&2
    exit 1
  fi
done

smoke_root="$(mktemp -d "${TMPDIR:-/tmp}/medstory-production-smoke.XXXXXX")"
smoke_repo="${smoke_root}/repo"
project_suffix="$(openssl rand -hex 6)"
export COMPOSE_PROJECT_NAME="medstory-smoke-${project_suffix}"
export API_HOST_PORT="$(python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')"
environment_file="${smoke_repo}/backend/.env.production"
compose_file="${smoke_repo}/backend/docker-compose.prod.yml"
docker_command=(docker)
compose=(docker compose --env-file "${environment_file}" -f "${compose_file}")
smoke_failed=1

safe_diagnostics() {
  if [[ -f "${environment_file}" ]]; then
    echo "Production smoke service state:" >&2
    "${compose[@]}" ps >&2 || true
    echo "Selected privacy-safe infrastructure logs:" >&2
    "${compose[@]}" logs --no-color --tail=40 db redis clamav 2>&1 \
      | sed -E 's#(postgres(ql)?://)[^@[:space:]]+@#\1[REDACTED]@#g' >&2 || true
  fi
}

cleanup() {
  if [[ "${smoke_failed}" -ne 0 ]]; then
    safe_diagnostics
  fi
  if [[ -f "${environment_file}" ]]; then
    "${compose[@]}" down --volumes --remove-orphans --timeout 30 >/dev/null 2>&1 || true
  fi
  rm -rf -- "${smoke_root}"
}
trap cleanup EXIT INT TERM

upsert_environment_value() {
  local key="$1"
  local value="$2"
  local temporary_file
  temporary_file="$(mktemp "${smoke_root}/environment.XXXXXX")"
  awk -v key="${key}" -v replacement="${key}=${value}" '
    BEGIN { found = 0 }
    index($0, key "=") == 1 { print replacement; found = 1; next }
    { print }
    END { if (!found) print replacement }
  ' "${environment_file}" > "${temporary_file}"
  mv -- "${temporary_file}" "${environment_file}"
  chmod 600 "${environment_file}"
}

assert_http_status() {
  local expected="$1"
  local path="$2"
  local actual
  actual="$(curl --silent --output /dev/null --write-out '%{http_code}' \
    --max-time 10 --header 'X-Forwarded-Proto: https' \
    "http://127.0.0.1:${API_HOST_PORT}${path}")"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "Expected HTTP ${expected} from ${path}; received ${actual}." >&2
    return 1
  fi
}

wait_for_readiness() {
  local attempt
  for attempt in {1..60}; do
    if curl --fail --silent --output /dev/null --max-time 5 \
      "http://127.0.0.1:${API_HOST_PORT}/readyz"; then
      return 0
    fi
    sleep 5
  done
  echo "Production stack did not regain readiness within 300 seconds." >&2
  return 1
}

assert_expected_services_running() {
  local service
  local expected_services=(api worker beat garage garage-proxy clamav db redis)
  local running_services
  running_services="$("${compose[@]}" ps --status running --services)"
  for service in "${expected_services[@]}"; do
    if ! grep -Fx "${service}" <<<"${running_services}" >/dev/null; then
      echo "Expected production service is not running: ${service}" >&2
      return 1
    fi
  done
  if [[ "$(wc -w <<<"${running_services}" | tr -d ' ')" -ne 8 ]]; then
    echo "Expected exactly eight long-running production services." >&2
    return 1
  fi
}

wait_for_configured_health() {
  local attempt
  local service
  local container_id
  local health
  local all_healthy
  for attempt in {1..60}; do
    all_healthy=1
    for service in api db redis garage-proxy; do
      container_id="$("${compose[@]}" ps -q "${service}")"
      health="$("${docker_command[@]}" inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}missing{{end}}' "${container_id}")"
      if [[ "${health}" != "healthy" ]]; then
        all_healthy=0
      fi
    done
    if [[ "${all_healthy}" -eq 1 ]]; then
      return 0
    fi
    sleep 5
  done
  echo "Configured container healthchecks did not all become healthy within 300 seconds." >&2
  return 1
}

assert_no_public_data_ports() {
  local service
  local container_id
  local port_bindings
  for service in db redis garage garage-proxy clamav; do
    container_id="$("${compose[@]}" ps -q "${service}")"
    port_bindings="$("${docker_command[@]}" inspect --format '{{json .HostConfig.PortBindings}}' "${container_id}")"
    if [[ "${port_bindings}" != "{}" && "${port_bindings}" != "null" ]]; then
      echo "${service} unexpectedly publishes a host port." >&2
      return 1
    fi
  done
}

assert_service_environment_allowlists() {
  local service
  local container_id
  local environment_names
  local forbidden_name
  local forbidden_app_names=(
    POSTGRES_ADMIN_PASSWORD
    POSTGRES_MIGRATOR_PASSWORD
    POSTGRES_APP_PASSWORD
    MIGRATION_DATABASE_URL
  )

  for service in api worker beat; do
    container_id="$("${compose[@]}" ps -q "${service}")"
    environment_names="$(
      "${docker_command[@]}" inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "${container_id}" \
        | sed 's/=.*$//'
    )"
    for forbidden_name in "${forbidden_app_names[@]}"; do
      if grep -Fx "${forbidden_name}" <<<"${environment_names}" >/dev/null; then
        echo "${service} unexpectedly receives ${forbidden_name}." >&2
        return 1
      fi
    done
  done

  environment_names="$(
    "${compose[@]}" run --rm --no-deps --entrypoint sh migrate \
      -c 'env | sed "s/=.*$//"' 2>/dev/null
  )"
  if grep -Fx POSTGRES_ADMIN_PASSWORD <<<"${environment_names}" >/dev/null; then
    echo "The migration service unexpectedly receives POSTGRES_ADMIN_PASSWORD." >&2
    return 1
  fi
}

assert_dirty_deploy_preflights() {
  local output
  local tracked_file="${smoke_repo}/backend/deploy/ovh/README.md"
  local untracked_file="${smoke_repo}/backend/medstory-smoke-untracked"

  printf '\n' >> "${tracked_file}"
  if output="$(cd "${smoke_repo}/backend" && ./deploy/ovh/deploy.sh 2>&1)"; then
    echo "Deploy preflight unexpectedly accepted a tracked edit." >&2
    return 1
  fi
  if ! grep -F "tracked or non-ignored untracked local changes" <<<"${output}" >/dev/null; then
    echo "Tracked-edit deploy preflight failed for an unexpected reason." >&2
    return 1
  fi
  git -C "${smoke_repo}" checkout --quiet -- backend/deploy/ovh/README.md

  printf 'synthetic smoke preflight marker\n' > "${untracked_file}"
  if output="$(cd "${smoke_repo}/backend" && ./deploy/ovh/deploy.sh 2>&1)"; then
    echo "Deploy preflight unexpectedly accepted a non-ignored untracked file." >&2
    return 1
  fi
  if ! grep -F "tracked or non-ignored untracked local changes" <<<"${output}" >/dev/null; then
    echo "Untracked-file deploy preflight failed for an unexpected reason." >&2
    return 1
  fi
  rm -f -- "${untracked_file}"

  if [[ -n "$(git -C "${smoke_repo}" status --porcelain=v1 --untracked-files=all)" ]]; then
    echo "The disposable checkout was not clean after deploy preflight tests." >&2
    return 1
  fi
  if [[ -n "$(git -C "${smoke_repo}" tag --points-at HEAD)" ]]; then
    echo "The disposable smoke commit must be untagged." >&2
    return 1
  fi
}

run_cycle() {
  local cycle="$1"
  local object_key="production-smoke/${project_suffix}-${cycle}"
  local canary="MEDSTORY_SMOKE_SENSITIVE_QUERY_${project_suffix}_${cycle}"
  local proxy_uid

  echo "Starting production Compose cold-start cycle ${cycle}/${cold_start_cycles}."
  (cd "${smoke_repo}/backend" && ./deploy/ovh/deploy.sh)

  assert_expected_services_running
  wait_for_configured_health
  assert_no_public_data_ports
  assert_service_environment_allowlists

  proxy_uid="$("${compose[@]}" exec -T garage-proxy id -u)"
  if [[ "${proxy_uid}" != "101" ]]; then
    echo "Garage proxy must run as UID 101; received ${proxy_uid}." >&2
    return 1
  fi

  assert_http_status 200 /healthz
  assert_http_status 200 /readyz
  assert_http_status 404 /admin/
  assert_http_status 404 /api/schema/
  assert_http_status 404 /api/docs/

  "${compose[@]}" exec -T api python deploy/ovh/production_smoke_checks.py database-role
  "${compose[@]}" exec -T api python deploy/ovh/production_smoke_checks.py storage-put "${object_key}"

  assert_http_status 401 "/api/v1/events/search?q=${canary}"
  if "${compose[@]}" logs --no-color api garage-proxy 2>/dev/null \
    | grep -F "${canary}" >/dev/null; then
    echo "A sensitive query canary appeared in API or Garage proxy logs." >&2
    return 1
  fi

  "${compose[@]}" restart db redis garage >/dev/null
  wait_for_readiness
  assert_expected_services_running
  wait_for_configured_health

  "${compose[@]}" exec -T api python deploy/ovh/production_smoke_checks.py storage-verify-delete "${object_key}"
  "${compose[@]}" exec -T api python deploy/ovh/production_smoke_checks.py celery
}

echo "Creating an isolated smoke checkout from commit ${source_commit} and the current non-ignored worktree."
git clone --quiet --local --no-hardlinks "${repo_root}" "${smoke_repo}"
git -C "${smoke_repo}" checkout --quiet --detach "${source_commit}"

while IFS= read -r -d '' relative_path; do
  mkdir -p -- "${smoke_repo}/$(dirname -- "${relative_path}")"
  cp -pP -- "${repo_root}/${relative_path}" "${smoke_repo}/${relative_path}"
done < <(
  {
    git -C "${repo_root}" diff HEAD --name-only --diff-filter=ACMRTUXB -z
    git -C "${repo_root}" ls-files --others --exclude-standard -z
  }
)
while IFS= read -r -d '' relative_path; do
  rm -f -- "${smoke_repo}/${relative_path}"
done < <(git -C "${repo_root}" diff HEAD --name-only --diff-filter=D -z)

git -C "${smoke_repo}" add --all
git -C "${smoke_repo}" \
  -c user.name='MedStory production smoke' \
  -c user.email='smoke@invalid.example' \
  commit --quiet --allow-empty --message='Synthetic production smoke snapshot'

(cd "${smoke_repo}/backend" && ./deploy/ovh/provision-secrets.sh)
(cd "${smoke_repo}/backend" && ./deploy/ovh/prepare-env.sh smoke.invalid no-reply@smoke.invalid)
upsert_environment_value EMAIL_HOST_PASSWORD smoke-only-no-network
upsert_environment_value AI_OPENAI_API_KEY smoke-only-no-network
upsert_environment_value AI_LLM_PROVIDER mock
upsert_environment_value AI_OCR_PROVIDER mock
upsert_environment_value AI_STT_PROVIDER mock
upsert_environment_value AI_ENABLED False
upsert_environment_value REGISTRATION_ENABLED False

assert_dirty_deploy_preflights

if ! docker info >/dev/null 2>&1; then
  if command -v sudo >/dev/null 2>&1 && sudo -n docker info >/dev/null 2>&1; then
    docker_command=(sudo -n docker)
    compose=(sudo -n docker compose --env-file "${environment_file}" -f "${compose_file}")
  else
    echo "Docker is not available to the current user and passwordless sudo Docker is unavailable." >&2
    exit 1
  fi
fi

for ((cycle = 1; cycle <= cold_start_cycles; cycle += 1)); do
  run_cycle "${cycle}"
  if [[ "${cycle}" -lt "${cold_start_cycles}" ]]; then
    "${compose[@]}" down --volumes --remove-orphans --timeout 30 >/dev/null
  fi
done

smoke_failed=0
echo "Production Compose smoke test passed ${cold_start_cycles} cold-start cycle(s)."
