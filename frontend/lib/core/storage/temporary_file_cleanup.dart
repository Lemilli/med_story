import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<void> clearSensitiveTemporaryFiles() async {
  await _clearTemporaryDirectories(const [
    'medstory_originals',
    'voice_capture',
  ]);
}

Future<void> clearOriginalTemporaryFiles() async {
  await _clearTemporaryDirectories(const ['medstory_originals']);
}

Future<void> _clearTemporaryDirectories(List<String> directoryNames) async {
  try {
    final root = await getTemporaryDirectory();
    for (final directoryName in directoryNames) {
      final directory = Directory(p.join(root.path, directoryName));
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  } on Object {
    // Best-effort cleanup is repeated at startup and logout.
  }
}
