import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../timeline/presentation/controllers/timeline_controller.dart';
import '../../data/document_repository.dart';
import '../../domain/medical_document.dart';

final documentDetailProvider = FutureProvider.autoDispose
    .family<MedicalDocument, String>((ref, id) {
      return ref.watch(documentRepositoryProvider).getDocument(id);
    });

final documentUploadControllerProvider =
    AsyncNotifierProvider<DocumentUploadController, DocumentUploadState>(
      DocumentUploadController.new,
    );

class DocumentUploadController extends AsyncNotifier<DocumentUploadState> {
  @override
  Future<DocumentUploadState> build() async {
    return const DocumentUploadState(stage: DocumentUploadStage.idle);
  }

  Future<MedicalDocument> upload(DocumentUploadDraft draft) async {
    state = const AsyncValue.data(
      DocumentUploadState(stage: DocumentUploadStage.uploading),
    );

    final repository = ref.read(documentRepositoryProvider);
    try {
      final result = await repository.createAndUpload(draft);
      state = AsyncValue.data(
        DocumentUploadState(
          stage: DocumentUploadStage.processing,
          documentId: result.documentId,
        ),
      );
      late final MedicalDocument document;
      try {
        document = await repository.pollDocumentUntilTerminal(
          id: result.documentId,
        );
      } on Object {
        await _deleteFailedDocument(repository, result.documentId);
        rethrow;
      }
      state = AsyncValue.data(
        DocumentUploadState(
          stage: DocumentUploadStage.processed,
          documentId: document.id,
          document: document,
        ),
      );
      ref.invalidate(timelineControllerProvider);
      return document;
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(
      DocumentUploadState(stage: DocumentUploadStage.idle),
    );
  }

  Future<void> _deleteFailedDocument(
    DocumentRepository repository,
    String documentId,
  ) async {
    try {
      await repository.deleteDocument(documentId);
    } on Object {
      // Do not hide the processing failure from the capture flow.
    }
  }
}

class DocumentUploadState {
  const DocumentUploadState({
    required this.stage,
    this.documentId,
    this.document,
  });

  final DocumentUploadStage stage;
  final String? documentId;
  final MedicalDocument? document;
}

enum DocumentUploadStage { idle, uploading, processing, processed }
