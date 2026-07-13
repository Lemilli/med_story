import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/features/events/domain/medical_event.dart';

void main() {
  test('parses backend medical event JSON', () {
    final event = MedicalEvent.fromJson({
      'id': 'event-1',
      'event_type': 'treatment_outcome',
      'title': 'Mesalazine helped',
      'description': 'Symptoms improved after two weeks.',
      'event_date': '2026-06-01',
      'event_end_date': null,
      'attributes': {'effectiveness': 'improved'},
      'source': 'user_manual',
      'source_document_id': null,
      'confidence': null,
      'tags': ['IBS', 'flare'],
      'subject_id': 'subject-1',
      'created_at': '2026-06-01T10:00:00Z',
      'updated_at': '2026-06-01T10:00:00Z',
    });

    expect(event.eventType, MedicalEventType.treatmentOutcome);
    expect(event.source, EventSource.userManual);
    expect(event.tags, ['IBS', 'flare']);
    expect(event.attributes['effectiveness'], 'improved');
    expect(event.subjectId, 'subject-1');
  });
}
