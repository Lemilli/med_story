import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/events/data/event_repository.dart';
import 'package:med_story/features/events/data/original_asset_file_opener.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:med_story/features/events/presentation/screens/event_detail_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_app_file/open_app_file.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

class _MockEventRepository extends Mock implements EventRepository {}

class _FakeOriginalAssetFileOpener implements OriginalAssetFileOpener {
  _FakeOriginalAssetFileOpener(this.result);

  final OpenResult result;
  String? openedPath;
  String? openedMimeType;

  @override
  Future<OpenResult> open(String path, {String? mimeType}) async {
    openedPath = path;
    openedMimeType = mimeType;
    return result;
  }
}

void main() {
  testWidgets(
    'closing original source cleans up without reading disposed ref',
    (tester) async {
      final documentRepository = _MockDocumentRepository();
      final eventRepository = _MockEventRepository();
      when(
        () => eventRepository.getEvent('event-1'),
      ).thenAnswer((_) async => _event());
      when(
        () => documentRepository.getDocument('document-1'),
      ).thenAnswer((_) async => _document());
      when(
        documentRepository.cleanupTemporaryOriginals,
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentRepositoryProvider.overrideWithValue(documentRepository),
            eventRepositoryProvider.overrideWithValue(eventRepository),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const EventDetailScreen(eventId: 'event-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(EventDetailScreen)),
      )!;
      await tester.tap(find.text(l10n.eventViewOriginalAction));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      verify(documentRepository.cleanupTemporaryOriginals).called(1);
      expect(tester.takeException(), isNull);
    },
  );

  for (final resultType in ResultType.values.where(
    (type) => type != ResultType.done,
  )) {
    testWidgets(
      'shows unavailable feedback when file open returns $resultType',
      (tester) async {
        final documentRepository = _MockDocumentRepository();
        final eventRepository = _MockEventRepository();
        final opener = _FakeOriginalAssetFileOpener(OpenResult(resultType));
        const asset = DocumentAssetMetadata(
          id: 'asset-1',
          position: 0,
          fileName: 'synthetic-result.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 1024,
        );
        when(
          () => eventRepository.getEvent('event-1'),
        ).thenAnswer((_) async => _event());
        when(
          () => documentRepository.getDocument('document-1'),
        ).thenAnswer((_) async => _document(assets: [asset]));
        when(
          () => documentRepository.downloadAssetToTemporaryFile(
            documentId: 'document-1',
            asset: asset,
          ),
        ).thenAnswer((_) async => '/tmp/synthetic-result.pdf');
        when(
          documentRepository.cleanupTemporaryOriginals,
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              documentRepositoryProvider.overrideWithValue(documentRepository),
              eventRepositoryProvider.overrideWithValue(eventRepository),
              originalAssetFileOpenerProvider.overrideWithValue(opener),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: const EventDetailScreen(eventId: 'event-1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(EventDetailScreen)),
        )!;
        await tester.tap(find.text(l10n.eventViewOriginalAction));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, l10n.eventViewOriginalAction),
        );
        await tester.pumpAndSettle();

        expect(find.text(l10n.eventOriginalUnavailable), findsOneWidget);
        expect(opener.openedPath, '/tmp/synthetic-result.pdf');
        expect(opener.openedMimeType, 'application/pdf');
        expect(tester.takeException(), isNull);
      },
    );
  }
}

MedicalEvent _event() {
  return MedicalEvent(
    id: 'event-1',
    eventType: MedicalEventType.medicalRecord,
    title: 'Synthetic lab result',
    description: 'AI-organized result.',
    eventDate: '2026-05-12',
    source: EventSource.aiDocument,
    sourceDocumentId: 'document-1',
    sourceAssetCount: 1,
    subjectId: 'subject-1',
    createdAt: DateTime.utc(2026, 5, 12),
    updatedAt: DateTime.utc(2026, 5, 12),
  );
}

MedicalDocument _document({
  List<DocumentAssetMetadata> assets = const <DocumentAssetMetadata>[],
}) {
  return MedicalDocument(
    id: 'document-1',
    title: 'Synthetic lab result',
    docType: DocumentType.labResult,
    mimeType: 'image/png',
    sizeBytes: 1024,
    status: DocumentStatus.processed,
    subjectId: 'subject-1',
    assets: assets,
  );
}
