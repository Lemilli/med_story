# MedStory — Clear Index screen map

Canonical entry: [clear-index.html](clear-index.html). Use **Inspect screen**, the grouped journey list, **Screen gallery**, or **States & handoff**. All use the same screen catalog and render functions.

Deep links follow `clear-index.html#screen=SCREEN-ID&mode=prototype`. Other modes: `gallery`, `system`, `states`. Navigation updates local state first, so it still works when URL updates are blocked. A deep link starts from synthetic seed data, not a persisted account.

## Router reference boundary

The Flutter references below come from the user-supplied current-router description. The MedStory repository was not inspected or modified. These are supplied route references and route families, **not independently verified literal URI paths or class names**. Source viewer and page grouping are described as pushed inline routes. Dedicated review inbox, explanation, and revision comparison are design proposals for completing existing product/docs/localization support; they are not claimed to be shipped wiring.

## Complete coverage checklist

| Brief item | Design IDs | Form | Supplied Flutter reference / relationship |
|---|---|---|---|
| A1 Session restoration | `splash` | Loading state | splash |
| A2 Sign in, visibility, forgot, registration | `sign-in` | Screen | login |
| A3 Create account, single combined acceptance | `register` | Screen + expandable notice | register |
| A4 Six-digit verification, resend, invalid/expired | `verify`, `verify-invalid` | Screen + state | verify |
| A5 Reset request, code/new password, complete | `reset-request`, `reset-password`, `reset-complete` | Screens + success state | forgot |
| A6 Medical-organizer onboarding, add/not now | `onboarding` | Sheet | First-use overlay after verify |
| B7 Final populated history | `home` | Root tab | timeline |
| B8 Search; type/year/date/tag filters; reset | `filters`, `search-results`, `no-matches` | Sheet + result states | timeline |
| B9 Empty/offline cached history | `history-empty`, `history-offline` | States | timeline |
| B10 Source-linked unconfirmed review inbox | `review` | Screen | **Design proposal:** dedicated review wiring |
| B11 Review/edit/confirm/dismiss/complete | `suggestion`, `suggestion-edit`, `review-complete` | Screens + success | **Design proposal:** review flow |
| C12 Add actions + queue states | `add`, `processing`, `upload-failed` | Root tab + states | capture |
| C13 One document vs separate documents | `photo-grouping` | Sheet | Pushed inline page-grouping route |
| C14 Ordered pages, add/up/down/remove/submit | `pages` | Screen | Capture / inline page review |
| C15 Simulated pickers, selected file, progress | `photo-picker`, `file-picker`, `file-confirm`, `processing` | Sheets + screen/state | capture / system picker boundary |
| C16 Typed/voice note, stop/transcribe/append/retry | `note`, `recording`, `transcribing`, `voice-error` | Screen + states | notes/new |
| C17 Manual add/edit with validation | `manual-new`, `manual-error`, `event-edit` | Screens + error state | events/new, events/edit |
| D18 Event, organized/original text, source, edit/delete | `event` | Screen + delete dialog | events/detail |
| D19 Selective revision comparison | `revision` | Screen | **Design proposal:** revision wiring |
| D20 Library search/status/empty/error | `documents`, `documents-empty`, `documents-error` | Screen + states | documents/list |
| D21 Document metadata/pages/event/explanation/retry/delete | `document`, `document-failed` | Screens + delete dialog | documents/detail |
| D22 Summary/key points/glossary/language/regenerate | `explanation` | Screen | **Design proposal:** explanation wiring |
| D23 Online original, image pages/PDF/copies/offline | `original`, `original-offline` | Screen + copy sheet | Pushed inline original viewer |
| E24 Source-linked briefing, explicit refresh, cached states | `summary`, `summary-refreshing`, `summary-failed` | Root tab + states | summary |
| E25 Persistent <=300-character reason, no implicit refresh | `visit-reason` | Sheet | visit-preparation |
| E26 Single source direct, multiple source sheet, exports | `summary-sources`, `summary-export` | Sheets; PDF/JSON action simulation | summary → event → original |
| F27 Profile, language, privacy/usage, logout/delete | `settings`, `language` | Screen + sheet | timeline/settings |
| F28 Detailed privacy/limits | `privacy`, `limits` | Screens | Settings panels/details |
| F29 Logout, typed DELETE, local destructive intent | `logout`, `delete-account` | Confirmation sheets | Settings / authentication transition |

### G — browsable essential states

- [x] Loading / session restoration: `splash`
- [x] First-use empty: `history-empty`, `onboarding`
- [x] Search with no matches: `no-matches`
- [x] Offline cached timeline: `history-offline`
- [x] Required field validation: `manual-error`; interactive auth validation
- [x] Upload/processing failure and retry/dismiss: `upload-failed`; Add queue
- [x] Voice access/transcription failure and retry: `voice-error`
- [x] Unconfirmed suggestion: `suggestion`
- [x] Confirmed success: `review-complete`
- [x] Briefing refreshing/failure with cached content: `summary-refreshing`, `summary-failed`
- [x] Original unavailable/offline: `original-offline`
- [x] Invalid or expired code: `verify-invalid`
- [x] Account deletion confirmation: `delete-account`

These states are directly selectable and rendered in **States & handoff**. State-only views are seeded examples; working journeys update shared in-memory data. The outside-app **Advance demo step** and **Simulate failure** controls expose deterministic operational transitions without developer status codes inside the app.

## Connected journeys and back behavior

1. **Access:** sign-in → timeline; create account → one combined acceptance → verify → onboarding → Add or My Story. Reset request → code/new password → completion → sign-in. Invalid codes remain actionable; resend is simulated. Demo code `246810` is disclosed outside the app.
2. **Capture documents:** Add → simulated photos/scan → grouping → ordered pages → uploading → processing → one unconfirmed event per logical document → review/edit/confirm → confirmed event → timeline. Separate-document grouping creates one event per separate document, not per page of a grouped document.
3. **Capture a note:** Add → note → record → stop → transcribe → append to the latest edited text → record more/retry/discard → submit final text → unconfirmed event → confirmation. No recording file exists in this demo.
4. **History to source:** timeline → event → online original; event → edit or revision comparison. Back restores the prior screen and scroll position. Revision selection is staged until Apply; unselected fields and original text remain unchanged.
5. **Visit preparation:** For Visits → edit/save reason → cached briefing remains unchanged → explicit Refresh → new briefing preview → single-source event or multi-source picker → event → original. Refresh/failure never hides the cached briefing. Export formats open a simulated choice, not a backend export.
6. **Account:** settings → language preference → privacy / AI-storage disclosure → typed DELETE confirmation → simulated return to sign-in. Logout is a separate routine confirmation.

### Root and non-root navigation

`home`, `add`, and `summary` are the three roots. Only their root/state compositions render the shared bottom navigation. Details, forms, auth, library, settings, and explanatory views use back navigation. Sheets have a close control and Escape support. A history stack restores screen context, selected record/document, and scrolling; direct-entry screens use a meaningful fallback to their journey root.

Gallery **Inspect** returns to the Prototype mode at full size. Gallery phones are rendered previews with independent scrolling; their controls are not a second independent app. The global screen selector provides direct entry to every listed screen.

## Data and source relationships

The original five confirmed demo history entries are retained: 24 Oct blood test, 22 Oct follow-up visit, 20 Oct discomfort, 16 Oct ultrasound, and September continuation. Two additional synthetic document bundles seed the unconfirmed inbox without automatically altering those entries.

Image bundles have ordered source pages and a current-page indicator. PDFs use file-level provenance; no page-specific PDF attribution is invented. A document may link to a single confirmed event. Original notes remain separately readable after organization or user editing.
