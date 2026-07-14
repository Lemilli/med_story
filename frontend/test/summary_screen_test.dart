import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/subjects/data/subject_repository.dart';
import 'package:med_story/features/subjects/domain/subject.dart';
import 'package:med_story/features/summary/data/summary_repository.dart';
import 'package:med_story/features/summary/domain/medical_summary.dart';
import 'package:med_story/features/summary/presentation/screens/summary_screen.dart';
import 'package:med_story/features/visit_preparation/data/visit_preparation_api.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubjectRepository extends Mock implements SubjectRepository {}

class _MockSummaryRepository extends Mock implements SummaryRepository {}

class _MockVisitPreparationApi extends Mock implements VisitPreparationApi {}

void main() {
  late _MockSubjectRepository subjectRepository;
  late _MockSummaryRepository summaryRepository;
  late _MockVisitPreparationApi visitPreparationApi;

  setUp(() {
    subjectRepository = _MockSubjectRepository();
    summaryRepository = _MockSummaryRepository();
    visitPreparationApi = _MockVisitPreparationApi();

    when(
      () => subjectRepository.listSubjects(),
    ).thenAnswer((_) async => [_subject()]);
    when(() => visitPreparationApi.get('subject-1')).thenAnswer(
      (_) async => const VisitPreparation(
        id: 'prep-1',
        subjectId: 'subject-1',
        reason: 'Persistent abdominal pain',
      ),
    );
    when(() => visitPreparationApi.save('subject-1', any())).thenAnswer((
      invocation,
    ) async {
      final reason = invocation.positionalArguments[1] as String;
      return VisitPreparation(
        id: 'prep-1',
        subjectId: 'subject-1',
        reason: reason,
      );
    });
    when(
      () => subjectRepository.listSubjects(refresh: any(named: 'refresh')),
    ).thenAnswer((_) async => [_subject()]);
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
      visitPreparationApi,
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SummaryScreen)),
    )!;

    expect(find.text(l10n.summaryNotReadyTitle), findsOneWidget);
    expect(find.text(l10n.summaryGenerateAction), findsOneWidget);
    expect(find.text(l10n.summaryBoundaryNote), findsOneWidget);
  });

  testWidgets('renders a ready summary with the bottom boundary note', (
    tester,
  ) async {
    when(
      () => summaryRepository.getCurrentSummary(subjectId: 'subject-1'),
    ).thenAnswer((_) async => SummaryLoadResult.ready(_summary(version: 2)));
    await _pumpScreen(
      tester,
      subjectRepository,
      summaryRepository,
      visitPreparationApi,
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SummaryScreen)),
    )!;

    expect(find.text('Patient has recurring pain flares.'), findsNothing);
    expect(find.text(l10n.summarySectionCurrentConcerns), findsOneWidget);
    expect(find.text('Pain flare'), findsOneWidget);
    expect(
      find.text(l10n.summarySectionPreviousTreatmentsAndOutcomes),
      findsOneWidget,
    );
    expect(find.text('Mesalazine — symptoms improved'), findsOneWidget);
    expect(find.text('Prepare for visit'), findsNothing);
    expect(find.text(l10n.summaryBoundaryNote), findsOneWidget);
    expect(find.text(l10n.summaryVersionLabel(2)), findsNothing);
    expect(find.text(l10n.summaryEventCountLabel(3)), findsNothing);
    expect(
      find.text(
        DateFormat.yMMMd(
          Localizations.localeOf(
            tester.element(find.byType(SummaryScreen)),
          ).toLanguageTag(),
        ).format(DateTime.utc(2026, 6, 2).toLocal()),
      ),
      findsOneWidget,
    );
    expect(find.byTooltip(l10n.summaryRegenerateAction), findsOneWidget);
    expect(find.text('Persistent abdominal pain'), findsOneWidget);
    expect(find.text(l10n.summaryAiOrganizedNote), findsOneWidget);
    expect(find.byTooltip(l10n.summarySourceAction), findsOneWidget);
  });

  testWidgets('current concerns do not offer source links', (tester) async {
    final summary = _summary(version: 2);
    when(
      () => summaryRepository.getCurrentSummary(subjectId: 'subject-1'),
    ).thenAnswer(
      (_) async => SummaryLoadResult.ready(
        summary.copyWith(
          content: {'current_concerns': summary.content['current_concerns']},
        ),
      ),
    );
    await _pumpScreen(
      tester,
      subjectRepository,
      summaryRepository,
      visitPreparationApi,
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(SummaryScreen)),
    )!;

    expect(find.byTooltip(l10n.summarySourceAction), findsNothing);
  });

  testWidgets('renders legacy cached section names and string items', (
    tester,
  ) async {
    when(
      () => summaryRepository.getCurrentSummary(subjectId: 'subject-1'),
    ).thenAnswer(
      (_) async => SummaryLoadResult.ready(_legacySummary(), fromCache: true),
    );
    await _pumpScreen(
      tester,
      subjectRepository,
      summaryRepository,
      visitPreparationApi,
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(SummaryScreen)),
    )!;

    expect(find.text(l10n.summarySectionCurrentConcerns), findsOneWidget);
    expect(find.text('Current pain'), findsOneWidget);
    expect(find.text('Legacy duplicate pain'), findsNothing);
    expect(find.text(l10n.summarySectionCurrentMedications), findsOneWidget);
    expect(find.text('Mesalazine 500 mg'), findsOneWidget);
    expect(find.byTooltip(l10n.summarySourceAction), findsNothing);
  });

  testWidgets('editing visit reason saves it immediately', (tester) async {
    when(
      () => summaryRepository.getCurrentSummary(subjectId: 'subject-1'),
    ).thenAnswer((_) async => SummaryLoadResult.ready(_summary(version: 2)));
    await _pumpScreen(
      tester,
      subjectRepository,
      summaryRepository,
      visitPreparationApi,
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(SummaryScreen)),
    )!;

    await tester.tap(find.byTooltip(l10n.summaryVisitReasonEdit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Review new test results');
    await tester.tap(find.text(l10n.visitPrepSave));
    await tester.pumpAndSettle();

    verify(
      () => visitPreparationApi.save('subject-1', 'Review new test results'),
    ).called(1);
    expect(find.text('Review new test results'), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  SubjectRepository subjectRepository,
  SummaryRepository summaryRepository,
  VisitPreparationApi visitPreparationApi,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subjectRepositoryProvider.overrideWithValue(subjectRepository),
        summaryRepositoryProvider.overrideWithValue(summaryRepository),
        visitPreparationApiProvider.overrideWithValue(visitPreparationApi),
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
      'current_concerns': [
        {
          'text': 'Pain flare',
          'detail': '',
          'sources': [
            {
              'event_id': 'event-1',
              'title': 'Pain diary',
              'event_date': '2026-05-01',
              'document_title': null,
              'source_page_positions': <int>[],
            },
            {
              'event_id': 'event-2',
              'title': 'Specialist visit',
              'event_date': '2026-05-03',
              'document_title': 'Visit letter',
              'source_page_positions': [1],
            },
          ],
        },
      ],
      'previous_treatments_and_outcomes': [
        {
          'text': 'Mesalazine — symptoms improved',
          'detail': '',
          'sources': [
            {
              'event_id': 'event-3',
              'title': 'Mesalazine course',
              'event_date': '2026-05-04',
              'document_title': null,
              'source_page_positions': <int>[],
            },
          ],
        },
      ],
    },
    narrativeText: 'Patient has recurring pain flares.',
    language: 'en',
    generatedFromEventCount: 3,
    createdAt: DateTime.utc(2026, 6, version),
  );
}

MedicalSummary _legacySummary() => MedicalSummary(
  id: 'legacy-summary',
  subjectId: 'subject-1',
  version: 1,
  isCurrent: true,
  content: const {
    'current_concerns': ['Current pain'],
    'key_symptoms': ['Legacy duplicate pain'],
    'medications': ['Mesalazine 500 mg'],
  },
  narrativeText: 'Legacy narrative',
  language: 'en',
  generatedFromEventCount: 2,
  createdAt: DateTime.utc(2025, 1, 2, 14, 30),
);
