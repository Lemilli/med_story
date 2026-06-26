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
  String get recordVoiceSemanticHint =>
      'Starts a voice capture. You can review before saving.';

  @override
  String get voiceCaptureTitle => 'Voice capture';

  @override
  String get voiceCaptureMessage =>
      'Microphone recording will be wired to the capture controller next.';

  @override
  String get scanDocumentTitle => 'Scan document';

  @override
  String get scanDocumentDescription =>
      'Scan records, letters, reports, or prescriptions.';

  @override
  String get scanDocumentSemanticHint =>
      'Starts document capture. You can review AI suggestions later.';

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
  String get writeNoteSemanticHint => 'Opens a text note capture.';

  @override
  String get textNoteTitle => 'Text note';

  @override
  String get textNoteMessage =>
      'Manual note entry will be added to this flow next.';

  @override
  String get addPhotoTitle => 'Add photo or file';

  @override
  String get addPhotoDescription => 'Attach images or files from your device.';

  @override
  String get addPhotoSemanticHint => 'Opens photo or file selection.';

  @override
  String get photoOrFileTitle => 'Photo or file';

  @override
  String get photoOrFileMessage =>
      'Gallery and file picker support will be connected next.';

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
}
