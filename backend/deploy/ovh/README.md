# Put MedStory online on an OVHcloud VPS

This guide explains how to publish the MedStory backend on one OVHcloud VPS. It is written for a
first-time server operator. Follow it from top to bottom and do not use real medical information
until the **real-data launch gate** near the end is complete.

## What this deployment is—and is not

This is a low-cost single-VPS production target. The API, PostgreSQL, Redis, Garage, ClamAV, and
background workers all share that server. It can accept real data only after every real-data launch
gate in this runbook passes and registration is deliberately enabled.

- It supports a controlled real-data launch after the security, privacy, backup-restore, and
  synthetic end-to-end checks are complete.
- It is not a high-availability production system.
- MedStory does not make a separate application-managed database or object backup.
- The included OVHcloud Standard Automated Backup provides one daily full-VPS restore point on a
  24-hour rotation. It can lose approximately the most recent 24 hours of changes.
- Recovery is not promised until the operator has completed and recorded the full restore drill in
  this runbook. Even after a successful drill, this remains a single-server system without high
  availability or multi-day backup history.

The intended server is an x86-64 OVHcloud VPS-2 with Ubuntu 24.04 LTS, 4 vCPU, 8 GB RAM, and about
75 GB of storage. Prefer an EU location such as Warsaw or Frankfurt. Check the price, tax, server
architecture, location, storage, and included backup options on the order screen before paying.

> Important: this is technical guidance, not legal advice. The operator remains responsible for
> the release and may obtain specialist advice if a risk cannot be understood or accepted. A lawyer
> review is not treated as a mandatory engineering or store-submission checklist item.

## Your current progress

As of 5 August 2026:

- [x] OVHcloud account created.
- [x] Two-factor authentication enabled on OVHcloud.
- [x] Resend account and API key created.
- [x] OpenAI account and API key created.
- [x] OpenAI key added to the local development `backend/.env` file.
- [ ] Two-factor authentication checked on the source-control, Resend, domain-registrar, and OpenAI
  accounts.
- [ ] Domain purchased.
- [ ] Domain connected to the VPS.
- [ ] Resend sending domain verified with DNS records.
- [ ] Resend key added to the production VPS file `backend/.env.production`.
- [ ] OpenAI spending limit and alerts checked.
- [x] OVHcloud, Resend, and OpenAI founder-led privacy/DPA review completed; account/order evidence
  still collected during production setup.
- [x] Included backup identified as Standard Automated Backup: one daily restore point with a
  24-hour rotation; account/order evidence still retained privately.
- [ ] QEMU guest agent verified and the full synthetic OVHcloud restore drill passed.
- [ ] VPS ordered, secured, deployed, and tested with synthetic data.

You do not need to finish the DPA review before building and testing with mock providers and
synthetic data. You do need to finish it before MedStory accepts real names, personal email
addresses, documents, recordings, or health information.

## Before you begin: four names that look similar

This guide uses `example.com` as a placeholder. Replace it with the domain you buy.

- `example.com` — the domain you own.
- `api.example.com` — the public address of the MedStory backend.
- `mail.example.com` — the recommended Resend sending subdomain.
- `no-reply@mail.example.com` — the address MedStory uses to send verification and reset messages.

Using a separate `mail` subdomain protects the reputation of the main domain. It does not create an
inbox. Resend permits sending from an address on a verified domain without creating that mailbox,
although an address that can receive replies is preferable.

There are also two different environment files:

- `backend/.env` is for development on your computer.
- `backend/.env.production` is created later on the VPS and is used by the public service.

The public VPS needs its own dedicated Resend and OpenAI keys. Never commit either `.env` file,
paste a key into this README, put a key in a command, or send a key in a support ticket.

## Stage 1: buy and connect a domain

### 1. Buy the domain

Buy a domain from OVHcloud or another registrar. Turn on automatic renewal and registrar lock. Make
sure two-factor authentication is enabled for the registrar account.

You do not need web hosting or an email mailbox package just to run the API and send through Resend.
You need only the domain and access to its DNS settings.

### 2. Order the VPS

Choose Ubuntu 24.04 LTS, x86-64, and an EU location. Add your SSH public key during the order if the
form offers that option. Save the VPS IPv4 address from the OVHcloud Control Panel or welcome email.

### 3. Point `api.example.com` to the VPS

DNS is the internet's address book. An `A` record tells it that `api.example.com` should go to the
VPS IPv4 address.

If OVHcloud manages the domain's DNS:

1. Open the OVHcloud Control Panel.
2. Go to **Web Cloud → DNS zones** and select the domain.
3. Choose **Add an entry** and select record type **A**.
4. Enter `api` in the **Subdomain** field.
5. Enter the VPS IPv4 address in the **Target** field.
6. Confirm the change.

If the domain is managed elsewhere, add the same `A` record in that provider's DNS screen. DNS
changes can take several hours to appear everywhere. Do not add a public DNS record for PostgreSQL,
Redis, Garage, ClamAV, or port 8000.

Official help: [OVHcloud DNS guides](https://help.ovhcloud.com/csm/en-gb-documentation-web-cloud-domains-dns-configuration?id=kb_browse_cat&kb_category=3733f35841f8fa104a4e42ace3ea4ea3&kb_id=e17b4f25551974502d4c6e78b7421955).

## Stage 2: connect Resend and understand SPF, DKIM, and DMARC

SPF, DKIM, and DMARC are DNS records that help receiving mail services recognize legitimate email
from your domain:

- **SPF** says which service is allowed to send email for the domain.
- **DKIM** adds a cryptographic signature so the receiver can check that the email is authentic and
  was not changed in transit.
- **DMARC** tells the receiver what to do when authentication fails and can send failure reports.

You do not invent the SPF or DKIM values. Resend creates the exact records and you copy them into
the DNS control panel.

### Add the Resend DNS records

1. Sign in to Resend and open **Domains**.
2. Choose **Add Domain**.
3. Enter `mail.example.com`, with your real domain in place of `example.com`.
4. If Resend asks for a sending region, choose its EU/Ireland sending region. Be aware that Resend
   states that account data, email metadata, logs, and API records are still stored in the United
   States; this must be covered by the privacy review.
5. Resend displays the records needed for SPF and DKIM. Keep this page open.
6. In the DNS provider, add every record exactly as Resend displays it. Copy the **record type**,
   **name/host**, **value/target**, and **priority** when present.
7. Return to Resend and choose **I've added the records** or **Verify DNS Records**.
8. Wait for the sending status to become **Verified**. It can take several hours. Resend may keep
   checking for up to 72 hours.
9. Add the DMARC record suggested on the Resend domain page. Start with the monitoring policy Resend
   recommends; do not guess a strict rejection policy during initial setup.
10. Leave Resend open tracking and click tracking disabled. MedStory sends security messages, not
    marketing, and does not need recipient tracking.

DNS screens use different names for the same field. For a subdomain, OVHcloud may expect only the
part before your main domain in its **Subdomain** field. For example, if Resend shows a record for
`selector._domainkey.mail.example.com`, OVHcloud may display it as
`selector._domainkey.mail`. Always compare the complete record shown in the final DNS table with
Resend's requested complete name before verifying.

Do not delete an existing SPF record just because Resend gives you another one. A DNS name must not
have two separate SPF TXT records. If the exact same host already has SPF, stop and follow Resend's
conflict instructions or ask its support team how to merge it. DKIM selectors usually have unique
names and do not have this problem.

Official help:

- [Resend domain verification and record explanations](https://resend.com/docs/dashboard/domains/introduction)
- [Resend deliverability and DMARC guidance](https://resend.com/docs/dashboard/emails/deliverability-insights)
- [OVHcloud DMARC guide](https://help.ovhcloud.com/csm/asia-dns-zone-dmarc?id=kb_article_view&sysparm_article=KB0061458)

### Where the Resend API key goes

The key used as the SMTP password belongs in the production file on the VPS:

```dotenv
EMAIL_HOST_PASSWORD=your_resend_api_key
```

Do not add another variable named `RESEND_API_KEY`; this project uses
`EMAIL_HOST_PASSWORD`. The surrounding production email settings are already supplied by
`backend/.env.production.example`:

```dotenv
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.resend.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=resend
DEFAULT_FROM_EMAIL=no-reply@mail.example.com
```

The production file does not exist until `prepare-env.sh` is run in Stage 5. When it exists, open it
interactively with `nano .env.production` or another editor, replace
`CHANGE_ME_RESEND_API_KEY`, save, and close it. Do not paste the secret into a shell command because
commands may be recorded in shell history.

If you also want the backend on your own computer to send real test email, wait until the Resend
domain is verified and add the same email settings to `backend/.env`. From the repository root, open
it with `nano backend/.env` and add the following, replacing the two example values inside the
editor:

```dotenv
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.resend.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=resend
EMAIL_HOST_PASSWORD=your_resend_api_key
DEFAULT_FROM_EMAIL=no-reply@mail.example.com
```

This local key is optional. The default local console email backend is safer when you only need to
test the flow without sending an actual message. The public VPS still needs its own value in
`.env.production`.

MedStory must never put medical information in an email subject or body. Resend should receive only
the recipient's email address and the verification or password-reset message.

## Stage 3: complete the processor and DPA review

### What “processor” and “DPA” mean

MedStory decides why and how user information is used, so its operator is normally the **data
controller**. OVHcloud, Resend, and OpenAI handle some of that information for MedStory, so they are
**data processors** or subprocessors. A **Data Processing Agreement (DPA)** is the contract that
sets rules for that handling.

This is mostly a paperwork and decision step, not a programming step. “Complete the review” means:

1. Identify the person or legal entity operating MedStory and authorized to accept the agreements.
2. Obtain or accept each provider's current DPA.
3. Read and record where data is processed, how long it can be retained, which subprocessors are
   involved, how international transfers are protected, and what happens after deletion.
4. Confirm that the intended MedStory use is permitted by the provider's terms.
5. Record the operator's decision on unresolved risks. Specialist advice remains available if the
   operator cannot understand or accept a material risk, but it is not a project checklist item.
6. Save the agreements and evidence in a private legal folder—not in Git.
7. Update `docs/compliance/subprocessor-register.md` with only a non-secret reference, approval
   status, owner, and next review date.
8. Ensure the public privacy notice accurately names the providers and describes these data flows.

Use [the project's DPA checklist](../../../docs/compliance/dpa-execution-checklist.md) once for each
provider. The current status is tracked in
[the subprocessor register](../../../docs/compliance/subprocessor-register.md).

### Provider-by-provider actions

#### OVHcloud

1. Confirm that the VPS location shown on the order is in the EU/EEA.
2. In the OVHcloud account's contracts/legal area, download the applicable service terms, Data
   Processing Agreement, and current subprocessor list. OVHcloud says its DPA is attached to its
   customer contracts; confirm that it applies to the exact VPS service and your contracting entity.
3. Record the VPS region, support-access rules, subprocessors, breach-notification terms, deletion
   terms, and the snapshot/backup terms.
4. Save the files privately and record a reference and review date in the register.

Official sources: [OVHcloud contracts](https://www.ovhcloud.com/en-gb/terms-and-conditions/contracts/)
and [OVHcloud GDPR FAQ](https://www.ovhcloud.com/en-ie/personal-data-protection/faq/).

#### Resend

1. Read and save Resend's current DPA. Its published DPA says it becomes binding with acceptance of
   the service agreement and incorporates transfer safeguards, but the authorized MedStory
   operator must confirm that this is valid for their account and jurisdiction.
2. Record that Resend's primary processing is in the United States and review the transfer mechanism
   and subprocessor list.
3. Record the current message/metadata retention and deletion terms. Resend currently documents
   email-data retention and separately offers message-content storage controls only to qualifying
   paid customers. Do not assume the free plan provides zero retention.
4. Keep tracking disabled and confirm that MedStory sends no health content.
5. Save the evidence privately and update the register.

Official sources: [Resend DPA](https://resend.com/legal/dpa),
[Resend subprocessors](https://resend.com/legal/subprocessors), and
[Resend sensitive-data storage controls](https://resend.com/docs/knowledge-base/how-do-i-ensure-sensitive-data-isnt-stored-on-resend).

#### OpenAI API

1. Confirm that the API key belongs to a dedicated MedStory API project, not a personal ChatGPT
   workspace or an unrelated project.
2. Read and save the current OpenAI Services Agreement and DPA for the account's contracting entity.
3. Record the models/endpoints MedStory uses, subprocessors, transfer mechanism, retention, and
   whether regional processing or data-residency controls apply to the account.
4. Confirm the account's API data controls. OpenAI states that API data is not used for training by
   default unless the customer opts in, but default abuse-monitoring logs may retain customer
   content for up to 30 days. Zero Data Retention and Modified Abuse Monitoring require eligibility
   and approval; do not claim they are enabled unless the project dashboard confirms it.
5. Have the health-data use reviewed and approved. MedStory is not claiming HIPAA compliance or
   relying on an OpenAI healthcare/BAA arrangement for this deployment.
6. Save the evidence privately and update the register.

Official sources: [OpenAI DPA](https://openai.com/policies/data-processing-addendum/) and
[OpenAI API data controls](https://platform.openai.com/docs/models/default-usage-policies-by-endpoint).

### When this step is finished

For each of the three providers, you should be able to point to:

- the accepted/current DPA and terms;
- the service and data being sent;
- processing location and international-transfer basis;
- retention and deletion behavior;
- subprocessor list;
- your approval record and next annual review date; and
- matching language in the public privacy notice.

If you cannot answer one of these, keep using synthetic data and mock AI providers while you ask the
provider or a privacy professional. Do not mark a provider “approved” only because it has a GDPR
page.

## Stage 4: configure the included Standard Automated Backup

The VPS-2 promotion includes OVHcloud **Standard Automated Backup**. OVHcloud documents this as one
daily full-system backup that can be mounted or restored. Standard rotates that single restore point
after 24 hours; Premium's seven-day history is not included. The practical recovery-point objective
is therefore up to approximately 24 hours of lost changes, and there is no older point to select if
the current copy is unusable. Automated backups also exclude additional disks, so this deployment
must keep PostgreSQL, Garage, and the master-key file on the backed-up primary VPS disk.

In **OVHcloud Control Panel → Bare Metal Cloud → Virtual private servers → your VPS → Automated
backup**, confirm that Standard is active, choose a low-traffic UTC backup time, and privately record
the activation, region, schedule, retention, deletion behavior, and service/order evidence. Deleted
data can remain in the restore point until its 24-hour rotation; keep that behavior in the privacy
and erasure review.

### Install and verify the QEMU guest agent

OVHcloud recommends the QEMU guest agent so a live snapshot can prepare the filesystem. On Ubuntu:

```bash
file /dev/virtio-ports/org.qemu.guest_agent.0
sudo apt-get update
sudo apt-get install qemu-guest-agent
sudo systemctl enable qemu-guest-agent
sudo reboot
```

After reconnecting, verify both the device and service:

```bash
file /dev/virtio-ports/org.qemu.guest_agent.0
sudo systemctl is-active qemu-guest-agent
```

The device should be a link to a virtio port and the service should be `active`. Do not enable real
registration merely because the backup appears in the control panel. The full synthetic restore
drill under the real-data launch gate must succeed first.

Keep a verified encrypted offline copy of `secrets/original_master_key`. A VPS restore containing a
damaged or missing key cannot decrypt Garage objects, and the automated backup is not an independent
key escrow.

Official help: [OVHcloud Automated Backup guide](https://support.us.ovhcloud.com/hc/en-us/articles/360012678619-How-to-use-automated-backups-on-a-VPS).

## Stage 5: create and secure the VPS

This is the first command-line stage. Text in angle brackets, such as `<reviewed-commit>`, is a
placeholder. Replace it before running a command. Do not type the angle brackets themselves.

### 1. Connect by SSH and create the operator account

Use the initial administrator name and connection command shown in the OVHcloud welcome email. Then
update Ubuntu and install basic tools:

```bash
sudo apt update
sudo apt full-upgrade
sudo apt install unattended-upgrades ca-certificates curl git openssl ufw
```

Create the account that will operate MedStory and give it a private SSH folder:

```bash
sudo adduser medstory
sudo usermod -aG sudo medstory
sudo install -d -o medstory -g medstory -m 0700 /home/medstory/.ssh
sudo install -o medstory -g medstory -m 0600 ~/.ssh/authorized_keys /home/medstory/.ssh/authorized_keys
```

Keep the first SSH window open. Open a second terminal and verify that you can sign in as
`medstory`. Do not disable the original login until this test works.

### 2. Disable password and root SSH login

Create an SSH configuration file under `/etc/ssh/sshd_config.d/` containing:

```text
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

Validate it before reloading SSH:

```bash
sudo sshd -t
sudo systemctl reload ssh
```

If `sudo sshd -t` prints an error, do not reload SSH. Correct the file while the original session is
still open.

### 3. Turn on the firewall

If you have a fixed home/office IP or VPN address, replace `203.0.113.10` below with that address.
Do not use the example address literally.

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 203.0.113.10/32 to any port 22 proto tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

If your internet connection changes IP frequently, this rule may lock you out. Arrange a stable VPN
or get experienced help before restricting port 22. Keep an OVHcloud console session available
during firewall changes.

Also enable OVHcloud's Network Firewall and anti-DDoS controls where available. Only SSH (22), HTTP
(80), and HTTPS (443) should be reachable from the internet. PostgreSQL, Redis, Garage, ClamAV, and
port 8000 must remain private.

### 4. Install Docker and Caddy

Install Docker Engine and the Docker Compose plugin from the official Ubuntu instructions:

- [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Compose plugin](https://docs.docker.com/compose/install/linux/)

Install Caddy from its [official Ubuntu instructions](https://caddyserver.com/docs/install). Do not
add the `medstory` user to the `docker` group: membership gives root-equivalent access. The supplied
scripts intentionally use `sudo docker`.

## Stage 6: install MedStory on the VPS

### 1. Copy a reviewed release

Create the application directory and clone the repository. Replace `<repository-url>` and
`<reviewed-commit>` with the real commit approved for deployment.

```bash
sudo install -d -o medstory -g medstory -m 0750 /opt/medstory
sudo -u medstory git clone <repository-url> /opt/medstory
sudo -u medstory git -C /opt/medstory fetch origin
sudo -u medstory git -C /opt/medstory checkout --detach <reviewed-commit>
cd /opt/medstory/backend
```

For a private repository, use a read-only deploy key. Never put a personal access token in the Git
URL. Deploy a reviewed commit, not a changing development branch. The deploy script requires a
valid commit and rejects tracked changes, staged changes, and non-ignored untracked files. It does
not require a release tag; ignored `.env.production` and provisioned secret files remain allowed.

### 2. Generate the server secrets and production environment

Run the supplied scripts once, replacing the domain and sender address:

```bash
chmod +x deploy/ovh/*.sh
./deploy/ovh/provision-secrets.sh
./deploy/ovh/prepare-env.sh api.example.com no-reply@mail.example.com
```

These scripts:

- generate database, Django, storage, and internal certificate secrets;
- create `backend/.env.production` with permission mode `0600`; and
- refuse to overwrite existing secrets accidentally.

Open `.env.production` in an editor:

```bash
nano .env.production
```

Replace only these placeholders with dedicated production keys:

```dotenv
EMAIL_HOST_PASSWORD=CHANGE_ME_RESEND_API_KEY
AI_OPENAI_API_KEY=CHANGE_ME_OPENAI_API_KEY
```

Also confirm the domain, sender address, models, quotas, and limits. Save and close the editor.
Never show the finished file with `cat`, because that would print all secrets on screen.

### PostgreSQL role boundary

Production uses three fixed database identities and three independently generated passwords:

- `medstory_admin` is the PostgreSQL bootstrap superuser. Its
  `POSTGRES_ADMIN_PASSWORD` is supplied only to the database container.
- `medstory_migrator` is a non-superuser owner of the database, public schema, and
  migration-created objects. The one-shot `migrate` service connects through
  `MIGRATION_DATABASE_URL` and is the only application image allowed to perform DDL.
- `medstory_app` is the non-superuser API/worker/beat runtime role. `DATABASE_URL` identifies this
  role; it receives table DML and sequence access but cannot create or drop schema objects.

`POSTGRES_MIGRATOR_PASSWORD`, `POSTGRES_APP_PASSWORD`, and `MIGRATION_DATABASE_URL` are not passed
to the long-running API, worker, or beat containers. The role initializer supports only a new empty
PostgreSQL volume. There is no automatic conversion from the former single-role layout; because no
production database exists yet, discard test volumes and deploy from a fresh volume. If real data
ever exists under an older layout, stop and design a reviewed migration instead of rerunning the
initializer or deleting the volume.

### 3. Store the irreplaceable key offline

Securely copy these two files from the VPS to encrypted offline storage:

- `backend/secrets/original_master_key`
- `backend/secrets/storage_ca_private_key.pem`

The offline location may be an encrypted password vault that supports file attachments or an
encrypted external drive stored securely. Verify that both copied files can be opened and are not
empty. Then remove only `storage_ca_private_key.pem` from the VPS; the running application does not
need it after the internal certificate has been issued. Keep `original_master_key` on the VPS and an
encrypted offline copy. Losing that master key makes stored originals unreadable.

Do not upload either file to Git, ordinary cloud storage, email, chat, or a ticket. Keep every
remaining file under `backend/secrets/` and `.env.production` at permission mode `0600`.

### 4. Configure HTTPS

Copy the supplied Caddy configuration, edit it, validate it, and reload Caddy:

```bash
sudo cp deploy/ovh/Caddyfile.example /etc/caddy/Caddyfile
sudoedit /etc/caddy/Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile
sudo systemctl reload caddy
```

Replace every `api.example.com` with the real API domain before validation. Caddy will obtain and
renew the public TLS certificate. Access logging is intentionally disabled because URLs and search
parameters could contain sensitive context.

## Stage 7: deploy safely with test data first

### 1. Use mock AI for the first deployment

In `.env.production`, temporarily use:

```dotenv
AI_LLM_PROVIDER=mock
AI_OCR_PROVIDER=mock
AI_STT_PROVIDER=mock
```

Use invented names, emails you control, and synthetic medical files only. Then deploy:

```bash
./deploy/ovh/deploy.sh
```

The script checks the configuration, builds the containers, runs Django's production checks,
applies database migrations, starts all services, and waits up to five minutes for readiness.

Before using a release on the VPS, run the same isolated eight-service smoke test used by CI from a
development or CI machine with Docker, Compose, Git, OpenSSL, and direct Docker access (or
non-interactive `sudo docker` access as a fallback):

```bash
backend/deploy/ovh/production-smoke.sh
```

The smoke runner copies the current tracked and non-ignored worktree into a temporary repository,
creates a clean untagged disposable commit, generates synthetic secrets, uses mock AI, and runs the
real deployment script twice from empty volumes. It verifies PostgreSQL/Garage/Redis/Celery behavior,
credential allowlists, dirty-checkout rejection, and privacy controls, then always removes its
containers, volumes, environment, and secrets. It never copies, uses, or replaces the checkout's
ignored production files.
Production binds the API to loopback port `8000` by default. The smoke harness exports a temporary
free `API_HOST_PORT` so it can run beside a development stack; ordinary VPS deployment should keep
the default.

Garage 2.3 provides bucket-level `read`, `write`, and `owner` ACLs, not separate put and delete
actions. The upload and deletion keys are independent, separately rotated identities, but both use
the required `write` ACL; the read and processing identities cannot write or delete. The smoke test
checks these enforceable boundaries without weakening upload rollback behavior.

### 2. Check that the service is reachable

Replace the example domain and run:

```bash
curl --fail http://127.0.0.1:8000/healthz
curl --fail https://api.example.com/healthz
curl --fail https://api.example.com/readyz
curl --head http://api.example.com/healthz
```

Confirm all of the following:

- HTTP redirects to HTTPS.
- `/admin/`, `/api/schema/`, and `/api/docs/` return 404 in production.
- Only ports 22, 80, and 443 are externally reachable.
- Registration, email verification, login, manual events, document upload, voice transcription,
  explanation, summary, original download, logout, and account deletion work with synthetic data.

Delete the test accounts after testing.

### 3. Enable OpenAI only after the provider review

After all synthetic tests pass and the OpenAI review is approved, change the three provider values
from `mock` to `openai`, deploy again, and repeat one end-to-end test using only a synthetic fixture.

The API key alone does not mean real-data processing is approved. Keep AI disabled or mocked if the
DPA, retention, transfer, privacy-notice, or consent review is incomplete.

### 4. Build the mobile app

Build the mobile app on your development computer, not on the VPS. From the local repository root,
build Android with the public API address:

```bash
cd frontend
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

Use the equivalent `flutter build ipa` process for iOS signing and distribution.

## Real-data launch gate

Do not open the service to real users until every item is checked:

- [ ] Domain, Resend SPF/DKIM/DMARC, and HTTPS are verified.
- [ ] Resend and OpenAI spending/circuit breakers have been tested.
- [x] OVHcloud, Resend, and OpenAI DPA reviews are approved and recorded.
- [ ] Provider processing locations, transfers, subprocessors, and retention are documented.
- [ ] The Standard Automated Backup activation, schedule, retention, and deletion behavior are
  recorded.
- [ ] QEMU guest agent device and service are active.
- [ ] A full Standard Automated Backup restore drill has recovered the synthetic PostgreSQL and
  encrypted Garage markers, and its private evidence has been reviewed.
- [ ] The public privacy notice and consent screens match the real provider behavior.
- [ ] The one-daily-point, approximately 24-hour data-loss, and no-guaranteed-recovery notice has
  been approved.
- [ ] The encrypted offline `original_master_key` copy has been verified.
- [ ] Synthetic registration, upload, AI, download, and deletion tests pass.
- [ ] Registration and AI kill switches have been tested.
- [ ] The remaining pre-launch items in `docs/security-privacy.md` are complete.

## Routine operation

### Check server health without printing secrets

```bash
cd /opt/medstory/backend
sudo docker compose --env-file .env.production -f docker-compose.prod.yml ps
sudo docker stats --no-stream
df -h
```

Investigate before memory or disk usage stays above 80%. Keep at least 15 GB free for container
builds, ClamAV updates, PostgreSQL, and encrypted files. Logs rotate automatically. Do not enable
verbose AI-provider, proxy-request, or database-statement logging.

### Emergency switches

To stop all paid AI processing, set this in `.env.production` and deploy again:

```dotenv
AI_ENABLED=False
```

Keep new registration disabled until the restore drill has passed. To stop new registrations while
keeping existing verified accounts usable:

```dotenv
REGISTRATION_ENABLED=False
```

Then apply either change:

```bash
./deploy/ovh/deploy.sh
```

### Install an approved update

```bash
git fetch origin
git checkout --detach <reviewed-commit>
./deploy/ovh/deploy.sh
```

To roll back application code, check out the previous approved commit and deploy it. Database changes
must remain compatible with the previous release. Do not reverse database migrations on the live
VPS; publish a forward repair release instead.

## Standard Automated Backup restore drill

Complete this gate before setting `REGISTRATION_ENABLED=True` for real users:

1. Confirm the QEMU device and service checks above, keep AI mocked, and keep public registration
   disabled except during the brief synthetic-account setup.
2. Create a synthetic account and unique manual event (the PostgreSQL marker), upload a synthetic
   fixture through the normal app flow (the application-encrypted Garage marker), and record only
   their non-secret IDs plus the fixture's SHA-256 hash in a private operations record.
3. Wait until the control panel shows a Standard Automated Backup created after both markers. Record
   its timestamp. Do not assume the backup is usable merely because it is listed.
4. Delete or change the synthetic event and document, confirm the changes, then choose the full VPS
   **Restoration** action for that backup. This overwrites the VPS and may take time; perform it only
   in this pre-launch synthetic environment.
5. After OVHcloud reports completion, reconnect and verify Docker/Caddy startup, `/healthz`,
   `/readyz`, the restored PostgreSQL event, download/decrypt of the Garage-backed fixture with the
   same SHA-256 hash, and a Celery task whose result can be retrieved through Redis.
6. Confirm the restored registration setting is still `False`, delete the synthetic account, and
   privately record the backup timestamp, restore duration, observed data loss, checks performed,
   result, operator, and date. Never put user data, passwords, or keys in that record.
7. Enable real registration only after every check passes. If any check fails, leave registration
   disabled, repair the cause, wait for a new daily point, and repeat the complete drill.

Passing once establishes an observed recovery procedure, not guaranteed recovery. Standard still
has one daily point, approximately 24 hours of possible data loss, no high availability, and no
application-managed `pg_dump` or independent object copy. Repeat the drill after material storage,
encryption, host-layout, or backup-product changes and periodically during operation.
