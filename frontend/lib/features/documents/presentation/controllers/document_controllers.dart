import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/storage/local_database.dart' as db;
import '../../../auth/presentation/controllers/auth_controller.dart';
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
  String? _ownerUserId;
  int _sessionGeneration = 0;
  bool _isDisposed = false;

  @override
  Future<List<QueuedUpload>> build() async {
    final ownerUserId = ref.watch(activeUserIdProvider);
    final generation = ++_sessionGeneration;
    _ownerUserId = ownerUserId;
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _ownerUserId = null;
      _sessionGeneration++;
    });
    if (ownerUserId == null || ownerUserId.isEmpty) {
      return const [];
    }

    final database = ref.read(db.localDatabaseProvider);
    await (database.update(database.uploadQueueItems)..where(
          (item) =>
              item.ownerUserId.equals(ownerUserId) &
              item.status.isIn([
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
    if (!_isCurrentSession(ownerUserId, generation)) {
      return const [];
    }
    // This intentionally makes app termination visible as a retryable failure.
    return _loadVisibleItems(ownerUserId);
  }

  Future<UploadEnqueueResult> enqueue(DocumentUploadDraft draft) async {
    final session = _requireSession();
    final database = ref.read(db.localDatabaseProvider);
    final sourceSizes = await Future.wait(
      draft.sources.map((source) => _sourceSize(source.path)),
    );
    final fingerprint = _fingerprint(draft.sources, sourceSizes);
    final duplicate =
        await (database.select(database.uploadQueueItems)
              ..where((item) => item.ownerUserId.equals(session.ownerUserId))
              ..where((item) => item.fingerprint.equals(fingerprint))
              ..where(
                (item) => item.status.isIn([
                  UploadQueueStage.uploading.name,
                  UploadQueueStage.processing.name,
                ]),
              )
              ..limit(1))
            .getSingleOrNull();
    _ensureCurrentSession(session);
    if (duplicate != null) {
      return UploadEnqueueResult.duplicate;
    }

    final localFiles = await ref
        .read(documentRepositoryProvider)
        .localFileStore
        .saveAll(draft.sources);
    _ensureCurrentSession(session);
    final now = DateTime.now();
    final item = QueuedUpload(
      id: now.microsecondsSinceEpoch.toString(),
      ownerUserId: session.ownerUserId,
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
    _ensureCurrentSession(session);
    state = AsyncValue.data([...state.value ?? const [], item]);
    unawaited(_run(item, session));
    return UploadEnqueueResult.enqueued;
  }

  Future<void> retry(String id) async {
    final session = _requireSession();
    final item = await _findItem(id, session.ownerUserId);
    _ensureCurrentSession(session);
    if (item == null) return;
    final uploading = item.copyWith(
      stage: UploadQueueStage.uploading,
      errorMessage: null,
      updatedAt: DateTime.now(),
    );
    await _save(uploading, session);
    unawaited(_run(uploading, session));
  }

  Future<void> dismiss(String id) async {
    final session = _requireSession();
    final database = ref.read(db.localDatabaseProvider);
    final item = await _findItem(id, session.ownerUserId);
    _ensureCurrentSession(session);
    if (item == null) return;
    if (item.stage == UploadQueueStage.failed && item.documentId != null) {
      await ref
          .read(documentRepositoryProvider)
          .deleteDocument(item.documentId!);
      _ensureCurrentSession(session);
    }
    await ref
        .read(documentRepositoryProvider)
        .deleteOwnedSources(item.localFiles);
    _ensureCurrentSession(session);
    if (item.stage == UploadQueueStage.failed) {
      await (database.delete(database.uploadQueueItems)..where(
            (queueItem) =>
                queueItem.id.equals(id) &
                queueItem.ownerUserId.equals(session.ownerUserId),
          ))
          .go();
    } else {
      await (database.update(database.uploadQueueItems)..where(
            (queueItem) =>
                queueItem.id.equals(id) &
                queueItem.ownerUserId.equals(session.ownerUserId),
          ))
          .write(
            db.UploadQueueItemsCompanion(
              isDismissed: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
    }
    _ensureCurrentSession(session);
    state = AsyncValue.data(await _loadVisibleItems(session.ownerUserId));
  }

  Future<void> _run(QueuedUpload item, _UploadSession session) async {
    var current = item;
    try {
      _ensureCurrentSession(session);
      final repository = ref.read(documentRepositoryProvider);
      final existingDocumentId = item.documentId;
      late final String documentId;
      if (existingDocumentId != null &&
          item.draft.docType != DocumentType.audio) {
        final retry = await repository.retryProcessing(existingDocumentId);
        _ensureCurrentSession(session);
        documentId = retry.id;
      } else {
        if (existingDocumentId != null) {
          await repository.deleteDocument(existingDocumentId);
          _ensureCurrentSession(session);
        }
        final result = await repository.createAndUploadStored(
          item.draft,
          item.localFiles,
          onUploadProgress: (sent, total) {
            if (total > 0) {
              _setUploadProgress(item.id, sent / total, session);
            }
          },
          shouldContinue: () =>
              _isCurrentSession(session.ownerUserId, session.generation),
        );
        _ensureCurrentSession(session);
        documentId = result.documentId;
      }
      current = current.copyWith(
        stage: UploadQueueStage.processing,
        documentId: documentId,
        updatedAt: DateTime.now(),
      );
      await _save(current, session);
      if (item.draft.docType != DocumentType.audio) {
        await repository.deleteOwnedSources(item.localFiles);
        _ensureCurrentSession(session);
      }
      final document = await repository.pollDocumentUntilTerminal(
        id: documentId,
        shouldContinue: () =>
            _isCurrentSession(session.ownerUserId, session.generation),
      );
      _ensureCurrentSession(session);
      if (item.draft.docType == DocumentType.audio) {
        await repository.deleteOwnedSources(item.localFiles);
        _ensureCurrentSession(session);
      }
      await _save(
        current.copyWith(
          stage: UploadQueueStage.completed,
          documentId: document.id,
          updatedAt: DateTime.now(),
        ),
        session,
      );
      _ensureCurrentSession(session);
      ref.invalidate(timelineControllerProvider);
    } on DocumentUploadCancelled {
      return;
    } on _UploadSessionCancelled {
      return;
    } on Object catch (error) {
      if (!_isCurrentSession(session.ownerUserId, session.generation)) {
        return;
      }
      final duplicateDocumentId = error is AppFailure ? error.documentId : null;
      await _save(
        current.copyWith(
          stage: UploadQueueStage.failed,
          documentId: duplicateDocumentId ?? current.documentId,
          errorMessage: error.toString(),
          updatedAt: DateTime.now(),
        ),
        session,
      );
    }
  }

  Future<void> _save(QueuedUpload item, _UploadSession session) async {
    _ensureCurrentSession(session);
    final database = ref.read(db.localDatabaseProvider);
    await database
        .into(database.uploadQueueItems)
        .insertOnConflictUpdate(_companion(item));
    _ensureCurrentSession(session);
    state = AsyncValue.data(await _loadVisibleItems(session.ownerUserId));
  }

  void _setUploadProgress(String id, double value, _UploadSession session) {
    if (!_isCurrentSession(session.ownerUserId, session.generation)) return;
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final item in current)
        item.id == id
            ? item.copyWith(uploadProgress: value.clamp(0.0, 1.0).toDouble())
            : item,
    ]);
  }

  Future<QueuedUpload?> _findItem(String id, String ownerUserId) async {
    final database = ref.read(db.localDatabaseProvider);
    final row =
        await (database.select(database.uploadQueueItems)..where(
              (item) =>
                  item.id.equals(id) & item.ownerUserId.equals(ownerUserId),
            ))
            .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<List<QueuedUpload>> _loadVisibleItems(String ownerUserId) async {
    final database = ref.read(db.localDatabaseProvider);
    final rows =
        await (database.select(database.uploadQueueItems)
              ..where((item) => item.ownerUserId.equals(ownerUserId))
              ..orderBy([(item) => OrderingTerm(expression: item.createdAt)]))
            .get();
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
      ownerUserId: item.ownerUserId,
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
      ownerUserId: row.ownerUserId,
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

  _UploadSession _requireSession() {
    final ownerUserId = _ownerUserId;
    if (ownerUserId == null || ownerUserId.isEmpty || _isDisposed) {
      throw const AppFailure('authentication_required');
    }
    return _UploadSession(ownerUserId, _sessionGeneration);
  }

  bool _isCurrentSession(String ownerUserId, int generation) {
    return !_isDisposed &&
        _ownerUserId == ownerUserId &&
        _sessionGeneration == generation;
  }

  void _ensureCurrentSession(_UploadSession session) {
    if (!_isCurrentSession(session.ownerUserId, session.generation)) {
      throw const _UploadSessionCancelled();
    }
  }
}

class _UploadSession {
  const _UploadSession(this.ownerUserId, this.generation);

  final String ownerUserId;
  final int generation;
}

class _UploadSessionCancelled implements Exception {
  const _UploadSessionCancelled();
}

enum UploadEnqueueResult { enqueued, duplicate }

enum UploadQueueStage { uploading, processing, completed, failed }

class QueuedUpload {
  const QueuedUpload({
    required this.id,
    required this.ownerUserId,
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
  final String ownerUserId;
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
    ownerUserId: ownerUserId,
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
