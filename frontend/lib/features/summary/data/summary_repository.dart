import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/storage/local_database.dart' as db;
import '../domain/medical_summary.dart';
import 'summary_api.dart';
import 'summary_cache_mapper.dart';

final summaryShareServiceProvider = Provider<SummaryShareService>((ref) {
  return const PlatformSummaryShareService();
});

final summaryRepositoryProvider = Provider<SummaryRepository>((ref) {
  return SummaryRepository(
    api: ref.watch(summaryApiProvider),
    database: ref.watch(db.localDatabaseProvider),
    shareService: ref.watch(summaryShareServiceProvider),
  );
});

class SummaryRepository {
  const SummaryRepository({
    required this.api,
    required this.database,
    required this.shareService,
  });

  final SummaryApi api;
  final db.LocalDatabase database;
  final SummaryShareService shareService;

  Future<SummaryLoadResult> getCurrentSummary({
    required String subjectId,
    bool refresh = true,
  }) async {
    final cached = await database.getCurrentSummary(subjectId);
    if (!refresh && cached != null) {
      return SummaryLoadResult.ready(cached.toDomain(), fromCache: true);
    }

    try {
      final remote = await api.getCurrentSummary(subjectId: subjectId);
      await database.upsertSummaries([remote.toCacheCompanion()]);
      return SummaryLoadResult.ready(remote);
    } on SummaryNotReady {
      return const SummaryLoadResult.notReady();
    } on Object {
      if (cached != null) {
        return SummaryLoadResult.ready(cached.toDomain(), fromCache: true);
      }
      rethrow;
    }
  }

  Future<List<MedicalSummary>> listVersions({required String subjectId}) async {
    final cached = await database.getSummaryVersions(subjectId);
    try {
      final remote = await api.listVersions(subjectId: subjectId);
      await database.upsertSummaries(
        remote.map((summary) => summary.toCacheCompanion()),
      );
      return remote;
    } on Object {
      if (cached.isNotEmpty) {
        return cached.map((summary) => summary.toDomain()).toList();
      }
      rethrow;
    }
  }

  Future<SummaryRegenerateResult> regenerate({required String subjectId}) {
    return api.regenerateSummary(subjectId: subjectId);
  }

  Future<void> exportPdf({required String subjectId}) async {
    final bytes = await api.exportPdf(subjectId: subjectId);
    await shareService.sharePdf(bytes);
  }
}

abstract interface class SummaryShareService {
  Future<void> sharePdf(Uint8List bytes);
}

class PlatformSummaryShareService implements SummaryShareService {
  const PlatformSummaryShareService();

  @override
  Future<void> sharePdf(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, 'medstory-summary.pdf'));
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        fileNameOverrides: const ['medstory-summary.pdf'],
      ),
    );
  }
}

class SummaryLoadResult {
  const SummaryLoadResult._({this.summary, this.fromCache = false});

  const SummaryLoadResult.ready(
    MedicalSummary summary, {
    bool fromCache = false,
  }) : this._(summary: summary, fromCache: fromCache);

  const SummaryLoadResult.notReady() : this._();

  final MedicalSummary? summary;
  final bool fromCache;

  bool get isReady => summary != null;
}
