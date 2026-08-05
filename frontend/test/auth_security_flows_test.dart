import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_colors.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/core/error/app_failure.dart';
import 'package:med_story/features/auth/data/auth_repository.dart';
import 'package:med_story/features/auth/domain/auth_models.dart';
import 'package:med_story/features/auth/presentation/screens/auth_form_screen.dart';
import 'package:med_story/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:med_story/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(
      () => repository.restoreSession(),
    ).thenAnswer((_) async => const AuthState.unauthenticated());
  });

  testWidgets('registration requires privacy consent and leaves AI off', (
    tester,
  ) async {
    await _pump(
      tester,
      repository,
      const AuthFormScreen(mode: AuthFormMode.register),
    );
    await tester.pumpAndSettle();
    final l10n = _l10n(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alex');
    await tester.enterText(fields.at(1), 'alex@example.com');
    await tester.enterText(fields.at(2), 'strong-password');

    final privacy = find.widgetWithText(
      CheckboxListTile,
      l10n.authPrivacyConsentTitle,
    );
    final ai = find.widgetWithText(CheckboxListTile, l10n.authAiConsentTitle);
    expect(tester.widget<CheckboxListTile>(privacy).value, isFalse);
    expect(tester.widget<CheckboxListTile>(ai).value, isFalse);

    final registrationTheme = Theme.of(tester.element(fields.at(0)));
    expect(
      registrationTheme.inputDecorationTheme.fillColor,
      AppColors.clinicalWhite,
    );
    expect(registrationTheme.colorScheme.primary, AppColors.deepClinicalBlue);
    final consentGroup = tester.widget<Container>(
      find.byKey(const ValueKey('registration-consent-group')),
    );
    final consentBorder = consentGroup.foregroundDecoration! as BoxDecoration;
    expect((consentBorder.border! as Border).top.color, AppColors.clinicalLine);
    final disclosure = tester.widget<TextButton>(
      find.widgetWithText(TextButton, l10n.authPrivacyDetailsShowAction),
    );
    expect(
      disclosure.style?.foregroundColor?.resolve(<WidgetState>{}),
      AppColors.controlledCrimson,
    );
    final existingAccountAction = tester.widget<TextButton>(
      find.widgetWithText(TextButton, l10n.authAlreadyHaveAccountAction),
    );
    expect(
      existingAccountAction.style?.foregroundColor?.resolve(<WidgetState>{}),
      AppColors.controlledCrimson,
    );
    final logo = tester.widget<Image>(
      find.byKey(const ValueKey('registration-app-logo')),
    );
    expect(
      (logo.image as AssetImage).assetName,
      'assets/branding/medstory-app-icon.png',
    );
    final optional = find.byKey(
      const ValueKey('registration-full-name-optional'),
    );
    expect(
      tester.getTopRight(optional).dx,
      closeTo(tester.getTopRight(fields.at(0)).dx - 2, 0.5),
    );

    final fieldPositions = List.generate(
      3,
      (index) => tester.getTopLeft(fields.at(index)).dy,
    );
    final privacyPosition = tester.getTopLeft(privacy).dy;
    expect(fieldPositions[0], lessThan(fieldPositions[1]));
    expect(fieldPositions[1], lessThan(fieldPositions[2]));
    expect(fieldPositions[2], lessThan(privacyPosition));

    final submit = find.widgetWithText(
      FilledButton,
      l10n.authCreateAccountAction,
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text(l10n.authPrivacyConsentValidation), findsOneWidget);
    expect(
      tester.widget<CheckboxListTile>(privacy).focusNode?.hasFocus,
      isTrue,
    );
    verifyNever(
      () => repository.register(
        email: any(named: 'email'),
        password: any(named: 'password'),
        fullName: any(named: 'fullName'),
        locale: any(named: 'locale'),
        acceptPrivacyNotice: any(named: 'acceptPrivacyNotice'),
        aiProcessingConsent: any(named: 'aiProcessingConsent'),
      ),
    );
  });

  testWidgets('registration disclosures and password visibility are usable', (
    tester,
  ) async {
    await _pump(
      tester,
      repository,
      const AuthFormScreen(mode: AuthFormMode.register),
    );
    await tester.pumpAndSettle();
    final l10n = _l10n(tester);

    final password = find.byType(TextFormField).at(2);
    final passwordEditable = find.descendant(
      of: password,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(passwordEditable).obscureText, isTrue);

    final showPassword = find.byTooltip(l10n.authShowPasswordAction);
    await tester.ensureVisible(showPassword);
    await tester.tap(showPassword);
    await tester.pump();

    expect(tester.widget<EditableText>(passwordEditable).obscureText, isFalse);
    expect(find.byTooltip(l10n.authHidePasswordAction), findsOneWidget);

    final privacyDisclosure = find.text(l10n.authPrivacyDetailsShowAction);
    await tester.ensureVisible(privacyDisclosure);
    await tester.tap(privacyDisclosure);
    await tester.pumpAndSettle();
    expect(find.text(l10n.authPrivacyDetailsMessage), findsOneWidget);
    expect(find.text(l10n.authPrivacyDetailsSecondaryMessage), findsOneWidget);

    final aiDisclosure = find.text(l10n.authAiDetailsShowAction);
    await tester.ensureVisible(aiDisclosure);
    await tester.tap(aiDisclosure);
    await tester.pumpAndSettle();
    expect(find.text(l10n.authAiDetailsMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'registration submits real values and shows exact network error',
    (tester) async {
      final registration = Completer<RegistrationResult>();
      when(
        () => repository.register(
          email: 'alex@example.com',
          password: 'strong-password',
          fullName: 'Alex',
          locale: 'en',
          acceptPrivacyNotice: true,
          aiProcessingConsent: false,
        ),
      ).thenAnswer((_) => registration.future);

      await _pump(
        tester,
        repository,
        const AuthFormScreen(mode: AuthFormMode.register),
      );
      await tester.pumpAndSettle();
      final l10n = _l10n(tester);
      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'Alex');
      await tester.enterText(fields.at(1), 'alex@example.com');
      await tester.enterText(fields.at(2), 'strong-password');
      final privacy = find.widgetWithText(
        CheckboxListTile,
        l10n.authPrivacyConsentTitle,
      );
      await tester.ensureVisible(privacy);
      await tester.tap(privacy);
      await tester.pump();

      await tester.tap(
        find.widgetWithText(FilledButton, l10n.authCreateAccountAction),
      );
      await tester.pump();

      expect(find.text(l10n.authCreatingAccountAction), findsOneWidget);
      final loadingButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, l10n.authCreatingAccountAction),
      );
      expect(loadingButton.onPressed, isNull);
      verify(
        () => repository.register(
          email: 'alex@example.com',
          password: 'strong-password',
          fullName: 'Alex',
          locale: 'en',
          acceptPrivacyNotice: true,
          aiProcessingConsent: false,
        ),
      ).called(1);

      registration.completeError(const AppFailure('network_failed'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'We could not reach MedStory. Check your connection and try again.',
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.authTryAgainAction), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('registration actions remain above the keyboard', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await _pump(
      tester,
      repository,
      const AuthFormScreen(mode: AuthFormMode.register),
    );
    await tester.pumpAndSettle();
    final l10n = _l10n(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    final loginAction = find.widgetWithText(
      TextButton,
      l10n.authAlreadyHaveAccountAction,
    );
    expect(tester.getBottomRight(loginAction).dy, lessThanOrEqualTo(500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Russian registration fits a narrow screen at larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pump(
      tester,
      repository,
      const AuthFormScreen(mode: AuthFormMode.register),
      locale: const Locale('ru'),
    );
    await tester.pumpAndSettle();
    final l10n = _l10n(tester);

    expect(find.text(l10n.authPrivacyAiTitle), findsOneWidget);
    expect(find.text(l10n.authAlreadyHaveAccountAction), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('six-digit verification authenticates the account', (
    tester,
  ) async {
    when(
      () => repository.verifyEmail(email: 'alex@example.com', code: '123456'),
    ).thenAnswer((_) async => AuthState.authenticated(_user()));
    await _pump(
      tester,
      repository,
      const EmailVerificationScreen(email: 'alex@example.com'),
    );
    await tester.pumpAndSettle();
    final l10n = _l10n(tester);

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.widgetWithText(FilledButton, l10n.authVerifyAction));
    await tester.pumpAndSettle();

    verify(
      () => repository.verifyEmail(email: 'alex@example.com', code: '123456'),
    ).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password reset request reveals code and new password fields', (
    tester,
  ) async {
    when(
      () => repository.requestPasswordReset('alex@example.com'),
    ).thenAnswer((_) async {});
    await _pump(tester, repository, const PasswordResetScreen());
    await tester.pumpAndSettle();
    final l10n = _l10n(tester);

    await tester.enterText(find.byType(TextFormField), 'alex@example.com');
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.authSendResetCodeAction),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.authVerificationCodeLabel), findsOneWidget);
    expect(find.text(l10n.authNewPasswordLabel), findsOneWidget);
    verify(() => repository.requestPasswordReset('alex@example.com')).called(1);
  });
}

Future<void> _pump(
  WidgetTester tester,
  AuthRepository repository,
  Widget home, {
  Locale locale = const Locale('en'),
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: home,
      ),
    ),
  );
}

AppLocalizations _l10n(WidgetTester tester) {
  return AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
}

AppUser _user() => const AppUser(
  id: 'user-1',
  email: 'alex@example.com',
  fullName: 'Alex',
  locale: 'en',
);
