import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/auth_form_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/capture/presentation/screens/capture_screen.dart';
import '../features/documents/presentation/screens/document_detail_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/events/presentation/screens/event_form_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/shell/presentation/screens/app_shell.dart';
import '../features/summary/presentation/screens/summary_screen.dart';
import '../features/timeline/presentation/screens/timeline_screen.dart';

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

      if (authState.isLoading && !isAuthRoute) {
        return location == '/' ? null : '/';
      }

      final isAuthenticated =
          authState.hasValue && authState.value?.isAuthenticated == true;

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      if (isAuthenticated && (isAuthRoute || location == '/')) {
        return '/timeline';
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
      GoRoute(path: '/home', redirect: (context, state) => '/timeline'),
      GoRoute(
        path: '/events/new',
        builder: (context, state) => const EventFormScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/events/:id/edit',
        builder: (context, state) =>
            EventFormScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/documents/:id',
        builder: (context, state) =>
            DocumentDetailScreen(documentId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timeline',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: TimelineScreen()),
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
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SummaryScreen()),
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
