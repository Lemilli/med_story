import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../../../l10n/l10n.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showOnboardingIfNeeded(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.clinicalLine)),
        ),
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          backgroundColor: AppColors.clinicalWhite,
          indicatorColor: AppColors.quietSurface,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) => _goToBranch(context, index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.history_rounded),
              label: l10n.navTimeline,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline_rounded),
              selectedIcon: const Icon(Icons.add_circle_rounded),
              label: l10n.navCapture,
            ),
            NavigationDestination(
              icon: const Icon(Icons.assignment_outlined),
              selectedIcon: const Icon(Icons.assignment_rounded),
              label: l10n.navSummary,
            ),
          ],
        ),
      ),
    );
  }

  void _goToBranch(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  Future<void> _showOnboardingIfNeeded() async {
    final storage = ref.read(secureTokenStorageProvider);
    if (await storage.hasSeenOnboarding() || !mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sheetContext.l10n.onboardingTitle,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(sheetContext.l10n.onboardingBody),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  storage.markOnboardingSeen();
                  Navigator.pop(sheetContext);
                  context.go('/capture');
                },
                child: Text(sheetContext.l10n.onboardingStart),
              ),
              TextButton(
                onPressed: () {
                  storage.markOnboardingSeen();
                  Navigator.pop(sheetContext);
                },
                child: Text(sheetContext.l10n.onboardingSkip),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
