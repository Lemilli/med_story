import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);

    return SafeArea(
      child: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _SettingsMessage(message: l10n.networkFailedMessage),
        data: (state) {
          final user = state.user;
          if (user == null) {
            return _SettingsMessage(message: l10n.authCheckingSession);
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.settingsMessage,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondaryInk,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _AccountPanel(
                email: user.email,
                fullName: user.fullName,
                locale: user.locale,
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.authLogoutAction),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({
    required this.email,
    required this.fullName,
    required this.locale,
  });

  final String email;
  final String fullName;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = fullName.isEmpty ? l10n.authUnnamedUser : fullName;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        border: Border.all(color: AppColors.clinicalLine),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.authMePanelTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.lg),
            _AccountRow(label: l10n.authFullNameLabel, value: displayName),
            const Divider(height: AppSpacing.xl),
            _AccountRow(label: l10n.authEmailLabel, value: email),
            const Divider(height: AppSpacing.xl),
            _AccountRow(label: l10n.authLocaleLabel, value: locale),
          ],
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.secondaryInk,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SettingsMessage extends StatelessWidget {
  const _SettingsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
