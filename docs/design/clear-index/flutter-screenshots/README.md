# Clear Index Flutter renders

These images render the actual Flutter presentation widgets with synthetic, in-memory test providers. They are not prototype exports or captures of real medical records. Detail screens are pushed from the timeline so their normal back controls are visible. Settings retains the existing root shell navigation.

| Frame | Screen / state | Viewport and text |
|---|---|---|
| [01](01-my-story.png) | My Story, dated records and month dividers | 390 × 900, English, 100% |
| [02](02-add.png) | Add, existing capture choices | 390 × 900, English, 100% |
| [03](03-for-visits.png) | Existing summary, saved visit reason and source | 390 × 900, English, 100% |
| [04](04-sign-in.png) | Sign in | 390 × 900, English, 100% |
| [05](05-registration.png) | Registration and combined privacy / AI acceptance | 390 × 900, English, 100% |
| [06](06-note.png) | Typed note with existing voice and save actions | 390 × 900, English, 100% |
| [07](07-event.png) | Event detail and original / edit / delete actions | 390 × 900, English, 100% |
| [08](08-document.png) | Document metadata, result and deletion actions | 390 × 900, English, 100% |
| [09](09-settings.png) | Settings, collapsed disclosures and account actions | 390 × 900, English, 100% |
| [10](10-settings-ru-large.png) | Settings, responsive profile heading | 320 × 900, Russian, 150% |
| [11](11-my-story-ru-large.png) | My Story, wrapping records and root navigation | 320 × 900, Russian, 150% |
| [12](12-note-ru-large.png) | Typed note, scrolling editor and existing actions | 375 × 900, Russian, 150% |

The test reserves 24 logical pixels at the top and bottom for safe-area checks; it does not draw native system chrome. All content remains scrollable where the production widget supports scrolling. These initial frames do not show content below the viewport.

The production font family is retained; IBM Plex Sans remains deferred until a licensed asset with complete Cyrillic coverage is available. For readable test rendering, the harness loads the Flutter SDK's bundled Roboto (including Cyrillic) and MaterialIcons fonts. It also applies Roboto to test theme button styles to replace Flutter tests' Ahem font. These test-only font settings are not shipped in the app.

Regenerate from `frontend/` with a Flutter SDK compatible with the existing project requirements:

```sh
flutter test --no-pub \
  --dart-define=CLEAR_INDEX_SCREENSHOTS=true \
  --dart-define=FLUTTER_SCREENSHOT_SDK=/path/to/flutter \
  test/clear_index_visual_test.dart
```

The harness is opt-in and skipped during the ordinary test suite. It asserts absence of widget exceptions and verifies normal English root navigation dimensions: three equal 64px-minimum targets, 52 × 28px ordinary icon wrappers, a 52 × 32px Add wrapper, and 76px bar content plus one bottom safe inset. The thin top rule paints inside the bar's bounds.

These renders and widget checks do not verify a physical device, native keyboard, microphone or picker permissions, screen-reader operation, live authentication, upload, transcription, exports or destructive account actions.
