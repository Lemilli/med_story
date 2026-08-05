#!/usr/bin/env bash
set -Eeuo pipefail

: "${POSTGRES_DB:?POSTGRES_DB is required}"
: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_MIGRATOR_PASSWORD:?POSTGRES_MIGRATOR_PASSWORD is required}"
: "${POSTGRES_APP_PASSWORD:?POSTGRES_APP_PASSWORD is required}"

if [[ "${POSTGRES_USER}" != "medstory_admin" ]]; then
  echo "POSTGRES_USER must be medstory_admin for production initialization." >&2
  exit 1
fi

psql \
  --username "${POSTGRES_USER}" \
  --dbname "${POSTGRES_DB}" \
  --set=ON_ERROR_STOP=1 \
  --set=database_name="${POSTGRES_DB}" \
  --set=migrator_password="${POSTGRES_MIGRATOR_PASSWORD}" \
  --set=app_password="${POSTGRES_APP_PASSWORD}" <<'SQL'
SELECT format(
  'CREATE ROLE medstory_migrator LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION PASSWORD %L',
  :'migrator_password'
)
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'medstory_migrator')
\gexec

SELECT format(
  'ALTER ROLE medstory_migrator LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION PASSWORD %L',
  :'migrator_password'
)
\gexec

SELECT format(
  'CREATE ROLE medstory_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION PASSWORD %L',
  :'app_password'
)
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'medstory_app')
\gexec

SELECT format(
  'ALTER ROLE medstory_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION PASSWORD %L',
  :'app_password'
)
\gexec

SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC', :'database_name')
\gexec
SELECT format('ALTER DATABASE %I OWNER TO medstory_migrator', :'database_name')
\gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO medstory_app', :'database_name')
\gexec

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
ALTER SCHEMA public OWNER TO medstory_migrator;
GRANT USAGE ON SCHEMA public TO medstory_app;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO medstory_app;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO medstory_app;

ALTER DEFAULT PRIVILEGES FOR ROLE medstory_migrator IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO medstory_app;
ALTER DEFAULT PRIVILEGES FOR ROLE medstory_migrator IN SCHEMA public
  GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO medstory_app;
SQL
