import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/features/documents/data/document_api.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';

void main() {
  test('parses document status and cursor pagination response', () {
    final page = DocumentPage.fromJson({
      'results': [
        {
          'id': 'document-1',
          'title': 'Lab results May',
          'doc_type': 'lab_result',
          'mime_type': 'application/pdf',
          'local_uri_hint': 'app://documents/lab.pdf',
          'size_bytes': 1024,
          'status': 'processed',
          'subject_id': 'subject-1',
          'document_date': '2026-05-12',
          'language': 'en',
          'local_only': true,
          'extracted_text_available': true,
          'explanation_available': false,
          'event_count': 1,
          'error_message': '',
          'created_at': '2026-06-01T10:00:00Z',
          'updated_at': '2026-06-01T10:01:00Z',
        },
      ],
      'next': 'http://localhost:8000/api/v1/documents?cursor=doc-cursor',
      'previous': null,
    });

    expect(page.results, hasLength(1));
    expect(page.results.single.docType, DocumentType.labResult);
    expect(page.results.single.status, DocumentStatus.processed);
    expect(page.results.single.extractedTextAvailable, isTrue);
    expect(page.results.single.eventCount, 1);
    expect(page.nextCursor, 'doc-cursor');
    expect(page.previousCursor, isNull);
  });

  test('parses document explanation and regeneration response', () {
    final explanation = DocumentExplanation.fromJson({
      'document_id': 'document-1',
      'summary_text': 'This lab result is mostly within the expected range.',
      'key_points': ['CRP is mildly elevated', 'Hemoglobin is normal'],
      'glossary': {'CRP': 'A marker that can rise with inflammation'},
      'language': 'en',
      'created_at': '2026-06-01T10:00:00Z',
    });
    final regenerate = ExplanationRegenerateResult.fromJson({
      'job_id': 'job-1',
      'status': 'queued',
    });

    expect(explanation.documentId, 'document-1');
    expect(explanation.summaryText, contains('lab result'));
    expect(explanation.keyPoints, hasLength(2));
    expect(explanation.glossary['CRP'], contains('inflammation'));
    expect(explanation.createdAt, DateTime.utc(2026, 6, 1, 10));
    expect(regenerate.jobId, 'job-1');
    expect(regenerate.status, 'queued');
  });
}
