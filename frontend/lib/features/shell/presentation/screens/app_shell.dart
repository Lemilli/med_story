import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.clinicalLine)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex == 0 ? 0 : 2,
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
    if (index == 1) {
      _showAddSheet(context);
      return;
    }
    navigationShell.goBranch(
      index == 0 ? 0 : 1,
      initialLocation: (index == 0 ? 0 : 1) == navigationShell.currentIndex,
    );
  }

  void _showAddSheet(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _AddAction(icon: Icons.document_scanner_outlined, title: l10n.scanDocumentTitle, onTap: () => _open(sheetContext, '/capture')),
            _AddAction(icon: Icons.add_photo_alternate_outlined, title: l10n.addPhotoTitle, onTap: () => _open(sheetContext, '/capture')),
            _AddAction(icon: Icons.mic_none_rounded, title: l10n.recordVoiceTitle, onTap: () => _open(sheetContext, '/capture')),
            _AddAction(icon: Icons.edit_note_rounded, title: l10n.writeNoteTitle, onTap: () => _open(sheetContext, '/notes/new')),
            _AddAction(icon: Icons.add_rounded, title: l10n.timelineAddEvent, onTap: () => _open(sheetContext, '/events/new')),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.push(route);
  }
}

class _AddAction extends StatelessWidget {
  const _AddAction({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    minVerticalPadding: AppSpacing.sm,
    leading: Icon(icon),
    title: Text(title),
    onTap: onTap,
  );
}
