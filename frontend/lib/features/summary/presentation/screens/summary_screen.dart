import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/medical_summary.dart';
import '../controllers/summary_controller.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
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
                    if (state.loadResult.fromCache) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _BoundaryNotice(message: l10n.summaryOfflineNotice),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    if (state.visibleSummary == null)
                      _SummaryNotReady(state: state)
                    else
                      _SummaryContent(summary: state.visibleSummary!),
                    const SizedBox(height: AppSpacing.xxxl),
                    _BoundaryNotice(message: l10n.summaryBoundaryNote),
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
          ],
        ),
        if (summary != null) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (summary.createdAt != null)
                Flexible(
                  child: _MetaChip(
                    label: _formatDateTime(context, summary.createdAt!),
                  ),
                ),
              const Spacer(),
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
                    : const Icon(Icons.refresh_rounded),
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
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.quietSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.subject_rounded,
                      size: 21,
                      color: AppColors.deepClinicalBlue,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.summaryNarrativeTitle,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.patientInk,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  summary.narrativeText.isEmpty
                      ? l10n.summaryNoNarrativeMessage
                      : summary.narrativeText,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.patientInk,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (sections.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          for (final section in sections) ...[
            _StructuredSection(section: section),
            if (section != sections.last) const Divider(height: AppSpacing.xxl),
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
        Row(
          children: [
            SizedBox.square(
              dimension: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: section.emphasized
                      ? AppColors.selectedSurface
                      : AppColors.quietSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  section.icon,
                  size: 20,
                  color: section.emphasized
                      ? AppColors.controlledCrimson
                      : AppColors.deepClinicalBlue,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                section.title,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.patientInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.quietSurface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  '${section.items.length}',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.secondaryInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final item in section.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _SummaryItem(item: item),
          ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.item});

  final String item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final parts = _splitSummaryItem(item);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Icon(Icons.circle, size: 6, color: AppColors.deepClinicalBlue),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: parts == null
              ? Text(
                  item,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.patientInk,
                    height: 1.45,
                  ),
                )
              : Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: parts.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' — ${parts.$2}'),
                    ],
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.patientInk,
                    height: 1.45,
                  ),
                ),
        ),
      ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.shield_outlined,
          color: AppColors.deepClinicalBlue,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          ),
        ),
      ],
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
    'treatment_history',
    'important_examinations',
    'relevant_medications',
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
        return _SummarySection(
          title: _sectionTitle(l10n, key),
          items: items,
          icon: _sectionIcon(key),
          emphasized: key == 'key_symptoms' || key == 'major_diagnoses',
        );
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
    'treatment_history' => l10n.summarySectionTreatmentHistory,
    'important_examinations' => l10n.summarySectionImportantExaminations,
    'relevant_medications' => l10n.summarySectionRelevantMedications,
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

IconData _sectionIcon(String key) {
  return switch (key) {
    'key_symptoms' => Icons.monitor_heart_outlined,
    'major_diagnoses' => Icons.assignment_outlined,
    'treatment_history' || 'treatment_outcomes' => Icons.history_rounded,
    'important_examinations' || 'test_results' => Icons.biotech_outlined,
    'relevant_medications' || 'medications' => Icons.medication_outlined,
    'procedures' => Icons.medical_services_outlined,
    'hospitalizations' => Icons.local_hospital_outlined,
    'allergies' => Icons.warning_amber_rounded,
    'open_questions' => Icons.help_outline_rounded,
    'care_team' => Icons.people_outline_rounded,
    _ => Icons.notes_rounded,
  };
}

(String, String)? _splitSummaryItem(String item) {
  for (final separator in const [' — ', ' – ']) {
    final index = item.indexOf(separator);
    if (index > 0 && index < item.length - separator.length) {
      return (
        item.substring(0, index).trim(),
        item.substring(index + separator.length).trim(),
      );
    }
  }
  return null;
}

String _formatDateTime(BuildContext context, DateTime date) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).add_Hm().format(date.toLocal());
}

class _SummarySection {
  const _SummarySection({
    required this.title,
    required this.items,
    required this.icon,
    required this.emphasized,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final bool emphasized;
}

const _knownSummaryKeys = <String>{
  'key_symptoms',
  'major_diagnoses',
  'treatment_history',
  'important_examinations',
  'relevant_medications',
  'medications',
  'procedures',
  'hospitalizations',
  'allergies',
  'test_results',
  'treatment_outcomes',
  'open_questions',
  'care_team',
};
