import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_alert_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/domain/auth_models.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final settingsState = ref.watch(settingsControllerProvider);

    ref.listen(settingsControllerProvider, (previous, next) {
      final message = _snackMessage(l10n, next);
      if (message == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      ref.read(settingsControllerProvider.notifier).consumeActionMessages();
    });

    return Scaffold(
      body: SafeArea(
        child: authState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _SettingsMessage(message: l10n.networkFailedMessage),
          data: (state) {
            final user = state.user;
            if (user == null) {
              return _SettingsMessage(message: l10n.authCheckingSession);
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              children: [
                _SettingsHeader(user: user),
                const SizedBox(height: AppSpacing.xl),
                _OrganizerNotice(),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(
                  title: l10n.settingsAccountSectionTitle,
                  child: _AccountPanel(user: user),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsSection(
                  title: l10n.settingsPrivacySectionTitle,
                  child: const _PrivacyPanel(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsSection(
                  title: l10n.settingsLanguageSectionTitle,
                  child: _LanguagePanel(user: user, state: settingsState),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsSection(
                  title: l10n.settingsActionsSectionTitle,
                  child: _AccountActionsPanel(state: settingsState),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String? _snackMessage(AppLocalizations l10n, SettingsState state) {
    final message = state.actionMessage;
    if (message != null) {
      return switch (message) {
        SettingsActionMessage.localeUpdated =>
          l10n.settingsLocaleUpdatedMessage,
      };
    }
    final error = state.actionError;
    if (error == null) {
      return null;
    }
    return switch (error) {
      SettingsActionError.localeUpdateFailed =>
        l10n.settingsLocaleUpdateFailedMessage,
      SettingsActionError.deleteAccountFailed =>
        l10n.settingsDeleteAccountFailedMessage,
    };
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = user.fullName.isEmpty
        ? l10n.authUnnamedUser
        : user.fullName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          displayName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.secondaryInk,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _OrganizerNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      container: true,
      label: l10n.authBoundarySemanticLabel,
      child: _Panel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: AppColors.deepClinicalBlue,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsOrganizerNoticeTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.patientInk,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.settingsOrganizerNoticeDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryInk,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _AccountPanel extends StatelessWidget {
  const _AccountPanel({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = user.fullName.isEmpty
        ? l10n.authUnnamedUser
        : user.fullName;

    return _Panel(
      child: Column(
        children: [
          _AccountRow(label: l10n.authFullNameLabel, value: displayName),
          const Divider(height: AppSpacing.xl),
          _AccountRow(label: l10n.authEmailLabel, value: user.email),
          const Divider(height: AppSpacing.xl),
          _AccountRow(
            label: l10n.authLocaleLabel,
            value: _languageName(l10n, user.locale),
          ),
        ],
      ),
    );
  }
}

class _PrivacyPanel extends StatelessWidget {
  const _PrivacyPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.lock_outline_rounded,
            title: l10n.settingsPrivacyNoteTitle,
            description: l10n.settingsPrivacyNoteDescription,
          ),
        ],
      ),
    );
  }
}

class _LanguagePanel extends ConsumerWidget {
  const _LanguagePanel({required this.user, required this.state});

  final AppUser user;
  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _LanguageOption(
            label: l10n.settingsLanguageEnglish,
            value: 'en',
            groupValue: user.locale,
            isBusy: state.isUpdatingLocale,
          ),
          const Divider(height: 1),
          _LanguageOption(
            label: l10n.settingsLanguageRussian,
            value: 'ru',
            groupValue: user.locale,
            isBusy: state.isUpdatingLocale,
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends ConsumerWidget {
  const _LanguageOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.isBusy,
  });

  final String label;
  final String value;
  final String groupValue;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = groupValue == value;

    return ListTile(
      minVerticalPadding: AppSpacing.md,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      enabled: !isBusy || selected,
      onTap: isBusy || selected
          ? null
          : () => ref
                .read(settingsControllerProvider.notifier)
                .updateLocale(value),
      leading: isBusy && selected
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? AppColors.deepClinicalBlue
                  : AppColors.secondaryInk,
            ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.patientInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AccountActionsPanel extends ConsumerWidget {
  const _AccountActionsPanel({required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.logout_rounded,
            title: l10n.authLogoutAction,
            description: l10n.settingsLogoutDescription,
            actionLabel: l10n.authLogoutAction,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          const Divider(height: 1),
          _ActionTile(
            icon: Icons.delete_outline_rounded,
            title: l10n.settingsDeleteAccountTitle,
            description: l10n.settingsDeleteAccountDescription,
            actionLabel: l10n.settingsDeleteAccountAction,
            isDestructive: true,
            isLoading: state.isDeletingAccount,
            onPressed: state.isDeletingAccount
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => const _DeleteAccountDialog(),
                    );
                    if (confirmed != true) {
                      return;
                    }
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .deleteAccount();
                  },
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final accent = isDestructive
        ? AppColors.controlledCrimson
        : AppColors.deepClinicalBlue;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.patientInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryInk,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon),
            label: Text(actionLabel),
            style: isDestructive
                ? OutlinedButton.styleFrom(
                    foregroundColor: AppColors.controlledCrimson,
                    side: const BorderSide(color: AppColors.controlledCrimson),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.patientInk),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.patientInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryInk,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canDelete =
        _controller.text.trim() == l10n.settingsDeleteAccountConfirmValue;

    return AppAlertDialog(
      title: l10n.settingsDeleteAccountDialogTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsDeleteAccountDialogMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.settingsDeleteAccountConfirmLabel,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      primaryAction: FilledButton(
        onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.controlledCrimson,
        ),
        child: Text(l10n.settingsDeleteAccountConfirmAction),
      ),
      secondaryAction: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryInk,
          minimumSize: const Size(0, 48),
        ),
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(l10n.settingsDeleteAccountCancelAction),
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.quietSurface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.clinicalLine),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
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

String _languageName(AppLocalizations l10n, String locale) {
  return switch (locale) {
    'ru' => l10n.settingsLanguageRussian,
    _ => l10n.settingsLanguageEnglish,
  };
}
