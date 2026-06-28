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
      final document = await repository.pollDocumentUntilTerminal(
        id: result.documentId,
      );
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
