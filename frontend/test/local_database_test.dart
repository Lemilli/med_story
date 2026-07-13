import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/storage/local_database.dart';

void main() {
  late LocalDatabase database;

  setUp(() {
    database = LocalDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('watches cached events by subject and type', () async {
    final now = DateTime.utc(2026, 6);
    await database.upsertEvents([
      CachedMedicalEventsCompanion(
        id: const Value('event-1'),
        subjectId: const Value('subject-1'),
        eventType: const Value('symptom'),
        title: const Value('Pain flare'),
        description: const Value(''),
        eventDate: const Value('2026-06-01'),
        attributesJson: Value(encodeJson(<String, dynamic>{})),
        source: const Value('user_manual'),
        tagsJson: Value(encodeJson(<String>['IBS'])),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncedAt: Value(now),
      ),
      CachedMedicalEventsCompanion(
        id: const Value('event-2'),
        subjectId: const Value('subject-2'),
        eventType: const Value('medication'),
        title: const Value('Started medicine'),
        description: const Value(''),
        eventDate: const Value('2026-06-02'),
        attributesJson: Value(encodeJson(<String, dynamic>{})),
        source: const Value('user_manual'),
        tagsJson: Value(encodeJson(<String>[])),
        createdAt: Value(now),
        updatedAt: Value(now),
        syncedAt: Value(now),
      ),
    ]);

    final events = await database
        .watchEvents(subjectId: 'subject-1', types: const {'symptom'})
        .first;

    expect(events, hasLength(1));
    expect(events.single.id, 'event-1');
    expect(events.single.subjectId, 'subject-1');
  });

  test('caches current summaries and removes them with subject data', () async {
    final now = DateTime.utc(2026, 6);
    await database.upsertSummaries([
      CachedMedicalSummariesCompanion(
        id: const Value('summary-1'),
        subjectId: const Value('subject-1'),
        version: const Value(1),
        isCurrent: const Value(true),
        contentJson: Value(
          encodeJson(<String, dynamic>{
            'key_symptoms': ['Pain flare'],
          }),
        ),
        narrativeText: const Value('Patient has recurring pain flares.'),
        language: const Value('en'),
        generatedFromEventCount: const Value(3),
        createdAt: Value(now),
        syncedAt: Value(now),
      ),
    ]);

    final summary = await database.getCurrentSummary('subject-1');
    expect(summary?.id, 'summary-1');

    await database.removeSubject('subject-1');
    final removed = await database.getCurrentSummary('subject-1');
    expect(removed, null);
  });
}
