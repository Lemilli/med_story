import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/capture/presentation/screens/quick_note_screen.dart';
import 'package:med_story/features/documents/data/document_api.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/subjects/data/subject_repository.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentApi extends Mock implements DocumentApi {}

class _MockSubjectRepository extends Mock implements SubjectRepository {}

void main() {
  testWidgets('leaving during note polling does not access an unmounted ref', (
    tester,
  ) async {
    final documentApi = _MockDocumentApi();
    final subjectRepository = _MockSubjectRepository();
    when(
      () => subjectRepository.listSubjects(),
    ).thenAnswer((_) async => const []);
    when(
      () => documentApi.processNote(
        text: any(named: 'text'),
        subjectId: any(named: 'subjectId'),
        language: any(named: 'language'),
      ),
    ).thenAnswer(
      (_) async => const DocumentStatusUpdate(
        id: 'document-1',
        status: DocumentStatus.processing,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentApiProvider.overrideWithValue(documentApi),
          subjectRepositoryProvider.overrideWithValue(subjectRepository),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const _QuickNoteTestHost(),
        ),
      ),
    );
    await tester.tap(find.text('Open note'));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(QuickNoteScreen)),
    )!;
    await tester.enterText(find.byType(TextField), 'Synthetic medical note');
    await tester.tap(find.text(l10n.eventCreateAction));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Open note'), findsOneWidget);
    verifyNever(() => documentApi.getDocument(any()));
    expect(tester.takeException(), isNull);
  });
}

class _QuickNoteTestHost extends StatelessWidget {
  const _QuickNoteTestHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).push<void>(
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, _, _) => const QuickNoteScreen(),
            ),
          ),
          child: const Text('Open note'),
        ),
      ),
    );
  }
}
