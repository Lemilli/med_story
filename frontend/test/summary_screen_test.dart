import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:med_story/features/subjects/data/subject_repository.dart';
import 'package:med_story/features/subjects/domain/subject.dart';
import 'package:med_story/features/summary/data/summary_repository.dart';
import 'package:med_story/features/summary/domain/medical_summary.dart';
import 'package:med_story/features/summary/presentation/screens/summary_screen.dart';
import 'package:med_story/features/timeline/data/timeline_api.dart';
import 'package:med_story/features/timeline/data/timeline_repository.dart';
import 'package:med_story/features/timeline/domain/timeline_filters.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubjectRepository extends Mock implements SubjectRepository {}

class _MockSummaryRepository extends Mock implements SummaryRepository {}

class _MockTimelineRepository extends Mock implements TimelineRepository {}

void main() {
  late _MockSubjectRepository subjectRepository;
  late _MockSummaryRepository summaryRepository;
  late _MockTimelineRepository timelineRepository;

  setUpAll(() {
    registerFallbackValue(const TimelineFilters());
  });

  setUp(() {
    subjectRepository = _MockSubjectRepository();
    summaryRepository = _MockSummaryRepository();
    timelineRepository = _MockTimelineRepository();

    when(
      () => subjectRepository.listSubjects(),
    ).thenAnswer((_) async => [_subject()]);
    when(
      () => subjectRepository.listSubjects(refresh: any(named: 'refresh')),
    ).thenAnswer((_) async => [_subject()]);
    when(
      () => timelineRepository.watchTimeline(
        subjectId: any(named: 'subjectId'),
        filters: any(named: 'filters'),
      ),
    ).thenAnswer((_) => Stream.value([_event()]));
    when(
      () => timelineRepository.refreshTimeline(
        subjectId: any(named: 'subjectId'),
        filters: any(named: 'filters'),
        cursor: any(named: 'cursor'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const TimelinePage(
        results: <MedicalEvent>[],
        nextCursor: null,
        previousCursor: null,
      ),
    );
  });

  testWidgets('shows not-ready summary state with generate action', (
    tester,
  ) async {
    when(
      () => summaryRepository.getCurrentSummary(subjectId: 'subject-1'),
    ).thenAnswer((_) async => const SummaryLoadResult.notReady());

    await _pumpScreen(
      tester,
      subjectRepository,
      summaryRepository,
      timelineRepository,
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SummaryScreen)),
    )!;

    expect(find.text(l10n.summaryNotReadyTitle), findsOneWidget);
    expect(find.text(l10n.summaryGenerateAction), findsOneWidget);
    expect(find.text(l10n.summaryBoundaryNote), findsOneWidget);
  });

  testWidgets('renders ready summary, versions, and history search results', (
    tester,
  ) async {
    when(
      () => summaryRepository.getCurrentSummary(subjectId: 'subject-1'),
    ).thenAnswer((_) async => SummaryLoadResult.ready(_summary(version: 2)));
    when(
      () => summaryRepository.listVersions(subjectId: 'subject-1'),
    ).thenAnswer((_) async => [_summary(version: 2), _summary(version: 1)]);

    await _pumpScreen(
      tester,
      subjectRepository,
      summaryRepository,
      timelineRepository,
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SummaryScreen)),
    )!;

    expect(find.text('Patient has recurring pain flares.'), findsOneWidget);
    expect(find.text(l10n.summarySectionKeySymptoms), findsOneWidget);
    expect(find.text('Pain flare'), findsOneWidget);
    expect(find.text(l10n.summaryVersionHistoryAction), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'pain');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Pain flare in June'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  SubjectRepository subjectRepository,
  SummaryRepository summaryRepository,
  TimelineRepository timelineRepository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subjectRepositoryProvider.overrideWithValue(subjectRepository),
        summaryRepositoryProvider.overrideWithValue(summaryRepository),
        timelineRepositoryProvider.overrideWithValue(timelineRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(body: SummaryScreen()),
      ),
    ),
  );
}

Subject _subject() {
  return Subject(
    id: 'subject-1',
    displayName: 'Alex',
    relationship: SubjectRelationship.self,
    isDefault: true,
    createdAt: DateTime.utc(2026, 6),
    updatedAt: DateTime.utc(2026, 6),
  );
}

MedicalSummary _summary({required int version}) {
  return MedicalSummary(
    id: 'summary-$version',
    subjectId: 'subject-1',
    version: version,
    isCurrent: version == 2,
    content: const {
      'key_symptoms': ['Pain flare'],
    },
    narrativeText: 'Patient has recurring pain flares.',
    language: 'en',
    generatedFromEventCount: 3,
    createdAt: DateTime.utc(2026, 6, version),
  );
}

MedicalEvent _event() {
  return MedicalEvent(
    id: 'event-1',
    subjectId: 'subject-1',
    eventType: MedicalEventType.symptom,
    title: 'Pain flare in June',
    eventDate: '2026-06-01',
    createdAt: DateTime.utc(2026, 6),
    updatedAt: DateTime.utc(2026, 6),
  );
}
