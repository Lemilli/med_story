// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MedStory';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navCapture => 'Capture';

  @override
  String get navSummary => 'Summary';

  @override
  String get navSettings => 'Settings';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get timelineMessage =>
      'Your confirmed medical story will appear here.';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get summaryMessage =>
      'Doctor-ready summaries and exports will live here.';

  @override
  String get summaryHeadline => 'Doctor summary';

  @override
  String summarySubjectLabel(String name) {
    return 'For $name';
  }

  @override
  String get summaryNoSubjectMessage =>
      'MedStory could not load a profile for this summary.';

  @override
  String get summaryBoundaryNote =>
      'MedStory organizes your information; it does not diagnose or recommend treatment.';

  @override
  String get summaryOfflineNotice =>
      'Showing the saved summary. Refresh when you are back online.';

  @override
  String get summaryRefreshAction => 'Refresh summary';

  @override
  String get summaryRegenerateAction => 'Regenerate summary';

  @override
  String get summaryGenerateAction => 'Generate summary';

  @override
  String get summaryPrepareVisitAction => 'Prepare for visit';

  @override
  String get summaryNotReadyTitle => 'No summary yet';

  @override
  String get summaryNotReadyMessage =>
      'Generate a doctor-ready summary from your confirmed timeline events when you need to prepare for a visit.';

  @override
  String get summaryNarrativeTitle => 'Doctor-ready narrative';

  @override
  String get summaryNoNarrativeMessage =>
      'No narrative text was returned for this summary.';

  @override
  String summaryGeneratedAt(String date) {
    return 'Generated $date';
  }

  @override
  String summaryVersionLabel(int version) {
    return 'Version $version';
  }

  @override
  String summaryEventCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count confirmed events',
      one: '1 confirmed event',
      zero: 'No confirmed events',
    );
    return '$_temp0';
  }

  @override
  String get summaryReturnToCurrentAction => 'Return to current summary';

  @override
  String get summaryVersionHistoryAction => 'Version history';

  @override
  String get summaryCurrentVersionLabel => 'Current';

  @override
  String get summaryHistorySearchTitle => 'Search history';

  @override
  String get summaryHistorySearchLabel => 'Search timeline events';

  @override
  String get summaryHistorySearchEmptyHint =>
      'Search your saved timeline to review details while preparing for a visit.';

  @override
  String get summaryHistorySearchNoResults => 'No matching events found.';

  @override
  String get summaryHistorySearchFailedMessage =>
      'We could not refresh matching events. Saved results may still appear.';

  @override
  String get summaryRegenerateQueuedMessage =>
      'Summary generation has started. Pull to refresh in a moment.';

  @override
  String get summaryExportSharedMessage => 'Summary export is ready to share.';

  @override
  String get summaryRegenerateFailedMessage =>
      'We could not start summary generation. Check your connection and try again.';

  @override
  String get summaryExportFailedMessage =>
      'We could not prepare the summary export. Check your connection and try again.';

  @override
  String get summaryActionFailedMessage =>
      'We could not complete that action. Try again.';

  @override
  String get summaryLoadFailedMessage => 'We could not load this summary.';

  @override
  String get summarySectionKeySymptoms => 'Key symptoms';

  @override
  String get summarySectionMajorDiagnoses => 'Major diagnoses';

  @override
  String get summarySectionMedications => 'Medications';

  @override
  String get summarySectionProcedures => 'Procedures';

  @override
  String get summarySectionHospitalizations => 'Hospitalizations';

  @override
  String get summarySectionAllergies => 'Allergies';

  @override
  String get summarySectionTestResults => 'Test results';

  @override
  String get summarySectionTreatmentOutcomes => 'Treatment outcomes';

  @override
  String get summarySectionOpenQuestions => 'Open questions';

  @override
  String get summarySectionCareTeam => 'Care team';

  @override
  String summaryUnknownSectionTitle(String name) {
    return '$name';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMessage =>
      'Privacy, account, subjects, and locale settings.';

  @override
  String get captureHeadline => 'Add to your story';

  @override
  String get captureSubtitle =>
      'Capture what you remember. You can organize it later.';

  @override
  String get recordVoiceTitle => 'Record voice';

  @override
  String get recordVoiceDescription =>
      'Speak a memory, symptom update, or treatment note.';

  @override
  String get recordVoiceDeferredDescription =>
      'Voice capture comes later. Use a document, photo, or file for now.';

  @override
  String get recordVoiceSemanticHint =>
      'Starts a voice capture. You can review before saving.';

  @override
  String get recordVoiceDeferredSemanticHint =>
      'Voice capture is planned for a later phase.';

  @override
  String get voiceCaptureTitle => 'Voice capture';

  @override
  String get voiceCaptureMessage =>
      'Microphone recording will be wired to the capture controller next.';

  @override
  String get voiceCaptureDeferredMessage =>
      'Voice capture is deferred until the voice-first phase.';

  @override
  String get scanDocumentTitle => 'Scan document';

  @override
  String get scanDocumentDescription =>
      'Use the camera for records, reports, prescriptions, or letters.';

  @override
  String get scanDocumentSemanticHint =>
      'Opens the camera to capture a medical document.';

  @override
  String get documentScanTitle => 'Document scan';

  @override
  String get documentScanMessage =>
      'Camera and file capture will be wired to the upload flow next.';

  @override
  String get writeNoteTitle => 'Write a note';

  @override
  String get writeNoteDescription =>
      'Type thoughts, questions, or details you remember.';

  @override
  String get writeNoteDeferredDescription =>
      'Text notes stay manual for now. Add timeline events from the Timeline tab.';

  @override
  String get writeNoteSemanticHint => 'Opens a text note capture.';

  @override
  String get writeNoteDeferredSemanticHint =>
      'Text note capture is planned for a later phase.';

  @override
  String get textNoteTitle => 'Text note';

  @override
  String get textNoteMessage =>
      'Manual note entry will be added to this flow next.';

  @override
  String get textNoteDeferredMessage =>
      'For Phase 2, document ingestion handles photos and files. Manual notes stay in timeline events.';

  @override
  String get addPhotoTitle => 'Add photo or file';

  @override
  String get addPhotoDescription =>
      'Choose a document image from your photo library.';

  @override
  String get addPhotoSemanticHint =>
      'Opens the photo library to choose a document image.';

  @override
  String get chooseFileTitle => 'Choose PDF or image';

  @override
  String get chooseFileDescription => 'Upload a PDF, PNG, or JPEG up to 5 MB.';

  @override
  String get chooseFileSemanticHint =>
      'Opens file selection for a PDF or image document.';

  @override
  String get photoOrFileTitle => 'Photo or file';

  @override
  String get photoOrFileMessage =>
      'Gallery and file picker support will be connected next.';

  @override
  String get documentSelectionEmpty =>
      'Choose a camera photo, gallery image, or PDF/image file. MedStory will start processing it automatically.';

  @override
  String get documentProcessingTitle => 'Processing upload';

  @override
  String get documentReviewTitle => 'Selected document';

  @override
  String get documentUntitledTitle => 'Document';

  @override
  String get documentTitleLabel => 'Document title';

  @override
  String get documentTypeLabel => 'Document type';

  @override
  String get documentDateLabel => 'Document date';

  @override
  String get documentDateAddAction => 'Add document date';

  @override
  String documentDateSelected(String date) {
    return 'Document date: $date';
  }

  @override
  String get documentDefaultSubject =>
      'This document will use your default timeline profile.';

  @override
  String documentSelectedSubject(String name) {
    return 'This document will be added to $name.';
  }

  @override
  String documentFileMetadata(String mimeType, String size) {
    return '$mimeType • $size';
  }

  @override
  String get documentViewResultAction => 'View result';

  @override
  String get documentRetryAction => 'Try again';

  @override
  String get documentUploadAction => 'Upload and process';

  @override
  String get documentUploadIdle => 'Choose a file to start processing.';

  @override
  String get documentUploadUploading =>
      'Saving locally and uploading for one-time processing...';

  @override
  String get documentUploadProcessing =>
      'Extracting text and suggested events. You can leave this screen after it finishes.';

  @override
  String get documentUploadProcessed =>
      'Processing complete. You can view the result now.';

  @override
  String get documentUploadFailedMessage =>
      'We could not process this document. Check the file and try again.';

  @override
  String get documentFileTooLargeMessage =>
      'Choose a file that is 5 MB or smaller.';

  @override
  String get documentUnsupportedFileMessage =>
      'Phase 2 supports PDFs and images only.';

  @override
  String get documentProcessingFailedMessage =>
      'Processing failed. The original file remains on this device.';

  @override
  String get documentProcessingTimeoutMessage =>
      'Processing is taking longer than expected. Open the document again to refresh its status.';

  @override
  String get documentSourceMissingMessage =>
      'MedStory could not find the selected file on this device.';

  @override
  String get documentDetailTitle => 'Document detail';

  @override
  String get documentDateUnknown => 'No date set';

  @override
  String get documentMimeTypeLabel => 'File type';

  @override
  String get documentStorageLabel => 'Storage';

  @override
  String get documentLocalOnlyValue => 'Original saved on this device only';

  @override
  String get documentRemoteStorageValue => 'Stored remotely';

  @override
  String get documentExtractedTextLabel => 'Extracted text';

  @override
  String get documentAvailableValue => 'Available';

  @override
  String get documentNotAvailableValue => 'Not available';

  @override
  String get documentEventCountLabel => 'Suggested events';

  @override
  String documentEventCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String get documentCreatedAtLabel => 'Created';

  @override
  String get documentUpdatedAtLabel => 'Updated';

  @override
  String get documentDetailProcessingNote =>
      'Processing is still running. Pull to refresh this status.';

  @override
  String get documentDetailPrivacyNote =>
      'The original document stays in the app sandbox. The backend processes uploaded bytes transiently and returns only metadata and suggested events.';

  @override
  String get documentExplanationTitle => 'Plain-language explanation';

  @override
  String get documentExplanationSummaryTitle => 'Summary';

  @override
  String get documentExplanationKeyPointsTitle => 'Key points';

  @override
  String get documentExplanationGlossaryTitle => 'Glossary';

  @override
  String get documentExplanationLoading => 'Loading the explanation...';

  @override
  String get documentExplanationNotReadyMessage =>
      'No explanation is ready yet. MedStory can generate a plain-language version from the extracted text.';

  @override
  String get documentExplanationBoundaryNote =>
      'This explanation helps you understand the document. It does not diagnose or recommend treatment.';

  @override
  String get documentExplanationGenerateAction => 'Generate explanation';

  @override
  String get documentExplanationRegenerateAction => 'Regenerate explanation';

  @override
  String get documentExplanationQueuedAction => 'Queued';

  @override
  String get documentExplanationRetryAction => 'Try again';

  @override
  String get documentExplanationQueuedMessage =>
      'Explanation generation has started. Pull to refresh this document in a moment.';

  @override
  String get documentExplanationLoadFailed =>
      'We could not load this explanation. Check your connection and try again.';

  @override
  String get documentExplanationRegenerateFailed =>
      'We could not start explanation generation. Check your connection and try again.';

  @override
  String documentExplanationGeneratedAt(String date) {
    return 'Generated $date';
  }

  @override
  String get documentDeleteAction => 'Delete document';

  @override
  String get documentDeleteConfirmTitle => 'Delete this document?';

  @override
  String get documentDeleteConfirmMessage =>
      'Its derived events may also be removed from your timeline.';

  @override
  String get documentOpenTimelineAction => 'Open timeline';

  @override
  String get documentStatusPending => 'Pending';

  @override
  String get documentStatusProcessing => 'Processing';

  @override
  String get documentStatusProcessed => 'Processed';

  @override
  String get documentStatusFailed => 'Failed';

  @override
  String get documentTypeMedicalRecord => 'Medical record';

  @override
  String get documentTypeLabResult => 'Lab result';

  @override
  String get documentTypeReport => 'Report';

  @override
  String get documentTypePrescription => 'Prescription';

  @override
  String get documentTypeProcedureSummary => 'Procedure summary';

  @override
  String get documentTypeNote => 'Note';

  @override
  String get documentTypeImage => 'Image';

  @override
  String get documentTypeAudio => 'Audio';

  @override
  String get documentTypeOther => 'Other';

  @override
  String get privacyPanelSemanticLabel =>
      'Private to you. You review AI suggestions before they join your timeline.';

  @override
  String get privacyPanelTitle => 'Private to you';

  @override
  String get privacyPanelDescription =>
      'You review AI suggestions before they join your timeline.';

  @override
  String get boundaryNote =>
      'MedStory organizes your information; it does not diagnose.';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle =>
      'Sign in to keep building your medical story.';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle =>
      'Start with a private place for your medical history.';

  @override
  String get authBoundarySemanticLabel =>
      'MedStory is an organizer, not a diagnostic tool.';

  @override
  String get authBoundaryNote =>
      'MedStory helps organize and explain information. It does not diagnose or recommend treatment.';

  @override
  String get authFullNameLabel => 'Full name';

  @override
  String get authFullNameHelper =>
      'Optional, used only to personalize your account.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHelper => 'Use at least 8 characters.';

  @override
  String get authEmailValidation => 'Enter a valid email address.';

  @override
  String get authPasswordValidation => 'Enter at least 8 characters.';

  @override
  String get authCreateAccountAction => 'Create account';

  @override
  String get authLoginAction => 'Log in';

  @override
  String get authAlreadyHaveAccountAction => 'I already have an account';

  @override
  String get authNeedAccountAction => 'Create a new account';

  @override
  String get authLogoutAction => 'Log out';

  @override
  String get authFailedMessage =>
      'Check your email and password, then try again.';

  @override
  String get authEmailAlreadyExistsMessage =>
      'This email already has a MedStory account. Log in instead, or use another email.';

  @override
  String get authInvalidEmailMessage =>
      'Enter a valid email address. Example: name@example.com';

  @override
  String get authEmailRequiredMessage =>
      'Enter your email address to create an account.';

  @override
  String get authPasswordNotAcceptedMessage =>
      'Choose a stronger password. Use at least 8 characters and avoid common passwords.';

  @override
  String get authRegisterFailedMessage =>
      'We could not create your account. Check your details and try again.';

  @override
  String get networkFailedMessage =>
      'We could not reach MedStory. Check your connection and try again.';

  @override
  String get authCheckingSession => 'Checking your session';

  @override
  String get authMePanelTitle => 'Account from /me';

  @override
  String get authLocaleLabel => 'Locale';

  @override
  String get authUnnamedUser => 'No name set';

  @override
  String pendingActionMessage(String title, String message) {
    return '$title: $message';
  }

  @override
  String get timelineHeadline => 'Your medical story';

  @override
  String get timelineSubtitle =>
      'Browse the events you have saved, newest first.';

  @override
  String get timelineEmptyTitle => 'Start with one event';

  @override
  String get timelineEmptyMessage =>
      'Add a symptom, medication, diagnosis, procedure, or note you want to remember.';

  @override
  String get timelineNoSubjectTitle => 'No subject found';

  @override
  String get timelineNoSubjectMessage =>
      'MedStory could not load a profile for this timeline.';

  @override
  String get timelineAddEvent => 'Add';

  @override
  String get timelineSearchLabel => 'Search title or description';

  @override
  String get timelineFiltersAction => 'Filters';

  @override
  String get timelineAllTypes => 'All types';

  @override
  String get timelineOfflineNotice =>
      'Showing saved timeline items. Refresh when you are back online.';

  @override
  String get timelineLoadMore => 'Load more';

  @override
  String get timelineRefresh => 'Refresh timeline';

  @override
  String get subjectSwitcherLabel => 'Timeline subject';

  @override
  String get subjectDefaultLabel => 'Default';

  @override
  String get eventTypeSymptom => 'Symptom';

  @override
  String get eventTypeDiagnosis => 'Diagnosis';

  @override
  String get eventTypeMedication => 'Medication';

  @override
  String get eventTypeExamination => 'Examination';

  @override
  String get eventTypeProcedure => 'Procedure';

  @override
  String get eventTypeHospitalization => 'Hospitalization';

  @override
  String get eventTypeTreatmentOutcome => 'Treatment outcome';

  @override
  String get eventTypeNote => 'Note';

  @override
  String get eventNewTitle => 'Add event';

  @override
  String get eventEditTitle => 'Edit event';

  @override
  String get eventDetailTitle => 'Event detail';

  @override
  String get eventTitleLabel => 'Title';

  @override
  String get eventDescriptionLabel => 'Description';

  @override
  String get eventTypeLabel => 'Event type';

  @override
  String get eventDateLabel => 'Event date';

  @override
  String get eventEndDateLabel => 'End date';

  @override
  String get eventTagsLabel => 'Tags';

  @override
  String get eventTagsHelper => 'Separate tags with commas.';

  @override
  String get eventAttributesLabel => 'Structured details';

  @override
  String get eventAttributesHelper =>
      'Optional JSON object for details such as dose, severity, or result.';

  @override
  String get eventCreateAction => 'Save event';

  @override
  String get eventSaveAction => 'Save changes';

  @override
  String get eventEditAction => 'Edit';

  @override
  String get eventDeleteAction => 'Delete';

  @override
  String get eventDeleteConfirmTitle => 'Delete this event?';

  @override
  String get eventDeleteConfirmMessage =>
      'It will be removed from your timeline.';

  @override
  String get eventCancelAction => 'Cancel';

  @override
  String get eventRequiredValidation => 'This field is required.';

  @override
  String get eventInvalidJsonValidation =>
      'Enter a valid JSON object or leave this empty.';

  @override
  String get eventBoundaryNote =>
      'MedStory organizes your information; it does not diagnose or recommend treatment.';

  @override
  String get eventUnconfirmedBadge => 'Needs review';

  @override
  String get eventConfirmedBadge => 'Confirmed';

  @override
  String get eventConfirmAction => 'Confirm event';

  @override
  String get eventConfirmedMessage => 'Event confirmed.';

  @override
  String get eventAiSuggestedNote =>
      'AI suggested this event from a document. Review it before relying on it.';

  @override
  String get eventAiConfirmedNote => 'You confirmed this AI-suggested event.';

  @override
  String get eventResultTitle => 'Result';

  @override
  String get eventNotesTitle => 'Notes';

  @override
  String get eventStructuredDetailsTitle => 'Details';

  @override
  String eventConfidenceValue(String value) {
    return 'Extraction confidence: $value';
  }

  @override
  String get eventOpenSourceDocumentAction => 'Open source document';

  @override
  String get eventDetailsEmptyDescription => 'No description added.';

  @override
  String get eventNetworkRequired =>
      'Saving changes requires a connection to MedStory.';
}
