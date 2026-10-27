---
name: MedStory
description: A calm, trustworthy medical memory app for organizing long-term health history.
---

# Design System: MedStory

## 1. Overview

**Selected direction: "Clear Index"**

The Flutter app applies concept 03's palette and editorial timeline with concept 01 Quiet Ledger's bottom-navigation geometry. Existing feature behavior takes priority over prototype compositions. The existing system font is retained until a licensed Cyrillic-capable IBM Plex Sans distribution can be bundled and verified.

The [Clear Index design handoff](docs/design/clear-index/README.md) contains the screen map, detailed component specification, editable tokens, overview image, and prototype review instructions.

MedStory should feel like a careful personal health record that belongs to the patient, not a hospital system and not an AI doctor. The visual system is restrained, readable, and task-first: it helps people capture stressful medical information, review years of history, and prepare for appointments without adding cognitive load.

Use precise date-led hierarchy, generous breathing room, fine dividers, and familiar mobile affordances. The design should feel considerate through care and clarity. MedStory must never imply diagnosis, medical authority, or gamified wellness tracking.

**Key Characteristics:**

- Calm product utility over brand spectacle.
- Capture-first interaction with obvious next actions.
- Patient-controlled AI suggestions that look reviewable, not authoritative.
- Plain-language hierarchy for complex medical content.
- Familiar mobile patterns with enough polish to feel private and reliable.

## 2. Colors

White surfaces, slate text, and controlled cobalt replace the previous crimson direction.

| Role | Value | Use |
|------|-------|-----|
| Background / surface | `#FFFFFF` | Main canvas and navigation |
| Patient ink | `#233043` | Titles and body text |
| Secondary ink | `#5F6C7E` | Readable metadata and helper text |
| Cobalt | `#2757BD` | Primary actions, selected navigation, dates, source links |
| Accent tint | `#EDF2FC` | Quiet selected and review surfaces |
| Subtle surface | `#F3F6FA` | Secondary sections and states |
| Divider | `#DCE2EB` | Fine separators and provenance rules |
| Strong line | `#8997AA` | Input outlines and stronger control boundaries |

Use color to communicate interaction and state, with labels and icons as additional cues. Reserve destructive/error treatments for those actions and states; never use color to infer medical risk. Keep saturated surfaces small.

## 3. Typography

**Approved target:** IBM Plex Sans, weights 400–700 as needed. **Current Flutter implementation:** existing platform font, with Clear Index sizing, leading, and weight hierarchy.

**Character:** One coherent sans-serif family with clear numerals and readable long-form text. The prototype's Latin-only subsets are not shipped in Flutter; English and Russian retain the existing platform font support.

### Hierarchy

- **Screen title:** 32px reference size, adjusted for context and scaled with accessibility settings.
- **Section / event title:** 18px reference size with restrained medium or semibold weight.
- **Body:** 16px with comfortable line-height for explanations, summaries, and notes.
- **Supporting text:** 14px; metadata 13px, with sufficient contrast.
- **Index labels:** Restrained uppercase for event-type labels and the small brand eyebrow; sentence case for prose and ordinary controls.

Treat these as logical mobile reference sizes, not a reason to disable OS text scaling. Allow wrapping and scrolling at larger sizes. Navigation geometry is specified separately below.

### Named Rules

**The One Family Rule.** Do not introduce decorative display fonts, serif drama, or mono-forward styling unless a real shipped component earns it. Product trust comes from consistency.

## 4. Elevation

MedStory is flat by default and layered through tone, spacing, and dividers. Shadows should be subtle and state-based: a small lift for interactive feedback, a modal surface when truly needed, and no decorative floating cards.

### Named Rules

**The State-Only Motion Rule.** Motion and elevation should explain state: pressed, selected, loading, expanded, confirmed, or failed. No page-load choreography.

**The Quiet Surface Rule.** Cards and containers should feel organized, not precious. Use spacing and typography before reaching for shadow.

## 5. Geometry and Navigation

- Use a 4px spacing base: 4, 8, 12, 16, 20, 24, and 32px. Default content inset is 24px.
- Inputs and ordinary buttons use a restrained 4px radius. Timeline records remain flat with fine horizontal separators and a vertical rule separating dates from record content.
- Root destinations are **My Story**, **Add**, and **For Visits**, in three equal columns. Detail, form, authentication, and source-viewer screens use back/close navigation.
- Match **Quiet Ledger's geometry**, recolored with Clear Index tokens: 8px column gap; bar padding 8px top, 16px horizontally, 4px bottom; minimum item height 64px; vertical icon-over-label stack with a 5px gap; 22px icons; 12px reference labels.
- Ordinary icon wrappers are 52 × 28px. The central Add icon wrapper is 52 × 32px with a 6px radius and cobalt fill. Its label sits below the icon, like the other destinations.
- The reference bar content is 76px high before the device's bottom safe area. Respect device insets without double-padding; larger text can increase height.
- Use a white bar, a fine top divider, cobalt selected icons/labels, and slate inactive icons/labels. The active item has no top stripe. The Add destination does not use the previous wide horizontal button.
- Compact icon artwork must sit inside at least 48 × 48px actionable targets. Sheets, dialogs, controls, and links need visible keyboard focus and semantic labels.

## 6. Do's and Don'ts

### Do:

- **Do** make capture actions visually obvious and reachable within one or two taps.
- **Do** keep AI-suggested events, summaries, and explanations visibly reviewable, editable, and confirmable.
- **Do** support large text, high contrast, screen-reader labels, and minimum 48dp tap targets from the first implementation pass.
- **Do** use familiar mobile patterns for navigation, forms, lists, filters, empty states, and errors.
- **Do** write copy that reinforces MedStory as an organizer and memory aid, not a medical authority.

### Don't:

- **Don't** make MedStory look like an AI doctor, symptom checker, diagnostic assistant, or treatment recommendation tool.
- **Don't** use generic AI doctor chatbot patterns: chat-first, overconfident, diagnosis-adjacent interactions are prohibited.
- **Don't** make it feel like a telemedicine platform, appointment-booking service, insurance portal, or hospital integration hub.
- **Don't** mimic a complex electronic health record designed for clinicians rather than patients.
- **Don't** turn medical history into a productivity dashboard with metrics, streaks, or gamification.
- **Don't** soften the product into a decorative wellness app that fails to communicate security, seriousness, and long-term reliability.
- **Don't** reintroduce the earlier crimson brand palette or oversized horizontal Add navigation button into this selected direction.
