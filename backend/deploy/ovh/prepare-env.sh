#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <api-domain> <from-email>" >&2
  echo "Example: $0 api.example.com no-reply@example.com" >&2
  exit 1
fi

api_domain="$1"
from_email="$2"
if [[ ! "${api_domain}" =~ ^[A-Za-z0-9.-]+$ ]] || [[ "${api_domain}" != *.* ]]; then
  echo "The API domain is not valid." >&2
  exit 1
fi
if [[ ! "${from_email}" =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]]; then
  echo "The sender email is not valid." >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
backend_dir="$(cd -- "${script_dir}/../.." && pwd)"
environment_file="${backend_dir}/.env.production"
if [[ -e "${environment_file}" ]]; then
  echo "Refusing to overwrite ${environment_file}." >&2
  exit 1
fi

umask 077
django_secret="$(openssl rand -base64 64 | tr -d '\r\n')"
database_password="$(openssl rand -hex 32)"

sed \
  -e "s|<strong-secret>|${django_secret}|" \
  -e "s|<your-domain-or-server-ip>|${api_domain},localhost,127.0.0.1|" \
  -e "s|<your-api-domain>|${api_domain}|g" \
  -e "s|<strong-db-password>|${database_password}|g" \
  -e "s|<default-from-email>|${from_email}|" \
  "${backend_dir}/.env.production.example" > "${environment_file}"
chmod 600 "${environment_file}"

echo "Created ${environment_file} with generated Django and PostgreSQL secrets."
echo "Replace every CHANGE_ME value before deployment."
