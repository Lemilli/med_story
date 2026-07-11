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
import '../controllers/voice_capture_controller.dart';

const _maxDocumentBytes = 5 * 1024 * 1024;

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({this.initialAction, super.key});

  final String? initialAction;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (widget.initialAction) {
        case 'scan': _pickCameraImage();
        case 'photo': _pickGalleryImage();
        case 'file': _pickFile();
        case 'voice': _startVoiceRecording();
        case 'note': context.push('/notes/new');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final uploadState = ref.watch(documentUploadControllerProvider);
    final voiceState = ref.watch(voiceCaptureControllerProvider);
    final uploadStage = uploadState.maybeWhen(
      data: (state) => state.stage,
      orElse: () => null,
    );
    final isUploadBusy =
        uploadStage == DocumentUploadStage.uploading ||
        uploadStage == DocumentUploadStage.processing;
    final isVoiceBusy = voiceState.maybeWhen(
      data: (state) =>
          state.stage == VoiceCaptureStage.requestingPermission ||
          state.stage == VoiceCaptureStage.recording,
      orElse: () => false,
    );
    final activeVoiceState = voiceState.hasValue
        ? voiceState.requireValue
        : null;
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
          const SizedBox(height: AppSpacing.sm),
          MedStoryActionRow(
            icon: Icons.mic_none_rounded,
            title: l10n.recordVoiceTitle,
            description: l10n.recordVoiceDescription,
            semanticHint: l10n.recordVoiceSemanticHint,
            onTap: () {
              if (!isUploadBusy && !isVoiceBusy) {
                _startVoiceRecording();
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          if (voiceState.hasError)
            _VoiceErrorPanel(
              message: _voiceErrorMessage(context, voiceState.error!),
              onRetry: _startVoiceRecording,
            )
          else if (activeVoiceState?.stage == VoiceCaptureStage.recording ||
              activeVoiceState?.stage == VoiceCaptureStage.requestingPermission)
            _VoiceRecordingPanel(
              state: activeVoiceState!,
              onStop: _stopVoiceRecording,
              onDiscard: _discardVoiceRecording,
            )
          else if (activeVoiceState?.stage == VoiceCaptureStage.recorded)
            _RecordedVoicePanel(
              state: activeVoiceState!,
              isUploadBusy: isUploadBusy,
              onUpload: _uploadRecordedVoice,
              onDiscard: _discardVoiceRecording,
              onRecordAgain: _restartVoiceRecording,
            )
          else if (_selectedFile == null)
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

    await _discardVoiceRecording();
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
              language: Localizations.localeOf(context).languageCode,
            ),
          );
    } on Object {
      // Keep the selected source available so retry can re-upload it.
    }
  }

  void _retrySelectedFile() {
    final voiceState = ref.read(voiceCaptureControllerProvider);
    final voice = voiceState.hasValue ? voiceState.requireValue : null;
    if (voice?.stage == VoiceCaptureStage.recorded) {
      _uploadRecordedVoice();
      return;
    }
    _uploadSelectedFile();
  }

  void _viewProcessedDocument(DocumentUploadState state) {
    final documentId = state.document?.id ?? state.documentId;
    if (documentId == null) {
      return;
    }
    context.push('/documents/$documentId');
  }

  Future<void> _startVoiceRecording() async {
    setState(() {
      _selectedFile = null;
    });
    ref.read(documentUploadControllerProvider.notifier).reset();
    await ref.read(voiceCaptureControllerProvider.notifier).startRecording();
  }

  Future<void> _stopVoiceRecording() async {
    await ref.read(voiceCaptureControllerProvider.notifier).stopRecording();
    final voiceState = ref.read(voiceCaptureControllerProvider);
    final voice = voiceState.hasValue ? voiceState.requireValue : null;
    if (voice?.maxDurationReached == true && mounted) {
      _showSnack(context.l10n.voiceRecordingMaxDurationMessage);
    }
  }

  Future<void> _discardVoiceRecording() {
    return ref.read(voiceCaptureControllerProvider.notifier).discardRecording();
  }

  Future<void> _restartVoiceRecording() async {
    await _discardVoiceRecording();
    await _startVoiceRecording();
  }

  Future<void> _uploadRecordedVoice() async {
    final voiceState = ref.read(voiceCaptureControllerProvider);
    final recorded = voiceState.hasValue ? voiceState.requireValue : null;
    if (recorded == null ||
        recorded.stage != VoiceCaptureStage.recorded ||
        recorded.path == null ||
        recorded.fileName == null) {
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
              title: context.l10n.voiceNoteTitle,
              docType: DocumentType.audio,
              subjectId: subjectState?.selectedSubjectId,
              source: DocumentSourceFile(
                path: recorded.path!,
                fileName: recorded.fileName!,
                mimeType: voiceCaptureMimeType,
              ),
              language: Localizations.localeOf(context).languageCode,
            ),
          );
      await _discardVoiceRecording();
    } on Object {
      // Keep the recorded source available so retry can re-upload it.
    }
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

class _VoiceRecordingPanel extends StatelessWidget {
  const _VoiceRecordingPanel({
    required this.state,
    required this.onStop,
    required this.onDiscard,
  });

  final VoiceCaptureState state;
  final VoidCallback onStop;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRequestingPermission =
        state.stage == VoiceCaptureStage.requestingPermission;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.mic_rounded,
                color: AppColors.controlledCrimson,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRequestingPermission
                          ? l10n.voicePermissionRequesting
                          : l10n.voiceRecordingInProgress,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.patientInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      isRequestingPermission
                          ? l10n.voicePermissionRequestingDescription
                          : l10n.voiceRecordingDuration(
                              _formatDuration(state.duration),
                            ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryInk,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isRequestingPermission) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDiscard,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.voiceDiscardAction),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(l10n.voiceStopAction),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _RecordedVoicePanel extends StatelessWidget {
  const _RecordedVoicePanel({
    required this.state,
    required this.isUploadBusy,
    required this.onUpload,
    required this.onDiscard,
    required this.onRecordAgain,
  });

  final VoiceCaptureState state;
  final bool isUploadBusy;
  final VoidCallback onUpload;
  final VoidCallback onDiscard;
  final VoidCallback onRecordAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.voiceReviewTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.deepClinicalBlue,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.voiceNoteTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.patientInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.voiceRecordedMetadata(
                        _formatDuration(state.duration),
                        _formatBytes(state.sizeBytes),
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryInk,
                      ),
                    ),
                    if (state.maxDurationReached) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.voiceRecordingMaxDurationMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryInk,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: isUploadBusy ? null : onDiscard,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l10n.voiceDiscardAction),
              ),
              OutlinedButton.icon(
                onPressed: isUploadBusy ? null : onRecordAgain,
                icon: const Icon(Icons.mic_none_rounded),
                label: Text(l10n.voiceRecordAgainAction),
              ),
              FilledButton.icon(
                onPressed: isUploadBusy ? null : onUpload,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text(l10n.voiceUploadAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoiceErrorPanel extends StatelessWidget {
  const _VoiceErrorPanel({required this.message, required this.onRetry});

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
                Icons.mic_off_outlined,
                color: AppColors.deepClinicalBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(message)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.mic_none_rounded),
            label: Text(l10n.voiceRecordAgainAction),
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

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

String _voiceErrorMessage(BuildContext context, Object error) {
  final l10n = context.l10n;
  final message = error is AppFailure ? error.message : error.toString();
  final mapped = switch (message) {
    'voice_permission_denied' => l10n.voicePermissionDeniedMessage,
    'voice_recording_missing' => l10n.voiceRecordingMissingMessage,
    'voice_file_too_large' => l10n.voiceFileTooLargeMessage,
    _ => null,
  };
  if (mapped != null) {
    return mapped;
  }
  if (message.trim().isNotEmpty && !message.contains('_')) {
    return message;
  }
  return l10n.voiceRecordingFailedMessage;
}
