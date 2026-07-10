import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'privacy_api.dart';

final privacyShareServiceProvider = Provider<PrivacyShareService>((ref) {
  return const PlatformPrivacyShareService();
});

final privacyRepositoryProvider = Provider<PrivacyRepository>((ref) {
  return PrivacyRepository(
    api: ref.watch(privacyApiProvider),
    shareService: ref.watch(privacyShareServiceProvider),
  );
});

class PrivacyRepository {
  const PrivacyRepository({required this.api, required this.shareService});

  final PrivacyApi api;
  final PrivacyShareService shareService;

  Future<void> exportAndShareData() async {
    final payload = await api.exportData();
    await shareService.shareJson(payload);
  }
}

abstract interface class PrivacyShareService {
  Future<void> shareJson(Map<String, dynamic> payload);
}

class PlatformPrivacyShareService implements PrivacyShareService {
  const PlatformPrivacyShareService();

  @override
  Future<void> shareJson(Map<String, dynamic> payload) async {
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, 'medstory-privacy-export.json'));
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(payload), flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        fileNameOverrides: const ['medstory-privacy-export.json'],
      ),
    );
  }
}
