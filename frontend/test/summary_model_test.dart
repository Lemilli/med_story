import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/features/summary/domain/medical_summary.dart';

void main() {
  test('parses medical summary and regeneration response', () {
    final summary = MedicalSummary.fromJson({
      'id': 'summary-1',
      'subject_id': 'subject-1',
      'version': 3,
      'is_current': true,
      'content': {
        'key_symptoms': ['Pain flare'],
        'medications': [
          {'name': 'Medicine A', 'status': 'current'},
        ],
      },
      'narrative_text': 'Patient has a long-term symptom history.',
      'language': 'en',
      'generated_from_event_count': 12,
      'created_at': '2026-06-01T10:00:00Z',
    });
    final regenerate = SummaryRegenerateResult.fromJson({
      'job_id': 'job-1',
      'status': 'queued',
    });

    expect(summary.id, 'summary-1');
    expect(summary.subjectId, 'subject-1');
    expect(summary.version, 3);
    expect(summary.isCurrent, isTrue);
    expect(summary.content['key_symptoms'], isA<List<dynamic>>());
    expect(summary.narrativeText, contains('long-term'));
    expect(summary.generatedFromEventCount, 12);
    expect(summary.createdAt, DateTime.utc(2026, 6, 1, 10));
    expect(regenerate.jobId, 'job-1');
    expect(regenerate.status, 'queued');
  });
}
