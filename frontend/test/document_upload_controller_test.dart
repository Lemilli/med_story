import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/error/app_failure.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/documents/presentation/controllers/document_controllers.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

void main() {
  late _MockDocumentRepository repository;

  setUpAll(() {
    registerFallbackValue(_draft());
  });

  setUp(() {
    repository = _MockDocumentRepository();
  });

  test(
    'upload controller reaches processed state after polling succeeds',
    () async {
      final container = ProviderContainer(
        overrides: [documentRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      when(() => repository.createAndUpload(any())).thenAnswer(
        (_) async => DocumentIngestionResult(
          documentId: 'document-1',
          status: DocumentStatus.processing,
          localFile: const StoredDocumentFile(
            path: '/local/lab.pdf',
            fileName: 'lab.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 1024,
            localUriHint: 'app://documents/lab.pdf',
          ),
        ),
      );
      when(
        () => repository.pollDocumentUntilTerminal(id: 'document-1'),
      ).thenAnswer((_) async => _document(status: DocumentStatus.processed));

      final notifier = container.read(
        documentUploadControllerProvider.notifier,
      );
      final document = await notifier.upload(_draft());
      final state = container
          .read(documentUploadControllerProvider)
          .requireValue;

      expect(document.id, 'document-1');
      expect(state.stage, DocumentUploadStage.processed);
      expect(state.document?.status, DocumentStatus.processed);
    },
  );

  test('upload controller exposes errors when processing fails', () async {
    final container = ProviderContainer(
      overrides: [documentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    when(() => repository.createAndUpload(any())).thenAnswer(
      (_) async => DocumentIngestionResult(
        documentId: 'document-1',
        status: DocumentStatus.processing,
        localFile: const StoredDocumentFile(
          path: '/local/lab.pdf',
          fileName: 'lab.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 1024,
          localUriHint: 'app://documents/lab.pdf',
        ),
      ),
    );
    when(
      () => repository.pollDocumentUntilTerminal(id: 'document-1'),
    ).thenThrow(const AppFailure('document_processing_failed'));

    final notifier = container.read(documentUploadControllerProvider.notifier);

    await expectLater(notifier.upload(_draft()), throwsA(isA<AppFailure>()));
    expect(container.read(documentUploadControllerProvider).hasError, isTrue);
    verifyNever(() => repository.deleteDocument('document-1'));
  });
}

DocumentUploadDraft _draft() {
  return const DocumentUploadDraft(
    title: 'Lab results',
    docType: DocumentType.labResult,
    source: DocumentSourceFile(
      path: '/source/lab.pdf',
      fileName: 'lab.pdf',
      mimeType: 'application/pdf',
    ),
  );
}

MedicalDocument _document({required DocumentStatus status}) {
  return MedicalDocument(
    id: 'document-1',
    title: 'Lab results',
    docType: DocumentType.labResult,
    mimeType: 'application/pdf',
    sizeBytes: 1024,
    status: status,
    subjectId: 'subject-1',
    extractedTextAvailable: status == DocumentStatus.processed,
    eventCount: status == DocumentStatus.processed ? 1 : 0,
    createdAt: DateTime.utc(2026, 6),
    updatedAt: DateTime.utc(2026, 6, 1, 0, 1),
  );
}
