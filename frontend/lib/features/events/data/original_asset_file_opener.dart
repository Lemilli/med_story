import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_app_file/open_app_file.dart';

final originalAssetFileOpenerProvider = Provider<OriginalAssetFileOpener>((
  ref,
) {
  return const PlatformOriginalAssetFileOpener();
});

abstract interface class OriginalAssetFileOpener {
  Future<OpenResult> open(String path, {String? mimeType});
}

class PlatformOriginalAssetFileOpener implements OriginalAssetFileOpener {
  const PlatformOriginalAssetFileOpener();

  static const _iosPreviewChannel = MethodChannel(
    'med_story/original_file_preview',
  );

  @override
  Future<OpenResult> open(String path, {String? mimeType}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return OpenAppFile.open(path, mimeType: mimeType);
    }

    try {
      final response = await _iosPreviewChannel
          .invokeMapMethod<String, Object?>('preview', {'path': path});
      final code = response?['type'];
      final message = response?['message'];
      return OpenResult(
        _resultTypeFromCode(code is int ? code : -4),
        message: message is String ? message : 'Unable to preview the file.',
      );
    } on Object catch (error) {
      return OpenResult(ResultType.error, message: error.toString());
    }
  }
}

ResultType _resultTypeFromCode(int code) {
  return switch (code) {
    0 => ResultType.done,
    -1 => ResultType.noAppToOpen,
    -2 => ResultType.fileNotFound,
    -3 => ResultType.permissionDenied,
    _ => ResultType.error,
  };
}
