import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/error/app_failure.dart';
import '../domain/medical_document.dart';
import 'document_api.dart';

final documentLocalFileStoreProvider = Provider<DocumentLocalFileStore>((ref) {
  return const AppSandboxDocumentFileStore();
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(
    api: ref.watch(documentApiProvider),
    localFileStore: ref.watch(documentLocalFileStoreProvider),
  );
});

class DocumentRepository {
  const DocumentRepository({required this.api, required this.localFileStore});

  final DocumentApi api;
  final DocumentLocalFileStore localFileStore;

  Future<DocumentIngestionResult> createAndUpload(
    DocumentUploadDraft draft,
  ) async {
    final localFile = await localFileStore.save(draft.source);
    return createAndUploadStored(draft, localFile);
  }

  Future<DocumentIngestionResult> createAndUploadStored(
    DocumentUploadDraft draft,
    StoredDocumentFile localFile, {
    void Function(int sent, int total)? onUploadProgress,
  }) async {
    if (draft.docType == DocumentType.audio) {
      final uploaded = await api.uploadAudio(
        filePath: localFile.path,
        fileName: localFile.fileName,
        mimeType: localFile.mimeType,
        title: draft.title,
        subjectId: draft.subjectId,
        language: draft.language,
        localUriHint: localFile.localUriHint,
        documentDate: draft.documentDate,
        onSendProgress: onUploadProgress,
      );
      return DocumentIngestionResult(
        documentId: uploaded.id,
        localFile: localFile,
        status: uploaded.status,
      );
    }

    final created = await api.createDocument(
      DocumentCreateRequest(
        title: draft.title,
        docType: draft.docType,
        mimeType: localFile.mimeType,
        sizeBytes: localFile.sizeBytes,
        subjectId: draft.subjectId,
        documentDate: draft.documentDate,
        localUriHint: localFile.localUriHint,
        language: draft.language,
      ),
    );
    late final DocumentStatusUpdate ingest;
    try {
      ingest = await api.ingestDocument(
        documentId: created.id,
        filePath: localFile.path,
        fileName: localFile.fileName,
        mimeType: localFile.mimeType,
        onSendProgress: onUploadProgress,
      );
    } on Object {
      await _deleteCreatedDocument(created.id);
      rethrow;
    }
    return DocumentIngestionResult(
      documentId: created.id,
      localFile: localFile,
      status: ingest.status,
    );
  }

  Future<DocumentPage> listDocuments({
    String? subjectId,
    DocumentType? docType,
    DocumentStatus? status,
    String? query,
    String? cursor,
    int limit = 20,
  }) {
    return api.listDocuments(
      subjectId: subjectId,
      docType: docType,
      status: status,
      query: query,
      cursor: cursor,
      limit: limit,
    );
  }

  Future<MedicalDocument> getDocument(String id) {
    return api.getDocument(id);
  }

  Future<void> deleteDocument(String id) {
    return api.deleteDocument(id);
  }

  Future<void> _deleteCreatedDocument(String id) async {
    try {
      await deleteDocument(id);
    } on Object {
      // Preserve the original upload/processing failure for retry messaging.
    }
  }

  Future<MedicalDocument> pollDocumentUntilTerminal({
    required String id,
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      final document = await api.getDocument(id);
      if (document.status.isTerminal) {
        if (document.status == DocumentStatus.failed) {
          throw AppFailure(
            document.errorMessage.isEmpty
                ? 'document_processing_failed'
                : document.errorMessage,
          );
        }
        if (!document.extractedTextAvailable || document.eventCount == 0) {
          throw const AppFailure('medical_events_not_found');
        }
        return document;
      }
      if (DateTime.now().isAfter(deadline)) {
        throw const AppFailure('document_processing_timeout');
      }
      await Future<void>.delayed(interval);
    }
  }
}

abstract interface class DocumentLocalFileStore {
  Future<StoredDocumentFile> save(DocumentSourceFile source);
}

class AppSandboxDocumentFileStore implements DocumentLocalFileStore {
  const AppSandboxDocumentFileStore();

  @override
  Future<StoredDocumentFile> save(DocumentSourceFile source) async {
    final sourceFile = File(source.path);
    final exists = await sourceFile.exists();
    if (!exists) {
      throw const AppFailure('document_source_file_missing');
    }

    final root = await getApplicationDocumentsDirectory();
    final documentsDirectory = Directory(p.join(root.path, 'documents'));
    await documentsDirectory.create(recursive: true);

    final safeName = _safeFileName(source.fileName);
    final storedName = '${DateTime.now().microsecondsSinceEpoch}_$safeName';
    final destinationPath = p.join(documentsDirectory.path, storedName);
    final copied = await sourceFile.copy(destinationPath);
    final sizeBytes = await copied.length();

    return StoredDocumentFile(
      path: copied.path,
      fileName: storedName,
      mimeType: source.mimeType,
      sizeBytes: sizeBytes,
      localUriHint: 'app://documents/$storedName',
    );
  }

  String _safeFileName(String value) {
    final name = p.basename(value.trim());
    final fallback = name.isEmpty ? 'document' : name;
    return fallback.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }
}

class DocumentUploadDraft {
  const DocumentUploadDraft({
    required this.title,
    required this.docType,
    required this.source,
    this.subjectId,
    this.documentDate,
    this.language,
  });

  final String title;
  final DocumentType docType;
  final DocumentSourceFile source;
  final String? subjectId;
  final String? documentDate;
  final String? language;
}

class DocumentSourceFile {
  const DocumentSourceFile({
    required this.path,
    required this.fileName,
    required this.mimeType,
  });

  final String path;
  final String fileName;
  final String mimeType;
}

class StoredDocumentFile {
  const StoredDocumentFile({
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.localUriHint,
  });

  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String localUriHint;
}

class DocumentIngestionResult {
  const DocumentIngestionResult({
    required this.documentId,
    required this.localFile,
    required this.status,
  });

  final String documentId;
  final StoredDocumentFile localFile;
  final DocumentStatus status;
}
