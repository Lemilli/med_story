// Fictional type 2 diabetes history for opt-in README screenshots only.
// No account, patient data, backend, or external AI service is involved.
import 'package:med_story/features/documents/data/document_repository.dart';
import 'package:med_story/features/documents/domain/medical_document.dart';
import 'package:med_story/features/documents/presentation/controllers/document_controllers.dart';
import 'package:med_story/features/events/domain/medical_event.dart';

const readmeVisitReason =
    'New diabetes specialist: review my results and medication history.';

const readmeSummaryContent = <String, dynamic>{
  'current_concerns': [
    {
      'text': 'Tiredness around 3 pm, noted twice.',
      'detail': 'No glucose reading recorded; cause unknown.',
      'source_event_ids': ['demo-voice-note'],
    },
  ],
  'important_diagnoses_and_findings': [
    {
      'text': 'Type 2 diabetes · March 2024',
      'detail': 'Documented in the clinic letter.',
      'source_event_ids': ['demo-diagnosis'],
    },
  ],
  'current_medications': [
    {
      'text': 'Metformin · renewed 20 October',
      'detail': 'Prescriptions saved since March 2024.',
      'source_event_ids': [
        'demo-prescription-2026',
        'demo-prescription-2025',
        'demo-prescription-2024',
      ],
      'sources': [
        {
          'event_id': 'demo-prescription-2026',
          'title': 'Metformin prescription renewed',
          'event_date': '2026-10-20',
          'document_title': 'October prescription',
        },
        {
          'event_id': 'demo-prescription-2025',
          'title': 'Metformin prescription updated',
          'event_date': '2025-01-16',
          'document_title': 'January clinic letter',
        },
        {
          'event_id': 'demo-prescription-2024',
          'title': 'First metformin prescription',
          'event_date': '2024-03-14',
          'document_title': 'Initial diabetes visit',
        },
      ],
    },
  ],
  'important_test_results': [
    {
      'text': 'HbA1c: 7.1% · 24 October 2026',
      'detail': 'Earlier reports: 7.4% in July 2026; 7.8% in June 2025.',
      'source_event_ids': [
        'synthetic-event',
        'demo-hba1c-july',
        'demo-hba1c-2025',
      ],
      'sources': [
        {
          'event_id': 'synthetic-event',
          'title': 'HbA1c · 7.1%',
          'event_date': '2026-10-24',
          'document_title': 'October laboratory report',
        },
        {
          'event_id': 'demo-hba1c-july',
          'title': 'HbA1c · 7.4%',
          'event_date': '2026-07-22',
          'document_title': 'July laboratory report',
        },
        {
          'event_id': 'demo-hba1c-2025',
          'title': 'HbA1c · 7.8%',
          'event_date': '2025-06-19',
          'document_title': 'June laboratory report',
        },
      ],
    },
    {
      'text': 'Eye screening · 12 September 2026',
      'detail': 'The screening report is saved with its original document.',
      'source_event_ids': ['demo-eye-screening'],
    },
  ],
};

final readmeStamp = DateTime.utc(2026, 10, 28, 9, 41);

// Keep IDs, dates and results consistent across timeline, queue and summary.
final readmeEvents = [
  _event(
    'synthetic-event',
    MedicalEventType.examination,
    'HbA1c · 7.1%',
    '2026-10-24',
    description:
        'Glycated haemoglobin (HbA1c): 7.1%.\n\n'
        'Sample: venous blood\n'
        'Collected: 24 October 2026\n'
        'Laboratory: Northbridge Diagnostics\n'
        'Report: NB-261024-018\n\n'
        'Recorded from the October laboratory PDF. '
        'Reference ranges and laboratory comments '
        'can be checked in the original report.',
    documentId: 'synthetic-document',
    tags: const ['Diabetes'],
  ),
  _event(
    'demo-prescription-2026',
    MedicalEventType.medication,
    'Metformin prescription renewed',
    '2026-10-20',
    description:
        'Repeat prescription saved after my clinic visit. '
        'Bring the current prescription and earlier clinic letters '
        'to the new specialist.',
    documentId: 'demo-prescription-document-2026',
  ),
  _event(
    'demo-voice-note',
    MedicalEventType.symptom,
    'Tiredness in the afternoon',
    '2026-10-18',
    description:
        'Felt unusually tired around 3 pm on two days this week. '
        'No glucose reading recorded at those times. '
        'Wants to discuss the timing at the next visit.',
    source: EventSource.aiVoice,
    sourceText:
        'I felt really tired around three again today, like on Tuesday. '
        'I did not check my glucose then. '
        'Please keep this for my next diabetes visit '
        'because I always forget to mention it.',
    tags: const ['Personal note'],
  ),
  _event(
    'demo-eye-screening',
    MedicalEventType.examination,
    'Diabetic eye screening',
    '2026-09-12',
    description:
        'Annual eye-screening report saved from the screening service.',
    documentId: 'demo-eye-document',
  ),
  _event(
    'demo-specialist-questions',
    MedicalEventType.note,
    'Questions for the new specialist',
    '2026-08-28',
    description:
        'Bring my earlier HbA1c reports and prescriptions. '
        'Ask which records to keep between visits.',
  ),
  _event(
    'demo-hba1c-july',
    MedicalEventType.examination,
    'HbA1c · 7.4%',
    '2026-07-22',
    description: 'HbA1c: 7.4%. Sample collected on 22 July 2026.',
    documentId: 'demo-july-lab-document',
  ),
  _event(
    'demo-kidney-test',
    MedicalEventType.examination,
    'Kidney check · blood and urine tests',
    '2026-04-09',
    description: 'Blood and urine laboratory reports saved after the checkup.',
    documentId: 'demo-kidney-document',
  ),
  _event(
    'demo-annual-review',
    MedicalEventType.medicalRecord,
    'Annual diabetes review',
    '2025-11-06',
    description:
        'Visit letter saved with the medication list reviewed in clinic.',
    documentId: 'demo-review-document',
  ),
  _event(
    'demo-hba1c-2025',
    MedicalEventType.examination,
    'HbA1c · 7.8%',
    '2025-06-19',
    description: 'HbA1c: 7.8%. Sample collected on 19 June 2025.',
    documentId: 'demo-2025-lab-document',
  ),
  _event(
    'demo-prescription-2025',
    MedicalEventType.medication,
    'Metformin prescription updated',
    '2025-01-16',
    description:
        'Updated metformin prescription documented in the January clinic letter. '
        'Original letter saved for the medication history.',
    documentId: 'demo-prescription-document-2025',
  ),
  _event(
    'demo-hba1c-2024',
    MedicalEventType.examination,
    'HbA1c · 8.2%',
    '2024-03-14',
    description: 'HbA1c: 8.2%. Result recorded at the initial diabetes visit.',
    documentId: 'demo-initial-lab-document',
  ),
  _event(
    'demo-prescription-2024',
    MedicalEventType.medication,
    'First metformin prescription',
    '2024-03-14',
    description:
        'First metformin prescription recorded in the initial diabetes visit letter. '
        'The original prescription is saved with this record.',
    documentId: 'demo-prescription-document-2024',
  ),
  _event(
    'demo-diagnosis',
    MedicalEventType.diagnosis,
    'Type 2 diabetes documented',
    '2024-03-14',
    description: 'Type 2 diabetes documented by the clinician in the initial visit letter.',
    documentId: 'demo-diagnosis-document',
  ),
]..sort((a, b) => b.eventDate.compareTo(a.eventDate));

MedicalEvent _event(
  String id,
  MedicalEventType type,
  String title,
  String date, {
  required String description,
  String? documentId,
  EventSource? source,
  String? sourceText,
  List<String> tags = const [],
}) => MedicalEvent(
  id: id,
  eventType: type,
  title: title,
  description: description,
  source:
      source ??
      (documentId == null ? EventSource.userManual : EventSource.aiDocument),
  sourceDocumentId: documentId,
  sourceAssetCount: documentId == null ? 0 : 1,
  sourceText: sourceText,
  eventDate: date,
  tags: tags,
  subjectId: 'synthetic-subject',
  createdAt: readmeStamp,
  updatedAt: readmeStamp,
);

final readmeDocument = MedicalDocument(
  id: 'synthetic-document',
  title: 'HbA1c · October 2026',
  status: DocumentStatus.processed,
  docType: DocumentType.labResult,
  documentDate: '2026-10-24',
  mimeType: 'application/pdf',
  extractedTextAvailable: true,
  eventId: 'synthetic-event',
  eventCount: 1,
  assets: const [
    DocumentAssetMetadata(
      id: 'demo-october-lab-pdf',
      position: 0,
      fileName: 'HbA1c-October-2026.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 184320,
    ),
  ],
  createdAt: readmeStamp,
  updatedAt: readmeStamp,
);

// Queue fixtures represent adjacent moments in a batch of three uploads.
// They do not read local files or claim to exercise a picker or backend upload.
final readmeUploads = [
  _upload(
    'lab',
    'HbA1c · October 2026.pdf',
    UploadQueueStage.completed,
    documentId: 'synthetic-document',
  ),
  _upload('letter', 'Diabetes clinic letter.pdf', UploadQueueStage.processing),
  _upload(
    'prescription',
    'Metformin prescription.pdf',
    UploadQueueStage.uploading,
    progress: 0.64,
  ),
];

QueuedUpload _upload(
  String id,
  String name,
  UploadQueueStage stage, {
  String? documentId,
  double? progress,
}) => QueuedUpload(
  id: 'demo-upload-$id',
  ownerUserId: 'synthetic-user',
  displayName: name,
  fingerprint: 'demo-$id',
  localFiles: [
    StoredDocumentFile(
      path: '/synthetic/$id.pdf',
      fileName: name,
      mimeType: 'application/pdf',
      sizeBytes: 184320,
      localUriHint: 'sandbox://demo/$id.pdf',
    ),
  ],
  draft: DocumentUploadDraft(
    title: name,
    docType: DocumentType.other,
    sources: [
      DocumentSourceFile(
        path: '/synthetic/$id.pdf',
        fileName: name,
        mimeType: 'application/pdf',
      ),
    ],
    subjectId: 'synthetic-subject',
    language: 'en',
  ),
  stage: stage,
  documentId: documentId,
  uploadProgress: progress,
  createdAt: readmeStamp,
  updatedAt: readmeStamp,
);
