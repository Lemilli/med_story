import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:med_story/app/app.dart';
import 'package:med_story/app/theme/app_theme.dart';
import 'package:med_story/core/storage/secure_token_storage.dart';
import 'package:med_story/features/auth/domain/auth_models.dart';
import 'package:med_story/features/auth/presentation/controllers/auth_controller.dart';
import 'package:med_story/features/settings/presentation/screens/settings_screen.dart';
import 'package:med_story/features/shell/presentation/screens/app_shell.dart';
import 'package:med_story/features/subjects/presentation/controllers/subject_controller.dart';
import 'package:med_story/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:med_story/l10n/app_localizations.dart';

class _OnboardingSeenStorage extends SecureTokenStorage {
  const _OnboardingSeenStorage() : super(const FlutterSecureStorage());

  @override
  Future<bool> hasSeenOnboarding() async => true;
}

class _AuthenticatedAuthController extends AuthController {
  @override
  Future<AuthState> build() async => const AuthState.authenticated(
    AppUser(
      id: 'user-1',
      email: 'alex@example.com',
      fullName: 'Alex',
      locale: 'en',
    ),
  );
}

class _EmptySubjectController extends SubjectController {
  @override
  Future<SubjectState> build() async =>
      const SubjectState(subjects: [], selectedSubjectId: null);
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

  testWidgets(
    'settings stays in timeline shell and supports button and route pops',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(
              _AuthenticatedAuthController.new,
            ),
            subjectControllerProvider.overrideWith(_EmptySubjectController.new),
            secureTokenStorageProvider.overrideWithValue(
              const _OnboardingSeenStorage(),
            ),
          ],
          child: const MedStoryApp(),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(TimelineScreen)),
      )!;
      final router = GoRouter.of(tester.element(find.byType(TimelineScreen)));

      await tester.tap(find.byTooltip(l10n.navSettings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      expect(
        GoRouterState.of(tester.element(find.byType(SettingsScreen))).uri.path,
        '/timeline/settings',
      );
      expect(router.canPop(), isTrue);
      final settingsRoute =
          ModalRoute.of(tester.element(find.byType(SettingsScreen)))!
              as PageRoute<dynamic>;
      expect(settingsRoute.popGestureEnabled, isTrue);

      await tester.tap(
        find.byTooltip(
          MaterialLocalizations.of(
            tester.element(find.byType(SettingsScreen)),
          ).backButtonTooltip,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TimelineScreen), findsOneWidget);

      router.go('/settings');
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        GoRouterState.of(tester.element(find.byType(SettingsScreen))).uri.path,
        '/timeline/settings',
      );
      expect(router.canPop(), isTrue);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(TimelineScreen), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    },
  );
}
