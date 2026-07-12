import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// A durable, app-wide queue. Finished items stay in the local database so the
/// same file is not accidentally submitted again, while the Add tab only shows
/// items which still need the user's attention.
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
    final sourceSize = await _sourceSize(draft.source.path);
    final fingerprint = _fingerprint(draft.source.fileName, sourceSize);
    final duplicate =
        await (database.select(database.uploadQueueItems)
              ..where((item) => item.fingerprint.equals(fingerprint))
              ..limit(1))
            .getSingleOrNull();
    if (duplicate != null) {
      return UploadEnqueueResult.duplicate;
    }

    final localFile = await ref
        .read(documentRepositoryProvider)
        .localFileStore
        .save(draft.source);
    final now = DateTime.now();
    final item = QueuedUpload(
      id: now.microsecondsSinceEpoch.toString(),
      displayName: draft.source.fileName,
      fingerprint: fingerprint,
      localFile: localFile,
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
    await (database.update(
      database.uploadQueueItems,
    )..where((item) => item.id.equals(id))).write(
      db.UploadQueueItemsCompanion(
        isDismissed: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    state = AsyncValue.data(await _loadVisibleItems());
  }

  Future<void> _run(QueuedUpload item) async {
    try {
      final repository = ref.read(documentRepositoryProvider);
      final result = await repository.createAndUploadStored(
        item.draft,
        item.localFile,
        onUploadProgress: (sent, total) {
          if (total > 0) {
            _setUploadProgress(item.id, sent / total);
          }
        },
      );
      await _save(
        item.copyWith(
          stage: UploadQueueStage.processing,
          documentId: result.documentId,
          updatedAt: DateTime.now(),
        ),
      );
      final document = await repository.pollDocumentUntilTerminal(
        id: result.documentId,
      );
      await _save(
        item.copyWith(
          stage: UploadQueueStage.completed,
          documentId: document.id,
          updatedAt: DateTime.now(),
        ),
      );
      ref.invalidate(timelineControllerProvider);
    } on Object catch (error) {
      await _save(
        item.copyWith(
          stage: UploadQueueStage.failed,
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
      localPath: item.localFile.path,
      storedFileName: item.localFile.fileName,
      mimeType: item.localFile.mimeType,
      sizeBytes: item.localFile.sizeBytes,
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
    );
  }

  QueuedUpload _fromRow(db.UploadQueueItem row) {
    return QueuedUpload(
      id: row.id,
      displayName: row.displayName,
      fingerprint: row.fingerprint,
      localFile: StoredDocumentFile(
        path: row.localPath,
        fileName: row.storedFileName,
        mimeType: row.mimeType,
        sizeBytes: row.sizeBytes,
        localUriHint: 'app://documents/${row.storedFileName}',
      ),
      draft: DocumentUploadDraft(
        title: row.title,
        docType: DocumentType.values.byName(row.docType),
        subjectId: row.subjectId,
        language: row.language,
        source: DocumentSourceFile(
          path: row.localPath,
          fileName: row.displayName,
          mimeType: row.mimeType,
        ),
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

  String _fingerprint(String fileName, int sizeBytes) =>
      '${fileName.trim().toLowerCase()}::$sizeBytes';
}

enum UploadEnqueueResult { enqueued, duplicate }

enum UploadQueueStage { uploading, processing, completed, failed }

class QueuedUpload {
  const QueuedUpload({
    required this.id,
    required this.displayName,
    required this.fingerprint,
    required this.localFile,
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
  final StoredDocumentFile localFile;
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
    localFile: localFile,
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
