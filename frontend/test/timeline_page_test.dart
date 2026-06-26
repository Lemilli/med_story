import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/features/events/domain/medical_event.dart';
import 'package:med_story/features/timeline/data/timeline_api.dart';

void main() {
  test('parses cursor pagination response', () {
    final page = TimelinePage.fromJson({
      'results': [
        {
          'id': 'event-1',
          'event_type': 'symptom',
          'title': 'Pain flare',
          'description': '',
          'event_date': '2026-06-01',
          'event_end_date': null,
          'attributes': <String, dynamic>{},
          'source': 'user_manual',
          'source_document_id': null,
          'confidence': null,
          'is_confirmed': true,
          'tags': <String>[],
          'subject_id': 'subject-1',
          'created_at': '2026-06-01T10:00:00Z',
          'updated_at': '2026-06-01T10:00:00Z',
        },
      ],
      'next': 'http://localhost:8000/api/v1/timeline?cursor=abc123&limit=20',
      'previous': null,
    });

    expect(page.results, hasLength(1));
    expect(page.results.single.eventType, MedicalEventType.symptom);
    expect(page.nextCursor, 'abc123');
    expect(page.previousCursor, isNull);
  });
}
