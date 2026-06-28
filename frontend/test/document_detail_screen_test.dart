import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/documents/data/document_api.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/documents/presentation/screens/document_detail_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  late _MockDocumentRepository repository;

  setUp(() {
    repository = _MockDocumentRepository();
  });

  testWidgets('document detail shows available explanation content', (
    tester,
  ) async {
    when(
      () => repository.getDocument('document-1'),
    ).thenAnswer((_) async => _document(explanationAvailable: true));
    when(
      () => repository.getDocumentExplanation('document-1'),
    ).thenAnswer((_) async => _explanation());

    await _pumpScreen(tester, repository);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(DocumentDetailScreen)),
    )!;

    expect(find.text('Lab results May'), findsOneWidget);
    expect(find.text(l10n.documentExplanationTitle), findsOneWidget);
    expect(find.text('Most values are in the expected range.'), findsOneWidget);
    expect(find.text('CRP is mildly elevated.'), findsOneWidget);
    expect(find.text('CRP'), findsOneWidget);
    await tester.scrollUntilVisible(find.text(l10n.documentMimeTypeLabel), 160);
    expect(find.text(l10n.documentMimeTypeLabel), findsOneWidget);
  });

  testWidgets('document detail shows not-ready explanation empty state', (
    tester,
  ) async {
    when(
      () => repository.getDocument('document-1'),
    ).thenAnswer((_) async => _document());
    when(
      () => repository.getDocumentExplanation('document-1'),
    ).thenThrow(const DocumentExplanationNotReady());

    await _pumpScreen(tester, repository);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(DocumentDetailScreen)),
    )!;

    expect(find.text(l10n.documentExplanationNotReadyMessage), findsOneWidget);
    expect(find.text(l10n.documentExplanationGenerateAction), findsOneWidget);
    expect(find.text(l10n.documentMimeTypeLabel), findsOneWidget);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  DocumentRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const DocumentDetailScreen(documentId: 'document-1'),
      ),
    ),
  );
}

MedicalDocument _document({bool explanationAvailable = false}) {
  return MedicalDocument(
    id: 'document-1',
    title: 'Lab results May',
    docType: DocumentType.labResult,
    mimeType: 'application/pdf',
    sizeBytes: 1024,
    status: DocumentStatus.processed,
    subjectId: 'subject-1',
    documentDate: '2026-05-12',
    extractedTextAvailable: true,
    explanationAvailable: explanationAvailable,
    eventCount: 1,
    createdAt: DateTime.utc(2026, 6),
    updatedAt: DateTime.utc(2026, 6, 1, 0, 1),
  );
}

DocumentExplanation _explanation() {
  return DocumentExplanation(
    documentId: 'document-1',
    summaryText: 'Most values are in the expected range.',
    keyPoints: const ['CRP is mildly elevated.'],
    glossary: const {'CRP': 'A marker that can rise with inflammation.'},
    language: 'en',
    createdAt: DateTime.utc(2026, 6),
  );
}
