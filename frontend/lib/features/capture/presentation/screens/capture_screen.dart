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
import '../../../documents/presentation/document_l10n.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';

const _maxDocumentBytes = 5 * 1024 * 1024;

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _imagePicker = ImagePicker();
  DocumentType _docType = DocumentType.report;
  DateTime? _documentDate;
  _SelectedDocumentFile? _selectedFile;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final uploadState = ref.watch(documentUploadControllerProvider);

    return SafeArea(
      child: Form(
        key: _formKey,
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
              onTap: () => _pickCameraImage(),
            ),
            const SizedBox(height: AppSpacing.sm),
            MedStoryActionRow(
              icon: Icons.add_photo_alternate_outlined,
              title: l10n.addPhotoTitle,
              description: l10n.addPhotoDescription,
              isPrimary: true,
              semanticHint: l10n.addPhotoSemanticHint,
              onTap: () => _pickGalleryImage(),
            ),
            const SizedBox(height: AppSpacing.sm),
            MedStoryActionRow(
              icon: Icons.attach_file_rounded,
              title: l10n.chooseFileTitle,
              description: l10n.chooseFileDescription,
              semanticHint: l10n.chooseFileSemanticHint,
              onTap: () => _pickFile(),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_selectedFile == null)
              _EmptySelectionPanel(message: l10n.documentSelectionEmpty)
            else
              _UploadReviewPanel(
                selectedFile: _selectedFile!,
                titleController: _titleController,
                documentType: _docType,
                documentDate: _documentDate,
                onTypeChanged: (type) => setState(() => _docType = type),
                onDateChanged: (date) => setState(() => _documentDate = date),
              ),
            const SizedBox(height: AppSpacing.md),
            uploadState.when(
              data: (state) => _UploadStatusPanel(stage: state.stage),
              loading: () => const _UploadStatusPanel(
                stage: DocumentUploadStage.uploading,
              ),
              error: (error, _) => _InlineNotice(
                icon: Icons.error_outline_rounded,
                message: _documentErrorMessage(context, error),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _selectedFile == null || uploadState.isLoading
                  ? null
                  : _submit,
              icon: uploadState.isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(l10n.documentUploadAction),
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
      defaultType: DocumentType.image,
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
      defaultType: DocumentType.image,
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
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
      defaultType: _mimeTypeForName(file.name) == 'application/pdf'
          ? DocumentType.report
          : DocumentType.image,
    );
  }

  Future<void> _setPickedFile({
    required String path,
    required String fileName,
    required String mimeType,
    required DocumentType defaultType,
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
      _docType = defaultType;
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = _titleFromFileName(
          fileName,
          fallback: l10n.documentUntitledTitle,
        );
      }
    });
    ref.read(documentUploadControllerProvider.notifier).reset();
  }

  Future<void> _submit() async {
    final selectedFile = _selectedFile;
    if (selectedFile == null || !_formKey.currentState!.validate()) {
      return;
    }

    final subjectState = ref
        .read(subjectControllerProvider)
        .maybeWhen(data: (state) => state, orElse: () => null);
    final document = await ref
        .read(documentUploadControllerProvider.notifier)
        .upload(
          DocumentUploadDraft(
            title: _titleController.text.trim(),
            docType: _docType,
            subjectId: subjectState?.selectedSubjectId,
            documentDate: _documentDate == null
                ? null
                : _dateOnly(_documentDate!),
            source: DocumentSourceFile(
              path: selectedFile.path,
              fileName: selectedFile.fileName,
              mimeType: selectedFile.mimeType,
            ),
          ),
        );

    if (!mounted) {
      return;
    }
    context.push('/documents/${document.id}');
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

class _UploadReviewPanel extends ConsumerWidget {
  const _UploadReviewPanel({
    required this.selectedFile,
    required this.titleController,
    required this.documentType,
    required this.documentDate,
    required this.onTypeChanged,
    required this.onDateChanged,
  });

  final _SelectedDocumentFile selectedFile;
  final TextEditingController titleController;
  final DocumentType documentType;
  final DateTime? documentDate;
  final ValueChanged<DocumentType> onTypeChanged;
  final ValueChanged<DateTime?> onDateChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final subjects = ref.watch(subjectControllerProvider);

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentReviewTitle,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FileSummary(selectedFile: selectedFile),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: l10n.documentTitleLabel),
            textInputAction: TextInputAction.next,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.eventRequiredValidation
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<DocumentType>(
            initialValue: documentType,
            decoration: InputDecoration(labelText: l10n.documentTypeLabel),
            items: DocumentType.values
                .where((type) => type != DocumentType.audio)
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.label(l10n)),
                  ),
                )
                .toList(growable: false),
            onChanged: (type) {
              if (type != null) {
                onTypeChanged(type);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          subjects.maybeWhen(
            data: (state) => Text(
              state.selectedSubject == null
                  ? l10n.documentDefaultSubject
                  : l10n.documentSelectedSubject(
                      state.selectedSubject!.displayName,
                    ),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryInk,
              ),
            ),
            orElse: () => Text(
              l10n.documentDefaultSubject,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryInk,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: documentDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              onDateChanged(picked);
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(
              documentDate == null
                  ? l10n.documentDateAddAction
                  : l10n.documentDateSelected(_dateOnly(documentDate!)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileSummary extends StatelessWidget {
  const _FileSummary({required this.selectedFile});

  final _SelectedDocumentFile selectedFile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
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
      ),
    );
  }
}

class _UploadStatusPanel extends StatelessWidget {
  const _UploadStatusPanel({required this.stage});

  final DocumentUploadStage stage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = switch (stage) {
      DocumentUploadStage.idle => l10n.documentUploadIdle,
      DocumentUploadStage.uploading => l10n.documentUploadUploading,
      DocumentUploadStage.processing => l10n.documentUploadProcessing,
      DocumentUploadStage.processed => l10n.documentUploadProcessed,
    };
    return _InlineNotice(
      icon: stage == DocumentUploadStage.processed
          ? Icons.check_circle_outline_rounded
          : Icons.info_outline_rounded,
      message: message,
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

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.deepClinicalBlue),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message)),
        ],
      ),
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

String _dateOnly(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
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
  return switch (message) {
    'document_file_too_large' => l10n.documentFileTooLargeMessage,
    'document_unsupported_mime_type' => l10n.documentUnsupportedFileMessage,
    'document_processing_failed' => l10n.documentProcessingFailedMessage,
    'document_processing_timeout' => l10n.documentProcessingTimeoutMessage,
    'document_source_file_missing' => l10n.documentSourceMissingMessage,
    _ => l10n.documentUploadFailedMessage,
  };
}
