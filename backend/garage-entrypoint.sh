#!/bin/sh
set -eu

read_secret() {
  tr -d '\r\n' < "$1"
}

export GARAGE_RPC_SECRET="$(read_secret /run/secrets/garage_rpc_secret)"
export GARAGE_ADMIN_TOKEN="$(read_secret /run/secrets/garage_admin_token)"
# Garage's nested admin setting has used this expanded environment name too.
# Export both forms so the token is applied across the supported image line.
export GARAGE_ADMIN_ADMIN_TOKEN="$GARAGE_ADMIN_TOKEN"
export GARAGE_DEFAULT_ACCESS_KEY="$(read_secret /run/secrets/garage_bootstrap_access_key)"
export GARAGE_DEFAULT_SECRET_KEY="$(read_secret /run/secrets/garage_bootstrap_secret_key)"
export GARAGE_DEFAULT_BUCKET="${ORIGINAL_STORAGE_BUCKET:-medstory-originals}"

/garage server --single-node --default-bucket &
garage_pid=$!
trap 'kill "$garage_pid" 2>/dev/null || true' INT TERM

until /garage status >/dev/null 2>&1; do
  if ! kill -0 "$garage_pid" 2>/dev/null; then
    wait "$garage_pid"
    exit $?
  fi
  sleep 1
done

import_key() {
  name="$1"
  access_file="$2"
  secret_file="$3"
  permissions="$4"
  access_key="$(read_secret "$access_file")"
  secret_key="$(read_secret "$secret_file")"
  if ! /garage key info "$access_key" >/dev/null 2>&1; then
    /garage key import --yes "$access_key" "$secret_key" -n "$name" >/dev/null
  fi
  # Permissions are idempotent and bucket-scoped. None of these keys can
  # create buckets or administer Garage.
  # shellcheck disable=SC2086
  /garage bucket allow "$GARAGE_DEFAULT_BUCKET" --key "$access_key" $permissions >/dev/null
}

import_key medstory-upload /run/secrets/garage_upload_access_key /run/secrets/garage_upload_secret_key "--write"
import_key medstory-read /run/secrets/garage_read_access_key /run/secrets/garage_read_secret_key "--read"
import_key medstory-processing /run/secrets/garage_processing_access_key /run/secrets/garage_processing_secret_key "--read"
import_key medstory-deletion /run/secrets/garage_deletion_access_key /run/secrets/garage_deletion_secret_key "--write"

wait "$garage_pid"
