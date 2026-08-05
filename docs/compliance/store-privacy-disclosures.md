# Google Play and App Store Privacy Disclosures

Use this as the answer sheet when creating the store listings. Verify it against the release build
and production configuration immediately before submission.

## Shared release posture

- Primary category: health/medical history organizer; **not** diagnosis, treatment, telemedicine,
  prescription, or clinical decision support.
- Intended audience: adults; not designed for children.
- Advertising/tracking: none.
- Account required: yes. Account deletion is available in Settings and deletes server records.
- Encryption: TLS in transit; sensitive originals are encrypted at rest; authentication tokens use
  platform secure storage.
- AI: a core part of the service and not separately disableable. The minimum content needed for
  user-requested OCR, transcription, organization, summaries, and explanations is sent to OpenAI.
- Processors: OVHcloud (hosting), Resend (security email), and OpenAI (core AI processing).

## Google Play

Complete both **Data safety** and the **Health apps declaration**. Declare the app as a health app in
the medical/health management category and describe it as a personal record organizer.

Data collected and linked to the user:

| Play data type | Collected | Purpose |
|---|---:|---|
| Name | Yes, optional/profile or subject data | App functionality; account management |
| Email address | Yes | Account management; fraud prevention/security |
| User IDs | Yes | Account management; app functionality; security |
| Other personal info | Yes | Subject profile fields the user chooses to enter |
| Health info | Yes | Core app functionality |
| Photos | Yes, when selected/captured | Core document-capture functionality |
| Files and docs | Yes, when selected | Core document-capture functionality |
| Audio files / voice recordings | Yes, transient when voice capture is used | Core transcription functionality |
| Other user-generated content | Yes | Notes, visit context, and manual timeline content |
| App interactions / diagnostics | Operational metadata only | App functionality; security; maintenance |

The production release does not sell data, use it for advertising, or use it for cross-app
tracking. Transfers to contracted service providers are limited to providing the app. Answer Play's
“shared” questions using its current service-provider exception and the exact production facts;
do not hide collection merely because a processor receives it.

The public privacy-policy URL must be live, non-geofenced, non-PDF, and accessible without login.
The same policy must be linked or readily accessible inside the app. The microphone/camera prominent
disclosures must explain that recordings/images selected by the user are uploaded for the requested
feature before the Android permission prompt.

## Apple App Store Connect

Declare these as **Data Linked to the User**, used for **App Functionality** (and, for email/user ID,
account management/security as represented by App Store Connect's available purposes):

- Contact Info: Name, Email Address.
- Health & Fitness: Health.
- User Content: Photos or Videos, Audio Data, Other User Content.
- Identifiers: User ID.
- Usage Data / Diagnostics: only the operational categories actually present in the submitted
  build; there is no advertising identifier or tracking.

Answer **No** to tracking. OpenAI, Resend, and OVHcloud are service providers, not advertising
partners, but their handling must still be reflected in the privacy policy and privacy answers.
Explain in Review Notes that MedStory organizes user-provided records, AI suggestions require user
review, and the app provides no diagnosis or treatment recommendation.

## Required privacy-policy content before submission

The final public policy must identify:

- the individual or entity operating MedStory and a monitored privacy contact;
- every category above, its purpose, source, retention, and deletion path;
- OVHcloud, Resend, and OpenAI by name and their limited purposes;
- mandatory AI processing disclosed at signup, OpenAI's no-training-by-default posture,
  `store=false`, and possible
  abuse-monitoring retention of up to 30 days without claiming ZDR;
- Resend's security-email role and 30-day email-data retention;
- account deletion/export/correction rights and how to submit a privacy request;
- the no-guaranteed-backup posture and possible temporary snapshot persistence; and
- the effective date and notice-change process.

Do not submit a placeholder policy. Store review can be performed without a lawyer, but the store
forms and public policy must truthfully match the live build and server configuration.
