import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/core/storage/local_database.dart';
import 'package:med_story/features/events/data/event_api.dart';
import 'package:med_story/features/events/data/event_repository.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventApi extends Mock implements EventApi {}

void main() {
  late LocalDatabase database;
  late _MockEventApi api;

  setUp(() {
    database = LocalDatabase.forTesting(NativeDatabase.memory());
    api = _MockEventApi();
  });

  tearDown(() async {
    await database.close();
  });

  test('confirmEvent stores the confirmed AI event in cache', () async {
    final repository = EventRepository(api: api, database: database);
    final confirmed = _event(isConfirmed: true);

    when(() => api.confirmEvent('event-1')).thenAnswer((_) async => confirmed);

    final result = await repository.confirmEvent('event-1');
    final cached = await database.watchEvents(subjectId: 'subject-1').first;

    expect(result.isConfirmed, isTrue);
    expect(cached, hasLength(1));
    expect(cached.single.id, 'event-1');
    expect(cached.single.isConfirmed, isTrue);
  });
}

MedicalEvent _event({required bool isConfirmed}) {
  return MedicalEvent(
    id: 'event-1',
    eventType: MedicalEventType.examination,
    title: 'CRP measurement',
    description: 'CRP was elevated.',
    eventDate: '2026-05-12',
    attributes: const {
      'measurements': [
        {'label': 'CRP', 'value': '12 mg/L'},
      ],
    },
    source: EventSource.aiDocument,
    sourceDocumentId: 'document-1',
    confidence: 0.92,
    isConfirmed: isConfirmed,
    tags: const ['Lab'],
    subjectId: 'subject-1',
    createdAt: DateTime.utc(2026, 6),
    updatedAt: DateTime.utc(2026, 6, 1, 0, 1),
  );
}
