# Local private-storage secrets

Generate these files before starting the Garage-backed stack. This directory is
ignored by Git except for this README.

- `original_master_key`: base64 encoding of exactly 32 random bytes.
- `garage_rpc_secret`: 32 random bytes encoded as 64 lowercase hex characters.
- `garage_admin_token`: a long random token.
- `garage_bootstrap_access_key` / `garage_bootstrap_secret_key`: used only
  inside the Garage container to create the private bucket and application
  permissions. It uses the same Garage key formats below.
- Four independent Garage key pairs: `garage_upload_*`, `garage_read_*`,
  `garage_processing_*`, and `garage_deletion_*`. Access IDs must use Garage's
  `GK` plus 32 hexadecimal character format; secrets are 64 hexadecimal
  characters. The entrypoint grants only write, read, read, and write
  respectively, and none can create buckets.
- `storage_tls_certificate.pem` / `storage_tls_private_key.pem`: certificate
  and private key for the internal `garage-proxy` name.
- `storage_ca_certificate.pem`: CA certificate used by the API and worker to
  verify the internal storage proxy.

Use restrictive file permissions (`chmod 600`). Production secrets must be
provisioned by the host secret manager and must not be copied from development.
The certificate must include `DNS:garage-proxy` in its subject alternative
names. Use a private CA (or a self-signed development certificate) and never
disable verification in production.
