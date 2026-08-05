import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
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

    final submit = find.widgetWithText(
      FilledButton,
      l10n.authCreateAccountAction,
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text(l10n.authPrivacyConsentValidation), findsOneWidget);
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
  Widget home,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
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
