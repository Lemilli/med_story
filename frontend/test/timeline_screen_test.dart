import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:med_story/features/subjects/presentation/controllers/subject_controller.dart';
import 'package:med_story/features/timeline/data/timeline_api.dart';
import 'package:med_story/features/timeline/data/timeline_repository.dart';
import 'package:med_story/features/timeline/domain/timeline_filters.dart';
import 'package:med_story/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements TimelineRepository {}

class _SubjectController extends SubjectController {
  @override
  Future<SubjectState> build() async =>
      const SubjectState(subjects: [], selectedSubjectId: 'subject-1');
}

MedicalEvent _event(int index) => MedicalEvent(
  id: 'event-$index',
  subjectId: 'subject-1',
  eventType: index == 0 ? MedicalEventType.note : MedicalEventType.examination,
  title: index == 0
      ? 'Target note with full patient wording'
      : 'Synthetic record $index with a long source title',
  eventDate: index == 6 ? '2026-09-01' : '2026-10-${24 - index}',
  tags: index == 0 ? ['Personal note'] : [],
  createdAt: DateTime.utc(2026, 10, 28),
  updatedAt: DateTime.utc(2026, 10, 28),
);

void main() {
  setUpAll(() => registerFallbackValue(const TimelineFilters()));

  testWidgets(
    'timeline preserves search, filters, pagination, cached refresh and event navigation',
    (tester) async {
      final repository = _Repository();
      var loaded = 6;
      var calls = 0;
      String? lastCursor;
      var failRefresh = false;
      var lastFilters = const TimelineFilters();
      when(
        () => repository.refreshTimeline(
          subjectId: any(named: 'subjectId'),
          filters: any(named: 'filters'),
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer((invocation) async {
        calls++;
        lastFilters = invocation.namedArguments[#filters] as TimelineFilters;
        lastCursor = invocation.namedArguments[#cursor] as String?;
        if (failRefresh) throw StateError('synthetic offline');
        if (lastCursor != null) loaded = 7;
        return TimelinePage(
          results: [],
          nextCursor: loaded == 6 ? 'page-2' : null,
          previousCursor: null,
        );
      });
      when(
        () => repository.watchTimeline(
          subjectId: any(named: 'subjectId'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((invocation) {
        final filters = invocation.namedArguments[#filters] as TimelineFilters;
        return Stream.value(
          List.generate(loaded, _event)
              .where(
                (event) =>
                    (filters.query.isEmpty ||
                        event.title.toLowerCase().contains(
                          filters.query.toLowerCase(),
                        )) &&
                    (filters.types.isEmpty ||
                        filters.types.contains(event.eventType)),
              )
              .toList(),
        );
      });
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: TimelineScreen()),
          ),
          GoRoute(
            path: '/events/:id',
            builder: (_, state) => Scaffold(
              appBar: AppBar(),
              body: Text('Opened ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subjectControllerProvider.overrideWith(_SubjectController.new),
            timelineRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light(),
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(TimelineScreen)),
      )!;
      expect(calls, 1);
      expect(find.text('October 2026'), findsOneWidget);
      final timelineScroll = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text(l10n.timelineLoadMore),
        160,
        scrollable: timelineScroll,
      );
      await tester.tap(find.text(l10n.timelineLoadMore));
      await tester.pumpAndSettle();
      expect(lastCursor, 'page-2');
      await tester.scrollUntilVisible(
        find.text('September 2026'),
        160,
        scrollable: timelineScroll,
      );
      expect(find.text(l10n.timelineLoadMore), findsNothing);
      await tester.scrollUntilVisible(
        find.byType(TextField),
        -300,
        scrollable: timelineScroll,
      );
      await tester.enterText(find.byType(TextField), 'Target');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(lastFilters.query, 'Target');
      expect(
        find.text('Target note with full patient wording'),
        findsOneWidget,
      );
      expect(
        find.text('Synthetic record 1 with a long source title'),
        findsNothing,
      );
      await tester.tap(find.text('Target note with full patient wording'));
      await tester.pumpAndSettle();
      expect(find.text('Opened event-0'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Target',
      );
      await tester.tap(find.byTooltip(l10n.timelineClearSearchAction));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.timelineFiltersAction));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.scrollUntilVisible(
        find.text(l10n.timelineApplyFiltersAction),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text(l10n.timelineApplyFiltersAction));
      await tester.pumpAndSettle();
      expect(lastFilters.types, {MedicalEventType.symptom});
      expect(find.text(l10n.timelineEmptyTitle), findsOneWidget);
      await tester.tap(find.text(l10n.timelineClearFiltersAction));
      await tester.pumpAndSettle();
      expect(lastFilters.types, isEmpty);
      final beforeRefresh = calls;
      failRefresh = true;
      // A real pull gesture dispatches the unchanged controller refresh.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(calls, greaterThan(beforeRefresh));
      expect(find.text(l10n.timelineOfflineNotice), findsOneWidget);
      expect(
        find.text('Target note with full patient wording'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('date rails and long localized content wrap at 320px and 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _Repository();
    when(
      () => repository.refreshTimeline(
        subjectId: any(named: 'subjectId'),
        filters: any(named: 'filters'),
      ),
    ).thenAnswer(
      (_) async => const TimelinePage(
        results: [],
        nextCursor: null,
        previousCursor: null,
      ),
    );
    when(
      () => repository.watchTimeline(
        subjectId: any(named: 'subjectId'),
        filters: any(named: 'filters'),
      ),
    ).thenAnswer(
      (_) => Stream.value([
        _event(0).copyWith(
          title: 'Длинная заметка с полным текстом пациента без сокращения',
          tags: ['Длинная локализованная метка'],
        ),
      ]),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subjectControllerProvider.overrideWith(_SubjectController.new),
          timelineRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(body: TimelineScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Длинная локализованная метка'),
      140,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(
      find.text('Длинная заметка с полным текстом пациента без сокращения'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
