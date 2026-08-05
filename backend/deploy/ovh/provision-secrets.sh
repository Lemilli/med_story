#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
backend_dir="$(cd -- "${script_dir}/../.." && pwd)"
secret_dir="${backend_dir}/secrets"

required_commands=(openssl chmod mkdir tr)
for required_command in "${required_commands[@]}"; do
  if ! command -v "${required_command}" >/dev/null 2>&1; then
    echo "Required command is missing: ${required_command}" >&2
    exit 1
  fi
done

secret_files=(
  original_master_key
  garage_rpc_secret
  garage_admin_token
  garage_bootstrap_access_key
  garage_bootstrap_secret_key
  garage_upload_access_key
  garage_upload_secret_key
  garage_read_access_key
  garage_read_secret_key
  garage_processing_access_key
  garage_processing_secret_key
  garage_deletion_access_key
  garage_deletion_secret_key
  storage_ca_private_key.pem
  storage_ca_certificate.pem
  storage_tls_private_key.pem
  storage_tls_certificate.pem
)

mkdir -p "${secret_dir}"
for secret_file in "${secret_files[@]}"; do
  if [[ -e "${secret_dir}/${secret_file}" ]]; then
    echo "Refusing to overwrite existing secret: ${secret_dir}/${secret_file}" >&2
    echo "Move the existing secret set aside before intentionally provisioning a new deployment." >&2
    exit 1
  fi
done

umask 077
openssl rand -base64 32 | tr -d '\r\n' > "${secret_dir}/original_master_key"
openssl rand -hex 32 > "${secret_dir}/garage_rpc_secret"
openssl rand -hex 32 > "${secret_dir}/garage_admin_token"

for role in bootstrap upload read processing deletion; do
  printf 'GK%s\n' "$(openssl rand -hex 16)" > "${secret_dir}/garage_${role}_access_key"
  openssl rand -hex 32 > "${secret_dir}/garage_${role}_secret_key"
done

openssl req -x509 -newkey rsa:3072 -sha256 -days 3650 -nodes \
  -keyout "${secret_dir}/storage_ca_private_key.pem" \
  -out "${secret_dir}/storage_ca_certificate.pem" \
  -subj "/CN=MedStory Internal Storage CA"

certificate_request="$(mktemp "${TMPDIR:-/tmp}/medstory-garage-proxy.XXXXXX.csr")"
certificate_serial="${certificate_request%.csr}.srl"
trap 'rm -f -- "${certificate_request}" "${certificate_serial}"' EXIT

openssl req -new -newkey rsa:3072 -sha256 -nodes \
  -keyout "${secret_dir}/storage_tls_private_key.pem" \
  -out "${certificate_request}" \
  -subj "/CN=garage-proxy" \
  -addext "subjectAltName=DNS:garage-proxy"

openssl x509 -req -sha256 -days 825 \
  -in "${certificate_request}" \
  -CA "${secret_dir}/storage_ca_certificate.pem" \
  -CAkey "${secret_dir}/storage_ca_private_key.pem" \
  -CAserial "${certificate_serial}" \
  -CAcreateserial \
  -copy_extensions copy \
  -out "${secret_dir}/storage_tls_certificate.pem"

chmod 600 "${secret_dir}"/*

echo "Provisioned a new MedStory secret set in ${secret_dir}."
echo "Move storage_ca_private_key.pem and a copy of original_master_key to encrypted offline storage."
echo "Do not build or start production until .env.production has also been prepared."
