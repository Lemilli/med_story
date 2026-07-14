import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../documents/data/document_api.dart';
import '../../../documents/domain/medical_document.dart';
import '../../../subjects/presentation/controllers/subject_controller.dart';
import '../../../timeline/presentation/controllers/timeline_controller.dart';
import '../controllers/voice_capture_controller.dart';

/// A transient capture draft. Only the final text is submitted for extraction.
class QuickNoteScreen extends ConsumerStatefulWidget {
  const QuickNoteScreen({super.key});

  @override
  ConsumerState<QuickNoteScreen> createState() => _QuickNoteScreenState();
}

class _QuickNoteScreenState extends ConsumerState<QuickNoteScreen> {
  final _text = TextEditingController();
  bool _transcribing = false;
  bool _submitting = false;
  String? _message;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<VoiceCaptureState>>(voiceCaptureControllerProvider, (_, next) {
      final recording = _dataOrNull(next);
      if (recording?.stage == VoiceCaptureStage.recorded && !_transcribing) {
        unawaited(_transcribe(recording!));
      }
    });
    final voice = _dataOrNull(ref.watch(voiceCaptureControllerProvider));
    final recording = voice?.stage == VoiceCaptureStage.recording;
    final busy = _transcribing || _submitting || recording;
    final l10n = context.l10n;
    return PopScope(
      canPop: !_transcribing && recording != true,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && !busy) return;
        if (!didPop) return;
        await ref.read(voiceCaptureControllerProvider.notifier).discardRecording();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.writeNoteTitle),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: (_transcribing || recording == true) ? null : _discardAndClose,
            tooltip: l10n.voiceDiscardAction,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.writeNoteDescription),
                const SizedBox(height: AppSpacing.md),
                if (_message != null) ...[
                  Text(_message!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (_transcribing) const LinearProgressIndicator(),
                if (recording == true) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.voiceRecordingInProgress),
                ],
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _text,
                    autofocus: recording != true,
                    enabled: !_submitting,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(labelText: l10n.eventDescriptionLabel),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (recording == true)
                  FilledButton.icon(
                    onPressed: () => ref.read(voiceCaptureControllerProvider.notifier).stopRecording(),
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(l10n.voiceStopAction),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: busy ? null : _recordMore,
                    icon: const Icon(Icons.mic_rounded),
                    label: Text(l10n.recordVoiceTitle),
                  ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  onPressed: busy ? null : _submit,
                  child: _submitting
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.eventCreateAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _recordMore() async {
    setState(() => _message = null);
    await ref.read(voiceCaptureControllerProvider.notifier).startRecording();
  }

  Future<void> _transcribe(VoiceCaptureState recording) async {
    final path = recording.path;
    final name = recording.fileName;
    if (path == null || name == null) return;
    setState(() { _transcribing = true; _message = null; });
    try {
      final language = Localizations.localeOf(context).languageCode;
      final transcript = await ref.read(documentApiProvider).transcribeAudio(
        filePath: path, fileName: name, mimeType: voiceCaptureMimeType,
        language: language,
      );
      final separator = _text.text.trim().isEmpty ? '' : '\n\n';
      _text.text = '${_text.text.trimRight()}$separator$transcript';
    } catch (_) {
      if (mounted) _message = context.l10n.audioUnreadableMessage;
    } finally {
      await ref.read(voiceCaptureControllerProvider.notifier).discardRecording();
      if (mounted) setState(() => _transcribing = false);
    }
  }

  Future<void> _submit() async {
    final text = _text.text.trim();
    if (text.isEmpty) { setState(() => _message = context.l10n.audioNotMedicalMessage); return; }
    final subject = _dataOrNull(ref.read(subjectControllerProvider));
    setState(() { _submitting = true; _message = null; });
    try {
      final queued = await ref.read(documentApiProvider).processNote(
        text: text, subjectId: subject?.selectedSubjectId,
        language: Localizations.localeOf(context).languageCode,
      );
      await _waitForResult(queued.id);
    } catch (_) {
      if (mounted) setState(() => _message = context.l10n.audioNotMedicalMessage);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _waitForResult(String id) async {
    while (mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      final document = await ref.read(documentApiProvider).getDocument(id);
      if (document.status == DocumentStatus.processing) continue;
      if (document.status == DocumentStatus.processed) {
        ref.invalidate(timelineControllerProvider);
        if (mounted) Navigator.of(context).pop();
        return;
      }
      if (mounted) setState(() => _message = document.errorMessage.isEmpty ? context.l10n.audioNotMedicalMessage : document.errorMessage);
      return;
    }
  }

  Future<void> _discardAndClose() async {
    await ref.read(voiceCaptureControllerProvider.notifier).discardRecording();
    if (mounted) Navigator.of(context).pop();
  }
}

T? _dataOrNull<T>(AsyncValue<T> value) => value.maybeWhen(
  data: (data) => data,
  orElse: () => null,
);
