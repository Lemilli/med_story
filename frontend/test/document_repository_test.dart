import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/error/app_failure.dart';
import 'package:med_story/features/documents/data/document_api.dart';
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:mocktail/mocktail.dart';

class _MockDocumentApi extends Mock implements DocumentApi {}

class _FakeDocumentLocalFileStore implements DocumentLocalFileStore {
  const _FakeDocumentLocalFileStore(this.file);

  final StoredDocumentFile file;

  @override
  Future<StoredDocumentFile> save(DocumentSourceFile source) async {
    return file;
  }

  @override
  Future<List<StoredDocumentFile>> saveAll(
    List<DocumentSourceFile> sources,
  ) async => [file];
}

void main() {
  setUpAll(() {
    registerFallbackValue(_createRequest());
  });

  test(
    'audio drafts use the upload-audio endpoint with local file metadata',
    () async {
      final api = _MockDocumentApi();
      final repository = DocumentRepository(
        api: api,
        localFileStore: const _FakeDocumentLocalFileStore(
          StoredDocumentFile(
            path: '/local/voice.m4a',
            fileName: 'voice.m4a',
            mimeType: 'audio/m4a',
            sizeBytes: 2048,
            localUriHint: 'app://documents/voice.m4a',
          ),
        ),
      );

      when(
        () => api.uploadAudio(
          filePath: any(named: 'filePath'),
          fileName: any(named: 'fileName'),
          mimeType: any(named: 'mimeType'),
          title: any(named: 'title'),
          subjectId: any(named: 'subjectId'),
          language: any(named: 'language'),
          localUriHint: any(named: 'localUriHint'),
          documentDate: any(named: 'documentDate'),
        ),
      ).thenAnswer(
        (_) async => const DocumentStatusUpdate(
          id: 'audio-document-1',
          status: DocumentStatus.processing,
        ),
      );

      final result = await repository.createAndUpload(
        const DocumentUploadDraft(
          title: 'Voice note',
          docType: DocumentType.audio,
          subjectId: 'subject-1',
          language: 'en',
          sources: [
            DocumentSourceFile(
              path: '/tmp/voice.m4a',
              fileName: 'voice.m4a',
              mimeType: 'audio/m4a',
            ),
          ],
        ),
      );

      expect(result.documentId, 'audio-document-1');
      expect(result.status, DocumentStatus.processing);
      verify(
        () => api.uploadAudio(
          filePath: '/local/voice.m4a',
          fileName: 'voice.m4a',
          mimeType: 'audio/m4a',
          title: 'Voice note',
          subjectId: 'subject-1',
          language: 'en',
          localUriHint: 'app://documents/voice.m4a',
          documentDate: null,
        ),
      ).called(1);
      verifyNever(() => api.createDocument(any()));
      verifyNever(
        () => api.ingestDocument(
          documentId: any(named: 'documentId'),
          files: any(named: 'files'),
        ),
      );
    },
  );

  test(
    'document drafts retain the saved local URI hint when created',
    () async {
      final api = _MockDocumentApi();
      final repository = DocumentRepository(
        api: api,
        localFileStore: const _FakeDocumentLocalFileStore(
          StoredDocumentFile(
            path: '/local/report.jpg',
            fileName: 'report.jpg',
            mimeType: 'image/jpeg',
            sizeBytes: 1024,
            localUriHint: 'app://documents/report.jpg',
          ),
        ),
      );

      when(() => api.createDocument(any())).thenAnswer(
        (_) async => const DocumentStatusUpdate(
          id: 'document-1',
          status: DocumentStatus.pendingIngest,
        ),
      );
      when(
        () => api.ingestDocument(
          documentId: any(named: 'documentId'),
          files: any(named: 'files'),
        ),
      ).thenAnswer(
        (_) async => const DocumentStatusUpdate(
          id: 'document-1',
          status: DocumentStatus.processing,
        ),
      );

      await repository.createAndUpload(
        const DocumentUploadDraft(
          title: 'Medical photo',
          docType: DocumentType.medicalRecord,
          sources: [
            DocumentSourceFile(
              path: '/tmp/report.jpg',
              fileName: 'report.jpg',
              mimeType: 'image/jpeg',
            ),
          ],
        ),
      );

      final request =
          verify(() => api.createDocument(captureAny())).captured.single
              as DocumentCreateRequest;
      expect(request.localUriHint, 'app://documents/report.jpg');
    },
  );

  test('processing polling stops after its configured request limit', () async {
    final api = _MockDocumentApi();
    final repository = DocumentRepository(
      api: api,
      localFileStore: const _FakeDocumentLocalFileStore(
        StoredDocumentFile(
          path: '/local/report.jpg',
          fileName: 'report.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1024,
          localUriHint: 'app://documents/report.jpg',
        ),
      ),
    );
    when(
      () => api.getDocument('document-1'),
    ).thenAnswer((_) async => _processingDocument());

    await expectLater(
      repository.pollDocumentUntilTerminal(
        id: 'document-1',
        interval: Duration.zero,
        maxPollAttempts: 3,
      ),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.message,
          'message',
          'document_processing_timeout',
        ),
      ),
    );
    verify(() => api.getDocument('document-1')).called(3);
  });

  test(
    'session cancellation stops ingestion after document creation',
    () async {
      final api = _MockDocumentApi();
      final storedFile = const StoredDocumentFile(
        path: '/local/report.jpg',
        fileName: 'report.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1024,
        localUriHint: '',
      );
      final repository = DocumentRepository(
        api: api,
        localFileStore: _FakeDocumentLocalFileStore(storedFile),
      );
      var isActive = true;
      when(() => api.createDocument(any())).thenAnswer((_) async {
        isActive = false;
        return const DocumentStatusUpdate(
          id: 'document-1',
          status: DocumentStatus.pendingIngest,
        );
      });

      await expectLater(
        repository.createAndUploadStored(
          const DocumentUploadDraft(
            title: 'Medical photo',
            docType: DocumentType.medicalRecord,
            sources: [
              DocumentSourceFile(
                path: '/local/report.jpg',
                fileName: 'report.jpg',
                mimeType: 'image/jpeg',
              ),
            ],
          ),
          [storedFile],
          shouldContinue: () => isActive,
        ),
        throwsA(isA<DocumentUploadCancelled>()),
      );
      verifyNever(
        () => api.ingestDocument(
          documentId: any(named: 'documentId'),
          files: any(named: 'files'),
        ),
      );
    },
  );

  test('session cancellation stops processing polls immediately', () async {
    final api = _MockDocumentApi();
    final repository = DocumentRepository(
      api: api,
      localFileStore: const _FakeDocumentLocalFileStore(
        StoredDocumentFile(
          path: '/local/report.jpg',
          fileName: 'report.jpg',
          mimeType: 'image/jpeg',
          sizeBytes: 1024,
          localUriHint: '',
        ),
      ),
    );
    var isActive = true;
    when(() => api.getDocument('document-1')).thenAnswer((_) async {
      isActive = false;
      return _processingDocument();
    });

    await expectLater(
      repository.pollDocumentUntilTerminal(
        id: 'document-1',
        interval: Duration.zero,
        shouldContinue: () => isActive,
      ),
      throwsA(isA<DocumentUploadCancelled>()),
    );
    verify(() => api.getDocument('document-1')).called(1);
  });
}

DocumentCreateRequest _createRequest() {
  return const DocumentCreateRequest(
    title: 'Document',
    docType: DocumentType.medicalRecord,
    mimeType: 'application/pdf',
    sizeBytes: 1024,
  );
}

MedicalDocument _processingDocument() => MedicalDocument(
  id: 'document-1',
  title: 'Document',
  docType: DocumentType.medicalRecord,
  mimeType: 'image/jpeg',
  sizeBytes: 1024,
  status: DocumentStatus.processing,
  subjectId: 'subject-1',
  extractedTextAvailable: false,
  eventCount: 0,
  createdAt: DateTime.utc(2026, 7, 14),
  updatedAt: DateTime.utc(2026, 7, 14),
);
