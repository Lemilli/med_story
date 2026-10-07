#!/bin/sh
set -eu

# Compose file-backed secrets preserve host ownership on Linux. Copy only each
# service's allowlisted files into its private volume before non-root startup.
copy_secrets() {
  destination="$1"
  owner="$2"
  shift 2
  umask 077
  for name in "$@"; do
    cp "/run/secrets/${name}" "${destination}/${name}"
    chmod 400 "${destination}/${name}"
  done
  chown -R "${owner}:${owner}" "${destination}"
  chmod 700 "${destination}"
}

copy_secrets /secrets/api 10001 \
  original_master_key storage_ca_certificate \
  garage_upload_access_key garage_upload_secret_key \
  garage_read_access_key garage_read_secret_key \
  garage_deletion_access_key garage_deletion_secret_key
copy_secrets /secrets/worker 10001 \
  original_master_key storage_ca_certificate \
  garage_processing_access_key garage_processing_secret_key \
  garage_deletion_access_key garage_deletion_secret_key
copy_secrets /secrets/proxy 101 storage_tls_certificate storage_tls_private_key
