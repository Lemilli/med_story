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
        isConfirmed: const Value(true),
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
        isConfirmed: const Value(true),
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
}
