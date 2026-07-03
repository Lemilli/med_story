import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/storage/local_database.dart';
import 'package:med_story/features/summary/data/summary_api.dart';
import 'package:med_story/features/summary/data/summary_repository.dart';
import 'package:med_story/features/summary/domain/medical_summary.dart';
import 'package:mocktail/mocktail.dart';

class _MockSummaryApi extends Mock implements SummaryApi {}

class _FakeShareService implements SummaryShareService {
  Uint8List? sharedBytes;

  @override
  Future<void> sharePdf(Uint8List bytes) async {
    sharedBytes = bytes;
  }
}

void main() {
  late _MockSummaryApi api;
  late LocalDatabase database;
  late _FakeShareService shareService;
  late SummaryRepository repository;

  setUp(() {
    api = _MockSummaryApi();
    database = LocalDatabase.forTesting(NativeDatabase.memory());
    shareService = _FakeShareService();
    repository = SummaryRepository(
      api: api,
      database: database,
      shareService: shareService,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('loads current summary and caches it', () async {
    when(
      () => api.getCurrentSummary(subjectId: 'subject-1'),
    ).thenAnswer((_) async => _summary(version: 1));

    final result = await repository.getCurrentSummary(subjectId: 'subject-1');
    final cached = await database.getCurrentSummary('subject-1');

    expect(result.isReady, isTrue);
    expect(result.fromCache, isFalse);
    expect(result.summary?.version, 1);
    expect(cached?.id, 'summary-1');
  });

  test('not-ready summary is a normal load state', () async {
    when(
      () => api.getCurrentSummary(subjectId: 'subject-1'),
    ).thenThrow(const SummaryNotReady());

    final result = await repository.getCurrentSummary(subjectId: 'subject-1');

    expect(result.isReady, isFalse);
    expect(result.summary, isNull);
  });

  test('falls back to cached current summary on network failure', () async {
    when(
      () => api.getCurrentSummary(subjectId: 'subject-1'),
    ).thenAnswer((_) async => _summary(version: 2));
    await repository.getCurrentSummary(subjectId: 'subject-1');

    when(
      () => api.getCurrentSummary(subjectId: 'subject-1'),
    ).thenThrow(Exception('offline'));

    final result = await repository.getCurrentSummary(subjectId: 'subject-1');

    expect(result.isReady, isTrue);
    expect(result.fromCache, isTrue);
    expect(result.summary?.version, 2);
  });

  test('exports pdf bytes through the share service', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    when(
      () => api.exportPdf(subjectId: 'subject-1'),
    ).thenAnswer((_) async => bytes);

    await repository.exportPdf(subjectId: 'subject-1');

    expect(shareService.sharedBytes, bytes);
  });
}

MedicalSummary _summary({required int version}) {
  return MedicalSummary(
    id: 'summary-$version',
    subjectId: 'subject-1',
    version: version,
    isCurrent: true,
    content: const {
      'key_symptoms': ['Pain flare'],
    },
    narrativeText: 'Patient has recurring pain flares.',
    language: 'en',
    generatedFromEventCount: 3,
    createdAt: DateTime.utc(2026, 6, version),
  );
}
