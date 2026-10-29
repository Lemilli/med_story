# README screenshots

Updated on 30 October 2026. These captures render the production Clear Index Flutter screens with one connected, fictional type 2 diabetes history. No live account, backend requests, patient records, or AI calls are used.

The story follows Alex from a documented diagnosis and first prescription in March 2024 through lab reports, prescription updates, eye screening, personal notes, and preparation for a new specialist in October 2026. Thirteen dated events give the screenshots a shared history. Results are fictional recorded values, without clinical interpretation or treatment advice.

| File | State |
|---|---|
| `timeline.png` | Latest HbA1c result, metformin prescription, tiredness note, and eye screening |
| `capture.png` | Three PDFs: completed laboratory report, processing clinic letter, and prescription uploading at 64% |
| `document-result.png` | Completed queue item opened through its normal control; extracted HbA1c result, report details, and original-document action |
| `event-detail.png` | Tiredness record with original voice transcript and organized details, preserving the missing glucose reading |
| `search.png` | Search submitted for “metformin”; prescriptions from 2026, 2025, and 2024 with unrelated records filtered out |
| `filters.png` | Timeline filter sheet opened through its normal control |
| `visit-preparation.png` | New-specialist briefing with the saved reason, concerns, documented diagnosis, and medication history |
| `visit-sources.png` | HbA1c source sheet opened through the summary, linking the October 2026, July 2026, and June 2025 reports |

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

Fixtures live in `frontend/test/fixtures/readme_screenshot_data.dart`; the capture harness remains opt-in. The same IDs, dates, values, and source relationships connect the queue, timeline, records, and summary.

The harness checks for widget exceptions and verifies navigation geometry. It submits the normal search field, verifies all three prescription results and exclusion of an unrelated lab record, opens the completed queue result through a mocked repository, and opens the summary's source sheet through its normal control. Bounded pumping captures the animated upload queue at a repeatable moment.

Upload progress, extraction, transcription, and saved summaries are simulated provider states. The queue's PDF paths are placeholders; no local document is read, no file picker is exercised, and the original-document button is shown but not opened. These are widget renders, not device or live-service integration tests. No production UI, clinical logic, or backend behavior is changed by this harness.
