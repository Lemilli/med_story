// Fictional medical history used only for opt-in README screenshots.
// No account, patient data, backend, or external AI service is involved.
import 'package:med_story/features/events/domain/medical_event.dart';

const readmeVisitReason = 'Review my migraine notes and recent test results.';

const readmeSummaryContent = <String, dynamic>{
  'current_concerns': [
    {
      'text': 'Recurring migraine notes',
      'detail': 'Two episodes recorded in October, with timing and context.',
      'source_event_ids': ['synthetic-event', 'demo-migraine-note'],
    },
  ],
  'important_test_results': [
    {
      'text': 'Annual blood test · 18 October',
      'detail': 'Report saved with the original document.',
      'source_event_ids': ['demo-blood-test'],
    },
  ],
};

final _stamp = DateTime.utc(2026, 10, 28, 9, 41);

final readmeEvents = [
  MedicalEvent(
    id: 'synthetic-event',
    eventType: MedicalEventType.symptom,
    title: 'Migraine after a busy day',
    description:
        'Headache began around 4 pm after a long day at my desk. '
        'Light sensitivity noted. Rested in a quiet room; symptoms eased by evening.',
    sourceText:
        'Migraine again around four today. I had been at my desk '
        'most of the afternoon and the light felt too bright. I rested in a '
        'quiet room. It eased by the evening. I want to mention the timing at my next visit.',
    source: EventSource.aiVoice,
    eventDate: '2026-10-24',
    tags: const ['Migraine', 'Personal note'],
    subjectId: 'synthetic-subject',
    createdAt: _stamp,
    updatedAt: _stamp,
  ),
  MedicalEvent(
    id: 'demo-blood-test',
    eventType: MedicalEventType.examination,
    title: 'Annual blood test',
    description: 'Routine laboratory report saved for my next visit.',
    source: EventSource.aiDocument,
    sourceDocumentId: 'synthetic-document',
    sourceAssetCount: 1,
    eventDate: '2026-10-18',
    subjectId: 'synthetic-subject',
    createdAt: _stamp,
    updatedAt: _stamp,
  ),
  MedicalEvent(
    id: 'demo-migraine-note',
    eventType: MedicalEventType.symptom,
    title: 'Morning migraine note',
    description: 'Woke with a headache. Recorded the time and duration.',
    eventDate: '2026-10-12',
    tags: const ['Migraine'],
    subjectId: 'synthetic-subject',
    createdAt: _stamp,
    updatedAt: _stamp,
  ),
  MedicalEvent(
    id: 'demo-follow-up',
    eventType: MedicalEventType.medicalRecord,
    title: 'Follow-up visit notes',
    description: 'Saved the visit record and questions for next time.',
    source: EventSource.aiDocument,
    eventDate: '2026-09-22',
    subjectId: 'synthetic-subject',
    createdAt: _stamp,
    updatedAt: _stamp,
  ),
  MedicalEvent(
    id: 'demo-questions',
    eventType: MedicalEventType.note,
    title: 'Questions about my migraine pattern',
    description: 'Bring my symptom notes and ask about tracking changes.',
    eventDate: '2026-09-06',
    subjectId: 'synthetic-subject',
    createdAt: _stamp,
    updatedAt: _stamp,
  ),
];
