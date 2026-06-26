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
| Local cache (offline reads) | **Isar** (or drift) | Fast local timeline/summary cache |
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
Data sources (ApiClient, LocalDb)  ← dio + Isar
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
│   │   └── local_db.dart          # Isar setup
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
│   ├── subjects/                  # patient profile switcher
│   └── settings/                  # account, privacy/export/delete, locale
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
idle → selecting → saving_local → creating(POST /documents) → ingesting(POST /documents/{id}/ingest)
     → processing(poll GET /documents/{id})
     → done(events + explanation ready) | failed(retry)
```
- The user can leave the screen; files remain on-device, and processing surfaces via the
  documents list / timeline once `processed`.
- Newly extracted events show an **"AI-suggested, tap to confirm"** badge
  (`is_confirmed=false`) to keep the user in control.

### 7.2 Voice-First Capture
Record → save locally → transient ingest as `doc_type=audio` → poll → review extracted events.
Same machine as 7.1.

### 7.3 Timeline (Scenario E)
- Infinite scroll via cursor pagination; filter chips by `event_type`, date range, tag.
- Reads from Isar cache first (instant), then refreshes from `/timeline` (stale-while-revalidate).

### 7.4 Doctor Summary (Scenario D)
- `summary` screen shows the structured memory + narrative.
- "Prepare for visit" → `GET /summary/export?format=pdf` → share sheet.

## 8. Offline & Caching

- **Read-mostly offline**: timeline and current summary cached in Isar; viewable offline.
- **Writes require connectivity** for MVP (transient ingestion/AI need the backend); queued
  retry is a post-MVP enhancement.
- Document/audio binaries are durable on-device only; there is no cross-device sync/backup in MVP.
- Cache is per-`subject`; cleared on logout and on account deletion.

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
- Medical content is stored only in app-sandboxed storage (Isar + local files), not in
  insecure storage.
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

Still planned for later phases: `isar`/`isar_flutter_libs`, `image_picker`, `file_picker`,
`record`, and test helpers such as `mocktail`.

> Versions intentionally omitted here; pin them via the package manager during implementation.
