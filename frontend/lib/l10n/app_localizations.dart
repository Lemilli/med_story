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
  /// **'Timeline'**
  String get navTimeline;

  /// No description provided for @navCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get navCapture;

  /// No description provided for @navSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
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
  /// **'Your confirmed medical story will appear here.'**
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

  /// No description provided for @captureHeadline.
  ///
  /// In en, this message translates to:
  /// **'Add to your story'**
  String get captureHeadline;

  /// No description provided for @captureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture what you remember. You can organize it later.'**
  String get captureSubtitle;

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
  /// **'Microphone recording will be wired to the capture controller next.'**
  String get voiceCaptureMessage;

  /// No description provided for @scanDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get scanDocumentTitle;

  /// No description provided for @scanDocumentDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan records, letters, reports, or prescriptions.'**
  String get scanDocumentDescription;

  /// No description provided for @scanDocumentSemanticHint.
  ///
  /// In en, this message translates to:
  /// **'Starts document capture. You can review AI suggestions later.'**
  String get scanDocumentSemanticHint;

  /// No description provided for @documentScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Document scan'**
  String get documentScanTitle;

  /// No description provided for @documentScanMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera and file capture will be wired to the upload flow next.'**
  String get documentScanMessage;

  /// No description provided for @writeNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get writeNoteTitle;

  /// No description provided for @writeNoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Type thoughts, questions, or details you remember.'**
  String get writeNoteDescription;

  /// No description provided for @writeNoteSemanticHint.
  ///
  /// In en, this message translates to:
  /// **'Opens a text note capture.'**
  String get writeNoteSemanticHint;

  /// No description provided for @textNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Text note'**
  String get textNoteTitle;

  /// No description provided for @textNoteMessage.
  ///
  /// In en, this message translates to:
  /// **'Manual note entry will be added to this flow next.'**
  String get textNoteMessage;

  /// No description provided for @addPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add photo or file'**
  String get addPhotoTitle;

  /// No description provided for @addPhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Attach images or files from your device.'**
  String get addPhotoDescription;

  /// No description provided for @addPhotoSemanticHint.
  ///
  /// In en, this message translates to:
  /// **'Opens photo or file selection.'**
  String get addPhotoSemanticHint;

  /// No description provided for @photoOrFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo or file'**
  String get photoOrFileTitle;

  /// No description provided for @photoOrFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Gallery and file picker support will be connected next.'**
  String get photoOrFileMessage;

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
