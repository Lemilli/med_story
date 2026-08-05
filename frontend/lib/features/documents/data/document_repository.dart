import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/error/app_failure.dart';
import '../../../core/storage/local_database.dart' as db;
import '../../../core/storage/temporary_file_cleanup.dart';
import '../domain/medical_document.dart';
import 'document_api.dart';

final documentLocalFileStoreProvider = Provider<DocumentLocalFileStore>((ref) {
  return const AppSandboxDocumentFileStore();
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final repository = DocumentRepository(
    api: ref.watch(documentApiProvider),
    localFileStore: ref.watch(documentLocalFileStoreProvider),
    database: ref.watch(db.localDatabaseProvider),
  );
  unawaited(repository.cleanupTemporaryOriginals());
  return repository;
});

class DocumentRepository {
  const DocumentRepository({
    required this.api,
    required this.localFileStore,
    this.database,
  });

  final DocumentApi api;
  final DocumentLocalFileStore localFileStore;
  final db.LocalDatabase? database;

  Future<DocumentIngestionResult> createAndUpload(
    DocumentUploadDraft draft,
  ) async {
    final localFiles = await localFileStore.saveAll(draft.sources);
    return createAndUploadStored(draft, localFiles);
  }

  Future<DocumentIngestionResult> createAndUploadStored(
    DocumentUploadDraft draft,
    List<StoredDocumentFile> localFiles, {
    void Function(int sent, int total)? onUploadProgress,
    bool Function()? shouldContinue,
  }) async {
    _ensureUploadContinues(shouldContinue);
    if (draft.docType == DocumentType.audio) {
      final localFile = localFiles.single;
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
        localFiles: localFiles,
        status: uploaded.status,
      );
    }

    final created = await api.createDocument(
      DocumentCreateRequest(
        title: draft.title,
        docType: draft.docType,
        mimeType: localFiles.first.mimeType,
        sizeBytes: localFiles.fold(0, (total, file) => total + file.sizeBytes),
        subjectId: draft.subjectId,
        documentDate: draft.documentDate,
        localUriHint: localFiles.first.localUriHint,
        language: draft.language,
      ),
    );
    _ensureUploadContinues(shouldContinue);
    final ingest = await api.ingestDocument(
      documentId: created.id,
      files: [
        for (final file in localFiles)
          (path: file.path, fileName: file.fileName, mimeType: file.mimeType),
      ],
      onSendProgress: onUploadProgress,
    );
    return DocumentIngestionResult(
      documentId: created.id,
      localFiles: localFiles,
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

  Future<DocumentStatusUpdate> retryProcessing(String id) {
    return api.retryProcessing(id);
  }

  Future<Uint8List> loadAssetBytes({
    required String documentId,
    required String assetId,
    bool attachment = false,
  }) {
    return api.getAssetContent(
      documentId: documentId,
      assetId: assetId,
      attachment: attachment,
    );
  }

  Future<String> downloadAssetToTemporaryFile({
    required String documentId,
    required DocumentAssetMetadata asset,
  }) async {
    final bytes = await loadAssetBytes(
      documentId: documentId,
      assetId: asset.id,
      attachment: true,
    );
    final root = await getTemporaryDirectory();
    final directory = Directory(p.join(root.path, 'medstory_originals'));
    await directory.create(recursive: true);
    final safeName = _safeFileName(asset.fileName);
    final path = p.join(
      directory.path,
      '${DateTime.now().microsecondsSinceEpoch}_${asset.id}_$safeName',
    );
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<void> cleanupTemporaryOriginals() async {
    await clearOriginalTemporaryFiles();
  }

  Future<void> deleteOwnedSources(Iterable<StoredDocumentFile> files) async {
    for (final file in files.where((item) => item.deleteAfterUpload)) {
      final source = File(file.path);
      if (await source.exists()) {
        await source.delete();
      }
    }
  }

  Future<void> deleteDocument(String id) async {
    await api.deleteDocument(id);
    await database?.removeEventsForDocument(id);
  }

  Future<MedicalDocument> pollDocumentUntilTerminal({
    required String id,
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 1),
    int maxPollAttempts = 30,
    bool Function()? shouldContinue,
  }) async {
    assert(maxPollAttempts > 0);
    final deadline = DateTime.now().add(timeout);
    for (var attempt = 0; attempt < maxPollAttempts; attempt++) {
      _ensureUploadContinues(shouldContinue);
      final document = await api.getDocument(id);
      _ensureUploadContinues(shouldContinue);
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
      if (attempt < maxPollAttempts - 1) {
        await Future<void>.delayed(interval);
        _ensureUploadContinues(shouldContinue);
      }
    }
    // A request-count cap protects the app if the device clock is adjusted
    // while polling. Further processing is always an explicit user retry.
    throw const AppFailure('document_processing_timeout');
  }
}

void _ensureUploadContinues(bool Function()? shouldContinue) {
  if (shouldContinue != null && !shouldContinue()) {
    throw const DocumentUploadCancelled();
  }
}

class DocumentUploadCancelled implements Exception {
  const DocumentUploadCancelled();
}

abstract interface class DocumentLocalFileStore {
  Future<StoredDocumentFile> save(DocumentSourceFile source);
  Future<List<StoredDocumentFile>> saveAll(List<DocumentSourceFile> sources);
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

    final safeName = _safeFileName(source.fileName);
    final sizeBytes = await sourceFile.length();

    return StoredDocumentFile(
      path: sourceFile.path,
      fileName: safeName,
      mimeType: source.mimeType,
      sizeBytes: sizeBytes,
      localUriHint: '',
      deleteAfterUpload: source.deleteAfterUpload,
    );
  }

  @override
  Future<List<StoredDocumentFile>> saveAll(
    List<DocumentSourceFile> sources,
  ) async {
    final saved = <StoredDocumentFile>[];
    for (final source in sources) {
      saved.add(await save(source));
    }
    return saved;
  }
}

String _safeFileName(String value) {
  final name = p.basename(value.trim());
  final fallback = name.isEmpty ? 'document' : name;
  return fallback.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}

class DocumentUploadDraft {
  const DocumentUploadDraft({
    required this.title,
    required this.docType,
    required this.sources,
    this.subjectId,
    this.documentDate,
    this.language,
  });

  final String title;
  final DocumentType docType;
  final List<DocumentSourceFile> sources;
  DocumentSourceFile get source => sources.first;
  final String? subjectId;
  final String? documentDate;
  final String? language;
}

class DocumentSourceFile {
  const DocumentSourceFile({
    required this.path,
    required this.fileName,
    required this.mimeType,
    this.deleteAfterUpload = false,
  });

  final String path;
  final String fileName;
  final String mimeType;
  final bool deleteAfterUpload;
}

class StoredDocumentFile {
  const StoredDocumentFile({
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.localUriHint,
    this.deleteAfterUpload = false,
  });

  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String localUriHint;
  final bool deleteAfterUpload;
}

class DocumentIngestionResult {
  const DocumentIngestionResult({
    required this.documentId,
    required this.localFiles,
    required this.status,
  });

  final String documentId;
  final List<StoredDocumentFile> localFiles;
  final DocumentStatus status;
}
