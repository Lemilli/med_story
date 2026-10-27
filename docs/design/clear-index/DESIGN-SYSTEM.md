# MedStory — Clear Index design system

Version 1.0 · Design only · English mobile prototype

Canonical artifact: [clear-index.html](clear-index.html). Open its **Design system** mode for rendered components, or **Screen gallery** for full-size screens. The original [four-way comparison](index.html) remains an unchanged reference.

## Origin and intent

This system continues actual concept 03 from the original `tokens.css`, `styles.css`, and `app.js`: IBM Plex Sans, exact white/slate/cobalt colors, emphatic cobalt dates, fine vertical provenance dividers, uppercase event types, and squared controls. It replaces only the original concept 03 navigation morphology with the user-selected concept 01 geometry. No generic health dashboard, clinical scoring, or medical assessment is introduced.

## Editable source

- `clear-index/tokens.css`: independent, namespaced color, type, spacing, shape, motion, and navigation variables.
- `clear-index/components.js`: shared icons, fields, buttons, rows, badges, banners, reports, top bars, navigation, sheets, and timeline components.
- `clear-index/screens.js`: compositions using those components.
- `clear-index/data.js`: synthetic records, document bundles, suggestions, screen catalog, and seed state.
- `clear-index/app.js`: local navigation and interaction state.
- `clear-index/styles.css`: layout, responsive behavior, and component states.

Do not edit the original comparison bundle when extending this system.

## Palette

| Role | Value | Use |
|---|---|---|
| White | `#FFFFFF` | App surfaces, fields, root navigation |
| Ink | `#233043` | Primary text and strong section rules |
| Muted | `#5F6C7E` | Readable supporting text |
| Cobalt | `#2757BD` | Actions, selected states, date anchors |
| Pale | `#EDF2FC` | Unconfirmed suggestions and quiet selection |
| Subtle | `#F3F6FA` | Secondary surfaces and loading placeholders |
| Line | `#DCE2EB` | Fine dividers and provenance rails |
| Input line | `#8997AA` | Exact field boundaries |
| Destructive / error | `#B42332` | Deletion and actionable errors only |
| Success | `#23634B` on `#EFF7F2` | Confirmation of a user action |
| Warning | `#78561D` on `#FBF6E9` | Reserved for operational caution |

Semantic colors never encode whether a medical result is good or bad. Text labels accompany every status. The light divider color is decorative; essential control boundaries use the stronger input line, a visible selected shape, or a labeled action. Focus is a 2px cobalt outline with a 3px offset.

## Typography

One family: **IBM Plex Sans**, weights 400, 500, 600, 700. Existing local font files under `assets/fonts/` are reused without modification. Their SIL Open Font License files and source metadata remain beside them.

| Style | Size at 100% | Weight / treatment |
|---|---:|---|
| Home page title | 32px | 600, −1px tracking |
| Detail / access title | 28px | 500, tight but readable leading |
| Section | 24px | 500 |
| Top bar / subheading | 20px | 500 |
| Event title | 18px | 500 |
| Body / field | 16px | 400; 1.55 line height |
| Supporting text | 14px | 400 |
| Metadata / uppercase type | 13px | 400–500; controlled tracking |
| Navigation label | 12px | Exact selected geometry |
| Timeline day | 27–29px | 400, cobalt, proportional clamp |

Substantive content wraps fully. Lists do not hide source facts in ellipses. The miniature report text is an intentionally reduced document thumbnail; the full source frame is available in the original viewer. It is not product body copy.

### Cyrillic support

The existing local web font subsets were acquired for the English study and cover Latin text. The language preference includes English/Russian, while all visible mockups remain English. Later Flutter work must bundle and verify a full IBM Plex Sans distribution with Cyrillic glyphs, appropriate weights, and its license. Do not rely on silent mixed-family fallback. No Russian translation or Flutter font integration is claimed here.

## Grid, spacing, and shapes

- Logical phone viewport: **390 × 844**. Also designed for 375px width.
- Content gutters: 24px. Fields and primary content use normal flow and auto height.
- Spacing scale: 4, 8, 12, 16, 20, 24, 32px.
- Inputs/buttons: 4px radius, 1px border; 48px minimum hit area.
- Section rule: 2px ink. Fine provenance and list rules: 1px line.
- Sheets: 12px top corners, exact border, contained scrolling.
- No gradients or shadows in product surfaces. The neutral handset hardware is presentation chrome.
- Root layout: header / independently scrolling content / navigation. Detail layouts use back navigation and optional form action footers.

## Exact root navigation specification

The geometry comes from the actual Quiet Ledger rules in the original `styles.css`; colors and typography come from Clear Index.

| Property | Exact value |
|---|---|
| Grid | 3 equal `minmax(0, 1fr)` columns |
| Column gap | 8px |
| Bar padding | 8px top, 16px left/right, 4px bottom |
| Bar | White; 1px `#DCE2EB` top rule |
| Item layout | Vertical icon over label; centered |
| Minimum item height | 64px at 100% |
| Item padding | 4px top/bottom, 0 sides |
| Icon-label gap | 5px |
| Icon size | 22px |
| Ordinary icon wrap | 52 × 28px; transparent |
| Add icon wrap | 52 × 32px; 6px radius; cobalt fill, white icon |
| Label | 12px at 100% |
| Current root | Cobalt icon and label; `aria-current="page"` |
| Safe area | Separate 29px gesture inset beneath content |

Tabs: **My Story**, **Add**, **For Visits**. There is no broad horizontal Add button and no selected top stripe. All three roots share the same renderer and dimensions. Forms, details, settings, and authentication do not falsely display a root selection. Compact visible icons retain full 48px+ control targets.

At 150% text the labels become 18px and navigation item minimum height becomes 76px to accommodate wrapping. The locked 100% geometry is unchanged.

## Shared component contracts

| Component | Contract and states |
|---|---|
| Buttons | Primary cobalt, secondary border, text, destructive, disabled, progress; visible focus and darker hover |
| Inputs | Persistent labels; default, focus, filled, error, disabled; 16px base; inline guidance |
| Password | Visibility action with accessible show/hide label |
| Check/radio | Text label and selection shape; 48px+ row |
| Badges | Unconfirmed, reviewed, source, failed; never color alone |
| Action rows | Title + helper in a block; trailing coherent outline icon; 76px minimum |
| Banners | Operational information, failure, confirmed action; cached content remains readable |
| Timeline rows | Cobalt date column; uppercase event type; title/preview/source; fine vertical provenance rule |
| Top bars | Back/close target, wrapping title, optional action |
| Root navigation | Shared exact geometry above |
| Sheets/dialogs | Phone-contained scrim; inert background; explicit close; keyboard focus management |
| Empty/loading/error | Explanatory message and next action; progress line; errors do not erase cached content |
| Report pages | Locally rendered synthetic pages, natural full frame, image page indicator; no real record |
| Briefing sections | Source-linked recorded facts; hide empty sections |

Rendered examples in Design system mode include all of these, plus the seven briefing section headings: Current concerns; Important diagnoses and findings; Allergies; Current medications; Important test results; Previous treatments and outcomes; Procedures and hospitalizations. Only populated sections appear in the actual briefing.

## Safe areas, scrolling, and text scaling

- The handset preserves a 50px system status inset and a separate 29px gesture inset.
- Chrome does not cover content. Screen bodies and sheet bodies scroll independently.
- The outside-app **150% text** control scales product typography to 1.5×. Body becomes 24px; metadata 19.5–21px; navigation labels 18px. Filters reflow to two columns. Titles and action labels wrap; primary information is not ellipsized.
- Browser zoom is not disabled. Form inputs retain a mobile-friendly base size.
- Motion: 200ms entrance, 140ms exit token. Reduced motion disables progress travel and sheet entrance animation.
- Outline icons use a consistent 24-unit view box, 1.6-unit stroke, rounded ends, and explicit rendered geometry.
- Keyboard: logical tab order, visible focus, Escape closes sheets, and focus returns to an available control after closing.

## Provenance and product boundaries

User-written original text, source-derived organized notes, reviewed suggestions, and later user edits have different labels. Unconfirmed suggestions do not enter the timeline until explicit confirmation. Revision comparison changes only selected fields. One capture bundle produces one suggested event, regardless of its page count.

The interface organizes and explains existing records; it does not diagnose, prescribe, interpret omitted demo values, infer clinical findings, or rank treatment. AI is core. The registration screen requires one combined privacy/AI notice acceptance, without a second AI switch or consent checkbox.
