# MedStory — Clear Index design handoff

> Flutter implementation update, 28 October 2026: see [FLUTTER-IMPLEMENTATION.md](FLUTTER-IMPLEMENTATION.md) for actual screen coverage and behavior-preserving deviations. The remaining text records the original design-only prototype and its simulations; it is not a claim of Flutter feature wiring or device verification.

## What is delivered

A complete design-only mobile prototype in [clear-index.html](clear-index.html), with four review modes: Prototype, Screen gallery, Design system, States & handoff. It starts on the finalized 390 × 844 My Story home. Grouped selectors and deep links expose the full A–G screen coverage in [SCREEN-MAP.md](SCREEN-MAP.md). [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) and `clear-index/tokens.css` define the reusable system.

All new implementation source is under `clear-index/`. Existing local fonts are reused by reference. The original `index.html`, `app.js`, `styles.css`, `tokens.css`, and their behavior are preserved. No MedStory repository, Flutter code, generated Flutter files, backend, account, or real medical record was read or modified. No test_assets were used.

## Decisions carried forward

- Actual concept 03 Clear Index, with the locked white/ink/slate/cobalt palette and IBM Plex Sans.
- Exact Quiet Ledger root-navigation morphology in Clear Index colors: three equal columns; 8px gap; 8/16/4px padding; 64px minimum items; 5px vertical gap; 22px icons; 52 × 28px ordinary wraps; 52 × 32px Add wrap with 6px radius; 12px labels; thin top rule; separate gesture safe area.
- No concept 03 wide horizontal Add action and no selected top stripe.
- History remains the center: reverse chronological events, date anchors, month rules, search/filter access, restrained review access, readable previews, and source context.
- Full English product copy. Russian is an inspectable preference, not a claim that the mockups were translated.

## Source organization and reuse

| Source | Responsibility |
|---|---|
| `clear-index.html` | Canonical review shell, handset template, grouped selectors, mode panels |
| `clear-index/tokens.css` | Machine-readable design variables; independently namespaced |
| `clear-index/styles.css` | Shared product and review-shell layout, responsive rules, larger text |
| `clear-index/data.js` | Synthetic seed records, document bundles, suggestions, screen catalog |
| `clear-index/components.js` | Reusable fields, buttons, statuses, rows, bars, sheets, timeline, reports |
| `clear-index/screens.js` | Compositions shared by live prototype, screen gallery, states, overview |
| `clear-index/app.js` | In-memory state, navigation/back stack, staged actions, deterministic progress |
| `clear-index/overview.html` | Clean editable overview composition for the requested overview image |

The design gallery uses the same render functions and tokens, preventing screen drift. Gallery phones are inspection previews; **Inspect** opens the live full-size screen. Body scrolling and sheet scrolling are contained in each phone. Prototype controls live outside the phone.

## Interaction contracts for later Flutter implementation

### Access and first use

Email/password fields validate before the simulated transition. Password visibility has an explicit accessible control. Registration uses one combined privacy/AI notice acceptance with an expandable notice, and no social login or second AI consent toggle. Verification/reset code is six digits; `246810` is the deterministic outside-app demo code. Registration continues through onboarding rather than directly implying a real account creation.

### Capture, grouping, and review

Photo/camera/file interfaces are synthetic sheets; no file picker or permissions are requested. Ordered report pages are rendered locally from synthetic text, with accessible up/down controls and removal. A grouped bundle has one document identity and one suggested event; multiple pages do not create multiple events. Choosing separate documents creates a document/event candidate for each separate document.

Upload, processing, review-ready, completed, failed, retry, and dismiss are visible operational states. **Advance demo step** moves simulated work forward deterministically. Confirmation commits one candidate into the same data store that renders the timeline and linked document. Dismissal leaves confirmed history unchanged. AI-produced organization remains explicitly unconfirmed until reviewed.

### Voice notes

The note editor stores typed text independently of recording status. Recording duration/stop, transcribing, appended transcript, Record more, retry failure, and discard are modeled. Transcript completion reads the latest text and appends to it, preserving edits made before completion. Final submission includes the edited final text and produces one review candidate.

There is no microphone access, recording file, binary audio cache, or actual transcription in the prototype. The real product’s recording-retention policy is represented by copy and documented below; no deletion of real audio is claimed by this design task.

### Events, revisions, and documents

Original notes/extracted text remain distinct from organized notes and user edits. Manual edits mark provenance as Edited by you. The original text is not overwritten by editing the organized fields.

Revision comparison stages a per-field selection. Keep current changes nothing. Apply updates only checked fields; unchecked values are not applied. A source viewer supports image pages/current-page indication and PDF opening. PDF provenance remains file-level; page attribution is not fabricated.

The document library searches and filters status, with empty/error examples and retry. Details expose pages, linked single event, explanation, secondary extracted text, retry on failure, and a destructive confirmation. Deleting a source preserves existing events and marks source access unavailable in this in-memory model.

### For Visits

The briefing is approximately a short, 60-second read and contains recorded facts, not inferred findings. Seven section components exist, while the populated prototype hides sections with no recorded content. Sources open one event directly, or a multiple-source sheet with event/date/document context, then event → original.

The visit reason is at most 300 characters. Saving it persists the reason in this page session but does not generate a new briefing. Refresh is explicit. The cached briefing stays visible while refreshing and after failure. PDF/JSON export choices are simulations: no export backend exists here and no actual patient-summary export is created by clicking them.

### Account actions

Language selection is local and visible. Privacy and usage disclosures remain accessible from settings. Logout and destructive account deletion are separate confirmations. Deletion requires the exact uppercase word DELETE and returns to a simulated sign-in screen. No real account/session/data is changed.

## Product and privacy facts to preserve

These constraints are supplied by the current product brief, not verified by reading the application or backend in this task:

- Originals are encrypted in private server storage and viewed online on authenticated devices.
- There is **no automatic offline binary cache** of originals. Cached timeline/history or briefing content must not imply an offline original file exists.
- Explicit download/share creates user-controlled copies, separate from online access.
- Voice recording copies are transient: successful transcription deletes recording copies; failed recordings remain locally for retry.
- AI processing is core, cannot be toggled off, and is covered by one combined registration acceptance.
- No end-to-end-encryption claim, automatic-backup claim, local-only document claim, optional-AI toggle, or numeric upload-size limit is made.
- MedStory organizes, simplifies, and explains existing information. It is not an AI doctor, diagnostic tool, symptom checker, treatment recommender, appointment system, or provider-messaging service.
- No therapy ranking, prescription suggestion, diagnosis inference, medical reassurance, scores, streaks, invented vitals, reminders, caregiver management, biometrics, or deferred semantic search is added.

## Flutter route integration boundary and known code gaps

The supplied router covers splash, login/register/verify/forgot, timeline, capture, summary, notes/new, events/new/detail/edit, documents/list/detail, visit-preparation, and timeline/settings. Source viewing and page grouping use pushed inline routes.

**Design proposals for later wiring:** dedicated review inbox/detail/edit flow, document explanation, and selective revision comparison. The brief reports product/docs/localization support but incomplete current-screen wiring. This prototype demonstrates the intended interaction contract; it does not assert these are already shipped features.

The exact current Dart route strings, widgets, services, database schema, auth behavior, processing retention implementation, and repository gaps were intentionally not inspected. A later, separately authorized Flutter implementation must resolve those against the actual repository. The screen map uses supplied route references and does not invent verified path strings.

Potential implementation concerns:

- Bundle full IBM Plex Sans Cyrillic glyph coverage before Russian localization; the reused study font subsets cover Latin.
- Apply platform keyboard insets and system safe areas dynamically, while matching the locked 100% navigation geometry.
- At large text, permit wrapping and scrolling; do not force a fixed-height label or truncate source facts.
- Maintain one atomic capture-bundle identity across original pages, document processing, suggestion, and confirmation.
- Commit selected revision fields transactionally without applying unchecked values.
- Keep source documents, extracted text, user edits, and original notes distinguishable in model and UI.
- Preserve the cached briefing independently of refresh state and visit-reason edits.
- Reconnect real auth, uploads, voice, exports, deletion, usage, and retry semantics only in a separately authorized implementation task.

## Accessibility and responsive behavior

16px base body; 13–14px metadata; coherent outline icons; 48px+ hit areas; semantic field labels and visible focus. A 150% outside-app type-scale control demonstrates 24px body and wrapping layouts. Source pages preserve full-frame geometry. Reduced motion disables moving progress and sheet animations. A handset has a 50px top system inset and 29px gesture inset; product bars reserve their own grid rows. Mobile review controls and screen selection remain outside the phone.

## Verification record

Verification used OpenDesign’s available Chromium export renderer with temporary, same-component browser fixtures. Direct headless Chrome was not required. Fixtures were removed after the checks.

- **Desktop:** 185 assertions passed in a 1440px browser viewport. All six connected journeys were exercised through labeled controls, field entry, checkbox selection, and preview progress controls. This included registration’s single acceptance, invalid/valid verification, password reset, page reordering/removal/addition, grouped capture confirmation, appended voice transcripts, event editing, selective revisions, image/PDF sources, explicit briefing refresh/failure, language selection, and typed account deletion.
- **Complete coverage:** all 56 catalog entries rendered without initialization failures. Detail/auth screens were checked for absence of false root navigation; the capture gallery, design-system examples, and all 14 essential state previews rendered.
- **375px and 390px:** 50 geometry/accessibility assertions passed at each actual browser width. Twelve representative screen/sheet compositions checked full phone width, contained app/sheet content, and 48px control targets. Eight representative screens also checked wrapping at 150% text, including the filter sheet.
- **Navigation:** computed bar gap/padding, 64px item height, 52 × 28px ordinary wraps, 52 × 32px Add wrap, 6px Add radius, and 12px/18px label size/line height were checked on all three roots.
- **Data invariants:** grouped capture retry preserves its original bundle and page count; two grouped pages produce one suggestion. Typed edits survive transcript appending. Unconfirmed edits do not enter history. Unchecked revision fields and original source text remain unchanged. Saving a visit reason does not regenerate the briefing; cached content remains visible during refresh and failure.
- **Visual inspection:** finalized home, Add, event detail, dense explanation, summary, registration, settings, ordered capture pages, quick note, filter sheet, grouping sheet, and deletion confirmation were inspected through rendered captures. A review-header overflow discovered at phone width was corrected. The handset system chrome remains visible above sheets.
- **Clean overview:** [clear-index-overview.png](clear-index-overview.png) contains six representative full-size screen renders with no test logs over the UI. Its editable composition is `clear-index/overview.html`.

These are design-prototype/browser checks, not device, screen-reader, Flutter, security, backend, or production-service acceptance tests. No real login, upload, recording, generation, export integration, or destructive account action was performed.
