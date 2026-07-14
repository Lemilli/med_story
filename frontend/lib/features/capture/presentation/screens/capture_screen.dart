import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../core/widgets/med_story_action_row.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../documents/data/document_repository.dart';
import '../../../documents/domain/medical_document.dart';
import '../../../documents/presentation/controllers/document_controllers.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../controllers/voice_capture_controller.dart';

const _maxDocumentBytes = 5 * 1024 * 1024;

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _retrieveLostImageData();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final uploads = ref.watch(documentUploadControllerProvider);
    final hasUploads = uploads.when(
      data: (items) => items.isNotEmpty,
      loading: () => false,
      error: (_, _) => false,
    );
    return Material(
      color: AppColors.clinicalWhite,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            uploads.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (items) => items.isEmpty
                  ? const SizedBox.shrink()
                  : _UploadQueue(
                      items: items,
                      onRetry: (id) => ref
                          .read(documentUploadControllerProvider.notifier)
                          .retry(id),
                      onDismiss: (id) => ref
                          .read(documentUploadControllerProvider.notifier)
                          .dismiss(id),
                      onOpenDocument: (id) => context.push('/documents/$id'),
                      onOpenCompletedEvent: _openCompletedEvent,
                    ),
            ),
            if (hasUploads) const SizedBox(height: AppSpacing.xl),
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
            _CaptureActionGroup(
              actions: [
                _CaptureAction(
                  icon: Icons.add_photo_alternate_outlined,
                  title: l10n.addPhotoTitle,
                  description: l10n.addPhotoDescription,
                  semanticHint: l10n.addPhotoSemanticHint,
                  onTap: _pickGalleryImage,
                ),
                _CaptureAction(
                  icon: Icons.camera_alt_outlined,
                  title: l10n.scanDocumentTitle,
                  description: l10n.scanDocumentDescription,
                  semanticHint: l10n.scanDocumentSemanticHint,
                  onTap: _pickCameraImage,
                ),
                _CaptureAction(
                  icon: Icons.attach_file_rounded,
                  title: l10n.chooseFileTitle,
                  description: l10n.chooseFileDescription,
                  semanticHint: l10n.chooseFileSemanticHint,
                  onTap: _pickFile,
                ),
                _CaptureAction(
                  icon: Icons.edit_note_rounded,
                  title: l10n.writeNoteTitle,
                  description: l10n.writeNoteDescription,
                  semanticHint: l10n.writeNoteSemanticHint,
                  onTap: () => context.push('/notes/new'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const _PrivacyNotice(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCameraImage() async {
    final l10n = context.l10n;
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    if (!mounted) return;
    final pages = await Navigator.of(context, rootNavigator: true)
        .push<List<XFile>>(
          MaterialPageRoute(
            builder: (_) => _DocumentPagesReviewScreen(initialPages: [image]),
          ),
        );
    if (pages != null && pages.isNotEmpty) {
      await _enqueuePhotoBundle(
        pages,
        displayName: _friendlyCaptureLabel(l10n.medicalPhotoCaptureLabel),
      );
    }
  }

  Future<void> _pickGalleryImage() async {
    final l10n = context.l10n;
    final images = await _imagePicker.pickMultiImage();
    if (images.isEmpty) {
      return;
    }
    if (!mounted) return;
    if (images.length == 1) {
      await _enqueuePhotoBundle(
        images,
        displayName: _friendlyCaptureLabel(l10n.medicalPhotoCaptureLabel),
      );
      return;
    }
    final grouping = await Navigator.of(context, rootNavigator: true)
        .push<_PhotoGrouping>(
          MaterialPageRoute(
            builder: (_) => _PhotoGroupingChoiceScreen(images: images),
          ),
        );
    if (!mounted || grouping == null) return;
    if (grouping == _PhotoGrouping.separateDocuments) {
      for (final image in images) {
        await _enqueuePhotoBundle([
          image,
        ], displayName: _friendlyCaptureLabel(l10n.medicalPhotoCaptureLabel));
      }
      return;
    }
    final pages = await Navigator.of(context, rootNavigator: true)
        .push<List<XFile>>(
          MaterialPageRoute(
            builder: (_) => _DocumentPagesReviewScreen(initialPages: images),
          ),
        );
    if (pages != null && pages.isNotEmpty) {
      await _enqueuePhotoBundle(
        pages,
        displayName: _friendlyCaptureLabel(l10n.medicalPhotoCaptureLabel),
      );
    }
  }

  Future<void> _retrieveLostImageData() async {
    if (!Platform.isAndroid) {
      return;
    }

    final response = await _imagePicker.retrieveLostData();
    if (!mounted || response.isEmpty) {
      return;
    }

    final images =
        response.files ?? [if (response.file != null) response.file!];
    if (images.isNotEmpty) {
      if (images.length == 1) {
        await _enqueuePhotoBundle(
          images,
          displayName: _friendlyCaptureLabel(
            context.l10n.medicalPhotoCaptureLabel,
          ),
        );
      } else {
        final grouping = await Navigator.of(context, rootNavigator: true)
            .push<_PhotoGrouping>(
              MaterialPageRoute(
                builder: (_) => _PhotoGroupingChoiceScreen(images: images),
              ),
            );
        if (!mounted) return;
        if (grouping == _PhotoGrouping.oneDocument) {
          final pages = await Navigator.of(context, rootNavigator: true)
              .push<List<XFile>>(
                MaterialPageRoute(
                  builder: (_) =>
                      _DocumentPagesReviewScreen(initialPages: images),
                ),
              );
          if (!mounted) return;
          if (pages != null && pages.isNotEmpty) {
            await _enqueuePhotoBundle(
              pages,
              displayName: _friendlyCaptureLabel(
                context.l10n.medicalPhotoCaptureLabel,
              ),
            );
          }
        } else if (grouping == _PhotoGrouping.separateDocuments) {
          for (final image in images) {
            await _enqueuePhotoBundle(
              [image],
              displayName: _friendlyCaptureLabel(
                context.l10n.medicalPhotoCaptureLabel,
              ),
            );
          }
        }
      }
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
    String? displayName,
    int? sizeBytes,
  }) async {
    return _enqueueSources(
      [DocumentSourceFile(path: path, fileName: fileName, mimeType: mimeType)],
      displayName: displayName,
      sizeBytes: sizeBytes,
    );
  }

  Future<void> _enqueuePhotoBundle(
    List<XFile> images, {
    required String displayName,
  }) async {
    final sources = <DocumentSourceFile>[];
    for (var index = 0; index < images.length; index++) {
      final image = images[index];
      sources.add(
        DocumentSourceFile(
          path: image.path,
          fileName: image.name.trim().isEmpty
              ? _friendlyCaptureFileName(
                  'medical-page-${index + 1}',
                  image.mimeType,
                )
              : image.name,
          mimeType: image.mimeType ?? _mimeTypeForName(image.name),
        ),
      );
    }
    await _enqueueSources(sources, displayName: displayName);
  }

  Future<void> _enqueueSources(
    List<DocumentSourceFile> sources, {
    String? displayName,
    int? sizeBytes,
  }) async {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    if (sources.any((source) => !_isSupportedMimeType(source.mimeType))) {
      _showSnack(l10n.documentUnsupportedFileMessage);
      return;
    }

    final resolvedSize =
        sizeBytes ??
        (await Future.wait(
          sources.map((source) => File(source.path).length()),
        )).fold<int>(0, (total, size) => total + size);
    if (resolvedSize > _maxDocumentBytes) {
      _showSnack(l10n.documentFileTooLargeMessage);
      return;
    }

    final subjectState = ref
        .read(subjectControllerProvider)
        .maybeWhen(data: (state) => state, orElse: () => null);
    final result = await ref
        .read(documentUploadControllerProvider.notifier)
        .enqueue(
          DocumentUploadDraft(
            title:
                displayName ??
                _titleFromFileName(
                  sources.first.fileName,
                  fallback: l10n.documentUntitledTitle,
                ),
            docType: DocumentType.medicalRecord,
            subjectId: subjectState?.selectedSubjectId,
            sources: sources,
            language: language,
          ),
        );
    if (result == UploadEnqueueResult.duplicate && mounted) {
      _showSnack(l10n.uploadQueueDuplicateMessage);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _friendlyCaptureLabel(String label) =>
      '$label — ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_Hm().format(DateTime.now())}';

  String _friendlyCaptureFileName(String prefix, String? mimeType) {
    final extension = switch (mimeType) {
      'image/png' => 'png',
      'image/heic' || 'image/heif' => 'heic',
      'audio/m4a' => 'm4a',
      _ => 'jpg',
    };
    return '$prefix-${DateFormat('yyyy-MM-dd-HHmmss').format(DateTime.now())}.$extension';
  }

  Future<void> _openCompletedEvent(String documentId) async {
    final document = await ref
        .read(documentRepositoryProvider)
        .getDocument(documentId);
    final eventId = document.eventId;
    if (!mounted || eventId == null) return;
    context.push('/events/$eventId');
  }
}

enum _PhotoGrouping { oneDocument, separateDocuments }

class _PhotoGroupingChoiceScreen extends StatefulWidget {
  const _PhotoGroupingChoiceScreen({required this.images});

  final List<XFile> images;

  @override
  State<_PhotoGroupingChoiceScreen> createState() =>
      _PhotoGroupingChoiceScreenState();
}

class _PhotoGroupingChoiceScreenState
    extends State<_PhotoGroupingChoiceScreen> {
  _PhotoGrouping _selection = _PhotoGrouping.oneDocument;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.photoGroupingTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.photoGroupingDescription(widget.images.length),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryInk,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _GroupingOption(
                selected: _selection == _PhotoGrouping.oneDocument,
                title: l10n.photoGroupingOneTitle,
                description: l10n.photoGroupingOneDescription,
                images: widget.images,
                onTap: () =>
                    setState(() => _selection = _PhotoGrouping.oneDocument),
              ),
              const SizedBox(height: AppSpacing.md),
              _GroupingOption(
                selected: _selection == _PhotoGrouping.separateDocuments,
                title: l10n.photoGroupingSeparateTitle,
                description: l10n.photoGroupingSeparateDescription,
                images: widget.images,
                onTap: () => setState(
                  () => _selection = _PhotoGrouping.separateDocuments,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(_selection),
                child: Text(l10n.photoGroupingContinueAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupingOption extends StatelessWidget {
  const _GroupingOption({
    required this.selected,
    required this.title,
    required this.description,
    required this.images,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String description;
  final List<XFile> images;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.selectedSurface
                : AppColors.clinicalWhite,
            border: Border.all(
              color: selected
                  ? AppColors.controlledCrimson
                  : AppColors.clinicalLine,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? AppColors.controlledCrimson
                    : AppColors.secondaryInk,
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 76,
                height: 56,
                child: Stack(
                  children: [
                    for (var index = 0; index < images.take(3).length; index++)
                      Positioned(
                        left: index * 18,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.file(
                            File(images[index].path),
                            width: 40,
                            height: 54,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
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
        ),
      ),
    );
  }
}

class _DocumentPagesReviewScreen extends StatefulWidget {
  const _DocumentPagesReviewScreen({required this.initialPages});

  final List<XFile> initialPages;

  @override
  State<_DocumentPagesReviewScreen> createState() =>
      _DocumentPagesReviewScreenState();
}

class _DocumentPagesReviewScreenState
    extends State<_DocumentPagesReviewScreen> {
  late final List<XFile> _pages = [...widget.initialPages];
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentPagesReviewTitle)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.documentPagesCount(_pages.length),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: _pages.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final page = _pages.removeAt(oldIndex);
                    _pages.insert(newIndex, page);
                  });
                },
                itemBuilder: (context, index) => ListTile(
                  key: ValueKey(_pages[index].path),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_pages[index].path),
                      width: 56,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    l10n.documentPageLabel(index + 1),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(l10n.documentPageReorderHint),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Tooltip(
                          message: l10n.documentPageReorderHint,
                          child: const SizedBox.square(
                            dimension: 48,
                            child: Icon(Icons.drag_indicator_rounded),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.documentPageRemoveAction,
                        onPressed: _pages.length == 1
                            ? null
                            : () => setState(() => _pages.removeAt(index)),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _addPage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(l10n.documentPageAddAction),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_pages),
                    child: Text(l10n.documentPagesProcessAction),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPage() async {
    final page = await _picker.pickImage(source: ImageSource.camera);
    if (page != null && mounted) setState(() => _pages.add(page));
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

class _UploadQueue extends StatelessWidget {
  const _UploadQueue({
    required this.items,
    required this.onRetry,
    required this.onDismiss,
    required this.onOpenDocument,
    required this.onOpenCompletedEvent,
  });

  final List<QueuedUpload> items;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onDismiss;
  final ValueChanged<String> onOpenDocument;
  final Future<void> Function(String) onOpenCompletedEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: l10n.uploadQueueTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.uploadQueueTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.clinicalLine),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Column(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    _UploadQueueRow(
                      item: items[index],
                      onRetry: onRetry,
                      onDismiss: onDismiss,
                      onOpenDocument: onOpenDocument,
                      onOpenCompletedEvent: onOpenCompletedEvent,
                    ),
                    if (index != items.length - 1)
                      const Divider(height: 1, color: AppColors.clinicalLine),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadQueueRow extends StatelessWidget {
  const _UploadQueueRow({
    required this.item,
    required this.onRetry,
    required this.onDismiss,
    required this.onOpenDocument,
    required this.onOpenCompletedEvent,
  });

  final QueuedUpload item;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onDismiss;
  final ValueChanged<String> onOpenDocument;
  final Future<void> Function(String) onOpenCompletedEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isFailed = item.stage == UploadQueueStage.failed;
    final isAlreadyProcessed =
        item.errorMessage == 'document_already_processed' &&
        item.documentId != null;
    final isPhoto = item.localFile.mimeType.startsWith('image/');
    final isActive =
        item.stage == UploadQueueStage.uploading ||
        item.stage == UploadQueueStage.processing;
    final stageLabel = switch (item.stage) {
      UploadQueueStage.uploading when item.uploadProgress != null =>
        l10n.uploadQueueUploadingProgress((item.uploadProgress! * 100).round()),
      UploadQueueStage.uploading => l10n.uploadQueueUploading,
      UploadQueueStage.processing => l10n.uploadQueueProcessing,
      UploadQueueStage.completed => l10n.uploadQueueCompleted,
      UploadQueueStage.failed => _localizedUploadQueueError(
        l10n,
        item.errorMessage,
      ),
    };
    final row = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: isPhoto
                ? l10n.uploadQueuePhotoLabel
                : l10n.uploadQueueFileLabel,
            child: SizedBox(
              width: 40,
              height: 40,
              child: isPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(item.localFile.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const _QueueFileIcon(),
                      ),
                    )
                  : const _QueueFileIcon(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.patientInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stageLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isFailed
                        ? AppColors.controlledCrimson
                        : AppColors.secondaryInk,
                    fontWeight: isFailed ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: AppSpacing.sm),
                  LinearProgressIndicator(
                    value: item.stage == UploadQueueStage.uploading
                        ? item.uploadProgress
                        : null,
                  ),
                ],
              ],
            ),
          ),
          if (isFailed)
            Column(
              children: [
                if (isAlreadyProcessed)
                  TextButton.icon(
                    onPressed: () => onOpenDocument(item.documentId!),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(l10n.documentAlreadyProcessedAction),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.deepClinicalBlue,
                      minimumSize: const Size(48, 48),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => onRetry(item.id),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.documentRetryAction),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.controlledCrimson,
                      minimumSize: const Size(48, 48),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => onDismiss(item.id),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(l10n.uploadQueueDismissAction),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                ),
              ],
            ),
          if (item.stage == UploadQueueStage.completed)
            TextButton.icon(
              onPressed: () => onDismiss(item.id),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text(l10n.uploadQueueDismissAction),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.deepClinicalBlue,
                minimumSize: const Size(48, 48),
              ),
            ),
        ],
      ),
    );
    if (item.stage != UploadQueueStage.completed || item.documentId == null) {
      return row;
    }
    return Semantics(
      button: true,
      label: l10n.uploadQueueOpenResultHint,
      child: InkWell(
        onTap: () => onOpenCompletedEvent(item.documentId!),
        child: row,
      ),
    );
  }
}

String _localizedUploadQueueError(AppLocalizations l10n, String? errorCode) {
  return switch (errorCode) {
    'document_not_medical' => l10n.documentNotMedicalMessage,
    'document_unreadable' => l10n.documentUnreadableMessage,
    'audio_not_medical' => l10n.audioNotMedicalMessage,
    'audio_unreadable' => l10n.audioUnreadableMessage,
    'medical_events_not_found' => l10n.medicalEventsNotFoundMessage,
    'document_already_processed' => l10n.documentAlreadyProcessedMessage,
    _ => l10n.uploadQueueFailed,
  };
}

class _QueueFileIcon extends StatelessWidget {
  const _QueueFileIcon();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.quietSurface,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    child: Center(
      child: Icon(
        Icons.insert_drive_file_outlined,
        color: AppColors.deepClinicalBlue,
      ),
    ),
  );
}

class _CaptureAction {
  const _CaptureAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.semanticHint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String semanticHint;
  final VoidCallback onTap;
}

class _CaptureActionGroup extends StatelessWidget {
  const _CaptureActionGroup({required this.actions});

  final List<_CaptureAction> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.clinicalLine),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              MedStoryActionRow(
                icon: actions[index].icon,
                title: actions[index].title,
                description: actions[index].description,
                semanticHint: actions[index].semanticHint,
                onTap: actions[index].onTap,
                isGrouped: true,
              ),
              if (index != actions.length - 1)
                const Divider(height: 1, color: AppColors.clinicalLine),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Semantics(
      container: true,
      label: l10n.capturePrivacyNotice,
      child: Row(
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
              l10n.capturePrivacyNotice,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryInk,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Retained only for the existing audio-document backend flow; it is no longer
// reachable from Capture. Voice input is offered from Write a note instead.
// ignore: unused_element
class _VoiceCaptureFlowScreen extends ConsumerWidget {
  const _VoiceCaptureFlowScreen({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final voiceState = ref.watch(voiceCaptureControllerProvider);
    final voice = voiceState.hasValue ? voiceState.requireValue : null;
    return Scaffold(
      backgroundColor: AppColors.clinicalWhite,
      appBar: AppBar(title: Text(l10n.voiceCaptureTitle)),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: voiceState.hasError
              ? _VoiceErrorPanel(
                  message: _voiceErrorMessage(context, voiceState.error!),
                  onRetry: () => ref
                      .read(voiceCaptureControllerProvider.notifier)
                      .startRecording(),
                )
              : voice == null
              ? const Center(child: CircularProgressIndicator())
              : switch (voice.stage) {
                  VoiceCaptureStage.requestingPermission ||
                  VoiceCaptureStage.recording => _VoiceRecordingPanel(
                    state: voice,
                    onStop: () => ref
                        .read(voiceCaptureControllerProvider.notifier)
                        .stopRecording(),
                    onDiscard: () async {
                      await ref
                          .read(voiceCaptureControllerProvider.notifier)
                          .discardRecording();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                  VoiceCaptureStage.recorded => _RecordedVoicePanel(
                    state: voice,
                    isUploadBusy: false,
                    onUpload: onUpload,
                    onDiscard: () async {
                      await ref
                          .read(voiceCaptureControllerProvider.notifier)
                          .discardRecording();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    onRecordAgain: () async {
                      await ref
                          .read(voiceCaptureControllerProvider.notifier)
                          .discardRecording();
                      await ref
                          .read(voiceCaptureControllerProvider.notifier)
                          .startRecording();
                    },
                  ),
                  VoiceCaptureStage.idle => const SizedBox.shrink(),
                },
        ),
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
