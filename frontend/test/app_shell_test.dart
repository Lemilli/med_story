import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/core/storage/secure_token_storage.dart';
import 'package:med_story/features/shell/presentation/screens/app_shell.dart';
import 'package:med_story/l10n/app_localizations.dart';

class _OnboardingSeenStorage extends SecureTokenStorage {
  const _OnboardingSeenStorage() : super(const FlutterSecureStorage());

  @override
  Future<bool> hasSeenOnboarding() async => true;
}

void main() {
  testWidgets('middle navigation item opens the dedicated capture tab', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/timeline',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/timeline',
                  builder: (context, state) => const Text('Timeline tab'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/capture',
                  builder: (context, state) => const Text('Capture tab'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/summary',
                  builder: (context, state) => const Text('Summary tab'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStorageProvider.overrideWithValue(
            const _OnboardingSeenStorage(),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Capture tab'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
  });
}
