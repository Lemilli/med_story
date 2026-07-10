import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/error/app_failure.dart';

const maxVoiceCaptureBytes = 5 * 1024 * 1024;
const maxVoiceCaptureDuration = Duration(minutes: 4);
const voiceCaptureMimeType = 'audio/m4a';

final voiceRecorderServiceProvider = Provider<VoiceRecorderService>((ref) {
  final service = RecordVoiceRecorderService();
  ref.onDispose(service.dispose);
  return service;
});

final voiceRecordingPathFactoryProvider = Provider<VoiceRecordingPathFactory>((
  ref,
) {
  return const AppVoiceRecordingPathFactory();
});

final voiceCaptureControllerProvider =
    AsyncNotifierProvider<VoiceCaptureController, VoiceCaptureState>(
      VoiceCaptureController.new,
    );

class VoiceCaptureController extends AsyncNotifier<VoiceCaptureState> {
  Timer? _durationTimer;

  @override
  Future<VoiceCaptureState> build() async {
    ref.onDispose(_cancelTimer);
    return const VoiceCaptureState(stage: VoiceCaptureStage.idle);
  }

  Future<void> startRecording() async {
    _cancelTimer();
    await discardRecording();
    state = const AsyncValue.data(
      VoiceCaptureState(stage: VoiceCaptureStage.requestingPermission),
    );

    final recorder = ref.read(voiceRecorderServiceProvider);
    final hasPermission = await recorder.hasPermission();
    if (!hasPermission) {
      state = const AsyncValue.error(
        AppFailure('voice_permission_denied'),
        StackTrace.empty,
      );
      return;
    }

    final path = await ref.read(voiceRecordingPathFactoryProvider).nextPath();
    final startedAt = DateTime.now();
    await recorder.start(path);
    state = AsyncValue.data(
      VoiceCaptureState(
        stage: VoiceCaptureStage.recording,
        path: path,
        fileName: p.basename(path),
        startedAt: startedAt,
      ),
    );
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.hasValue ? state.requireValue : null;
      if (current == null || current.stage != VoiceCaptureStage.recording) {
        return;
      }
      final duration = DateTime.now().difference(current.startedAt!);
      if (duration >= maxVoiceCaptureDuration) {
        unawaited(stopRecording(maxDurationReached: true));
        return;
      }
      state = AsyncValue.data(current.copyWith(duration: duration));
    });
  }

  Future<void> stopRecording({bool maxDurationReached = false}) async {
    final current = state.hasValue ? state.requireValue : null;
    if (current == null || current.stage != VoiceCaptureStage.recording) {
      return;
    }
    _cancelTimer();

    final recorder = ref.read(voiceRecorderServiceProvider);
    final stoppedPath = await recorder.stop();
    final path = stoppedPath ?? current.path;
    if (path == null || path.isEmpty) {
      state = const AsyncValue.error(
        AppFailure('voice_recording_missing'),
        StackTrace.empty,
      );
      return;
    }

    final file = File(path);
    final exists = await file.exists();
    if (!exists) {
      state = const AsyncValue.error(
        AppFailure('voice_recording_missing'),
        StackTrace.empty,
      );
      return;
    }

    final sizeBytes = await file.length();
    final duration = current.startedAt == null
        ? current.duration
        : DateTime.now().difference(current.startedAt!);
    if (sizeBytes > maxVoiceCaptureBytes) {
      await _deleteFile(path);
      state = const AsyncValue.error(
        AppFailure('voice_file_too_large'),
        StackTrace.empty,
      );
      return;
    }

    state = AsyncValue.data(
      VoiceCaptureState(
        stage: VoiceCaptureStage.recorded,
        path: path,
        fileName: p.basename(path),
        duration: duration,
        sizeBytes: sizeBytes,
        maxDurationReached: maxDurationReached,
      ),
    );
  }

  Future<void> discardRecording() async {
    _cancelTimer();
    final current = state.hasValue ? state.requireValue : null;
    if (current?.stage == VoiceCaptureStage.recording) {
      await ref.read(voiceRecorderServiceProvider).cancel();
    }
    final path = current?.path;
    if (path != null && path.isNotEmpty) {
      await _deleteFile(path);
    }
    state = const AsyncValue.data(
      VoiceCaptureState(stage: VoiceCaptureStage.idle),
    );
  }

  void _cancelTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } on Object {
      // A stale temp recording should not block the user from continuing.
    }
  }
}

abstract interface class VoiceRecorderService {
  Future<bool> hasPermission();

  Future<void> start(String path);

  Future<String?> stop();

  Future<void> cancel();

  void dispose();
}

class RecordVoiceRecorderService implements VoiceRecorderService {
  RecordVoiceRecorderService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission() {
    return _recorder.hasPermission();
  }

  @override
  Future<void> start(String path) {
    return _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
  }

  @override
  Future<String?> stop() {
    return _recorder.stop();
  }

  @override
  Future<void> cancel() {
    return _recorder.cancel();
  }

  @override
  void dispose() {
    _recorder.dispose();
  }
}

abstract interface class VoiceRecordingPathFactory {
  Future<String> nextPath();
}

class AppVoiceRecordingPathFactory implements VoiceRecordingPathFactory {
  const AppVoiceRecordingPathFactory();

  @override
  Future<String> nextPath() async {
    final root = await getTemporaryDirectory();
    final directory = Directory(p.join(root.path, 'voice_capture'));
    await directory.create(recursive: true);
    final fileName =
        'voice_${DateTime.now().microsecondsSinceEpoch.toString()}.m4a';
    return p.join(directory.path, fileName);
  }
}

class VoiceCaptureState {
  const VoiceCaptureState({
    required this.stage,
    this.path,
    this.fileName,
    this.startedAt,
    this.duration = Duration.zero,
    this.sizeBytes = 0,
    this.maxDurationReached = false,
  });

  final VoiceCaptureStage stage;
  final String? path;
  final String? fileName;
  final DateTime? startedAt;
  final Duration duration;
  final int sizeBytes;
  final bool maxDurationReached;

  VoiceCaptureState copyWith({
    VoiceCaptureStage? stage,
    String? path,
    String? fileName,
    DateTime? startedAt,
    Duration? duration,
    int? sizeBytes,
    bool? maxDurationReached,
  }) {
    return VoiceCaptureState(
      stage: stage ?? this.stage,
      path: path ?? this.path,
      fileName: fileName ?? this.fileName,
      startedAt: startedAt ?? this.startedAt,
      duration: duration ?? this.duration,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      maxDurationReached: maxDurationReached ?? this.maxDurationReached,
    );
  }
}

enum VoiceCaptureStage { idle, requestingPermission, recording, recorded }
