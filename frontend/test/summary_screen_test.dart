import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/subjects/data/subject_repository.dart';
import 'package:med_story/features/subjects/domain/subject.dart';
import 'package:med_story/features/summary/data/summary_repository.dart';
import 'package:med_story/features/summary/domain/medical_summary.dart';
import 'package:med_story/features/summary/presentation/screens/summary_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockSubjectRepository extends Mock implements SubjectRepository {}

class _MockSummaryRepository extends Mock implements SummaryRepository {}

void main() {
  late _MockSubjectRepository subjectRepository;
  late _MockSummaryRepository summaryRepository;

  setUp(() {
    subjectRepository = _MockSubjectRepository();
    summaryRepository = _MockSummaryRepository();

    when(
      () => subjectRepository.listSubjects(),
    ).thenAnswer((_) async => [_subject()]);
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
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SummaryScreen)),
    )!;

    expect(find.text('Patient has recurring pain flares.'), findsOneWidget);
    expect(find.text(l10n.summarySectionKeySymptoms), findsOneWidget);
    expect(find.text('Pain flare'), findsOneWidget);
    expect(find.text(l10n.summaryBoundaryNote), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  SubjectRepository subjectRepository,
  SummaryRepository summaryRepository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        subjectRepositoryProvider.overrideWithValue(subjectRepository),
        summaryRepositoryProvider.overrideWithValue(summaryRepository),
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
