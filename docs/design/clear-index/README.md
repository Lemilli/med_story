# Clear Index redesign — design handoff

Design deliverables completed on 28 October 2026 using Local Codex. The existing Flutter app now applies the safe visual redesign; see the [implementation coverage, verification, screenshots, and deferrals](FLUTTER-IMPLEMENTATION.md). The prototype remains a visual reference, with its original simulated behavior preserved.

The selected system combines Clear Index's IBM Plex Sans typography, white/slate/cobalt palette, and editorial chronology with Quiet Ledger's compact vertical bottom navigation. The original four-concept comparison is preserved.

## Review

- [OpenDesign workspace](http://127.0.0.1:60786/projects/medstory-four-minimal-timeline-concepts-22b9/conversations/bc0c54f1-862e-471b-b56e-befd859f1130): open `clear-index.html` for Prototype, Screen gallery, Design system, and States & handoff.
- [Overview](overview.png): six representative screens.
- [Design system](DESIGN-SYSTEM.md), [screen map](SCREEN-MAP.md), [handoff](HANDOFF.md), and [tokens](clear-index/tokens.css) are snapshots of the generated design specifications.
- The root [DESIGN.md](../../../DESIGN.md) records the approved project-wide direction.

The local workspace URL is valid while the current OpenDesign runtime is running. The editable prototype and its sources remain in the OpenDesign project; this directory stores the documentation and overview, not a runnable copy. Relative prototype links in the mirrored documents refer to files in that OpenDesign project.

## Scope and verification

The design contains 56 screen/sheet/state entries across access, onboarding, timeline, review, capture, events, documents, explanations, visit summaries, settings, and account flows. All authentication, uploads, recordings, exports, and deletions are synthetic in-memory simulations.

The generator reports six connected journeys passing browser-renderer checks, 185 desktop assertions, and 50 layout/accessibility assertions at each of 375px and 390px, including representative 150% text layouts. These checks do not establish Flutter/device/screen-reader or production-service behavior.

The generated handoff's statements about not inspecting or modifying the repository describe the OpenDesign generation. The coordinating task inspected the current router/screens/docs to supply its brief and updated design documentation only. Existing unrelated changes were preserved.

## Verified current route references

These paths were read from `frontend/lib/app/router.dart`; they supplement the generated screen map's supplied route-family references.

| Design family | Existing route |
|---|---|
| Session / access | `/`, `/login`, `/register`, `/verify-email`, `/forgot-password` |
| Root tabs | `/timeline`, `/capture`, `/summary` |
| Quick note and voice editing | `/notes/new` |
| Manual event / event / edit | `/events/new`, `/events/:id`, `/events/:id/edit` |
| Documents | `/documents`, `/documents/:id` |
| Visit preparation | `/visit-preparation` |
| Settings | `/timeline/settings` |

Document grouping/page review, first-use onboarding, and the original viewer use their existing pushed routes or overlays. Dedicated review inbox, explanation, and revision-comparison surfaces remain unwired in Flutter and were intentionally not added. The implementation restyles existing surfaces without changing retention/authentication semantics.
