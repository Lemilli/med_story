---
name: MedStory
description: A calm, trustworthy medical memory app for organizing long-term health history.
---

# Design System: MedStory

## 1. Overview

**Creative North Star: "The Patient Ledger"**

MedStory should feel like a careful personal health record that belongs to the patient, not a hospital system and not an AI doctor. The visual system is restrained, readable, and task-first: it helps people capture stressful medical information, review years of history, and prepare for appointments without adding cognitive load.

The product should borrow Apple Health's trust and familiarity: clear hierarchy, generous breathing room, strong accessibility defaults, and familiar mobile affordances. The design should feel warm through care and clarity, not decorative softness. MedStory must never imply diagnosis, medical authority, or gamified wellness tracking.

**Key Characteristics:**

- Calm product utility over brand spectacle.
- Capture-first interaction with obvious next actions.
- Patient-controlled AI suggestions that look reviewable, not authoritative.
- Plain-language hierarchy for complex medical content.
- Familiar mobile patterns with enough polish to feel private and reliable.

## 2. Colors

The starter strategy is restrained: pure or near-white surfaces, highly readable ink, and one controlled crimson accent used sparingly for primary action, capture, and important state.

### Primary

- **Controlled Crimson** ([to be resolved during implementation]): The primary brand accent. Use it for capture, primary actions, selected navigation, and urgent-but-not-alarming emphasis. It should be confident, not emergency-room red.

### Neutral

- **Clinical White** ([to be resolved during implementation]): The default app background. Keep the base clean and untinted so the product feels precise rather than generically warm.
- **Quiet Surface** ([to be resolved during implementation]): The panel and container layer for timelines, summaries, document previews, and settings groups.
- **Patient Ink** ([to be resolved during implementation]): The body text color. It must be dark enough for long medical explanations and multi-year timelines.
- **Secondary Ink** ([to be resolved during implementation]): Supporting text for metadata, timestamps, helper copy, and secondary labels. It must remain readable for older users and tired users.
- **Clinical Line** ([to be resolved during implementation]): Dividers, outlines, and input borders. Use it to structure information without turning the app into a grid.

### Named Rules

**The Ten Percent Crimson Rule.** Crimson is rare by default. If more than roughly 10% of a normal screen is crimson, the interface is shouting and should be pulled back.

**The No Emergency Red Rule.** Crimson cannot be used as the generic error color without a distinct treatment. MedStory's primary accent must not make ordinary actions feel medically alarming.

## 3. Typography

**Display Font:** [humanist sans to be chosen at implementation]
**Body Font:** [same humanist sans to be chosen at implementation]
**Label/Mono Font:** [not required for seed]

**Character:** Use one humanist sans family across the product. The voice should feel patient, modern, and readable, with enough warmth for sensitive health content and enough discipline for structured records.

### Hierarchy

- **Display** ([to be resolved], fixed mobile scale, tight but readable line-height): Reserved for onboarding, empty states, and major summary moments. Do not use display type inside dense task screens.
- **Headline** ([to be resolved], fixed mobile scale): Screen titles, timeline period headings, summary sections, and document explanation headings.
- **Title** ([to be resolved], fixed mobile scale): Cards, list rows, confirmation prompts, and form groups.
- **Body** ([to be resolved], comfortable line-height): Medical explanations, summaries, event notes, and instructions. Long prose should stay within a readable measure.
- **Label** ([to be resolved], no aggressive uppercase): Buttons, chips, metadata, and field labels. Labels should remain clear at small sizes and with text scaling enabled.

### Named Rules

**The One Family Rule.** Do not introduce decorative display fonts, serif drama, or mono-forward styling unless a real shipped component earns it. Product trust comes from consistency.

## 4. Elevation

MedStory is flat by default and layered through tone, spacing, and dividers. Shadows should be subtle and state-based: a small lift for interactive feedback, a modal surface when truly needed, and no decorative floating cards.

### Named Rules

**The State-Only Motion Rule.** Motion and elevation should explain state: pressed, selected, loading, expanded, confirmed, or failed. No page-load choreography.

**The Quiet Surface Rule.** Cards and containers should feel organized, not precious. Use spacing and typography before reaching for shadow.

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
- **Don't** use crimson as decoration, generic error red, or a large saturated surface on ordinary task screens.
