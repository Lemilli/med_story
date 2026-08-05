# MedStory — Frontend Architecture (Flutter)

> The iOS/Android client. Companion to [Technical Architecture](./technical-architecture.md)
> and [API Specification](./api-specification.md). Existing scaffold lives in `frontend/`.

## 1. Goals

Translate the BRD's UX principles into the app:
- **Simplicity & low data-entry burden** → capture-first UI (scan/photo/voice in ≤2 taps).
- **Clarity** → plain-language explanations and a readable timeline.
- **Accessibility** → large text support, high contrast, screen-reader labels.
- **Long-term value** → fast, cached browsing of years of history.
- **Trust/privacy** → clear "organizer, not a doctor" framing; secure local token storage.

## 2. Tech Choices

| Concern | Choice | Rationale |
|--------|--------|-----------|
| State management | **Riverpod** | Testable, compile-safe, good async support |
| Navigation | **go_router** | Declarative, deep-link friendly |
| Networking | **dio** | Interceptors for auth/refresh, retries |
| Models / immutability | **freezed** + **json_serializable** | Safe DTOs, less boilerplate |
| Secure storage | **flutter_secure_storage** | JWTs in Keychain/Keystore |
| Local cache (offline reads) | **Drift** | Structured local timeline/summary cache with mature Flutter support |
| Media capture | **image_picker / camera**, **file_picker** | Document scan & local file storage |
| Voice | **record** + local audio save | Voice-first capture |
| Env config | **--dart-define** / flavors | dev/staging/prod base URLs |
| i18n | **flutter_localizations / intl** | English (default) + Russian; NO hardcoded UI strings |

## 3. Architecture Pattern

Layered **feature-first** structure with unidirectional data flow:

```
UI (Widgets / Screens)
  ▼  reads state / sends intents
Controllers (Riverpod Notifiers)   ← presentation logic, view-state
  ▼  calls
Repositories                       ← orchestrate remote + local cache
  ▼  calls
Data sources (ApiClient, LocalDb)  ← dio + Drift
  ▼
DTOs / Domain models (freezed)
```

- **Widgets** are dumb: render state, dispatch user intents.
- **Controllers** (`AsyncNotifier`) hold screen state (`loading/data/error`) and call repos.
- **Repositories** are the single source of truth per domain; they merge API + cache and
  expose domain models.
- **Data sources** isolate transport (HTTP, secure storage, local DB).

## 4. Project Structure

```
frontend/lib/
├── main.dart                      # entry; ProviderScope + App
├── app/
│   ├── app.dart                   # MaterialApp.router, theme
│   ├── router.dart                # go_router config + guards
│   └── theme/                     # colors, typography, spacing, a11y
├── core/
│   ├── config/                    # env, flavors, constants
│   ├── network/
│   │   ├── api_client.dart        # dio instance + base options
│   │   └── auth_interceptor.dart  # attach JWT, refresh on 401
│   ├── storage/
│   │   ├── secure_token_storage.dart # tokens
│   │   └── local_database.dart    # Drift setup
│   ├── error/
│   │   └── app_failure.dart       # stable failure codes for UI mapping
│   └── widgets/                   # shared UI (buttons, empty/error states)
├── features/
│   ├── auth/                      # login/register; password reset planned
│   │   ├── data/ (api, repo)
│   │   ├── domain/ (models)
│   │   └── presentation/ (screens, controllers, widgets)
│   ├── onboarding/                # first-run, "organizer not a doctor" disclaimer
│   ├── capture/                   # scan / photo / file / voice upload flow
│   ├── documents/                 # list, detail, explanation
│   ├── timeline/                  # chronological events (home)
│   ├── events/                    # event detail, manual add/edit, confirm
│   ├── summary/                   # medical memory + doctor export
│   ├── organize/                  # review inbox, medication history, unified search
│   ├── visit_preparation/         # per-subject questions/concerns for a visit
│   ├── subjects/                  # patient profile switcher
│   └── settings/                  # account, privacy/delete, locale
└── l10n/                          # ARB files (en, ru) + generated AppLocalizations
```

## 5. State Management Details (Riverpod)

- **Providers**
  - `authControllerProvider` (`AsyncNotifier<AuthState>`) — session, token lifecycle. **Implemented
    in Phase 0** with register/login/logout, secure token restore, and `/me` verification.
  - `timelineControllerProvider` — paginated event list with cursor + filters.
  - `documentUploadControllerProvider` — drives local-save + ingest state machine (§7).
  - `summaryControllerProvider` — current summary + regenerate action.
  - Repository providers injected into controllers; data-source providers injected into repos.
- **Auth guard**: `router.dart` redirects based on `authControllerProvider` (logged in/out).
- **Error handling**: controllers expose `AsyncValue`; UI renders unified loading/empty/error.

## 6. Navigation Map (go_router)

```
/                      → Splash / auth gate
/login, /register
/forgot-password        → planned
/onboarding            → first-run disclaimer + subject setup
/home (shell)
  ├── /timeline        → default tab (chronological history)
  ├── /capture         → scan/photo/file/voice (FAB)
  ├── /summary         → medical memory + export
  └── /settings
/documents/:id         → document detail + explanation
/events/:id            → event detail / edit / confirm
/subjects              → manage/switch patient profiles
```

## 7. Key Flows

### 7.1 Document Capture & Processing (Scenario A + B)
A client-side state machine mirrors the async backend pipeline:
```
idle → selecting → preparing_source → creating(POST /documents) → ingesting(POST /documents/{id}/ingest)
     → processing(poll GET /documents/{id})
     → done(events + explanation ready) | failed(retry)
```
- Gallery multi-selection always asks whether photos are pages of one document or separate
  documents. Camera scanning enters a reorderable page review and allows more pages.
- One logical document bundle contains ordered server assets and resolves to one timeline event.
- `202` means validation, malware scanning, encryption, Garage acknowledgement, and asset
  persistence have completed. Camera/gallery picker temporaries are then deleted. System
  Files/gallery sources remain user-controlled and are never deleted by MedStory.
- Processing failure keeps Retry/Delete access to the retained original; retry calls
  `/documents/{id}/retry-processing` without re-uploading.
- Newly extracted events show an **"AI-suggested, tap to confirm"** badge
  with edit and deletion controls to keep the user in control.
- Regeneration opens a field-selectable draft comparison. The edited event remains unchanged until
  the user applies selected changes.

### 7.2 Voice-First Capture
Record to app temp → encrypted transient server upload → transcribe → delete both copies on success.
On failure the local recording remains for explicit retry; abandoned server staging is cleaned
automatically.

### 7.3 Timeline (Scenario E)
- Infinite scroll via cursor pagination; filter chips by `event_type`, date range, tag.
- Reads from the Drift cache first (instant), then refreshes from `/timeline`
  (stale-while-revalidate).

### 7.4 Prepare for a Visit (Scenario D)
- The screen is a structured, approximately 60-second briefing understandable to both doctor and
  patient. It shows seven ordered sections: current concerns; important diagnoses and findings;
  allergies; current medications; important test results; previous treatments and outcomes; and
  procedures and hospitalizations. Empty sections are hidden.
- Items prefer one concise line and may use a second line only when necessary. A trailing blue
  source icon is the compact provenance action. One source opens the event; multiple sources open a
  bottom sheet (event title, date, and document name) before the selected event opens.
- The navigation contract is `Summary → Event → authenticated online original`. A one-based supporting position
  can select an uploaded image/page asset in a multi-image scan. Internal pages of a single PDF are
  not separately identified or rendered in the current MVP, so PDFs and sources without asset-level
  provenance open at the file/document start. Images use an in-app paged viewer; PDFs use an
  app-temporary file and platform viewer. Explicit Download/Share creates a user-controlled copy.
- The free-text reason for visit is saved per subject until changed. Refresh is the only generation
  trigger. The old cached summary stays visible with a compact updating state and remains available
  if regeneration fails.
- Source links are for the in-app phone experience; exports do not attempt to preserve local links.

## 8. Offline & Caching

- **Read-mostly offline**: timeline and current summary metadata remain cached in Drift.
- Originals are online-only from any authenticated device; there is no automatic binary cache.
- Upload, processing retry, original viewing, download, and share require connectivity. The upload
  queue retains source paths only until the server acknowledges storage.
- Cache is per-`subject`; cleared on logout and on account deletion.
- Durable upload-queue metadata is keyed to the authenticated user. Auth-session
  changes detach active upload/polling work immediately, and logout or account
  deletion clears the queue together with the rest of the local cache.

## 9. Theming, Accessibility & Localization

- Material 3 theme; calm, clinical-but-friendly palette; generous spacing.
- Respect OS text scaling; minimum tap targets 48dp; semantic labels on all actionable widgets.
- **No hardcoded visible text** — all user-facing strings live in `lib/l10n/` ARB files and are
  accessed via `AppLocalizations` (generated by `flutter gen-l10n`). Use the `context.l10n`
  extension from `lib/l10n/l10n.dart` in widgets.
- **Supported locales:** English (`en`, default) and Russian (`ru`). Add new languages by creating
  `app_<locale>.arb` alongside `app_en.arb` (the template) and running `flutter gen-l10n`.
- Locale drives both UI strings and the `locale` sent to the backend so AI
  explanations/summaries are generated in the user's language.

## 10. Security on the Client

- JWTs stored only in `flutter_secure_storage`; never in plain prefs or logs.
- `auth_interceptor` transparently refreshes the access token on `401` and retries once.
- Drift stores medical metadata but never original binaries. Sensitive temporary viewer/capture
  files are cleaned after use where possible and on startup/logout/account deletion.
- Upload queue reads and mutations are scoped to the active user ID as a defense in depth against
  stale in-memory work surviving an account change.
- Certificate pinning and biometric app-lock are planned post-MVP (see roadmap).

## 11. Testing Strategy

| Level | Tooling | Scope |
|-------|---------|-------|
| Unit | `flutter_test`, `mocktail` | controllers, repositories, mappers |
| Widget | `flutter_test` | screens render correct states |
| Integration | `integration_test` | auth → capture → timeline happy path |
| Contract | mock API from OpenAPI | DTO (de)serialization vs API spec |

## 12. Dependencies to Add (`pubspec.yaml`)

Phase 0 has added: `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`,
`freezed_annotation`, `json_annotation`, `intl`, plus dev deps `build_runner`, `freezed`, and
`json_serializable`.

Implemented beyond Phase 0: `drift`, `sqlite3_flutter_libs`, `path_provider`,
`image_picker`, `file_picker`, `open_filex`, `record`, and test helpers such as `mocktail`.

> Versions intentionally omitted here; pin them via the package manager during implementation.
