import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
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

  testWidgets('document detail does not request or show an AI explanation', (
    tester,
  ) async {
    when(
      () => repository.getDocument('document-1'),
    ).thenAnswer((_) async => _document());

    await _pumpScreen(tester, repository);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(DocumentDetailScreen)),
    )!;

    expect(find.text('Lab results May'), findsOneWidget);
    await tester.scrollUntilVisible(find.text(l10n.documentMimeTypeLabel), 160);
    expect(find.text(l10n.documentMimeTypeLabel), findsOneWidget);
    expect(
      find.textContaining('explanation', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('narrow large-text metadata remains readable through scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(
      () => repository.getDocument('document-1'),
    ).thenAnswer((_) async => _document());
    await _pumpScreen(
      tester,
      repository,
      locale: const Locale('ru'),
      textScale: 2,
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(DocumentDetailScreen)),
    )!;
    await tester.scrollUntilVisible(find.text(l10n.documentMimeTypeLabel), 160);
    expect(find.text('application/pdf'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(l10n.documentUpdatedAtLabel),
      160,
    );
    expect(find.text(l10n.documentUpdatedAtLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  DocumentRepository repository, {
  Locale locale = const Locale('en'),
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const DocumentDetailScreen(documentId: 'document-1'),
      ),
    ),
  );
}

MedicalDocument _document() {
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
    eventCount: 1,
    createdAt: DateTime.utc(2026, 6),
    updatedAt: DateTime.utc(2026, 6, 1, 0, 1),
  );
}
