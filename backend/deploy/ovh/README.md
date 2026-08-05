# OVHcloud VPS demonstration deployment

This runbook deploys the complete MedStory backend to one OVHcloud VPS. It is intentionally a
low-cost, single-node demonstration environment: PostgreSQL, Redis, Garage, ClamAV, the API, and
Celery all share one host. It has no application-managed backup or availability guarantee.

The target size is OVHcloud VPS-2 (4 vCPU, 8 GB RAM, 75 GB NVMe) running Ubuntu 24.04 LTS on
x86-64. Prefer Warsaw when it is offered at the target price; otherwise use Frankfurt. Confirm the
final regional price, tax, and included features before purchasing. If VPS-2 is unavailable or is
more than USD 10/month before tax, use a Hetzner CAX21 and run the same ARM64-compatible stack.

## 1. Accounts, domain, and spending controls

1. Enable MFA on OVHcloud, the source-control account, Resend, the domain registrar, and OpenAI.
2. Buy a domain and create an `A` record such as `api.example.com` pointing to the VPS IPv4 address.
3. Create a Resend account, verify the sending domain, and publish its SPF, DKIM, and DMARC records.
   The free transactional plan is sufficient for the demo. Never place health content in email.
4. Create a dedicated OpenAI project and API key. Configure a USD 10 monthly project budget and
   alerts at USD 5, USD 8, and USD 10. MedStory's application quotas are the primary circuit breaker;
   the provider setting is a second operational signal.
5. Complete the processor/DPA review for OVHcloud, Resend, and OpenAI before accepting real health
   information.

OVHcloud currently includes a rolling VPS snapshot. MedStory does not operate or promise restores
from it. The privacy notice must state that recovery is not guaranteed and that deleted bytes may
remain in an infrastructure-provider snapshot until that provider's retention period expires.

## 2. Create and secure the VPS

Add an SSH public key during VPS creation. Sign in as the initially provisioned administrator, apply
updates, and create the long-lived operator account:

```bash
sudo apt update
sudo apt full-upgrade
sudo apt install unattended-upgrades ca-certificates curl git openssl ufw
sudo adduser medstory
sudo usermod -aG sudo medstory
sudo install -d -o medstory -g medstory -m 0700 /home/medstory/.ssh
```

Copy the approved SSH public key into `/home/medstory/.ssh/authorized_keys`, set it to mode `0600`,
and confirm a second SSH session works as `medstory` before disabling password and root login. Add an
`sshd_config.d` drop-in containing:

```text
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

Validate with `sudo sshd -t`, then reload SSH. Configure the host firewall, substituting the
operator's actual fixed IP or VPN CIDR:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 203.0.113.10/32 to any port 22 proto tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

Also enable OVHcloud's network firewall/anti-DDoS controls where available. PostgreSQL, Redis,
Garage, ClamAV, and port 8000 must never be opened publicly. Docker publishes only the API on host
loopback, so it cannot bypass the public firewall for those services.

Install Docker Engine and its Compose plugin from Docker's official Ubuntu apt repository; do not
use the convenience script for production. Follow:

- <https://docs.docker.com/engine/install/ubuntu/>
- <https://docs.docker.com/compose/install/linux/>

Install the official Caddy Ubuntu package from <https://caddyserver.com/docs/install>. Keep the
deployment user out of the `docker` group; the supplied scripts use `sudo docker` because Docker
group membership is root-equivalent.

## 3. Install a tagged MedStory release

```bash
sudo install -d -o medstory -g medstory -m 0750 /opt/medstory
sudo -u medstory git clone <repository-url> /opt/medstory
sudo -u medstory git -C /opt/medstory fetch --tags
sudo -u medstory git -C /opt/medstory checkout <release-tag>
cd /opt/medstory/backend
```

Use a read-only repository deploy key. Do not embed a personal access token in the Git remote URL.
Deploy only signed-off tags and never a moving branch.

Provision a new secret set once:

```bash
chmod +x deploy/ovh/*.sh
./deploy/ovh/provision-secrets.sh
./deploy/ovh/prepare-env.sh api.example.com no-reply@example.com
```

Move `secrets/storage_ca_private_key.pem` and an encrypted copy of `secrets/original_master_key` to
offline storage, then remove the CA private key from the VPS. The application never needs the CA
private key after the internal Garage certificate has been issued. Keep every remaining secret and
`.env.production` at mode `0600`.

Edit `.env.production` and replace both `CHANGE_ME` values with the dedicated Resend and OpenAI API
keys. Confirm all hostnames, sender addresses, AI models, quotas, and limits. Never paste secrets into
shell command arguments, Git, tickets, or deployment logs.

Install the public proxy configuration:

```bash
sudo cp deploy/ovh/Caddyfile.example /etc/caddy/Caddyfile
sudoedit /etc/caddy/Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

Replace `api.example.com` before validation. The configuration intentionally does not enable Caddy
access logs because URLs and query strings can contain sensitive search context.

## 4. Pre-publication deployment

For the first deployment, temporarily set all three AI providers to `mock` and use synthetic data
only. Deploy from the clean tagged checkout:

```bash
./deploy/ovh/deploy.sh
```

The script validates Compose, builds current base images, runs Django's deployment checks with
warnings treated as failures, applies migrations, starts the stack, and waits up to five minutes
for `/readyz` so the database, Redis, Garage, and ClamAV must all be available.

Verify locally and publicly:

```bash
curl --fail http://127.0.0.1:8000/healthz
curl --fail https://api.example.com/healthz
curl --fail https://api.example.com/readyz
curl --head http://api.example.com/healthz
```

Confirm HTTP redirects to HTTPS; admin, schema, and Swagger paths return 404; and only ports 22, 80,
and 443 are reachable externally. Run a synthetic registration, email verification, login, manual
event, PDF/image upload, voice transcription, explanation, summary, original download, and account
deletion flow.

After the synthetic flow passes, delete all test accounts, set the AI providers to `openai`, deploy
again, and repeat one end-to-end flow with a synthetic fixture. Publish the mobile build only after
the AI and email circuit breakers have been observed in the live environment.

Build the native client with the public API URL:

```bash
cd /opt/medstory/frontend
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

Use the equivalent `flutter build ipa` workflow for iOS signing and distribution.

## 5. Routine operation

Inspect state without printing environment values:

```bash
cd /opt/medstory/backend
sudo docker compose --env-file .env.production -f docker-compose.prod.yml ps
sudo docker stats --no-stream
df -h
```

Alert or intervene before host memory or disk remains above 80%. Keep at least 15 GB free so image
builds, ClamAV signatures, PostgreSQL, and encrypted originals do not exhaust the disk. Application
logs rotate automatically; never enable verbose provider, proxy request, or database statement logs.

To disable paid processing immediately, set `AI_ENABLED=False` in `.env.production` and redeploy.
To close registration, set `REGISTRATION_ENABLED=False` and redeploy. Existing verified accounts
remain usable.

For a release update:

```bash
git fetch --tags
git checkout <new-release-tag>
./deploy/ovh/deploy.sh
```

Rollback means checking out the previous release tag and redeploying its containers. Database
migrations must remain backward-compatible across one release; do not run reverse migrations on the
live VPS. If a migration is not backward-compatible, ship a forward repair release.

There is deliberately no `pg_dump`, Garage copy, or off-site restore procedure for this demo. Do not
represent this environment as durable production storage.
