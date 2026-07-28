import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/error/app_failure.dart';
import 'package:med_story/core/storage/local_database.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/documents/presentation/controllers/document_controllers.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentRepository extends Mock implements DocumentRepository {}

class _MockDocumentFileStore extends Mock implements DocumentLocalFileStore {}

void main() {
  late _MockDocumentRepository repository;
  late _MockDocumentFileStore fileStore;
  late LocalDatabase database;
  late Directory tempDirectory;

  setUpAll(() {
    registerFallbackValue(_draft());
    registerFallbackValue(_storedFile());
    registerFallbackValue(_draft().source);
  });

  setUp(() async {
    repository = _MockDocumentRepository();
    fileStore = _MockDocumentFileStore();
    database = LocalDatabase.forTesting(NativeDatabase.memory());
    tempDirectory = await Directory.systemTemp.createTemp(
      'med_story_upload_test',
    );
    when(() => repository.localFileStore).thenReturn(fileStore);
    when(
      () => fileStore.saveAll(any()),
    ).thenAnswer((_) async => [_storedFile()]);
    when(() => repository.deleteOwnedSources(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await database.close();
    await tempDirectory.delete(recursive: true);
  });

  test(
    'completed uploads remain visible until dismissed and stay recorded',
    () async {
      final container = _container(repository, database);
      addTearDown(container.dispose);
      final source = await _sourceFile(tempDirectory);

      when(
        () => repository.createAndUploadStored(
          any(),
          any(),
          onUploadProgress: any(named: 'onUploadProgress'),
        ),
      ).thenAnswer(
        (_) async => DocumentIngestionResult(
          documentId: 'document-1',
          status: DocumentStatus.processing,
          localFiles: [_storedFile()],
        ),
      );
      when(
        () => repository.pollDocumentUntilTerminal(id: 'document-1'),
      ).thenAnswer((_) async => _document(status: DocumentStatus.processed));

      await container.read(documentUploadControllerProvider.future);
      final result = await container
          .read(documentUploadControllerProvider.notifier)
          .enqueue(_draft(source.path));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(result, UploadEnqueueResult.enqueued);
      final item = container
          .read(documentUploadControllerProvider)
          .requireValue
          .single;
      expect(item.stage, UploadQueueStage.completed);
      await container
          .read(documentUploadControllerProvider.notifier)
          .dismiss(item.id);
      expect(
        container.read(documentUploadControllerProvider).requireValue,
        isEmpty,
      );
      expect(
        (await database.select(database.uploadQueueItems).getSingle()).status,
        UploadQueueStage.completed.name,
      );
    },
  );

  test('failed uploads can be dismissed with their remote document', () async {
    final container = _container(repository, database);
    addTearDown(container.dispose);
    final source = await _sourceFile(tempDirectory);

    when(
      () => repository.createAndUploadStored(
        any(),
        any(),
        onUploadProgress: any(named: 'onUploadProgress'),
      ),
    ).thenAnswer(
      (_) async => DocumentIngestionResult(
        documentId: 'document-1',
        status: DocumentStatus.processing,
        localFiles: [_storedFile()],
      ),
    );
    when(
      () => repository.pollDocumentUntilTerminal(id: 'document-1'),
    ).thenThrow(const AppFailure('document_processing_failed'));

    await container.read(documentUploadControllerProvider.future);
    await container
        .read(documentUploadControllerProvider.notifier)
        .enqueue(_draft(source.path));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final item = container
        .read(documentUploadControllerProvider)
        .requireValue
        .single;
    expect(item.stage, UploadQueueStage.failed);
    expect(item.documentId, 'document-1');

    when(
      () => repository.deleteDocument('document-1'),
    ).thenAnswer((_) async {});
    await container
        .read(documentUploadControllerProvider.notifier)
        .dismiss(item.id);

    verify(() => repository.deleteDocument('document-1')).called(1);
    expect(
      container.read(documentUploadControllerProvider).requireValue,
      isEmpty,
    );
    expect(await database.select(database.uploadQueueItems).get(), isEmpty);
  });

  test(
    'a processed upload without extracted text or events remains failed',
    () async {
      final container = _container(repository, database);
      addTearDown(container.dispose);
      final source = await _sourceFile(tempDirectory);

      when(
        () => repository.createAndUploadStored(
          any(),
          any(),
          onUploadProgress: any(named: 'onUploadProgress'),
        ),
      ).thenAnswer(
        (_) async => DocumentIngestionResult(
          documentId: 'document-1',
          status: DocumentStatus.processing,
          localFiles: [_storedFile()],
        ),
      );
      when(
        () => repository.pollDocumentUntilTerminal(id: 'document-1'),
      ).thenThrow(const AppFailure('medical_events_not_found'));

      await container.read(documentUploadControllerProvider.future);
      await container
          .read(documentUploadControllerProvider.notifier)
          .enqueue(_draft(source.path));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final item = container
          .read(documentUploadControllerProvider)
          .requireValue
          .single;
      expect(item.stage, UploadQueueStage.failed);
      expect(item.errorMessage, 'medical_events_not_found');
    },
  );

  test(
    'links to the existing document when the backend rejects a duplicate',
    () async {
      final container = _container(repository, database);
      addTearDown(container.dispose);
      final source = await _sourceFile(tempDirectory);

      when(
        () => repository.createAndUploadStored(
          any(),
          any(),
          onUploadProgress: any(named: 'onUploadProgress'),
        ),
      ).thenThrow(
        const AppFailure(
          'document_already_processed',
          documentId: 'existing-document',
        ),
      );

      await container.read(documentUploadControllerProvider.future);
      await container
          .read(documentUploadControllerProvider.notifier)
          .enqueue(_draft(source.path));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final item = container
          .read(documentUploadControllerProvider)
          .requireValue
          .single;
      expect(item.stage, UploadQueueStage.failed);
      expect(item.errorMessage, 'document_already_processed');
      expect(item.documentId, 'existing-document');
    },
  );

  test('retries processing from the retained server original', () async {
    final container = _container(repository, database);
    addTearDown(container.dispose);
    final now = DateTime.now();
    await database
        .into(database.uploadQueueItems)
        .insert(
          UploadQueueItemsCompanion.insert(
            id: 'failed-item',
            displayName: 'lab.pdf',
            fingerprint: 'lab.pdf::3',
            localPath: '/missing/lab.pdf',
            storedFileName: 'lab.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 3,
            docType: DocumentType.labResult.name,
            title: 'Lab results',
            status: UploadQueueStage.failed.name,
            documentId: const Value('document-1'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    when(() => repository.retryProcessing('document-1')).thenAnswer(
      (_) async => const DocumentStatusUpdate(
        id: 'document-1',
        status: DocumentStatus.processing,
      ),
    );
    when(
      () => repository.pollDocumentUntilTerminal(id: 'document-1'),
    ).thenAnswer((_) async => _document(status: DocumentStatus.processed));

    await container.read(documentUploadControllerProvider.future);
    await container
        .read(documentUploadControllerProvider.notifier)
        .retry('failed-item');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(
      container
          .read(documentUploadControllerProvider)
          .requireValue
          .single
          .stage,
      UploadQueueStage.completed,
    );
    verify(() => repository.retryProcessing('document-1')).called(1);
    verifyNever(
      () => repository.createAndUploadStored(
        any(),
        any(),
        onUploadProgress: any(named: 'onUploadProgress'),
      ),
    );
  });

  test('blocks a matching file already being uploaded', () async {
    final container = _container(repository, database);
    addTearDown(container.dispose);
    final source = await _sourceFile(tempDirectory);
    final now = DateTime.now();
    await container.read(documentUploadControllerProvider.future);
    await database
        .into(database.uploadQueueItems)
        .insert(
          UploadQueueItemsCompanion.insert(
            id: 'existing',
            displayName: 'lab.pdf',
            fingerprint: 'lab.pdf::3',
            localPath: '/local/lab.pdf',
            storedFileName: 'lab.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 3,
            docType: DocumentType.labResult.name,
            title: 'Lab results',
            subjectId: const Value.absent(),
            language: const Value.absent(),
            status: UploadQueueStage.uploading.name,
            documentId: const Value.absent(),
            errorMessage: const Value.absent(),
            createdAt: now,
            updatedAt: now,
          ),
        );

    expect(
      await container
          .read(documentUploadControllerProvider.notifier)
          .enqueue(_draft(source.path)),
      UploadEnqueueResult.duplicate,
    );
  });
}

ProviderContainer _container(
  DocumentRepository repository,
  LocalDatabase database,
) => ProviderContainer(
  overrides: [
    documentRepositoryProvider.overrideWithValue(repository),
    localDatabaseProvider.overrideWithValue(database),
  ],
);

Future<File> _sourceFile(Directory directory) async {
  final file = File('${directory.path}/lab.pdf');
  await file.writeAsBytes([1, 2, 3]);
  return file;
}

DocumentUploadDraft _draft([String path = '/source/lab.pdf']) =>
    DocumentUploadDraft(
      title: 'Lab results',
      docType: DocumentType.labResult,
      sources: [
        DocumentSourceFile(
          path: path,
          fileName: 'lab.pdf',
          mimeType: 'application/pdf',
        ),
      ],
    );

StoredDocumentFile _storedFile() => const StoredDocumentFile(
  path: '/local/lab.pdf',
  fileName: 'lab.pdf',
  mimeType: 'application/pdf',
  sizeBytes: 1024,
  localUriHint: 'app://documents/lab.pdf',
);

MedicalDocument _document({required DocumentStatus status}) => MedicalDocument(
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
