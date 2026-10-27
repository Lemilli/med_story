# README screenshots

Updated for the Clear Index redesign on 28 October 2026. These captures render the production Flutter screens with an in-memory fictional history. No live account, backend requests, patient records, or AI calls are used.

| File | State |
|---|---|
| `timeline.png` | My Story with dated symptoms, a laboratory report, and visit notes |
| `capture.png` | Add menu with photo, scan, file, and note options |
| `event-detail.png` | Migraine record with original voice transcript and organized details |
| `search.png` | Search submitted for “migraine”; unrelated records filtered out |
| `filters.png` | Timeline filter sheet opened through its normal control |
| `visit-preparation.png` | For Visits with a saved reason, concerns, and a linked report |

The images use a 390 × 900 logical viewport and 3× rendering (1170 × 2700 PNGs), with 24 logical pixels reserved at the top and bottom. Native status/navigation chrome is not drawn. The harness loads the Flutter SDK’s bundled Roboto and MaterialIcons fonts for readable widget-test rendering; production font settings are unchanged.

From `frontend/`, use a Flutter SDK compatible with `pubspec.yaml`:

```sh
flutter test --no-pub \
  --dart-define=CLEAR_INDEX_SCREENSHOTS=true \
  --dart-define=README_SCREENSHOTS=true \
  --dart-define=FLUTTER_SCREENSHOT_SDK=/absolute/path/to/flutter \
  test/clear_index_visual_test.dart
```

The default output for this mode is `assets/screenshots/` at the repository root. To preview elsewhere, pass `--dart-define=CLEAR_INDEX_SCREENSHOT_DIR=/absolute/output/directory`. Omit `README_SCREENSHOTS` to retain the existing design-review capture mode.

Fixtures live in `frontend/test/fixtures/readme_screenshot_data.dart`; the capture harness remains opt-in. It checks for widget exceptions and verifies navigation geometry. The search capture submits the normal search field and checks that unrelated records disappear. These are widget renders, not device or live-service integration tests.
