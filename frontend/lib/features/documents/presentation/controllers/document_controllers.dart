import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/storage/local_database.dart' as db;
import '../../../timeline/presentation/controllers/timeline_controller.dart';
import '../../data/document_repository.dart';
import '../../domain/medical_document.dart';

final documentDetailProvider = FutureProvider.autoDispose
    .family<MedicalDocument, String>((ref, id) {
      return ref.watch(documentRepositoryProvider).getDocument(id);
    });

final documentUploadControllerProvider =
    AsyncNotifierProvider<DocumentUploadController, List<QueuedUpload>>(
      DocumentUploadController.new,
    );

/// A durable metadata-only queue. Source paths remain only while an upload can
/// still be retried; temporary captures are removed once the server has the
/// authoritative original.
class DocumentUploadController extends AsyncNotifier<List<QueuedUpload>> {
  @override
  Future<List<QueuedUpload>> build() async {
    final database = ref.read(db.localDatabaseProvider);
    await (database.update(database.uploadQueueItems)..where(
          (item) => item.status.isIn([
            UploadQueueStage.uploading.name,
            UploadQueueStage.processing.name,
          ]),
        ))
        .write(
          db.UploadQueueItemsCompanion(
            status: Value(UploadQueueStage.failed.name),
            errorMessage: Value('upload_interrupted'),
          ),
        );
    // This intentionally makes app termination visible as a retryable failure.
    return _loadVisibleItems();
  }

  Future<UploadEnqueueResult> enqueue(DocumentUploadDraft draft) async {
    final database = ref.read(db.localDatabaseProvider);
    final sourceSizes = await Future.wait(
      draft.sources.map((source) => _sourceSize(source.path)),
    );
    final fingerprint = _fingerprint(draft.sources, sourceSizes);
    final duplicate =
        await (database.select(database.uploadQueueItems)
              ..where((item) => item.fingerprint.equals(fingerprint))
              ..where(
                (item) => item.status.isIn([
                  UploadQueueStage.uploading.name,
                  UploadQueueStage.processing.name,
                ]),
              )
              ..limit(1))
            .getSingleOrNull();
    if (duplicate != null) {
      return UploadEnqueueResult.duplicate;
    }

    final localFiles = await ref
        .read(documentRepositoryProvider)
        .localFileStore
        .saveAll(draft.sources);
    final now = DateTime.now();
    final item = QueuedUpload(
      id: now.microsecondsSinceEpoch.toString(),
      displayName: draft.sources.length == 1
          ? draft.source.fileName
          : '${draft.sources.length} pages',
      fingerprint: fingerprint,
      localFiles: localFiles,
      draft: draft,
      stage: UploadQueueStage.uploading,
      createdAt: now,
      updatedAt: now,
    );
    await database.into(database.uploadQueueItems).insert(_companion(item));
    state = AsyncValue.data([...state.value ?? const [], item]);
    unawaited(_run(item));
    return UploadEnqueueResult.enqueued;
  }

  Future<void> retry(String id) async {
    final item = await _findItem(id);
    if (item == null) return;
    final uploading = item.copyWith(
      stage: UploadQueueStage.uploading,
      errorMessage: null,
      updatedAt: DateTime.now(),
    );
    await _save(uploading);
    unawaited(_run(uploading));
  }

  Future<void> dismiss(String id) async {
    final database = ref.read(db.localDatabaseProvider);
    final item = await _findItem(id);
    if (item == null) return;
    if (item.stage == UploadQueueStage.failed && item.documentId != null) {
      await ref
          .read(documentRepositoryProvider)
          .deleteDocument(item.documentId!);
    }
    await ref
        .read(documentRepositoryProvider)
        .deleteOwnedSources(item.localFiles);
    if (item.stage == UploadQueueStage.failed) {
      await (database.delete(
        database.uploadQueueItems,
      )..where((queueItem) => queueItem.id.equals(id))).go();
    } else {
      await (database.update(
        database.uploadQueueItems,
      )..where((queueItem) => queueItem.id.equals(id))).write(
        db.UploadQueueItemsCompanion(
          isDismissed: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
    state = AsyncValue.data(await _loadVisibleItems());
  }

  Future<void> _run(QueuedUpload item) async {
    var current = item;
    try {
      final repository = ref.read(documentRepositoryProvider);
      final existingDocumentId = item.documentId;
      late final String documentId;
      if (existingDocumentId != null &&
          item.draft.docType != DocumentType.audio) {
        final retry = await repository.retryProcessing(existingDocumentId);
        documentId = retry.id;
      } else {
        if (existingDocumentId != null) {
          await repository.deleteDocument(existingDocumentId);
        }
        final result = await repository.createAndUploadStored(
          item.draft,
          item.localFiles,
          onUploadProgress: (sent, total) {
            if (total > 0) {
              _setUploadProgress(item.id, sent / total);
            }
          },
        );
        documentId = result.documentId;
      }
      current = current.copyWith(
        stage: UploadQueueStage.processing,
        documentId: documentId,
        updatedAt: DateTime.now(),
      );
      await _save(current);
      if (item.draft.docType != DocumentType.audio) {
        await repository.deleteOwnedSources(item.localFiles);
      }
      final document = await repository.pollDocumentUntilTerminal(
        id: documentId,
      );
      if (item.draft.docType == DocumentType.audio) {
        await repository.deleteOwnedSources(item.localFiles);
      }
      await _save(
        current.copyWith(
          stage: UploadQueueStage.completed,
          documentId: document.id,
          updatedAt: DateTime.now(),
        ),
      );
      ref.invalidate(timelineControllerProvider);
    } on Object catch (error) {
      final duplicateDocumentId = error is AppFailure ? error.documentId : null;
      await _save(
        current.copyWith(
          stage: UploadQueueStage.failed,
          documentId: duplicateDocumentId ?? current.documentId,
          errorMessage: error.toString(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _save(QueuedUpload item) async {
    final database = ref.read(db.localDatabaseProvider);
    await database
        .into(database.uploadQueueItems)
        .insertOnConflictUpdate(_companion(item));
    state = AsyncValue.data(await _loadVisibleItems());
  }

  void _setUploadProgress(String id, double value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final item in current)
        item.id == id
            ? item.copyWith(uploadProgress: value.clamp(0.0, 1.0).toDouble())
            : item,
    ]);
  }

  Future<QueuedUpload?> _findItem(String id) async {
    final database = ref.read(db.localDatabaseProvider);
    final row = await (database.select(
      database.uploadQueueItems,
    )..where((item) => item.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<List<QueuedUpload>> _loadVisibleItems() async {
    final database = ref.read(db.localDatabaseProvider);
    final rows = await (database.select(
      database.uploadQueueItems,
    )..orderBy([(item) => OrderingTerm(expression: item.createdAt)])).get();
    return rows
        .where(
          (item) =>
              item.status != UploadQueueStage.completed.name ||
              !item.isDismissed,
        )
        .map(_fromRow)
        .toList();
  }

  db.UploadQueueItemsCompanion _companion(QueuedUpload item) {
    return db.UploadQueueItemsCompanion.insert(
      id: item.id,
      displayName: item.displayName,
      fingerprint: item.fingerprint,
      localPath: item.localFiles.first.path,
      storedFileName: item.localFiles.first.fileName,
      mimeType: item.localFiles.first.mimeType,
      sizeBytes: item.localFiles.fold(
        0,
        (total, file) => total + file.sizeBytes,
      ),
      docType: item.draft.docType.name,
      title: item.draft.title,
      subjectId: Value(item.draft.subjectId),
      language: Value(item.draft.language),
      status: item.stage.name,
      documentId: Value(item.documentId),
      errorMessage: Value(item.errorMessage),
      isDismissed: Value(item.isDismissed),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      assetsJson: Value(
        jsonEncode([
          for (final file in item.localFiles)
            {
              'path': file.path,
              'file_name': file.fileName,
              'mime_type': file.mimeType,
              'size_bytes': file.sizeBytes,
              'delete_after_upload': file.deleteAfterUpload,
            },
        ]),
      ),
    );
  }

  QueuedUpload _fromRow(db.UploadQueueItem row) {
    final decodedAssets = (jsonDecode(row.assetsJson) as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(
          (asset) => StoredDocumentFile(
            path: asset['path'] as String,
            fileName: asset['file_name'] as String,
            mimeType: asset['mime_type'] as String,
            sizeBytes: asset['size_bytes'] as int,
            localUriHint: '',
            deleteAfterUpload: asset['delete_after_upload'] == true,
          ),
        )
        .toList();
    final localFiles = decodedAssets.isEmpty
        ? [
            StoredDocumentFile(
              path: row.localPath,
              fileName: row.storedFileName,
              mimeType: row.mimeType,
              sizeBytes: row.sizeBytes,
              localUriHint: '',
            ),
          ]
        : decodedAssets;
    return QueuedUpload(
      id: row.id,
      displayName: row.displayName,
      fingerprint: row.fingerprint,
      localFiles: localFiles,
      draft: DocumentUploadDraft(
        title: row.title,
        docType: DocumentType.values.byName(row.docType),
        subjectId: row.subjectId,
        language: row.language,
        sources: [
          for (final file in localFiles)
            DocumentSourceFile(
              path: file.path,
              fileName: file.fileName,
              mimeType: file.mimeType,
              deleteAfterUpload: file.deleteAfterUpload,
            ),
        ],
      ),
      stage: UploadQueueStage.values.byName(row.status),
      documentId: row.documentId,
      errorMessage: row.errorMessage,
      isDismissed: row.isDismissed,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<int> _sourceSize(String path) => File(path).length();

  String _fingerprint(List<DocumentSourceFile> files, List<int> sizes) => [
    for (var index = 0; index < files.length; index++)
      '${files[index].fileName.trim().toLowerCase()}::${sizes[index]}',
  ].join('|');
}

enum UploadEnqueueResult { enqueued, duplicate }

enum UploadQueueStage { uploading, processing, completed, failed }

class QueuedUpload {
  const QueuedUpload({
    required this.id,
    required this.displayName,
    required this.fingerprint,
    required this.localFiles,
    required this.draft,
    required this.stage,
    required this.createdAt,
    required this.updatedAt,
    this.documentId,
    this.errorMessage,
    this.isDismissed = false,
    this.uploadProgress,
  });

  final String id;
  final String displayName;
  final String fingerprint;
  final List<StoredDocumentFile> localFiles;
  StoredDocumentFile get localFile => localFiles.first;
  final DocumentUploadDraft draft;
  final UploadQueueStage stage;
  final String? documentId;
  final String? errorMessage;
  final bool isDismissed;
  final double? uploadProgress;
  final DateTime createdAt;
  final DateTime updatedAt;

  QueuedUpload copyWith({
    UploadQueueStage? stage,
    String? documentId,
    Object? errorMessage = _unchanged,
    bool? isDismissed,
    double? uploadProgress,
    DateTime? updatedAt,
  }) => QueuedUpload(
    id: id,
    displayName: displayName,
    fingerprint: fingerprint,
    localFiles: localFiles,
    draft: draft,
    stage: stage ?? this.stage,
    documentId: documentId ?? this.documentId,
    errorMessage: errorMessage == _unchanged
        ? this.errorMessage
        : errorMessage as String?,
    isDismissed: isDismissed ?? this.isDismissed,
    uploadProgress: uploadProgress ?? this.uploadProgress,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

const _unchanged = Object();
