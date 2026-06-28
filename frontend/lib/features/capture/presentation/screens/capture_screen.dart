import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/widgets/med_story_action_row.dart';
import '../../../../l10n/l10n.dart';
import '../../../documents/data/document_repository.dart';
import '../../../documents/domain/medical_document.dart';
import '../../../documents/presentation/controllers/document_controllers.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';

const _maxDocumentBytes = 5 * 1024 * 1024;

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _imagePicker = ImagePicker();
  _SelectedDocumentFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _retrieveLostImageData();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final uploadState = ref.watch(documentUploadControllerProvider);
    final uploadStage = uploadState.maybeWhen(
      data: (state) => state.stage,
      orElse: () => null,
    );
    final isUploadBusy =
        uploadStage == DocumentUploadStage.uploading ||
        uploadStage == DocumentUploadStage.processing;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          Text(
            l10n.captureHeadline,
            style: textTheme.headlineLarge?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              height: 1.05,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.captureSubtitle,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryInk,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          MedStoryActionRow(
            icon: Icons.document_scanner_outlined,
            title: l10n.scanDocumentTitle,
            description: l10n.scanDocumentDescription,
            isPrimary: true,
            semanticHint: l10n.scanDocumentSemanticHint,
            onTap: () {
              if (!isUploadBusy) {
                _pickCameraImage();
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          MedStoryActionRow(
            icon: Icons.add_photo_alternate_outlined,
            title: l10n.addPhotoTitle,
            description: l10n.addPhotoDescription,
            isPrimary: true,
            semanticHint: l10n.addPhotoSemanticHint,
            onTap: () {
              if (!isUploadBusy) {
                _pickGalleryImage();
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          MedStoryActionRow(
            icon: Icons.attach_file_rounded,
            title: l10n.chooseFileTitle,
            description: l10n.chooseFileDescription,
            semanticHint: l10n.chooseFileSemanticHint,
            onTap: () {
              if (!isUploadBusy) {
                _pickFile();
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_selectedFile == null)
            _EmptySelectionPanel(message: l10n.documentSelectionEmpty)
          else
            _SelectedFilePanel(selectedFile: _selectedFile!),
          const SizedBox(height: AppSpacing.md),
          uploadState.when(
            data: (state) => _UploadStatusPanelView(
              state: state,
              onViewResult: () => _viewProcessedDocument(state),
            ),
            loading: () => const _UploadStatusPanelView(
              state: DocumentUploadState(stage: DocumentUploadStage.uploading),
            ),
            error: (error, _) => _UploadErrorPanel(
              message: _documentErrorMessage(context, error),
              onRetry: _retrySelectedFile,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          MedStoryActionRow(
            icon: Icons.mic_none_rounded,
            title: l10n.recordVoiceTitle,
            description: l10n.recordVoiceDeferredDescription,
            semanticHint: l10n.recordVoiceDeferredSemanticHint,
            onTap: () => _showDeferredAction(
              title: l10n.voiceCaptureTitle,
              message: l10n.voiceCaptureDeferredMessage,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MedStoryActionRow(
            icon: Icons.edit_note_rounded,
            title: l10n.writeNoteTitle,
            description: l10n.writeNoteDeferredDescription,
            semanticHint: l10n.writeNoteDeferredSemanticHint,
            onTap: () => _showDeferredAction(
              title: l10n.textNoteTitle,
              message: l10n.textNoteDeferredMessage,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _PrivacyPanel(),
          const SizedBox(height: AppSpacing.lg),
          const _BoundaryNote(),
        ],
      ),
    );
  }

  Future<void> _pickCameraImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    await _setPickedFile(
      path: image.path,
      fileName: image.name,
      mimeType: image.mimeType ?? _mimeTypeForName(image.name),
    );
  }

  Future<void> _pickGalleryImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }
    await _setPickedFile(
      path: image.path,
      fileName: image.name,
      mimeType: image.mimeType ?? _mimeTypeForName(image.name),
    );
  }

  Future<void> _retrieveLostImageData() async {
    if (!Platform.isAndroid) {
      return;
    }

    final response = await _imagePicker.retrieveLostData();
    if (!mounted || response.isEmpty) {
      return;
    }

    final image = response.files?.firstOrNull ?? response.file;
    if (image != null) {
      await _setPickedFile(
        path: image.path,
        fileName: image.name,
        mimeType: image.mimeType ?? _mimeTypeForName(image.name),
      );
      return;
    }

    final message = response.exception?.message;
    if (message != null && message.isNotEmpty) {
      _showSnack(message);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: false,
    );
    final file = result?.files.singleOrNull;
    final path = file?.path;
    if (file == null || path == null) {
      return;
    }
    await _setPickedFile(
      path: path,
      fileName: file.name,
      mimeType: _mimeTypeForName(file.name),
      sizeBytes: file.size,
    );
  }

  Future<void> _setPickedFile({
    required String path,
    required String fileName,
    required String mimeType,
    int? sizeBytes,
  }) async {
    final l10n = context.l10n;
    if (!_isSupportedMimeType(mimeType)) {
      _showSnack(l10n.documentUnsupportedFileMessage);
      return;
    }

    final resolvedSize = sizeBytes ?? await File(path).length();
    if (resolvedSize > _maxDocumentBytes) {
      _showSnack(l10n.documentFileTooLargeMessage);
      return;
    }

    setState(() {
      _selectedFile = _SelectedDocumentFile(
        path: path,
        fileName: fileName,
        mimeType: mimeType,
        sizeBytes: resolvedSize,
      );
    });
    await _uploadSelectedFile();
  }

  Future<void> _uploadSelectedFile() async {
    final selectedFile = _selectedFile;
    if (selectedFile == null) {
      return;
    }

    ref.read(documentUploadControllerProvider.notifier).reset();
    final subjectState = ref
        .read(subjectControllerProvider)
        .maybeWhen(data: (state) => state, orElse: () => null);
    try {
      await ref
          .read(documentUploadControllerProvider.notifier)
          .upload(
            DocumentUploadDraft(
              title: _titleFromFileName(
                selectedFile.fileName,
                fallback: context.l10n.documentUntitledTitle,
              ),
              docType: DocumentType.medicalRecord,
              subjectId: subjectState?.selectedSubjectId,
              source: DocumentSourceFile(
                path: selectedFile.path,
                fileName: selectedFile.fileName,
                mimeType: selectedFile.mimeType,
              ),
            ),
          );
    } on Object {
      // Keep the selected source available so retry can re-upload it.
    }
  }

  void _retrySelectedFile() {
    _uploadSelectedFile();
  }

  void _viewProcessedDocument(DocumentUploadState state) {
    final documentId = state.document?.id ?? state.documentId;
    if (documentId == null) {
      return;
    }
    context.push('/documents/$documentId');
  }

  void _showDeferredAction({required String title, required String message}) {
    _showSnack(context.l10n.pendingActionMessage(title, message));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _SelectedFilePanel extends StatelessWidget {
  const _SelectedFilePanel({required this.selectedFile});

  final _SelectedDocumentFile selectedFile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentReviewTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: AppColors.deepClinicalBlue,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedFile.fileName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.documentFileMetadata(
                        selectedFile.mimeType,
                        _formatBytes(selectedFile.sizeBytes),
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadStatusPanelView extends StatelessWidget {
  const _UploadStatusPanelView({required this.state, this.onViewResult});

  final DocumentUploadState state;
  final VoidCallback? onViewResult;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stage = state.stage;
    final message = switch (stage) {
      DocumentUploadStage.idle => l10n.documentUploadIdle,
      DocumentUploadStage.uploading => l10n.documentUploadUploading,
      DocumentUploadStage.processing => l10n.documentUploadProcessing,
      DocumentUploadStage.processed => l10n.documentUploadProcessed,
    };
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                stage == DocumentUploadStage.processed
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                color: AppColors.deepClinicalBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
          if (stage == DocumentUploadStage.uploading ||
              stage == DocumentUploadStage.processing) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
          if (stage == DocumentUploadStage.processed &&
              onViewResult != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onViewResult,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(l10n.documentViewResultAction),
            ),
          ],
        ],
      ),
    );
  }
}

class _UploadErrorPanel extends StatelessWidget {
  const _UploadErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.deepClinicalBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.documentRetryAction),
          ),
        ],
      ),
    );
  }
}

class _EmptySelectionPanel extends StatelessWidget {
  const _EmptySelectionPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.upload_file_outlined,
            color: AppColors.deepClinicalBlue,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _PrivacyPanel extends StatelessWidget {
  const _PrivacyPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Semantics(
      container: true,
      label: l10n.privacyPanelSemanticLabel,
      child: _Panel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.deepClinicalBlue,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.privacyPanelTitle,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.patientInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.privacyPanelDescription,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryInk,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoundaryNote extends StatelessWidget {
  const _BoundaryNote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.shield_outlined,
          color: AppColors.deepClinicalBlue,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            l10n.boundaryNote,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.clinicalWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

class _SelectedDocumentFile {
  const _SelectedDocumentFile({
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
}

String _mimeTypeForName(String fileName) {
  final extension = p.extension(fileName).toLowerCase();
  return switch (extension) {
    '.pdf' => 'application/pdf',
    '.png' => 'image/png',
    '.jpg' || '.jpeg' => 'image/jpeg',
    _ => 'application/octet-stream',
  };
}

bool _isSupportedMimeType(String mimeType) {
  return mimeType == 'application/pdf' || mimeType.startsWith('image/');
}

String _titleFromFileName(String fileName, {required String fallback}) {
  final basename = p.basenameWithoutExtension(fileName).trim();
  if (basename.isEmpty) {
    return fallback;
  }
  return basename.replaceAll(RegExp(r'[_-]+'), ' ');
}

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
  return '$bytes B';
}

String _documentErrorMessage(BuildContext context, Object error) {
  final l10n = context.l10n;
  final message = error is AppFailure ? error.message : error.toString();
  final mapped = switch (message) {
    'document_file_too_large' => l10n.documentFileTooLargeMessage,
    'document_unsupported_mime_type' => l10n.documentUnsupportedFileMessage,
    'document_processing_failed' => l10n.documentProcessingFailedMessage,
    'document_processing_timeout' => l10n.documentProcessingTimeoutMessage,
    'document_source_file_missing' => l10n.documentSourceMissingMessage,
    _ => null,
  };
  if (mapped != null) {
    return mapped;
  }
  if (message.trim().isNotEmpty && !message.contains('_')) {
    return message;
  }
  return l10n.documentUploadFailedMessage;
}
