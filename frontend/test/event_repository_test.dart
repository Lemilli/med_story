import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/storage/local_database.dart';
import 'package:med_story/features/events/data/event_api.dart';
import 'package:med_story/features/events/data/event_repository.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventApi extends Mock implements EventApi {}

void main() {
  test('getEvent falls back to cached source details when offline', () async {
    final api = _MockEventApi();
    final database = LocalDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = EventRepository(api: api, database: database);
    final event = MedicalEvent(
      id: 'event-1',
      eventType: MedicalEventType.examination,
      title: 'Vitamin D test',
      eventDate: '2026-05-01',
      source: EventSource.aiDocument,
      sourceDocumentId: 'document-1',
      sourceText: 'Local source text',
      sourceAssetCount: 3,
      sourcePagePositions: const [2],
      subjectId: 'subject-1',
      createdAt: DateTime.utc(2026, 5),
      updatedAt: DateTime.utc(2026, 5),
    );

    when(() => api.getEvent('event-1')).thenAnswer((_) async => event);
    await repository.getEvent('event-1');
    when(() => api.getEvent('event-1')).thenThrow(Exception('offline'));

    final cached = await repository.getEvent('event-1');

    expect(cached.title, 'Vitamin D test');
    expect(cached.sourceText, 'Local source text');
    expect(cached.sourceAssetCount, 3);
    expect(cached.sourcePagePositions, [2]);
  });
}
