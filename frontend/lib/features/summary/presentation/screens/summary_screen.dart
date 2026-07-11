import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../../events/domain/medical_event.dart';
import '../../../events/presentation/event_type_l10n.dart';
import '../../domain/medical_summary.dart';
import '../controllers/summary_controller.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen(summaryControllerProvider, (previous, next) {
      final state = next.hasValue ? next.value : null;
      if (state == null) {
        return;
      }
      final message = _snackMessage(l10n, state);
      if (message == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      ref.read(summaryControllerProvider.notifier).consumeActionMessages();
    });

    final summaryState = ref.watch(summaryControllerProvider);
    return SafeArea(
      child: summaryState.when(
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
                    const SizedBox(height: AppSpacing.lg),
                    _BoundaryNotice(message: l10n.summaryBoundaryNote),
                    if (state.loadResult.fromCache) ...[
                      const SizedBox(height: AppSpacing.md),
                      _BoundaryNotice(message: l10n.summaryOfflineNotice),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    if (state.visibleSummary == null)
                      _SummaryNotReady(state: state)
                    else
                      _SummaryContent(summary: state.visibleSummary!),
                    const SizedBox(height: AppSpacing.xl),
                    _VersionHistory(state: state),
                    const SizedBox(height: AppSpacing.xl),
                    _HistorySearch(
                      controller: _searchController,
                      query: state.searchQuery,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _snackMessage(AppLocalizations l10n, SummaryState state) {
    if (state.queuedMessage != null) {
      return l10n.summaryRegenerateQueuedMessage;
    }
    if (state.exportCompleted) {
      return l10n.summaryExportSharedMessage;
    }
    final error = state.actionError;
    if (error == null) {
      return null;
    }
    if (error == 'summary_not_ready') {
      return l10n.summaryNotReadyMessage;
    }
    if (error.contains('summary_regenerate_failed')) {
      return l10n.summaryRegenerateFailedMessage;
    }
    if (error.contains('summary_export_failed')) {
      return l10n.summaryExportFailedMessage;
    }
    return l10n.summaryActionFailedMessage;
  }
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
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
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    state.subject == null
                        ? l10n.summaryNoSubjectMessage
                        : l10n.summarySubjectLabel(state.subject!.displayName),
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryInk,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              tooltip: l10n.summaryRefreshAction,
              onPressed: state.isRefreshing
                  ? null
                  : () =>
                        ref.read(summaryControllerProvider.notifier).refresh(),
              icon: state.isRefreshing
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        if (summary != null) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaChip(label: l10n.summaryVersionLabel(summary.version)),
              _MetaChip(
                label: l10n.summaryEventCountLabel(
                  summary.generatedFromEventCount,
                ),
              ),
              if (summary.createdAt != null)
                _MetaChip(
                  label: l10n.summaryGeneratedAt(
                    _formatDateTime(context, summary.createdAt!),
                  ),
                ),
            ],
          ),
          if (state.isPreviewingVersion) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => ref
                  .read(summaryControllerProvider.notifier)
                  .previewVersion(null),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(l10n.summaryReturnToCurrentAction),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.currentSummary == null
                      ? null
                      : () => context.push('/visit-preparation'),
                  icon: state.isExporting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share_rounded),
                  label: Text(l10n.summaryPrepareVisitAction),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.outlined(
                tooltip: l10n.summaryRegenerateAction,
                onPressed: state.isRegenerating
                    ? null
                    : () => ref
                          .read(summaryControllerProvider.notifier)
                          .regenerate(),
                icon: state.isRegenerating
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_fix_high_rounded),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SummaryNotReady extends ConsumerWidget {
  const _SummaryNotReady({required this.state});

  final SummaryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.assignment_outlined,
              color: AppColors.deepClinicalBlue,
              size: 36,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.summaryNotReadyTitle,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.patientInk,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.summaryNotReadyMessage,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.secondaryInk,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: state.subject == null || state.isRegenerating
                  ? null
                  : () => ref
                        .read(summaryControllerProvider.notifier)
                        .regenerate(),
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
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary});

  final MedicalSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final sections = _summarySections(l10n, summary.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.summaryNarrativeTitle,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          summary.narrativeText.isEmpty
              ? l10n.summaryNoNarrativeMessage
              : summary.narrativeText,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.patientInk,
            height: 1.45,
          ),
        ),
        if (sections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          for (final section in sections) ...[
            _StructuredSection(section: section),
            const Divider(height: AppSpacing.xl),
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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in section.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: SizedBox.square(
                    dimension: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepClinicalBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.patientInk,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VersionHistory extends ConsumerWidget {
  const _VersionHistory({required this.state});

  final SummaryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (state.versions.isEmpty) {
      return const SizedBox.shrink();
    }
    return OutlinedButton.icon(
      onPressed: () => _showVersionHistory(context, ref, state),
      icon: const Icon(Icons.history_rounded),
      label: Text(l10n.summaryVersionHistoryAction),
    );
  }

  void _showVersionHistory(
    BuildContext context,
    WidgetRef ref,
    SummaryState state,
  ) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            itemBuilder: (context, index) {
              final summary = state.versions[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.summaryVersionLabel(summary.version)),
                subtitle: Text(
                  [
                    if (summary.createdAt != null)
                      _formatDateTime(context, summary.createdAt!),
                    l10n.summaryEventCountLabel(
                      summary.generatedFromEventCount,
                    ),
                    if (summary.language.isNotEmpty) summary.language,
                  ].join(' · '),
                ),
                trailing: summary.isCurrent
                    ? Text(l10n.summaryCurrentVersionLabel)
                    : const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).pop();
                  ref
                      .read(summaryControllerProvider.notifier)
                      .previewVersion(summary.isCurrent ? null : summary);
                },
              );
            },
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemCount: state.versions.length,
          ),
        );
      },
    );
  }
}

class _HistorySearch extends ConsumerWidget {
  const _HistorySearch({required this.controller, required this.query});

  final TextEditingController controller;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    if (controller.text != query) {
      controller.text = query;
    }
    final events = ref.watch(summarySearchEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.summaryHistorySearchTitle,
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.summaryHistorySearchLabel,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => ref
              .read(summaryControllerProvider.notifier)
              .updateSearchQuery(value),
        ),
        const SizedBox(height: AppSpacing.md),
        if (query.isEmpty)
          Text(
            l10n.summaryHistorySearchEmptyHint,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          )
        else
          events.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (_, _) => Text(l10n.summaryHistorySearchFailedMessage),
            data: (items) {
              if (items.isEmpty) {
                return Text(l10n.summaryHistorySearchNoResults);
              }
              return Column(
                children: items
                    .map((event) => _SummaryEventRow(event: event))
                    .toList(growable: false),
              );
            },
          ),
      ],
    );
  }
}

class _SummaryEventRow extends StatelessWidget {
  const _SummaryEventRow({required this.event});

  final MedicalEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final date = DateTime.tryParse(event.eventDate);
    final formattedDate = date == null
        ? event.eventDate
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(date);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: AppSpacing.sm,
      title: Text(
        event.title,
        style: textTheme.titleSmall?.copyWith(
          color: AppColors.patientInk,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        '$formattedDate · ${event.eventType.label(l10n)}',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.secondaryInk),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push('/events/${event.id}'),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(label),
      ),
    );
  }
}

class _BoundaryNotice extends StatelessWidget {
  const _BoundaryNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.deepClinicalBlue,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _SummaryError extends StatelessWidget {
  const _SummaryError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 42),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.summaryLoadFailedMessage, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

List<_SummarySection> _summarySections(
  AppLocalizations l10n,
  Map<String, dynamic> content,
) {
  final keys = <String>[
    'key_symptoms',
    'major_diagnoses',
    'medications',
    'procedures',
    'hospitalizations',
    'allergies',
    'test_results',
    'treatment_outcomes',
    'open_questions',
    'care_team',
    ...content.keys.where((key) => !_knownSummaryKeys.contains(key)),
  ];

  return keys
      .map((key) {
        final items = _summaryItems(content[key]);
        if (items.isEmpty) {
          return null;
        }
        return _SummarySection(title: _sectionTitle(l10n, key), items: items);
      })
      .nonNulls
      .toList(growable: false);
}

List<String> _summaryItems(Object? value) {
  if (value == null) {
    return const <String>[];
  }
  if (value is String) {
    return value.trim().isEmpty ? const <String>[] : <String>[value.trim()];
  }
  if (value is List) {
    return value
        .map(_summaryItemText)
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
  final text = _summaryItemText(value);
  return text.isEmpty ? const <String>[] : <String>[text];
}

String _summaryItemText(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value.trim();
  }
  if (value is Map) {
    final parts = <String>[];
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final text = _summaryItemText(entry.value);
      if (text.isNotEmpty) {
        parts.add('$key: $text');
      }
    }
    return parts.join(', ');
  }
  if (value is Iterable) {
    return value
        .map(_summaryItemText)
        .where((item) => item.isNotEmpty)
        .join(', ');
  }
  return value.toString();
}

String _sectionTitle(AppLocalizations l10n, String key) {
  return switch (key) {
    'key_symptoms' => l10n.summarySectionKeySymptoms,
    'major_diagnoses' => l10n.summarySectionMajorDiagnoses,
    'medications' => l10n.summarySectionMedications,
    'procedures' => l10n.summarySectionProcedures,
    'hospitalizations' => l10n.summarySectionHospitalizations,
    'allergies' => l10n.summarySectionAllergies,
    'test_results' => l10n.summarySectionTestResults,
    'treatment_outcomes' => l10n.summarySectionTreatmentOutcomes,
    'open_questions' => l10n.summarySectionOpenQuestions,
    'care_team' => l10n.summarySectionCareTeam,
    _ => l10n.summaryUnknownSectionTitle(key.replaceAll('_', ' ')),
  };
}

String _formatDateTime(BuildContext context, DateTime date) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).add_Hm().format(date.toLocal());
}

class _SummarySection {
  const _SummarySection({required this.title, required this.items});

  final String title;
  final List<String> items;
}

const _knownSummaryKeys = <String>{
  'key_symptoms',
  'major_diagnoses',
  'medications',
  'procedures',
  'hospitalizations',
  'allergies',
  'test_results',
  'treatment_outcomes',
  'open_questions',
  'care_team',
};
