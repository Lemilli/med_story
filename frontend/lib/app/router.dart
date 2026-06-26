import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/auth_form_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/capture/presentation/screens/capture_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/shell/presentation/screens/app_shell.dart';
import '../features/shell/presentation/screens/placeholder_tab_screen.dart';
import '../l10n/l10n.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.listen(authControllerProvider, (_, _) => refreshNotifier.notify());
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';

      if (authState.isLoading) {
        return location == '/' ? null : '/';
      }

      final isAuthenticated =
          authState.hasValue && authState.value?.isAuthenticated == true;

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      if (isAuthenticated && (isAuthRoute || location == '/')) {
        return '/capture';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const AuthFormScreen(mode: AuthFormMode.login),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const AuthFormScreen(mode: AuthFormMode.register),
      ),
      GoRoute(path: '/home', redirect: (context, state) => '/capture'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                pageBuilder: (context, state) {
                  final l10n = context.l10n;
                  return NoTransitionPage(
                    child: PlaceholderTabScreen(
                      icon: Icons.history_rounded,
                      title: l10n.timelineTitle,
                      message: l10n.timelineMessage,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/capture',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CaptureScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/summary',
                pageBuilder: (context, state) {
                  final l10n = context.l10n;
                  return NoTransitionPage(
                    child: PlaceholderTabScreen(
                      icon: Icons.assignment_outlined,
                      title: l10n.summaryTitle,
                      message: l10n.summaryMessage,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
