import 'package:flutter_test/flutter_test.dart';
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
          source: DocumentSourceFile(
            path: '/tmp/voice.m4a',
            fileName: 'voice.m4a',
            mimeType: 'audio/m4a',
          ),
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
          filePath: any(named: 'filePath'),
          fileName: any(named: 'fileName'),
          mimeType: any(named: 'mimeType'),
        ),
      );
    },
  );
}

DocumentCreateRequest _createRequest() {
  return const DocumentCreateRequest(
    title: 'Document',
    docType: DocumentType.medicalRecord,
    mimeType: 'application/pdf',
    sizeBytes: 1024,
  );
}
