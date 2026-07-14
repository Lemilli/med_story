import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MedStory'**
  String get appTitle;

  /// No description provided for @navTimeline.
  ///
  /// In en, this message translates to:
  /// **'My Story'**
  String get navTimeline;

  /// No description provided for @navCapture.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navCapture;

  /// No description provided for @navSummary.
  ///
  /// In en, this message translates to:
  /// **'For Visits'**
  String get navSummary;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @timelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineTitle;

  /// No description provided for @timelineMessage.
  ///
  /// In en, this message translates to:
  /// **'Your medical story will appear here.'**
  String get timelineMessage;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @summaryMessage.
  ///
  /// In en, this message translates to:
  /// **'Doctor-ready summaries and exports will live here.'**
  String get summaryMessage;

  /// No description provided for @summaryHeadline.
  ///
  /// In en, this message translates to:
  /// **'Prepare for a visit'**
  String get summaryHeadline;

  /// No description provided for @summarySubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'For {name}'**
  String summarySubjectLabel(String name);

  /// No description provided for @summaryNoSubjectMessage.
  ///
  /// In en, this message translates to:
  /// **'MedStory could not load a profile for this summary.'**
  String get summaryNoSubjectMessage;

  /// No description provided for @summaryBoundaryNote.
  ///
  /// In en, this message translates to:
  /// **'MedStory organizes your information; it does not diagnose or recommend treatment.'**
  String get summaryBoundaryNote;

  /// No description provided for @summaryOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing the saved summary. Refresh when you are back online.'**
  String get summaryOfflineNotice;

  /// No description provided for @summaryRefreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh summary'**
  String get summaryRefreshAction;

  /// No description provided for @summaryRegenerateAction.
  ///
  /// In en, this message translates to:
  /// **'Regenerate summary'**
  String get summaryRegenerateAction;

  /// No description provided for @summaryGenerateAction.
  ///
  /// In en, this message translates to:
  /// **'Generate summary'**
  String get summaryGenerateAction;

  /// No description provided for @summaryPrepareVisitAction.
  ///
  /// In en, this message translates to:
  /// **'Prepare for visit'**
  String get summaryPrepareVisitAction;

  /// No description provided for @summaryNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'No summary yet'**
  String get summaryNotReadyTitle;

  /// No description provided for @summaryNotReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Generate a doctor-ready summary from your timeline events when you need to prepare for a visit.'**
  String get summaryNotReadyMessage;

  /// No description provided for @summaryNarrativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Doctor-ready narrative'**
  String get summaryNarrativeTitle;

  /// No description provided for @summaryNoNarrativeMessage.
  ///
  /// In en, this message translates to:
  /// **'No narrative text was returned for this summary.'**
  String get summaryNoNarrativeMessage;

  /// No description provided for @summaryGeneratedAt.
  ///
  /// In en, this message translates to:
  /// **'Generated {date}'**
  String summaryGeneratedAt(String date);

  /// No description provided for @summaryVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String summaryVersionLabel(int version);

  /// No description provided for @summaryEventCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No events} =1{1 event} other{{count} events}}'**
  String summaryEventCountLabel(int count);

  /// No description provided for @summaryReturnToCurrentAction.
  ///
  /// In en, this message translates to:
  /// **'Return to current summary'**
  String get summaryReturnToCurrentAction;

  /// No description provided for @summaryVersionHistoryAction.
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get summaryVersionHistoryAction;

  /// No description provided for @summaryCurrentVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get summaryCurrentVersionLabel;

  /// No description provided for @summaryHistorySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search history'**
  String get summaryHistorySearchTitle;

  /// No description provided for @summaryHistorySearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search timeline events'**
  String get summaryHistorySearchLabel;

  /// No description provided for @summaryHistorySearchEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Search your saved timeline to review details while preparing for a visit.'**
  String get summaryHistorySearchEmptyHint;

  /// No description provided for @summaryHistorySearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching events found.'**
  String get summaryHistorySearchNoResults;

  /// No description provided for @summaryHistorySearchFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not refresh matching events. Saved results may still appear.'**
  String get summaryHistorySearchFailedMessage;

  /// No description provided for @summaryRegenerateQueuedMessage.
  ///
  /// In en, this message translates to:
  /// **'Summary generation has started. Pull to refresh in a moment.'**
  String get summaryRegenerateQueuedMessage;

  /// No description provided for @summaryExportSharedMessage.
  ///
  /// In en, this message translates to:
  /// **'Summary export is ready to share.'**
  String get summaryExportSharedMessage;

  /// No description provided for @summaryRegenerateFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not start summary generation. Check your connection and try again.'**
  String get summaryRegenerateFailedMessage;

  /// No description provided for @summaryExportFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not prepare the summary export. Check your connection and try again.'**
  String get summaryExportFailedMessage;

  /// No description provided for @summaryActionFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not complete that action. Try again.'**
  String get summaryActionFailedMessage;

  /// No description provided for @summaryLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not load this summary.'**
  String get summaryLoadFailedMessage;

  /// No description provided for @summarySectionKeySymptoms.
  ///
  /// In en, this message translates to:
  /// **'Key symptoms'**
  String get summarySectionKeySymptoms;

  /// No description provided for @summarySectionMajorDiagnoses.
  ///
  /// In en, this message translates to:
  /// **'Major diagnoses'**
  String get summarySectionMajorDiagnoses;

  /// No description provided for @summarySectionMedications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get summarySectionMedications;

  /// No description provided for @summarySectionProcedures.
  ///
  /// In en, this message translates to:
  /// **'Procedures'**
  String get summarySectionProcedures;

  /// No description provided for @summarySectionHospitalizations.
  ///
  /// In en, this message translates to:
  /// **'Hospitalizations'**
  String get summarySectionHospitalizations;

  /// No description provided for @summarySectionAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get summarySectionAllergies;

  /// No description provided for @summarySectionTestResults.
  ///
  /// In en, this message translates to:
  /// **'Test results'**
  String get summarySectionTestResults;

  /// No description provided for @summarySectionTreatmentOutcomes.
  ///
  /// In en, this message translates to:
  /// **'Treatment outcomes'**
  String get summarySectionTreatmentOutcomes;

  /// No description provided for @summarySectionOpenQuestions.
  ///
  /// In en, this message translates to:
  /// **'Open questions'**
  String get summarySectionOpenQuestions;

  /// No description provided for @summarySectionCareTeam.
  ///
  /// In en, this message translates to:
  /// **'Care team'**
  String get summarySectionCareTeam;

  /// No description provided for @summaryUnknownSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}'**
  String summaryUnknownSectionTitle(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Privacy, account, subjects, and locale settings.'**
  String get settingsMessage;

  /// No description provided for @settingsAccountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSectionTitle;

  /// No description provided for @settingsPrivacySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacySectionTitle;

  /// No description provided for @settingsLanguageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSectionTitle;

  /// No description provided for @settingsActionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account actions'**
  String get settingsActionsSectionTitle;

  /// No description provided for @settingsPrivacyNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'What stays here'**
  String get settingsPrivacyNoteTitle;

  /// No description provided for @settingsPrivacyNoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Original uploads are not stored on the server. Local timeline and summary caches are cleared when you log out or delete your account.'**
  String get settingsPrivacyNoteDescription;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsLocaleUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Language updated.'**
  String get settingsLocaleUpdatedMessage;

  /// No description provided for @settingsLocaleUpdateFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not update the language. Check your connection and try again.'**
  String get settingsLocaleUpdateFailedMessage;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your MedStory account and backend records.'**
  String get settingsDeleteAccountDescription;

  /// No description provided for @settingsDeleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountAction;

  /// No description provided for @settingsDeleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settingsDeleteAccountDialogTitle;

  /// No description provided for @settingsDeleteAccountDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and backend records.'**
  String get settingsDeleteAccountDialogMessage;

  /// No description provided for @settingsDeleteAccountConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get settingsDeleteAccountConfirmLabel;

  /// No description provided for @settingsDeleteAccountConfirmValue.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get settingsDeleteAccountConfirmValue;

  /// No description provided for @settingsDeleteAccountCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsDeleteAccountCancelAction;

  /// No description provided for @settingsDeleteAccountConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get settingsDeleteAccountConfirmAction;

  /// No description provided for @settingsDeleteAccountFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not delete your account. Check your connection and try again.'**
  String get settingsDeleteAccountFailedMessage;

  /// No description provided for @settingsLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out on this device and clear local cached medical data.'**
  String get settingsLogoutDescription;

  /// No description provided for @settingsOrganizerNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Organizer, not a doctor'**
  String get settingsOrganizerNoticeTitle;

  /// No description provided for @settingsOrganizerNoticeDescription.
  ///
  /// In en, this message translates to:
  /// **'MedStory helps organize and explain your records. It does not diagnose, recommend treatment, or replace care from a clinician.'**
  String get settingsOrganizerNoticeDescription;

  /// No description provided for @captureHeadline.
  ///
  /// In en, this message translates to:
  /// **'Add to your story'**
  String get captureHeadline;

  /// No description provided for @captureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add something. You can review it before it becomes part of your story.'**
  String get captureSubtitle;

  /// No description provided for @capturePrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'Private to you. You review suggestions before they join your story. MedStory organizes your information; it does not diagnose.'**
  String get capturePrivacyNotice;

  /// No description provided for @recordVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Record voice'**
  String get recordVoiceTitle;

  /// No description provided for @recordVoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Speak a memory, symptom update, or treatment note.'**
  String get recordVoiceDescription;

  /// No description provided for @recordVoiceSemanticHint.
  ///
  /// In en, this message translates to:
  /// **'Starts a voice capture. You can review before saving.'**
  String get recordVoiceSemanticHint;

  /// No description provided for @voiceCaptureTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice capture'**
  String get voiceCaptureTitle;

  /// No description provided for @voiceCaptureMessage.
  ///
  /// In en, this message translates to:
  /// **'Record a short voice note, review it, then upload it for suggested timeline events.'**
  String get voiceCaptureMessage;

  /// No description provided for @voiceNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNoteTitle;

  /// No description provided for @voiceNoteCaptureLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNoteCaptureLabel;

  /// No description provided for @medicalPhotoCaptureLabel.
  ///
  /// In en, this message translates to:
  /// **'Medical photo'**
  String get medicalPhotoCaptureLabel;

  /// No description provided for @voicePermissionRequesting.
  ///
  /// In en, this message translates to:
  /// **'Checking microphone access'**
  String get voicePermissionRequesting;

  /// No description provided for @voicePermissionRequestingDescription.
  ///
  /// In en, this message translates to:
  /// **'Your recording stays on this device until you choose to upload it.'**
  String get voicePermissionRequestingDescription;

  /// No description provided for @voiceRecordingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get voiceRecordingInProgress;

  /// No description provided for @voiceRecordingDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String voiceRecordingDuration(String duration);

  /// No description provided for @voiceStopAction.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get voiceStopAction;

  /// No description provided for @voiceDiscardAction.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get voiceDiscardAction;

  /// No description provided for @voiceReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review voice note'**
  String get voiceReviewTitle;

  /// No description provided for @voiceRecordedMetadata.
  ///
  /// In en, this message translates to:
  /// **'{duration} • {size}'**
  String voiceRecordedMetadata(String duration, String size);

  /// No description provided for @voiceRecordAgainAction.
  ///
  /// In en, this message translates to:
  /// **'Record again'**
  String get voiceRecordAgainAction;

  /// No description provided for @voiceUploadAction.
  ///
  /// In en, this message translates to:
  /// **'Upload voice note'**
  String get voiceUploadAction;

  /// No description provided for @voiceRecordingMaxDurationMessage.
  ///
  /// In en, this message translates to:
  /// **'Recording stopped at 4 minutes to keep the upload small.'**
  String get voiceRecordingMaxDurationMessage;

  /// No description provided for @voiceFileTooLargeMessage.
  ///
  /// In en, this message translates to:
  /// **'Record a shorter voice note. Audio uploads must be 5 MB or smaller.'**
  String get voiceFileTooLargeMessage;

  /// No description provided for @voicePermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to record a voice note. You can still add documents or manual events.'**
  String get voicePermissionDeniedMessage;

  /// No description provided for @voiceRecordingMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'MedStory could not find the recording on this device.'**
  String get voiceRecordingMissingMessage;

  /// No description provided for @voiceRecordingFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not record this voice note. Try again or add a document instead.'**
  String get voiceRecordingFailedMessage;

  /// No description provided for @scanDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get scanDocumentTitle;

  /// No description provided for @scanDocumentDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the camera for records, reports, prescriptions, or letters.'**
  String get scanDocumentDescription;

  /// No description provided for @scanDocumentSemanticHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the camera to capture a medical document.'**
  String get scanDocumentSemanticHint;

  /// No description provided for @writeNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get writeNoteTitle;

  /// No description provided for @writeNoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Type or dictate thoughts, symptoms, or details you remember.'**
  String get writeNoteDescription;

  /// No description provided for @writeNoteSemanticHint.
  ///
  /// In en, this message translates to:
  /// **'Opens a note where you can type or dictate your memory.'**
  String get writeNoteSemanticHint;

  /// No description provided for @addPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhotoTitle;

  /// No description provided for @addPhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a document image from your photo library.'**
  String get addPhotoDescription;

  /// No description provided for @addPhotoSemanticHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the photo library to choose a document image.'**
  String get addPhotoSemanticHint;

  /// No description provided for @chooseFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse files'**
  String get chooseFileTitle;

  /// No description provided for @chooseFileDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF or image from your device files, up to 5 MB.'**
  String get chooseFileDescription;

  /// No description provided for @chooseFileSemanticHint.
  ///
  /// In en, this message translates to:
  /// **'Opens your device files to choose a PDF or image document.'**
  String get chooseFileSemanticHint;

  /// No description provided for @documentSelectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Choose a camera photo, gallery image, or PDF/image file. MedStory will start processing it automatically.'**
  String get documentSelectionEmpty;

  /// No description provided for @documentProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing upload'**
  String get documentProcessingTitle;

  /// No description provided for @documentProcessingBackgroundMessage.
  ///
  /// In en, this message translates to:
  /// **'Processing status is shown in the Add tab.'**
  String get documentProcessingBackgroundMessage;

  /// No description provided for @documentProcessingDoneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get documentProcessingDoneAction;

  /// No description provided for @documentReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected document'**
  String get documentReviewTitle;

  /// No description provided for @documentUntitledTitle.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get documentUntitledTitle;

  /// No description provided for @documentTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Document title'**
  String get documentTitleLabel;

  /// No description provided for @documentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Document type'**
  String get documentTypeLabel;

  /// No description provided for @documentDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Document date'**
  String get documentDateLabel;

  /// No description provided for @documentDateAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add document date'**
  String get documentDateAddAction;

  /// No description provided for @documentDateSelected.
  ///
  /// In en, this message translates to:
  /// **'Document date: {date}'**
  String documentDateSelected(String date);

  /// No description provided for @documentDefaultSubject.
  ///
  /// In en, this message translates to:
  /// **'This document will use your default timeline profile.'**
  String get documentDefaultSubject;

  /// No description provided for @documentSelectedSubject.
  ///
  /// In en, this message translates to:
  /// **'This document will be added to {name}.'**
  String documentSelectedSubject(String name);

  /// No description provided for @documentFileMetadata.
  ///
  /// In en, this message translates to:
  /// **'{mimeType} • {size}'**
  String documentFileMetadata(String mimeType, String size);

  /// No description provided for @documentViewResultAction.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get documentViewResultAction;

  /// No description provided for @documentRetryAction.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get documentRetryAction;

  /// No description provided for @documentUploadAction.
  ///
  /// In en, this message translates to:
  /// **'Upload and process'**
  String get documentUploadAction;

  /// No description provided for @documentUploadIdle.
  ///
  /// In en, this message translates to:
  /// **'Choose a file to start processing.'**
  String get documentUploadIdle;

  /// No description provided for @documentUploadUploading.
  ///
  /// In en, this message translates to:
  /// **'Saving locally and uploading for one-time processing...'**
  String get documentUploadUploading;

  /// No description provided for @documentUploadProcessing.
  ///
  /// In en, this message translates to:
  /// **'Extracting text and suggested events.'**
  String get documentUploadProcessing;

  /// No description provided for @documentUploadProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processing complete. You can view the result now.'**
  String get documentUploadProcessed;

  /// No description provided for @documentUploadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not process this document. Check the file and try again.'**
  String get documentUploadFailedMessage;

  /// No description provided for @documentNotMedicalMessage.
  ///
  /// In en, this message translates to:
  /// **'This doesn’t appear to be a medical document.'**
  String get documentNotMedicalMessage;

  /// No description provided for @documentUnreadableMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t read this document. Try a clearer photo or file.'**
  String get documentUnreadableMessage;

  /// No description provided for @audioNotMedicalMessage.
  ///
  /// In en, this message translates to:
  /// **'This voice note doesn’t appear to contain medical information.'**
  String get audioNotMedicalMessage;

  /// No description provided for @audioUnreadableMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t understand this recording. Try a clearer voice note.'**
  String get audioUnreadableMessage;

  /// No description provided for @medicalEventsNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find medical information to add to your story.'**
  String get medicalEventsNotFoundMessage;

  /// No description provided for @documentFileTooLargeMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a file that is 5 MB or smaller.'**
  String get documentFileTooLargeMessage;

  /// No description provided for @documentUnsupportedFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Phase 2 supports PDFs and images only.'**
  String get documentUnsupportedFileMessage;

  /// No description provided for @uploadQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing uploads'**
  String get uploadQueueTitle;

  /// No description provided for @uploadQueueUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get uploadQueueUploading;

  /// No description provided for @uploadQueueUploadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {progress}%'**
  String uploadQueueUploadingProgress(int progress);

  /// No description provided for @uploadQueueProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get uploadQueueProcessing;

  /// No description provided for @uploadQueueCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get uploadQueueCompleted;

  /// No description provided for @uploadQueueFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t finish — retry'**
  String get uploadQueueFailed;

  /// No description provided for @uploadQueueDuplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'This file is already being processed or was added before.'**
  String get uploadQueueDuplicateMessage;

  /// No description provided for @documentAlreadyProcessedMessage.
  ///
  /// In en, this message translates to:
  /// **'This document was already processed and added to your story.'**
  String get documentAlreadyProcessedMessage;

  /// No description provided for @documentAlreadyProcessedAction.
  ///
  /// In en, this message translates to:
  /// **'Open existing document'**
  String get documentAlreadyProcessedAction;

  /// No description provided for @uploadQueuePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo upload'**
  String get uploadQueuePhotoLabel;

  /// No description provided for @uploadQueueFileLabel.
  ///
  /// In en, this message translates to:
  /// **'File upload'**
  String get uploadQueueFileLabel;

  /// No description provided for @uploadQueueDismissAction.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get uploadQueueDismissAction;

  /// No description provided for @uploadQueueOpenResultHint.
  ///
  /// In en, this message translates to:
  /// **'Open upload result'**
  String get uploadQueueOpenResultHint;

  /// No description provided for @documentProcessingFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Processing failed. The original file remains on this device.'**
  String get documentProcessingFailedMessage;

  /// No description provided for @documentProcessingTimeoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Processing is taking longer than expected. Open the document again to refresh its status.'**
  String get documentProcessingTimeoutMessage;

  /// No description provided for @documentSourceMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'MedStory could not find the selected file on this device.'**
  String get documentSourceMissingMessage;

  /// No description provided for @documentDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Document detail'**
  String get documentDetailTitle;

  /// No description provided for @documentDateUnknown.
  ///
  /// In en, this message translates to:
  /// **'No date set'**
  String get documentDateUnknown;

  /// No description provided for @documentMimeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get documentMimeTypeLabel;

  /// No description provided for @documentStorageLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get documentStorageLabel;

  /// No description provided for @documentLocalOnlyValue.
  ///
  /// In en, this message translates to:
  /// **'Original saved on this device only'**
  String get documentLocalOnlyValue;

  /// No description provided for @documentRemoteStorageValue.
  ///
  /// In en, this message translates to:
  /// **'Stored remotely'**
  String get documentRemoteStorageValue;

  /// No description provided for @documentExtractedTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Extracted text'**
  String get documentExtractedTextLabel;

  /// No description provided for @documentAvailableValue.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get documentAvailableValue;

  /// No description provided for @documentNotAvailableValue.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get documentNotAvailableValue;

  /// No description provided for @documentEventCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested events'**
  String get documentEventCountLabel;

  /// No description provided for @documentEventCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No events} =1{1 event} other{{count} events}}'**
  String documentEventCountValue(int count);

  /// No description provided for @documentCreatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get documentCreatedAtLabel;

  /// No description provided for @documentUpdatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get documentUpdatedAtLabel;

  /// No description provided for @documentDetailProcessingNote.
  ///
  /// In en, this message translates to:
  /// **'Processing is still running. Pull to refresh this status.'**
  String get documentDetailProcessingNote;

  /// No description provided for @documentDetailPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'The original document stays in the app sandbox. The backend processes uploaded bytes transiently and returns only metadata and suggested events.'**
  String get documentDetailPrivacyNote;

  /// No description provided for @documentDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete document'**
  String get documentDeleteAction;

  /// No description provided for @documentDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this document?'**
  String get documentDeleteConfirmTitle;

  /// No description provided for @documentDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Its derived events may also be removed from your timeline.'**
  String get documentDeleteConfirmMessage;

  /// No description provided for @documentOpenTimelineAction.
  ///
  /// In en, this message translates to:
  /// **'Open timeline'**
  String get documentOpenTimelineAction;

  /// No description provided for @documentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get documentStatusPending;

  /// No description provided for @documentStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get documentStatusProcessing;

  /// No description provided for @documentStatusProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get documentStatusProcessed;

  /// No description provided for @documentStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get documentStatusFailed;

  /// No description provided for @documentTypeMedicalRecord.
  ///
  /// In en, this message translates to:
  /// **'Medical record'**
  String get documentTypeMedicalRecord;

  /// No description provided for @documentTypeLabResult.
  ///
  /// In en, this message translates to:
  /// **'Lab result'**
  String get documentTypeLabResult;

  /// No description provided for @documentTypeReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get documentTypeReport;

  /// No description provided for @documentTypePrescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get documentTypePrescription;

  /// No description provided for @documentTypeProcedureSummary.
  ///
  /// In en, this message translates to:
  /// **'Procedure summary'**
  String get documentTypeProcedureSummary;

  /// No description provided for @documentTypeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get documentTypeNote;

  /// No description provided for @documentTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get documentTypeImage;

  /// No description provided for @documentTypeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get documentTypeAudio;

  /// No description provided for @documentTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get documentTypeOther;

  /// No description provided for @privacyPanelSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Private to you. You review AI suggestions before they join your timeline.'**
  String get privacyPanelSemanticLabel;

  /// No description provided for @privacyPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Private to you'**
  String get privacyPanelTitle;

  /// No description provided for @privacyPanelDescription.
  ///
  /// In en, this message translates to:
  /// **'You review AI suggestions before they join your timeline.'**
  String get privacyPanelDescription;

  /// No description provided for @boundaryNote.
  ///
  /// In en, this message translates to:
  /// **'MedStory organizes your information; it does not diagnose.'**
  String get boundaryNote;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep building your medical story.'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a private place for your medical history.'**
  String get authRegisterSubtitle;

  /// No description provided for @authBoundarySemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'MedStory is an organizer, not a diagnostic tool.'**
  String get authBoundarySemanticLabel;

  /// No description provided for @authBoundaryNote.
  ///
  /// In en, this message translates to:
  /// **'MedStory helps organize and explain information. It does not diagnose or recommend treatment.'**
  String get authBoundaryNote;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional, used only to personalize your account.'**
  String get authFullNameHelper;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get authPasswordHelper;

  /// No description provided for @authEmailValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailValidation;

  /// No description provided for @authPasswordValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 8 characters.'**
  String get authPasswordValidation;

  /// No description provided for @authCreateAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountAction;

  /// No description provided for @authLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginAction;

  /// No description provided for @authAlreadyHaveAccountAction.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get authAlreadyHaveAccountAction;

  /// No description provided for @authNeedAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get authNeedAccountAction;

  /// No description provided for @authLogoutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogoutAction;

  /// No description provided for @authFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your email and password, then try again.'**
  String get authFailedMessage;

  /// No description provided for @authEmailAlreadyExistsMessage.
  ///
  /// In en, this message translates to:
  /// **'This email already has a MedStory account. Log in instead, or use another email.'**
  String get authEmailAlreadyExistsMessage;

  /// No description provided for @authInvalidEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address. Example: name@example.com'**
  String get authInvalidEmailMessage;

  /// No description provided for @authEmailRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to create an account.'**
  String get authEmailRequiredMessage;

  /// No description provided for @authPasswordNotAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password. Use at least 8 characters and avoid common passwords.'**
  String get authPasswordNotAcceptedMessage;

  /// No description provided for @authRegisterFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not create your account. Check your details and try again.'**
  String get authRegisterFailedMessage;

  /// No description provided for @networkFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We could not reach MedStory. Check your connection and try again.'**
  String get networkFailedMessage;

  /// No description provided for @authCheckingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking your session'**
  String get authCheckingSession;

  /// No description provided for @authMePanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Account from /me'**
  String get authMePanelTitle;

  /// No description provided for @authLocaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Locale'**
  String get authLocaleLabel;

  /// No description provided for @authUnnamedUser.
  ///
  /// In en, this message translates to:
  /// **'No name set'**
  String get authUnnamedUser;

  /// No description provided for @pendingActionMessage.
  ///
  /// In en, this message translates to:
  /// **'{title}: {message}'**
  String pendingActionMessage(String title, String message);

  /// No description provided for @photoGroupingTitle.
  ///
  /// In en, this message translates to:
  /// **'How should we add these photos?'**
  String get photoGroupingTitle;

  /// No description provided for @photoGroupingDescription.
  ///
  /// In en, this message translates to:
  /// **'You selected {count} photos. Choose how they belong in MedStory.'**
  String photoGroupingDescription(int count);

  /// No description provided for @photoGroupingOneTitle.
  ///
  /// In en, this message translates to:
  /// **'One document'**
  String get photoGroupingOneTitle;

  /// No description provided for @photoGroupingOneDescription.
  ///
  /// In en, this message translates to:
  /// **'They are pages of the same document.'**
  String get photoGroupingOneDescription;

  /// No description provided for @photoGroupingSeparateTitle.
  ///
  /// In en, this message translates to:
  /// **'Separate documents'**
  String get photoGroupingSeparateTitle;

  /// No description provided for @photoGroupingSeparateDescription.
  ///
  /// In en, this message translates to:
  /// **'Each photo should create its own event.'**
  String get photoGroupingSeparateDescription;

  /// No description provided for @photoGroupingContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get photoGroupingContinueAction;

  /// No description provided for @documentPagesReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review document pages'**
  String get documentPagesReviewTitle;

  /// No description provided for @documentPagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String documentPagesCount(int count);

  /// No description provided for @documentPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String documentPageLabel(int number);

  /// No description provided for @documentPageReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Hold and drag to reorder'**
  String get documentPageReorderHint;

  /// No description provided for @documentPageRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove page'**
  String get documentPageRemoveAction;

  /// No description provided for @documentPageAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add another page'**
  String get documentPageAddAction;

  /// No description provided for @documentPagesProcessAction.
  ///
  /// In en, this message translates to:
  /// **'Process one document'**
  String get documentPagesProcessAction;

  /// No description provided for @eventViewOriginalPagesAction.
  ///
  /// In en, this message translates to:
  /// **'View {count} original pages'**
  String eventViewOriginalPagesAction(int count);

  /// No description provided for @eventViewOriginalAction.
  ///
  /// In en, this message translates to:
  /// **'View original'**
  String get eventViewOriginalAction;

  /// No description provided for @eventOriginalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The original is unavailable on this device.'**
  String get eventOriginalUnavailable;

  /// No description provided for @eventOriginalLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Originals stay in this app on this device. Uploaded bytes are processed transiently.'**
  String get eventOriginalLocalOnly;

  /// No description provided for @eventRevisionCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare suggested changes'**
  String get eventRevisionCompareTitle;

  /// No description provided for @eventRevisionSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'Your edited event stays unchanged until you apply changes.'**
  String get eventRevisionSafetyNote;

  /// No description provided for @eventRevisionCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current event'**
  String get eventRevisionCurrent;

  /// No description provided for @eventRevisionSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested revision'**
  String get eventRevisionSuggested;

  /// No description provided for @eventRevisionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply selected changes'**
  String get eventRevisionApply;

  /// No description provided for @eventRevisionKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep current event'**
  String get eventRevisionKeep;

  /// No description provided for @eventRevisionRegenerateAction.
  ///
  /// In en, this message translates to:
  /// **'Regenerate suggestion'**
  String get eventRevisionRegenerateAction;

  /// No description provided for @eventOriginalShareAction.
  ///
  /// In en, this message translates to:
  /// **'Open or share original'**
  String get eventOriginalShareAction;

  /// No description provided for @documentSingleEventValue.
  ///
  /// In en, this message translates to:
  /// **'One timeline event'**
  String get documentSingleEventValue;

  /// No description provided for @documentNoEventValue.
  ///
  /// In en, this message translates to:
  /// **'No event created'**
  String get documentNoEventValue;

  /// No description provided for @timelineHeadline.
  ///
  /// In en, this message translates to:
  /// **'MedStory'**
  String get timelineHeadline;

  /// No description provided for @timelineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse the events you have saved, newest first.'**
  String get timelineSubtitle;

  /// No description provided for @timelineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with one event'**
  String get timelineEmptyTitle;

  /// No description provided for @timelineEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a symptom, medication, diagnosis, procedure, or note you want to remember.'**
  String get timelineEmptyMessage;

  /// No description provided for @timelineNoSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'No subject found'**
  String get timelineNoSubjectTitle;

  /// No description provided for @timelineNoSubjectMessage.
  ///
  /// In en, this message translates to:
  /// **'MedStory could not load a profile for this timeline.'**
  String get timelineNoSubjectMessage;

  /// No description provided for @timelineAddEvent.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get timelineAddEvent;

  /// No description provided for @timelineSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search title or description'**
  String get timelineSearchLabel;

  /// No description provided for @timelineFiltersAction.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get timelineFiltersAction;

  /// No description provided for @timelineApplyFiltersAction.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get timelineApplyFiltersAction;

  /// No description provided for @timelineClearFiltersAction.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get timelineClearFiltersAction;

  /// No description provided for @timelineClearSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get timelineClearSearchAction;

  /// No description provided for @timelineFiltersActive.
  ///
  /// In en, this message translates to:
  /// **'Filters are applied'**
  String get timelineFiltersActive;

  /// No description provided for @timelineAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get timelineAllTypes;

  /// No description provided for @timelineAllYears.
  ///
  /// In en, this message translates to:
  /// **'All years'**
  String get timelineAllYears;

  /// No description provided for @timelineOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing saved timeline items. Refresh when you are back online.'**
  String get timelineOfflineNotice;

  /// No description provided for @timelineLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get timelineLoadMore;

  /// No description provided for @timelineRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh timeline'**
  String get timelineRefresh;

  /// No description provided for @subjectSwitcherLabel.
  ///
  /// In en, this message translates to:
  /// **'Timeline subject'**
  String get subjectSwitcherLabel;

  /// No description provided for @subjectDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get subjectDefaultLabel;

  /// No description provided for @eventTypeSymptom.
  ///
  /// In en, this message translates to:
  /// **'Symptom'**
  String get eventTypeSymptom;

  /// No description provided for @eventTypeDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis'**
  String get eventTypeDiagnosis;

  /// No description provided for @eventTypeMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get eventTypeMedication;

  /// No description provided for @eventTypeExamination.
  ///
  /// In en, this message translates to:
  /// **'Examination'**
  String get eventTypeExamination;

  /// No description provided for @eventTypeProcedure.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get eventTypeProcedure;

  /// No description provided for @eventTypeHospitalization.
  ///
  /// In en, this message translates to:
  /// **'Hospitalization'**
  String get eventTypeHospitalization;

  /// No description provided for @eventTypeTreatmentOutcome.
  ///
  /// In en, this message translates to:
  /// **'Treatment outcome'**
  String get eventTypeTreatmentOutcome;

  /// No description provided for @eventTypeMedicalRecord.
  ///
  /// In en, this message translates to:
  /// **'Medical record'**
  String get eventTypeMedicalRecord;

  /// No description provided for @eventTypeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get eventTypeNote;

  /// No description provided for @eventNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get eventNewTitle;

  /// No description provided for @eventEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get eventEditTitle;

  /// No description provided for @eventDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Event detail'**
  String get eventDetailTitle;

  /// No description provided for @eventTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitleLabel;

  /// No description provided for @eventDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescriptionLabel;

  /// No description provided for @eventTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Event type'**
  String get eventTypeLabel;

  /// No description provided for @eventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Event date'**
  String get eventDateLabel;

  /// No description provided for @eventEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get eventEndDateLabel;

  /// No description provided for @eventTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get eventTagsLabel;

  /// No description provided for @eventTagsHelper.
  ///
  /// In en, this message translates to:
  /// **'Separate tags with commas.'**
  String get eventTagsHelper;

  /// No description provided for @eventAttributesLabel.
  ///
  /// In en, this message translates to:
  /// **'Structured details'**
  String get eventAttributesLabel;

  /// No description provided for @eventAttributesHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional JSON object for details such as dose, severity, or result.'**
  String get eventAttributesHelper;

  /// No description provided for @eventCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Save event'**
  String get eventCreateAction;

  /// No description provided for @eventSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get eventSaveAction;

  /// No description provided for @eventEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get eventEditAction;

  /// No description provided for @eventDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get eventDeleteAction;

  /// No description provided for @eventDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this event?'**
  String get eventDeleteConfirmTitle;

  /// No description provided for @eventDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from your timeline.'**
  String get eventDeleteConfirmMessage;

  /// No description provided for @eventCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get eventCancelAction;

  /// No description provided for @eventRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get eventRequiredValidation;

  /// No description provided for @eventInvalidJsonValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid JSON object or leave this empty.'**
  String get eventInvalidJsonValidation;

  /// No description provided for @eventBoundaryNote.
  ///
  /// In en, this message translates to:
  /// **'MedStory organizes your information; it does not diagnose or recommend treatment.'**
  String get eventBoundaryNote;

  /// No description provided for @eventAiSuggestedNote.
  ///
  /// In en, this message translates to:
  /// **'AI extracted this event from a document. You can edit it if needed.'**
  String get eventAiSuggestedNote;

  /// No description provided for @eventOriginalSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Original note'**
  String get eventOriginalSourceTitle;

  /// No description provided for @eventOriginalTranscriptTitle.
  ///
  /// In en, this message translates to:
  /// **'Original transcript'**
  String get eventOriginalTranscriptTitle;

  /// No description provided for @eventAiAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'AI analysis'**
  String get eventAiAnalysisTitle;

  /// No description provided for @eventResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get eventResultTitle;

  /// No description provided for @eventNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get eventNotesTitle;

  /// No description provided for @eventStructuredDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get eventStructuredDetailsTitle;

  /// No description provided for @eventConfidenceValue.
  ///
  /// In en, this message translates to:
  /// **'Extraction confidence: {value}'**
  String eventConfidenceValue(String value);

  /// No description provided for @eventOpenSourceDocumentAction.
  ///
  /// In en, this message translates to:
  /// **'Open source document'**
  String get eventOpenSourceDocumentAction;

  /// No description provided for @eventDetailsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'No description added.'**
  String get eventDetailsEmptyDescription;

  /// No description provided for @eventNetworkRequired.
  ///
  /// In en, this message translates to:
  /// **'Saving changes requires a connection to MedStory.'**
  String get eventNetworkRequired;

  /// No description provided for @visitPrepTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare for a visit'**
  String get visitPrepTitle;

  /// No description provided for @visitPrepHint.
  ///
  /// In en, this message translates to:
  /// **'Questions or concerns you want to discuss'**
  String get visitPrepHint;

  /// No description provided for @visitPrepSave.
  ///
  /// In en, this message translates to:
  /// **'Save visit note'**
  String get visitPrepSave;

  /// No description provided for @visitPrepExport.
  ///
  /// In en, this message translates to:
  /// **'Export visit summary'**
  String get visitPrepExport;

  /// No description provided for @visitPrepSaved.
  ///
  /// In en, this message translates to:
  /// **'Visit note saved.'**
  String get visitPrepSaved;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your medical story, in one place'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'MedStory helps you organize and understand your records. It does not diagnose or recommend treatment.'**
  String get onboardingBody;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Add your first record'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onboardingSkip;

  /// No description provided for @timelineYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get timelineYear;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
