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
        'important_test_results': [
          {
            'text': 'Vitamin D low — 11.7 ng/mL · ref. 30–100',
            'detail': '',
            'sources': [
              {
                'event_id': 'event-1',
                'title': 'Vitamin D test',
                'event_date': '2020-10-16',
                'document_title': 'Lab report',
                'source_page_positions': [2],
              },
            ],
          },
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
    final item = SummaryItem.fromJson(
      Map<String, dynamic>.from(
        (summary.content['important_test_results'] as List).single as Map,
      ),
    );
    expect(item.text, contains('11.7 ng/mL'));
    expect(item.sources.single.eventId, 'event-1');
    expect(item.sources.single.sourcePagePositions, [2]);
    expect(summary.narrativeText, contains('long-term'));
    expect(summary.generatedFromEventCount, 12);
    expect(summary.createdAt, DateTime.utc(2026, 6, 1, 10));
    expect(regenerate.jobId, 'job-1');
    expect(regenerate.status, 'queued');
  });
}
