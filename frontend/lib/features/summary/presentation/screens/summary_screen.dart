import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_alert_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/medical_summary.dart';
import '../controllers/summary_controller.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.listen(summaryControllerProvider, (previous, next) {
      final state = next.value;
      if (state == null) return;
      final message = _snackMessage(l10n, state);
      if (message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      ref.read(summaryControllerProvider.notifier).consumeActionMessages();
    });

    return SafeArea(
      child: ref
          .watch(summaryControllerProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _SummaryError(message: error.toString()),
            data: (state) => RefreshIndicator(
              onRefresh: () =>
                  ref.read(summaryControllerProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xxxl,
                    ),
                    sliver: SliverList.list(
                      children: [
                        _SummaryHeader(state: state),
                        if (state.visibleSummary == null)
                          _SummaryNotReady(state: state)
                        else
                          _SummaryContent(summary: state.visibleSummary!),
                        if (state.visibleSummary != null) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            l10n.summaryAiOrganizedNote,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.secondaryInk,
                                  height: 1.4,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          l10n.summaryBoundaryNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.secondaryInk,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

String? _snackMessage(AppLocalizations l10n, SummaryState state) {
  final error = state.actionError;
  if (error == null) return null;
  if (error.contains('summary_regenerate_failed')) {
    return l10n.summaryRegenerateFailedMessage;
  }
  if (error == 'visit_reason_save_failed') {
    return l10n.summaryVisitReasonSaveFailed;
  }
  return l10n.summaryActionFailedMessage;
}

class _SummaryHeader extends ConsumerWidget {
  const _SummaryHeader({required this.state});

  final SummaryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final summary = state.visibleSummary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.summaryHeadline,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (summary != null) ...[
          _SummaryStatusRow(
            createdAt: summary.createdAt,
            isBusy:
                state.isRegenerating ||
                state.isSavingReason ||
                state.isRefreshing,
            isRegenerating: state.isRegenerating,
            onRegenerate: () =>
                ref.read(summaryControllerProvider.notifier).regenerate(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _VisitReasonRow(
          reason: state.reason,
          enabled:
              !state.isSavingReason &&
              !state.isRegenerating &&
              !state.isRefreshing,
          isSaving: state.isSavingReason,
        ),
      ],
    );
  }
}

class _SummaryStatusRow extends StatelessWidget {
  const _SummaryStatusRow({
    required this.createdAt,
    required this.isBusy,
    required this.isRegenerating,
    required this.onRegenerate,
  });

  final DateTime? createdAt;
  final bool isBusy;
  final bool isRegenerating;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final updatedAt = createdAt == null
        ? null
        : _formatDateTime(context, createdAt!);
    return Row(
      children: [
        Expanded(
          child: updatedAt == null
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.secondaryInk,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        updatedAt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        IconButton.outlined(
          tooltip: context.l10n.summaryRegenerateAction,
          onPressed: isBusy ? null : onRegenerate,
          icon: isRegenerating
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }
}

class _VisitReasonRow extends ConsumerWidget {
  const _VisitReasonRow({
    required this.reason,
    required this.enabled,
    required this.isSaving,
  });
  final String reason;
  final bool enabled;
  final bool isSaving;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? () => _editReason(context, ref, reason) : null,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.quietSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.deepClinicalBlue,
                size: 21,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.summaryVisitReasonLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.secondaryInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      reason.isEmpty ? l10n.summaryVisitReasonEmpty : reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: reason.isEmpty
                            ? AppColors.secondaryInk
                            : AppColors.patientInk,
                        fontWeight: reason.isEmpty
                            ? FontWeight.w400
                            : FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.summaryVisitReasonEdit,
                onPressed: enabled
                    ? () => _editReason(context, ref, reason)
                    : null,
                icon: isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editReason(
    BuildContext context,
    WidgetRef ref,
    String initial,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _VisitReasonDialog(initial: initial),
    );
    if (result != null) {
      await ref.read(summaryControllerProvider.notifier).updateReason(result);
    }
  }
}

class _VisitReasonDialog extends StatefulWidget {
  const _VisitReasonDialog({required this.initial});
  final String initial;

  @override
  State<_VisitReasonDialog> createState() => _VisitReasonDialogState();
}

class _VisitReasonDialogState extends State<_VisitReasonDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppAlertDialog(
    title: context.l10n.summaryVisitReasonLabel,
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: 300,
      minLines: 1,
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: context.l10n.summaryVisitReasonHint,
        alignLabelWithHint: true,
      ),
    ),
    primaryAction: FilledButton(
      onPressed: () => Navigator.pop(context, _controller.text.trim()),
      child: Text(context.l10n.visitPrepSave),
    ),
    secondaryAction: TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryInk,
        minimumSize: const Size(0, 48),
      ),
      onPressed: () => Navigator.pop(context),
      child: Text(context.l10n.eventCancelAction),
    ),
  );
}

class _SummaryNotReady extends ConsumerWidget {
  const _SummaryNotReady({required this.state});
  final SummaryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.summaryNotReadyTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.summaryNotReadyMessage),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed:
                state.subject == null ||
                    state.isRegenerating ||
                    state.isSavingReason ||
                    state.isRefreshing
                ? null
                : () =>
                      ref.read(summaryControllerProvider.notifier).regenerate(),
            icon: state.isRegenerating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high_rounded),
            label: Text(l10n.summaryGenerateAction),
          ),
        ],
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary});
  final MedicalSummary summary;

  @override
  Widget build(BuildContext context) {
    final sections = _summarySections(context.l10n, summary.content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          for (var index = 0; index < sections.length; index++) ...[
            _StructuredSection(section: sections[index]),
            if (index != sections.length - 1)
              const Divider(height: AppSpacing.xxl),
          ],
        ],
      ],
    );
  }
}

class _StructuredSection extends StatelessWidget {
  const _StructuredSection({required this.section});
  final _SummarySection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(section.icon, size: 21, color: AppColors.deepClinicalBlue),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.patientInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in section.items.take(5))
          _SummaryItemRow(
            item: item,
            showSourceAction: section.showSourceAction,
          ),
      ],
    );
  }
}

class _SummaryItemRow extends StatelessWidget {
  const _SummaryItemRow({required this.item, required this.showSourceAction});
  final SummaryItem item;
  final bool showSourceAction;

  @override
  Widget build(BuildContext context) {
    final sources = item.sources.isNotEmpty
        ? item.sources
        : item.sourceEventIds
              .map(
                (id) =>
                    SummarySource(eventId: id, title: item.text, eventDate: ''),
              )
              .toList(growable: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(
              Icons.circle,
              size: 6,
              color: AppColors.deepClinicalBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.patientInk,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (item.detail.trim().isNotEmpty)
                  Text(
                    item.detail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryInk,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
          if (showSourceAction && sources.isNotEmpty)
            IconButton(
              tooltip: context.l10n.summarySourceAction,
              color: AppColors.deepClinicalBlue,
              onPressed: () => _openSources(context, sources),
              icon: const Icon(Icons.description_outlined, size: 20),
            ),
        ],
      ),
    );
  }
}

Future<void> _openSources(
  BuildContext context,
  List<SummarySource> sources,
) async {
  if (sources.length == 1) {
    context.push('/events/${sources.single.eventId}');
    return;
  }
  final selected = await showModalBottomSheet<SummarySource>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Text(
              context.l10n.summarySourcesTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final source in sources)
                  ListTile(
                    title: Text(source.title),
                    subtitle: Text(
                      [
                            _formatEventDate(context, source.eventDate),
                            source.documentTitle,
                          ]
                          .whereType<String>()
                          .where((value) => value.isNotEmpty)
                          .join(' • '),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.pop(sheetContext, source),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  if (selected != null && context.mounted) {
    context.push('/events/${selected.eventId}');
  }
}

class _SummaryError extends StatelessWidget {
  const _SummaryError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Text('${context.l10n.summaryLoadFailedMessage}\n$message'),
    ),
  );
}

List<_SummarySection> _summarySections(
  AppLocalizations l10n,
  Map<String, dynamic> content,
) {
  const definitions = <(List<String>, IconData)>[
    (['current_concerns', 'key_symptoms'], Icons.monitor_heart_outlined),
    (
      ['important_diagnoses_and_findings', 'major_diagnoses'],
      Icons.assignment_outlined,
    ),
    (['allergies'], Icons.warning_amber_rounded),
    (
      ['current_medications', 'relevant_medications', 'medications'],
      Icons.medication_outlined,
    ),
    (
      ['important_test_results', 'important_examinations', 'test_results'],
      Icons.biotech_outlined,
    ),
    (
      [
        'previous_treatments_and_outcomes',
        'treatment_history',
        'treatment_outcomes',
      ],
      Icons.history_rounded,
    ),
    (
      ['procedures_and_hospitalizations', 'procedures', 'hospitalizations'],
      Icons.local_hospital_outlined,
    ),
  ];
  return definitions
      .map((definition) {
        final items = _firstSummaryItems(content, definition.$1);
        if (items.isEmpty) return null;
        return _SummarySection(
          title: switch (definition.$1.first) {
            'current_concerns' => l10n.summarySectionCurrentConcerns,
            'important_diagnoses_and_findings' =>
              l10n.summarySectionImportantDiagnosesAndFindings,
            'allergies' => l10n.summarySectionAllergies,
            'current_medications' => l10n.summarySectionCurrentMedications,
            'important_test_results' => l10n.summarySectionImportantTestResults,
            'previous_treatments_and_outcomes' =>
              l10n.summarySectionPreviousTreatmentsAndOutcomes,
            _ => l10n.summarySectionProceduresAndHospitalizations,
          },
          items: items,
          icon: definition.$2,
          showSourceAction: definition.$1.first != 'current_concerns',
        );
      })
      .nonNulls
      .toList(growable: false);
}

List<SummaryItem> _firstSummaryItems(
  Map<String, dynamic> content,
  List<String> keys,
) {
  for (final key in keys) {
    final items = _summaryItems(content[key]).take(5).toList(growable: false);
    if (items.isNotEmpty) return items;
  }
  return const [];
}

Iterable<SummaryItem> _summaryItems(Object? value) sync* {
  if (value is String) {
    if (value.trim().isNotEmpty) yield SummaryItem(text: value.trim());
    return;
  }
  if (value is List) {
    for (final item in value) {
      if (item is String && item.trim().isNotEmpty) {
        yield SummaryItem(text: item.trim());
      } else if (item is Map) {
        final parsed = SummaryItem.fromJson(Map<String, dynamic>.from(item));
        if (parsed.text.trim().isNotEmpty) yield parsed;
      }
    }
  }
}

String _formatDateTime(BuildContext context, DateTime date) => DateFormat.yMMMd(
  Localizations.localeOf(context).toLanguageTag(),
).format(date.toLocal());

String _formatEventDate(BuildContext context, String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
}

class _SummarySection {
  const _SummarySection({
    required this.title,
    required this.items,
    required this.icon,
    required this.showSourceAction,
  });
  final String title;
  final List<SummaryItem> items;
  final IconData icon;
  final bool showSourceAction;
}
