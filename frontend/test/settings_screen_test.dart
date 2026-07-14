import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/features/auth/data/auth_repository.dart';
import 'package:med_story/features/auth/domain/auth_models.dart';
import 'package:med_story/features/settings/presentation/screens/settings_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository authRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
    when(
      () => authRepository.restoreSession(),
    ).thenAnswer((_) async => AuthState.authenticated(_user(locale: 'en')));
    when(
      () => authRepository.updateLocale('ru'),
    ).thenAnswer((_) async => _user(locale: 'ru'));
    when(() => authRepository.deleteAccount()).thenAnswer((_) async {});
    when(() => authRepository.logout()).thenAnswer((_) async {});
  });

  testWidgets('renders privacy, language, and account actions', (tester) async {
    await _pumpScreen(tester, authRepository);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    )!;

    expect(find.text(l10n.settingsPrivacySectionTitle), findsOneWidget);
    await _scrollToText(tester, l10n.settingsLanguageRussian);
    expect(find.text(l10n.settingsLanguageRussian), findsOneWidget);
    final deleteAction = find.widgetWithText(
      OutlinedButton,
      l10n.settingsDeleteAccountAction,
    );
    await _scrollToFinder(tester, deleteAction);
    expect(deleteAction, findsOneWidget);
  });

  testWidgets('updates locale', (tester) async {
    await _pumpScreen(tester, authRepository);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    )!;

    await _scrollToText(tester, l10n.settingsLanguageRussian);
    await tester.tap(find.text(l10n.settingsLanguageRussian));
    await tester.pumpAndSettle();
    verify(() => authRepository.updateLocale('ru')).called(1);
  });

  testWidgets('requires typed confirmation before account deletion', (
    tester,
  ) async {
    await _pumpScreen(tester, authRepository);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(SettingsScreen)),
    )!;

    final deleteAction = find.widgetWithText(
      OutlinedButton,
      l10n.settingsDeleteAccountAction,
    );
    await _scrollToFinder(tester, deleteAction);
    await tester.tap(deleteAction);
    await tester.pumpAndSettle();

    final confirmButton = find.text(l10n.settingsDeleteAccountConfirmAction);
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: confirmButton,
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byType(TextField),
      l10n.settingsDeleteAccountConfirmValue,
    );
    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    verify(() => authRepository.deleteAccount()).called(1);
  });
}

Future<void> _scrollToText(WidgetTester tester, String text) {
  return _scrollToFinder(tester, find.text(text));
}

Future<void> _scrollToFinder(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpScreen(
  WidgetTester tester,
  AuthRepository authRepository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(body: SettingsScreen()),
      ),
    ),
  );
}

AppUser _user({required String locale}) {
  return AppUser(
    id: 'user-1',
    email: 'alex@example.com',
    fullName: 'Alex',
    locale: locale,
  );
}
