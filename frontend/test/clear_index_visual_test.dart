// Opt-in screenshots of production widgets using synthetic, in-memory fixtures.
// Run from frontend with:
// flutter test --dart-define=CLEAR_INDEX_SCREENSHOTS=true \
//   --dart-define=FLUTTER_SCREENSHOT_SDK=/path/to/flutter \
//   test/clear_index_visual_test.dart
// Add --dart-define=README_SCREENSHOTS=true for the six README captures.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/core/storage/secure_token_storage.dart';
import 'package:med_story/core/widgets/clear_index_navigation_bar.dart';
import 'package:med_story/features/auth/domain/auth_models.dart';
import 'package:med_story/features/auth/presentation/controllers/auth_controller.dart';
import 'package:med_story/features/auth/presentation/screens/auth_form_screen.dart';
import 'package:med_story/features/capture/presentation/controllers/voice_capture_controller.dart';
import 'package:med_story/features/capture/presentation/screens/capture_screen.dart';
import 'package:med_story/features/capture/presentation/screens/quick_note_screen.dart';
import 'package:med_story/features/documents/data/document_api.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/documents/presentation/controllers/document_controllers.dart';
import 'package:med_story/features/documents/presentation/screens/document_detail_screen.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:med_story/features/events/presentation/controllers/event_controllers.dart';
import 'package:med_story/features/events/presentation/screens/event_detail_screen.dart';
import 'package:med_story/features/settings/presentation/controllers/settings_controller.dart';
import 'package:med_story/features/settings/presentation/screens/settings_screen.dart';
import 'package:med_story/features/shell/presentation/screens/app_shell.dart';
import 'package:med_story/features/subjects/domain/subject.dart';
import 'package:med_story/features/subjects/presentation/controllers/subject_controller.dart';
import 'package:med_story/features/summary/data/summary_repository.dart';
import 'package:med_story/features/summary/domain/medical_summary.dart';
import 'package:med_story/features/summary/presentation/controllers/summary_controller.dart';
import 'package:med_story/features/summary/presentation/screens/summary_screen.dart';
import 'package:med_story/features/timeline/domain/timeline_filters.dart';
import 'package:med_story/features/timeline/presentation/controllers/timeline_controller.dart';
import 'package:med_story/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures/readme_screenshot_data.dart';

const _capture = bool.fromEnvironment('CLEAR_INDEX_SCREENSHOTS');
const _readme = bool.fromEnvironment('README_SCREENSHOTS');
const _sdk = String.fromEnvironment('FLUTTER_SCREENSHOT_SDK');
const _destination = String.fromEnvironment(
  'CLEAR_INDEX_SCREENSHOT_DIR',
  defaultValue: _readme
      ? '../assets/screenshots'
      : '../docs/design/clear-index/flutter-screenshots',
);

void main() {
  setUpAll(() async {
    if (!_capture) return;
    // The SDK's bundled, licensed Roboto fonts keep these captures readable.
    // This affects test rendering only; no font asset is added to the app.
    final sdk = _sdk.isEmpty ? Platform.environment['FLUTTER_ROOT'] : _sdk;
    if (sdk == null || sdk.isEmpty) {
      throw StateError('Set FLUTTER_SCREENSHOT_SDK to the Flutter SDK path.');
    }
    final fonts = FontLoader('Roboto');
    for (final weight in ['Regular', 'Medium', 'Bold']) {
      fonts.addFont(
        Future.value(
          ByteData.sublistView(
            File('$sdk/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf')
                .readAsBytesSync(),
          ),
        ),
      );
    }
    await fonts.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(
      Future.value(
        ByteData.sublistView(
          File(
            '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
          ).readAsBytesSync(),
        ),
      ),
    );
    await icons.load();
  });

  for (final scene in const [
    if (_readme) ...[
      _Scene('timeline', '/timeline'),
      _Scene('capture', '/capture'),
      _Scene('event-detail', '/events/synthetic-event'),
      _Scene('search', '/timeline'),
      _Scene('filters', '/timeline'),
      _Scene('visit-preparation', '/summary'),
    ] else ...[
      _Scene('01-my-story', '/timeline'),
      _Scene('02-add', '/capture'),
      _Scene('03-for-visits', '/summary'),
      _Scene('04-sign-in', '/login'),
      _Scene('05-registration', '/register'),
      _Scene('06-note', '/notes/new'),
      _Scene('07-event', '/events/synthetic-event'),
      _Scene('08-document', '/documents/synthetic-document'),
      _Scene('09-settings', '/timeline/settings'),
      _Scene(
        '10-settings-ru-large',
        '/timeline/settings',
        locale: Locale('ru'),
        width: 320,
        scale: 1.5,
      ),
      _Scene(
        '11-my-story-ru-large',
        '/timeline',
        locale: Locale('ru'),
        width: 320,
        scale: 1.5,
      ),
      _Scene(
        '12-note-ru-large',
        '/notes/new',
        locale: Locale('ru'),
        width: 375,
        scale: 1.5,
      ),
    ],
  ]) {
    testWidgets('Clear Index ${scene.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(scene.width, 900);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      final boundaryKey = GlobalKey();
      final detail =
          scene.path.startsWith('/events/') ||
          scene.path.startsWith('/documents/');
      final router = _router(detail ? '/timeline' : scene.path);
      addTearDown(router.dispose);
      final theme = AppTheme.light();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureTokenStorageProvider.overrideWithValue(
              const _OnboardingSeenStorage(),
            ),
            authControllerProvider.overrideWith(_FixtureAuthController.new),
            accountUsageProvider.overrideWith(
              (_) async => const AccountUsage(
                aiUnitsRemainingToday: 8,
                storageBytesUsed: 1024 * 1024,
                storageBytesLimit: 100 * 1024 * 1024,
              ),
            ),
            subjectControllerProvider.overrideWith(
              _FixtureSubjectController.new,
            ),
            timelineControllerProvider.overrideWith(
              _FixtureTimelineController.new,
            ),
            timelineEventsProvider.overrideWith((ref) {
              final query =
                  ref
                      .watch(timelineControllerProvider)
                      .value
                      ?.filters
                      .query
                      .toLowerCase() ??
                  '';
              return Stream.value(
                _events
                    .where(
                      (event) => '${event.title} ${event.description}'
                          .toLowerCase()
                          .contains(query),
                    )
                    .toList(),
              );
            }),
            summaryControllerProvider.overrideWith(
              _FixtureSummaryController.new,
            ),
            documentUploadControllerProvider.overrideWith(
              _FixtureUploadController.new,
            ),
            voiceCaptureControllerProvider.overrideWith(
              _FixtureVoiceController.new,
            ),
            documentApiProvider.overrideWithValue(_UnusedDocumentApi()),
            eventDetailProvider('synthetic-event')
                .overrideWith((_) async => _events.first),
            documentDetailProvider('synthetic-document').overrideWith(
              (_) async => MedicalDocument(
                id: 'synthetic-document',
                title: 'Synthetic laboratory report',
                status: DocumentStatus.processed,
                docType: DocumentType.labResult,
                documentDate: '2026-10-24',
                mimeType: 'application/pdf',
                eventId: 'synthetic-event',
                eventCount: 1,
                createdAt: _stamp,
                updatedAt: _stamp,
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: theme.copyWith(
              textTheme: theme.textTheme.apply(fontFamily: 'Roboto'),
              primaryTextTheme: theme.primaryTextTheme.apply(
                fontFamily: 'Roboto',
              ),
              appBarTheme: theme.appBarTheme.copyWith(
                titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
                  fontFamily: 'Roboto',
                ),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: _buttonFont(theme.filledButtonTheme.style),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: _buttonFont(theme.outlinedButtonTheme.style),
              ),
              textButtonTheme: TextButtonThemeData(
                style: _buttonFont(theme.textButtonTheme.style),
              ),
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: scene.locale,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scene.scale)),
              child: RepaintBoundary(key: boundaryKey, child: child!),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (detail) {
        router.push(scene.path);
        await tester.pumpAndSettle();
      }
      if (_readme && scene.name == 'search') {
        await tester.enterText(find.byType(TextField), 'migraine');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        expect(find.text('Migraine after a busy day'), findsOneWidget);
        expect(find.text('Annual blood test'), findsNothing);
      }
      if (scene.scale == 1 &&
          const ['/timeline', '/capture', '/summary'].contains(scene.path)) {
        final bar = find.byType(ClearIndexNavigationBar);
        final targets = find.descendant(
          of: bar,
          matching: find.byType(InkWell),
        );
        expect(targets, findsNWidgets(3));
        final sizes = List.generate(
          3,
          (index) => tester.getSize(targets.at(index)),
        );
        for (final size in sizes) {
          expect(size.height, 64);
          expect(size.width, closeTo(sizes.first.width, 0.01));
          expect(size.width, greaterThanOrEqualTo(48));
        }
        final wrappers = find.descendant(
          of: bar,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container && widget.constraints?.maxWidth == 52,
          ),
        );
        expect(wrappers, findsNWidgets(3));
        expect(tester.getSize(wrappers.at(0)), const Size(52, 28));
        expect(tester.getSize(wrappers.at(1)), const Size(52, 32));
        expect(tester.getSize(wrappers.at(2)), const Size(52, 28));
        // The one-pixel rule paints inside the 76px bar content.
        expect(tester.getSize(bar).height, 76 + 24);
      }
      if (scene.path == '/notes/new') {
        await tester.enterText(
          find.byType(TextField),
          'Synthetic note for layout review.\n\nI want to keep the wording of my visit together with my report.',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      }
      if (_readme && scene.name == 'filters') {
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: _readme ? 3 : 1);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        final output = File('$_destination/${scene.name}.png');
        await output.parent.create(recursive: true);
        await output.writeAsBytes(bytes.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }, skip: !_capture);
  }
}

class _Scene {
  const _Scene(
    this.name,
    this.path, {
    this.locale = const Locale('en'),
    this.width = 390,
    this.scale = 1,
  });

  final String name;
  final String path;
  final Locale locale;
  final double width;
  final double scale;
}

ButtonStyle _buttonFont(ButtonStyle? style) =>
    (style ?? const ButtonStyle()).copyWith(
      textStyle: WidgetStateProperty.resolveWith(
        (states) => (style?.textStyle?.resolve(states) ?? const TextStyle())
            .copyWith(fontFamily: 'Roboto'),
      ),
    );

GoRouter _router(String initialLocation) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timeline',
              builder: (_, _) => const TimelineScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (_, _) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/capture', builder: (_, _) => const CaptureScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/summary', builder: (_, _) => const SummaryScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const AuthFormScreen(mode: AuthFormMode.login),
    ),
    GoRoute(
      path: '/register',
      builder: (_, _) => const AuthFormScreen(mode: AuthFormMode.register),
    ),
    GoRoute(path: '/notes/new', builder: (_, _) => const QuickNoteScreen()),
    GoRoute(
      path: '/events/:id',
      builder: (_, _) => const EventDetailScreen(eventId: 'synthetic-event'),
    ),
    GoRoute(
      path: '/documents/:id',
      builder: (_, _) =>
          const DocumentDetailScreen(documentId: 'synthetic-document'),
    ),
  ],
);

class _OnboardingSeenStorage extends SecureTokenStorage {
  const _OnboardingSeenStorage() : super(const FlutterSecureStorage());

  @override
  Future<bool> hasSeenOnboarding() async => true;
}

class _FixtureAuthController extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState.authenticated(
    AppUser(
      id: 'synthetic-user',
      email: 'alex@example.com',
      fullName: 'Alex Example',
      locale: 'en',
    ),
  );
}

class _FixtureSubjectController extends SubjectController {
  @override
  Future<SubjectState> build() async =>
      SubjectState(subjects: [_subject], selectedSubjectId: _subject.id);
}

class _FixtureTimelineController extends TimelineController {
  @override
  Future<TimelineState> build() async =>
      const TimelineState(subjectId: 'synthetic-subject');

  @override
  Future<void> updateFilters(TimelineFilters filters) async {
    state = AsyncValue.data(state.requireValue.copyWith(filters: filters));
  }
}

class _FixtureSummaryController extends SummaryController {
  @override
  Future<SummaryState> build() async => SummaryState(
    subject: _subject,
    reason: _readme
        ? readmeVisitReason
        : 'Discuss my saved reports and visit notes.',
    savedReason: _readme
        ? readmeVisitReason
        : 'Discuss my saved reports and visit notes.',
    loadResult: SummaryLoadResult.ready(
      MedicalSummary(
        id: 'synthetic-summary',
        subjectId: 'synthetic-subject',
        version: 1,
        createdAt: _stamp,
        content: _readme
            ? readmeSummaryContent
            : const {
                'current_concerns': [
                  {
                    'text': 'Visit notes saved for discussion',
                    'detail': 'A personal note records questions to bring to the next visit.',
                  },
                ],
                'important_test_results': [
                  {
                    'text': 'Laboratory report saved',
                    'detail': 'The original report is linked to the timeline. This fixture contains no clinical measurements.',
                    'source_event_ids': ['synthetic-event'],
                  },
                ],
              },
      ),
    ),
  );
}

class _FixtureUploadController extends DocumentUploadController {
  @override
  Future<List<QueuedUpload>> build() async => const [];
}

class _FixtureVoiceController extends VoiceCaptureController {
  @override
  Future<VoiceCaptureState> build() async =>
      const VoiceCaptureState(stage: VoiceCaptureStage.idle);

  @override
  Future<void> discardRecording() async {}
}

class _UnusedDocumentApi extends Mock implements DocumentApi {}

final _stamp = DateTime.utc(2026, 10, 28);
final _subject = Subject(
  id: 'synthetic-subject',
  displayName: 'Alex Example',
  relationship: SubjectRelationship.self,
  isDefault: true,
  createdAt: _stamp,
  updatedAt: _stamp,
);
final _events = _readme
    ? readmeEvents
    : [
        MedicalEvent(
          id: 'synthetic-event',
          eventType: MedicalEventType.examination,
          title: 'Laboratory report saved',
          description: 'A synthetic report is linked to this event for layout review. No clinical values are included.',
          eventDate: '2026-10-24',
          source: EventSource.aiDocument,
          sourceDocumentId: 'synthetic-document',
          sourceAssetCount: 1,
          subjectId: 'synthetic-subject',
          createdAt: _stamp,
          updatedAt: _stamp,
        ),
        MedicalEvent(
          id: 'synthetic-note',
          eventType: MedicalEventType.note,
          title: 'Questions for my next visit',
          description: 'Synthetic personal note for visual review.',
          eventDate: '2026-10-22',
          tags: const ['Visit notes'],
          subjectId: 'synthetic-subject',
          createdAt: _stamp,
          updatedAt: _stamp,
        ),
        MedicalEvent(
          id: 'synthetic-record',
          eventType: MedicalEventType.medicalRecord,
          title: 'Follow-up visit record',
          eventDate: '2026-09-16',
          subjectId: 'synthetic-subject',
          createdAt: _stamp,
          updatedAt: _stamp,
        ),
      ];
