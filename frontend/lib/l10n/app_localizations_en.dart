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
  String get navTimeline => 'My Story';

  @override
  String get navCapture => 'Add';

  @override
  String get navSummary => 'For Visits';

  @override
  String get navSettings => 'Settings';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get timelineMessage => 'Your medical story will appear here.';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get summaryMessage =>
      'Doctor-ready summaries and exports will live here.';

  @override
  String get summaryHeadline => 'Prepare for a visit';

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
      'Generate a doctor-ready summary from your timeline events when you need to prepare for a visit.';

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
      other: '$count events',
      one: '1 event',
      zero: 'No events',
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
  String get settingsAccountSectionTitle => 'Account';

  @override
  String get settingsPrivacySectionTitle => 'Privacy';

  @override
  String get settingsLanguageSectionTitle => 'Language';

  @override
  String get settingsActionsSectionTitle => 'Account actions';

  @override
  String get settingsPrivacyNoteTitle => 'What stays here';

  @override
  String get settingsPrivacyNoteDescription =>
      'Original uploads are not stored on the server. Local timeline and summary caches are cleared when you log out or delete your account.';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsLocaleUpdatedMessage => 'Language updated.';

  @override
  String get settingsLocaleUpdateFailedMessage =>
      'We could not update the language. Check your connection and try again.';

  @override
  String get settingsDeleteAccountTitle => 'Delete account';

  @override
  String get settingsDeleteAccountDescription =>
      'Permanently delete your MedStory account and backend records.';

  @override
  String get settingsDeleteAccountAction => 'Delete account';

  @override
  String get settingsDeleteAccountDialogTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountDialogMessage =>
      'This permanently deletes your account and backend records.';

  @override
  String get settingsDeleteAccountConfirmLabel => 'Type DELETE to confirm';

  @override
  String get settingsDeleteAccountConfirmValue => 'DELETE';

  @override
  String get settingsDeleteAccountCancelAction => 'Cancel';

  @override
  String get settingsDeleteAccountConfirmAction => 'Delete permanently';

  @override
  String get settingsDeleteAccountFailedMessage =>
      'We could not delete your account. Check your connection and try again.';

  @override
  String get settingsLogoutDescription =>
      'Sign out on this device and clear local cached medical data.';

  @override
  String get settingsOrganizerNoticeTitle => 'Organizer, not a doctor';

  @override
  String get settingsOrganizerNoticeDescription =>
      'MedStory helps organize and explain your records. It does not diagnose, recommend treatment, or replace care from a clinician.';

  @override
  String get captureHeadline => 'Add to your story';

  @override
  String get captureSubtitle =>
      'Choose how you want to add something. You can review it before it becomes part of your story.';

  @override
  String get capturePrivacyNotice =>
      'Private to you. You review suggestions before they join your story. MedStory organizes your information; it does not diagnose.';

  @override
  String get recordVoiceTitle => 'Record voice';

  @override
  String get recordVoiceDescription =>
      'Speak a memory, symptom update, or treatment note.';

  @override
  String get recordVoiceSemanticHint =>
      'Starts a voice capture. You can review before saving.';

  @override
  String get voiceCaptureTitle => 'Voice capture';

  @override
  String get voiceCaptureMessage =>
      'Record a short voice note, review it, then upload it for suggested timeline events.';

  @override
  String get voiceNoteTitle => 'Voice note';

  @override
  String get voiceNoteCaptureLabel => 'Voice note';

  @override
  String get medicalPhotoCaptureLabel => 'Medical photo';

  @override
  String get voicePermissionRequesting => 'Checking microphone access';

  @override
  String get voicePermissionRequestingDescription =>
      'Your recording stays on this device until you choose to upload it.';

  @override
  String get voiceRecordingInProgress => 'Recording';

  @override
  String voiceRecordingDuration(String duration) {
    return 'Duration: $duration';
  }

  @override
  String get voiceStopAction => 'Stop';

  @override
  String get voiceDiscardAction => 'Discard';

  @override
  String get voiceReviewTitle => 'Review voice note';

  @override
  String voiceRecordedMetadata(String duration, String size) {
    return '$duration • $size';
  }

  @override
  String get voiceRecordAgainAction => 'Record again';

  @override
  String get voiceUploadAction => 'Upload voice note';

  @override
  String get voiceRecordingMaxDurationMessage =>
      'Recording stopped at 4 minutes to keep the upload small.';

  @override
  String get voiceFileTooLargeMessage =>
      'Record a shorter voice note. Audio uploads must be 5 MB or smaller.';

  @override
  String get voicePermissionDeniedMessage =>
      'Microphone access is needed to record a voice note. You can still add documents or manual events.';

  @override
  String get voiceRecordingMissingMessage =>
      'MedStory could not find the recording on this device.';

  @override
  String get voiceRecordingFailedMessage =>
      'We could not record this voice note. Try again or add a document instead.';

  @override
  String get scanDocumentTitle => 'Scan document';

  @override
  String get scanDocumentDescription =>
      'Use the camera for records, reports, prescriptions, or letters.';

  @override
  String get scanDocumentSemanticHint =>
      'Opens the camera to capture a medical document.';

  @override
  String get writeNoteTitle => 'Write a note';

  @override
  String get writeNoteDescription =>
      'Type or dictate thoughts, symptoms, or details you remember.';

  @override
  String get writeNoteSemanticHint =>
      'Opens a note where you can type or dictate your memory.';

  @override
  String get addPhotoTitle => 'Add a photo';

  @override
  String get addPhotoDescription =>
      'Choose a document image from your photo library.';

  @override
  String get addPhotoSemanticHint =>
      'Opens the photo library to choose a document image.';

  @override
  String get chooseFileTitle => 'Browse files';

  @override
  String get chooseFileDescription =>
      'Choose a PDF or image from your device files, up to 5 MB.';

  @override
  String get chooseFileSemanticHint =>
      'Opens your device files to choose a PDF or image document.';

  @override
  String get documentSelectionEmpty =>
      'Choose a camera photo, gallery image, or PDF/image file. MedStory will start processing it automatically.';

  @override
  String get documentProcessingTitle => 'Processing upload';

  @override
  String get documentProcessingBackgroundMessage =>
      'Processing status is shown in the Add tab.';

  @override
  String get documentProcessingDoneAction => 'Done';

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
      'Extracting text and suggested events.';

  @override
  String get documentUploadProcessed =>
      'Processing complete. You can view the result now.';

  @override
  String get documentUploadFailedMessage =>
      'We could not process this document. Check the file and try again.';

  @override
  String get documentNotMedicalMessage =>
      'This doesn’t appear to be a medical document.';

  @override
  String get documentUnreadableMessage =>
      'We couldn’t read this document. Try a clearer photo or file.';

  @override
  String get audioNotMedicalMessage =>
      'This voice note doesn’t appear to contain medical information.';

  @override
  String get audioUnreadableMessage =>
      'We couldn’t understand this recording. Try a clearer voice note.';

  @override
  String get medicalEventsNotFoundMessage =>
      'We couldn’t find medical information to add to your story.';

  @override
  String get documentFileTooLargeMessage =>
      'Choose a file that is 5 MB or smaller.';

  @override
  String get documentUnsupportedFileMessage =>
      'Phase 2 supports PDFs and images only.';

  @override
  String get uploadQueueTitle => 'Processing uploads';

  @override
  String get uploadQueueUploading => 'Uploading';

  @override
  String uploadQueueUploadingProgress(int progress) {
    return 'Uploading $progress%';
  }

  @override
  String get uploadQueueProcessing => 'Processing';

  @override
  String get uploadQueueCompleted => 'Completed';

  @override
  String get uploadQueueFailed => 'Couldn’t finish — retry';

  @override
  String get uploadQueueDuplicateMessage =>
      'This file is already being processed or was added before.';

  @override
  String get documentAlreadyProcessedMessage =>
      'This document was already processed and added to your story.';

  @override
  String get documentAlreadyProcessedAction => 'Open existing document';

  @override
  String get uploadQueuePhotoLabel => 'Photo upload';

  @override
  String get uploadQueueFileLabel => 'File upload';

  @override
  String get uploadQueueDismissAction => 'Dismiss';

  @override
  String get uploadQueueOpenResultHint => 'Open upload result';

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
  String get photoGroupingTitle => 'How should we add these photos?';

  @override
  String photoGroupingDescription(int count) {
    return 'You selected $count photos. Choose how they belong in MedStory.';
  }

  @override
  String get photoGroupingOneTitle => 'One document';

  @override
  String get photoGroupingOneDescription =>
      'They are pages of the same document.';

  @override
  String get photoGroupingSeparateTitle => 'Separate documents';

  @override
  String get photoGroupingSeparateDescription =>
      'Each photo should create its own event.';

  @override
  String get photoGroupingContinueAction => 'Continue';

  @override
  String get documentPagesReviewTitle => 'Review document pages';

  @override
  String documentPagesCount(int count) {
    return '$count pages';
  }

  @override
  String documentPageLabel(int number) {
    return 'Page $number';
  }

  @override
  String get documentPageReorderHint => 'Hold and drag to reorder';

  @override
  String get documentPageRemoveAction => 'Remove page';

  @override
  String get documentPageAddAction => 'Add another page';

  @override
  String get documentPagesProcessAction => 'Process one document';

  @override
  String eventViewOriginalPagesAction(int count) {
    return 'View $count original pages';
  }

  @override
  String get eventViewOriginalAction => 'View original';

  @override
  String get eventOriginalUnavailable =>
      'The original is unavailable on this device.';

  @override
  String get eventOriginalLocalOnly =>
      'Originals stay in this app on this device. Uploaded bytes are processed transiently.';

  @override
  String get eventRevisionCompareTitle => 'Compare suggested changes';

  @override
  String get eventRevisionSafetyNote =>
      'Your edited event stays unchanged until you apply changes.';

  @override
  String get eventRevisionCurrent => 'Current event';

  @override
  String get eventRevisionSuggested => 'Suggested revision';

  @override
  String get eventRevisionApply => 'Apply selected changes';

  @override
  String get eventRevisionKeep => 'Keep current event';

  @override
  String get eventRevisionRegenerateAction => 'Regenerate suggestion';

  @override
  String get eventOriginalShareAction => 'Open or share original';

  @override
  String get documentSingleEventValue => 'One timeline event';

  @override
  String get documentNoEventValue => 'No event created';

  @override
  String get timelineHeadline => 'MedStory';

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
  String get timelineApplyFiltersAction => 'Show results';

  @override
  String get timelineClearFiltersAction => 'Clear all filters';

  @override
  String get timelineClearSearchAction => 'Clear search';

  @override
  String get timelineFiltersActive => 'Filters are applied';

  @override
  String get timelineAllTypes => 'All types';

  @override
  String get timelineAllYears => 'All years';

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
  String get eventTypeMedicalRecord => 'Medical record';

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
  String get eventAiSuggestedNote =>
      'AI extracted this event from a document. You can edit it if needed.';

  @override
  String get eventOriginalSourceTitle => 'Original note';

  @override
  String get eventOriginalTranscriptTitle => 'Original transcript';

  @override
  String get eventAiAnalysisTitle => 'AI analysis';

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

  @override
  String get visitPrepTitle => 'Prepare for a visit';

  @override
  String get visitPrepHint => 'Questions or concerns you want to discuss';

  @override
  String get visitPrepSave => 'Save visit note';

  @override
  String get visitPrepExport => 'Export visit summary';

  @override
  String get visitPrepSaved => 'Visit note saved.';

  @override
  String get onboardingTitle => 'Your medical story, in one place';

  @override
  String get onboardingBody =>
      'MedStory helps you organize and understand your records. It does not diagnose or recommend treatment.';

  @override
  String get onboardingStart => 'Add your first record';

  @override
  String get onboardingSkip => 'Not now';

  @override
  String get timelineYear => 'Year';
}
