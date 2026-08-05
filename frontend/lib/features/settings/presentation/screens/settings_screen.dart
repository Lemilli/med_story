import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      if (message == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
        ref.read(settingsControllerProvider.notifier).consumeActionMessages();
      });
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              context.go('/timeline');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: authState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _SettingsMessage(message: l10n.networkFailedMessage),
          data: (auth) {
            final user = auth.user;
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
                _ProfileHeader(user: user),
                const SizedBox(height: AppSpacing.xxl),
                _SettingsGroup(
                  title: l10n.settingsDataSectionTitle,
                  children: const [_PrivacyDisclosure()],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsGroup(
                  title: l10n.settingsPreferencesSectionTitle,
                  children: [
                    const _LimitsDisclosure(),
                    const _GroupDivider(),
                    _LanguageDisclosure(user: user, state: settingsState),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsGroup(
                  title: l10n.settingsAccountSectionTitle,
                  children: [
                    _LogoutRow(),
                    const _GroupDivider(),
                    _DeleteAccountRow(state: settingsState),
                  ],
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
    return switch (state.actionError) {
      null => null,
      SettingsActionError.localeUpdateFailed =>
        l10n.settingsLocaleUpdateFailedMessage,
      SettingsActionError.deleteAccountFailed =>
        l10n.settingsDeleteAccountFailedMessage,
    };
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = user.fullName.isEmpty
        ? l10n.authUnnamedUser
        : user.fullName;
    final initial = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().characters.first.toUpperCase();

    return Semantics(
      header: true,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.selectedSurface,
            foregroundColor: AppColors.controlledCrimson,
            child: Text(
              initial,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.patientInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryInk,
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

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.secondaryInk,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Material(
          color: AppColors.quietSurface,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.clinicalLine),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) => const Divider(height: 1, indent: 64);
}

class _PrivacyDisclosure extends StatefulWidget {
  const _PrivacyDisclosure();

  @override
  State<_PrivacyDisclosure> createState() => _PrivacyDisclosureState();
}

class _PrivacyDisclosureState extends State<_PrivacyDisclosure> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _DisclosureRow(
      icon: Icons.lock_outline_rounded,
      title: l10n.settingsPrivacyNoteTitle,
      summary: l10n.settingsPrivacySummary,
      expanded: _expanded,
      onTap: () => setState(() => _expanded = !_expanded),
      expandedChild: Text(
        l10n.settingsPrivacyNoteDescription,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryInk,
          height: 1.4,
        ),
      ),
    );
  }
}

class _LimitsDisclosure extends ConsumerStatefulWidget {
  const _LimitsDisclosure();

  @override
  ConsumerState<_LimitsDisclosure> createState() => _LimitsDisclosureState();
}

class _LimitsDisclosureState extends ConsumerState<_LimitsDisclosure> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final usage = ref.watch(accountUsageProvider);
    final summary = usage.when(
      loading: () => l10n.settingsLimitsLoading,
      error: (_, _) => l10n.settingsUsageUnavailable,
      data: (_) => l10n.settingsLimitsSummary,
    );
    return _DisclosureRow(
      icon: Icons.speed_outlined,
      title: l10n.settingsLimitsTitle,
      summary: summary,
      expanded: _expanded,
      onTap: () => setState(() => _expanded = !_expanded),
      expandedChild: usage.when(
        loading: () => const LinearProgressIndicator(),
        error: (_, _) => _SettingsRetry(
          message: l10n.settingsUsageLoadFailedMessage,
          onRetry: () => ref.invalidate(accountUsageProvider),
        ),
        data: (value) => Column(
          children: [
            _MetricRow(
              label: l10n.settingsAiUnitsLabel,
              value: value.aiUnitsRemainingToday == null
                  ? l10n.settingsUsageUnavailable
                  : l10n.settingsAiUnitsValue(value.aiUnitsRemainingToday!),
            ),
            const SizedBox(height: AppSpacing.md),
            _MetricRow(
              label: l10n.settingsStorageUsageLabel,
              value: value.storageBytesLimit <= 0
                  ? l10n.settingsUsageUnavailable
                  : l10n.settingsStorageUsageValue(
                      _formatMegabytes(value.storageBytesUsed),
                      _formatMegabytes(value.storageBytesLimit),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageDisclosure extends StatefulWidget {
  const _LanguageDisclosure({required this.user, required this.state});

  final AppUser user;
  final SettingsState state;

  @override
  State<_LanguageDisclosure> createState() => _LanguageDisclosureState();
}

class _LanguageDisclosureState extends State<_LanguageDisclosure> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _DisclosureRow(
      icon: Icons.language_rounded,
      title: l10n.settingsLanguageSectionTitle,
      summary: _languageName(l10n, widget.user.locale),
      expanded: _expanded,
      onTap: () => setState(() => _expanded = !_expanded),
      expandedChild: Column(
        children: [
          _LanguageOption(
            label: l10n.settingsLanguageEnglish,
            value: 'en',
            groupValue: widget.user.locale,
            isBusy: widget.state.isUpdatingLocale,
          ),
          const SizedBox(height: AppSpacing.xs),
          _LanguageOption(
            label: l10n.settingsLanguageRussian,
            value: 'ru',
            groupValue: widget.user.locale,
            isBusy: widget.state.isUpdatingLocale,
          ),
        ],
      ),
    );
  }
}

class _DisclosureRow extends StatelessWidget {
  const _DisclosureRow({
    required this.icon,
    required this.title,
    required this.summary,
    required this.expanded,
    required this.onTap,
    required this.expandedChild,
  });

  final IconData icon;
  final String title;
  final String summary;
  final bool expanded;
  final VoidCallback onTap;
  final Widget expandedChild;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.deepClinicalBlue),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.patientInk,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.secondaryInk),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.secondaryInk,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: expandedChild,
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryInk),
        ),
      ),
      const SizedBox(width: AppSpacing.md),
      Text(
        value,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.patientInk,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _SettingsRetry extends StatelessWidget {
  const _SettingsRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryInk),
      ),
      const SizedBox(height: AppSpacing.sm),
      OutlinedButton(
        onPressed: onRetry,
        child: Text(context.l10n.documentRetryAction),
      ),
    ],
  );
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
    return Semantics(
      selected: selected,
      child: ListTile(
        minVerticalPadding: AppSpacing.xs,
        contentPadding: EdgeInsets.zero,
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
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _LogoutRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _ActionRow(
      icon: Icons.logout_rounded,
      title: l10n.authLogoutAction,
      description: l10n.settingsLogoutDescription,
      onTap: () => ref.read(authControllerProvider.notifier).logout(),
    );
  }
}

class _DeleteAccountRow extends ConsumerWidget {
  const _DeleteAccountRow({required this.state});

  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _ActionRow(
      icon: Icons.delete_outline_rounded,
      title: l10n.settingsDeleteAccountTitle,
      description: l10n.settingsDeleteAccountDescription,
      destructive: true,
      isLoading: state.isDeletingAccount,
      onTap: state.isDeletingAccount
          ? null
          : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => const _DeleteAccountDialog(),
              );
              if (confirmed == true) {
                await ref
                    .read(settingsControllerProvider.notifier)
                    .deleteAccount();
              }
            },
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.destructive = false,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool destructive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? AppColors.controlledCrimson
        : AppColors.deepClinicalBlue;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      color: color,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
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

class _SettingsMessage extends StatelessWidget {
  const _SettingsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
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

String _languageName(AppLocalizations l10n, String locale) => switch (locale) {
  'ru' => l10n.settingsLanguageRussian,
  _ => l10n.settingsLanguageEnglish,
};

int _formatMegabytes(int bytes) => (bytes / (1024 * 1024)).ceil();
