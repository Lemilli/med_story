#!/usr/bin/env python
"""Synthetic, privacy-safe assertions used by the production Compose smoke test."""

import argparse
import os
import sys
import uuid
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

import django  # noqa: E402

django.setup()

from botocore.exceptions import ClientError  # noqa: E402
from django.db import DatabaseError, connection, transaction  # noqa: E402

from config.celery import app as celery_app  # noqa: E402
from medical.original_storage import get_object_store  # noqa: E402


MARKER_PAYLOAD = b"MedStory production smoke test: synthetic data only."


class _UnexpectedDdlSuccess(Exception):
    pass


def _assert_insufficient_privilege(statement):
    try:
        with transaction.atomic():
            with connection.cursor() as cursor:
                cursor.execute(statement)
            # Raising inside the transaction guarantees rollback before the assertion fails.
            raise _UnexpectedDdlSuccess
    except DatabaseError as exc:
        cause = exc.__cause__
        sqlstate = getattr(cause, "sqlstate", None) or getattr(cause, "pgcode", None)
        if sqlstate != "42501":
            raise AssertionError(
                f"DDL failed for an unexpected reason (SQLSTATE {sqlstate or 'unknown'})."
            ) from exc
    except _UnexpectedDdlSuccess as exc:
        raise AssertionError("The runtime database role unexpectedly executed DDL.") from exc


def check_database_role():
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT current_user, rolsuper, rolcreatedb, rolcreaterole
              FROM pg_roles
             WHERE rolname = current_user
            """
        )
        role_name, is_superuser, can_create_db, can_create_role = cursor.fetchone()
        cursor.execute(
            """
            SELECT nspowner::regrole::text
              FROM pg_namespace
             WHERE nspname = 'public'
            """
        )
        schema_owner = cursor.fetchone()[0]
        cursor.execute(
            """
            SELECT relname, relowner::regrole::text
              FROM pg_class
              JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
             WHERE pg_namespace.nspname = 'public'
               AND pg_class.relkind IN ('r', 'p', 'S')
             ORDER BY relname
            """
        )
        object_owners = cursor.fetchall()

    if role_name != "medstory_app":
        raise AssertionError(f"Expected medstory_app, received {role_name!r}.")
    if any((is_superuser, can_create_db, can_create_role)):
        raise AssertionError("The runtime database role has administrative privileges.")
    if schema_owner != "medstory_migrator":
        raise AssertionError(f"The public schema is owned by {schema_owner!r}.")
    if not any(name == "django_migrations" for name, _ in object_owners):
        raise AssertionError("The migration-created django_migrations table is missing.")
    unexpected_owners = [
        f"{name}:{owner}" for name, owner in object_owners if owner != "medstory_migrator"
    ]
    if unexpected_owners:
        raise AssertionError(
            "Migration-created public objects have unexpected owners: "
            + ", ".join(unexpected_owners)
        )

    table_name = f"medstory_smoke_ddl_{uuid.uuid4().hex}"
    _assert_insufficient_privilege(f'CREATE TABLE "{table_name}" (id integer)')
    _assert_insufficient_privilege("DROP TABLE django_migrations")
    print("Runtime database role is non-administrative and DDL is denied.")


def _assert_s3_denied(operation, description):
    try:
        operation()
    except ClientError as exc:
        response = exc.response or {}
        status = response.get("ResponseMetadata", {}).get("HTTPStatusCode")
        code = response.get("Error", {}).get("Code")
        if status != 403 and code not in {"AccessDenied", "Forbidden"}:
            raise AssertionError(
                f"{description} failed with {code or status}, not an authorization denial."
            ) from exc
    else:
        raise AssertionError(f"{description} unexpectedly succeeded.")


def put_storage_marker(object_key):
    upload = get_object_store("upload")
    read = get_object_store("read")
    deletion = get_object_store("deletion")

    upload.put(object_key, MARKER_PAYLOAD)
    _assert_s3_denied(
        lambda: upload.client.get_object(Bucket=upload.bucket, Key=object_key),
        "Upload-role read",
    )
    if read.get(object_key) != MARKER_PAYLOAD:
        raise AssertionError("The read role returned the wrong synthetic marker.")
    _assert_s3_denied(
        lambda: read.client.put_object(
            Bucket=read.bucket,
            Key=f"{object_key}-forbidden",
            Body=MARKER_PAYLOAD,
        ),
        "Read-role write",
    )
    _assert_s3_denied(
        lambda: read.client.delete_object(Bucket=read.bucket, Key=object_key),
        "Read-role delete",
    )
    _assert_s3_denied(
        lambda: deletion.client.get_object(Bucket=deletion.bucket, Key=object_key),
        "Deletion-role read",
    )
    print("Garage role separation and synthetic marker write/read succeeded.")


def verify_and_delete_storage_marker(object_key):
    read = get_object_store("read")
    deletion = get_object_store("deletion")

    if read.get(object_key) != MARKER_PAYLOAD:
        raise AssertionError("The synthetic Garage marker did not survive the restart.")
    deletion.delete(object_key)
    try:
        read.client.get_object(Bucket=read.bucket, Key=object_key)
    except ClientError as exc:
        response = exc.response or {}
        status = response.get("ResponseMetadata", {}).get("HTTPStatusCode")
        code = response.get("Error", {}).get("Code")
        if status != 404 and code not in {"NoSuchKey", "NotFound"}:
            raise AssertionError(
                f"Deleted marker lookup failed with {code or status}, not not-found."
            ) from exc
    else:
        raise AssertionError("The deletion role did not remove the synthetic Garage marker.")
    print("Garage persistence and deletion succeeded.")


def check_celery_round_trip():
    result = celery_app.send_task("medical.tasks.purge_storage_deletions_task")
    try:
        value = result.get(timeout=60)
        if not isinstance(value, dict) or "processed" not in value:
            raise AssertionError("Celery returned an unexpected synthetic smoke result.")
    finally:
        result.forget()
    print("Celery dispatch and result retrieval succeeded.")


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("database-role")
    put_parser = subparsers.add_parser("storage-put")
    put_parser.add_argument("object_key")
    delete_parser = subparsers.add_parser("storage-verify-delete")
    delete_parser.add_argument("object_key")
    subparsers.add_parser("celery")
    args = parser.parse_args()

    if args.command == "database-role":
        check_database_role()
    elif args.command == "storage-put":
        put_storage_marker(args.object_key)
    elif args.command == "storage-verify-delete":
        verify_and_delete_storage_marker(args.object_key)
    elif args.command == "celery":
        check_celery_round_trip()


if __name__ == "__main__":
    main()
