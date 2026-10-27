import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../../../core/widgets/clear_index_navigation_bar.dart';
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
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: ClearIndexNavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => _goToBranch(context, index),
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
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: AppColors.clinicalWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (sheetContext) => _OnboardingSheet(
        onStart: () {
          storage.markOnboardingSeen();
          Navigator.pop(sheetContext);
          context.go('/capture');
        },
        onSkip: () {
          storage.markOnboardingSeen();
          Navigator.pop(sheetContext);
        },
      ),
    );
  }
}

class _OnboardingSheet extends StatelessWidget {
  const _OnboardingSheet({required this.onStart, required this.onSkip});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.clinicalLine,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.selectedSurface,
                shape: BoxShape.circle,
              ),
              child: const ExcludeSemantics(
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.cobalt,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.l10n.onboardingTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.16,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                context.l10n.onboardingBody,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryInk,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onStart,
                child: Text(context.l10n.onboardingStart),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 48),
                foregroundColor: AppColors.secondaryInk,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(context.l10n.onboardingSkip),
            ),
          ],
        ),
      ),
    );
  }
}
