import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/error/app_failure.dart';
import 'package:med_story/features/capture/presentation/controllers/voice_capture_controller.dart';

class _FakeVoiceRecorderService implements VoiceRecorderService {
  _FakeVoiceRecorderService({
    this.permission = true,
    this.bytesOnStop = const <int>[1, 2, 3],
  });

  final bool permission;
  final List<int> bytesOnStop;
  String? activePath;
  bool cancelled = false;

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<void> start(String path) async {
    activePath = path;
  }

  @override
  Future<String?> stop() async {
    final path = activePath;
    if (path == null) {
      return null;
    }
    await File(path).writeAsBytes(bytesOnStop);
    return path;
  }

  @override
  Future<void> cancel() async {
    cancelled = true;
  }

  @override
  void dispose() {}
}

class _FakeVoiceRecordingPathFactory implements VoiceRecordingPathFactory {
  const _FakeVoiceRecordingPathFactory(this.path);

  final String path;

  @override
  Future<String> nextPath() async => path;
}

void main() {
  late Directory tempDir;
  late String recordingPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('med_story_voice_test_');
    recordingPath = '${tempDir.path}/voice.m4a';
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('records and exposes a reviewed local audio file', () async {
    final recorder = _FakeVoiceRecorderService();
    final container = _container(recorder, recordingPath);
    addTearDown(container.dispose);

    final notifier = container.read(voiceCaptureControllerProvider.notifier);
    await notifier.startRecording();

    expect(
      container.read(voiceCaptureControllerProvider).requireValue.stage,
      VoiceCaptureStage.recording,
    );

    await notifier.stopRecording();
    final state = container.read(voiceCaptureControllerProvider).requireValue;

    expect(state.stage, VoiceCaptureStage.recorded);
    expect(state.path, recordingPath);
    expect(state.fileName, 'voice.m4a');
    expect(state.sizeBytes, 3);
    expect(await File(recordingPath).exists(), isTrue);
  });

  test('permission denial exposes a stable app failure', () async {
    final recorder = _FakeVoiceRecorderService(permission: false);
    final container = _container(recorder, recordingPath);
    addTearDown(container.dispose);

    await container
        .read(voiceCaptureControllerProvider.notifier)
        .startRecording();

    final state = container.read(voiceCaptureControllerProvider);
    expect(state.hasError, isTrue);
    expect(
      state.error,
      isA<AppFailure>().having(
        (failure) => failure.message,
        'message',
        'voice_permission_denied',
      ),
    );
  });

  test('discard cancels and removes the temp recording', () async {
    final recorder = _FakeVoiceRecorderService();
    final container = _container(recorder, recordingPath);
    addTearDown(container.dispose);

    final notifier = container.read(voiceCaptureControllerProvider.notifier);
    await notifier.startRecording();
    await File(recordingPath).writeAsBytes(<int>[1, 2, 3]);
    await notifier.discardRecording();

    expect(recorder.cancelled, isTrue);
    expect(await File(recordingPath).exists(), isFalse);
    expect(
      container.read(voiceCaptureControllerProvider).requireValue.stage,
      VoiceCaptureStage.idle,
    );
  });

  test('oversized audio is rejected and removed', () async {
    final recorder = _FakeVoiceRecorderService(
      bytesOnStop: List<int>.filled(maxVoiceCaptureBytes + 1, 1),
    );
    final container = _container(recorder, recordingPath);
    addTearDown(container.dispose);

    final notifier = container.read(voiceCaptureControllerProvider.notifier);
    await notifier.startRecording();
    await notifier.stopRecording();

    final state = container.read(voiceCaptureControllerProvider);
    expect(state.hasError, isTrue);
    expect(
      state.error,
      isA<AppFailure>().having(
        (failure) => failure.message,
        'message',
        'voice_file_too_large',
      ),
    );
    expect(await File(recordingPath).exists(), isFalse);
  });
}

ProviderContainer _container(
  VoiceRecorderService recorder,
  String recordingPath,
) {
  return ProviderContainer(
    overrides: [
      voiceRecorderServiceProvider.overrideWithValue(recorder),
      voiceRecordingPathFactoryProvider.overrideWithValue(
        _FakeVoiceRecordingPathFactory(recordingPath),
      ),
    ],
  );
}
