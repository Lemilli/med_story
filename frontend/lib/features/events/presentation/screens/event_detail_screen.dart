import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/medical_event.dart';
import '../controllers/event_controllers.dart';
import '../event_type_l10n.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(eventDetailProvider(eventId));
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventDetailTitle)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (event) => _EventDetailBody(event: event),
      ),
    );
  }
}

class _EventDetailBody extends ConsumerWidget {
  const _EventDetailBody({required this.event});

  final MedicalEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final date = DateTime.tryParse(event.eventDate);
    final formattedDate = date == null
        ? event.eventDate
        : DateFormat.yMMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(date);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        children: [
          Text(
            event.title,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${event.eventType.label(l10n)} • $formattedDate',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryInk,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Panel(
            child: _DetailSection(
              title: l10n.eventResultTitle,
              child: Text(
                event.description.isEmpty
                    ? l10n.eventDetailsEmptyDescription
                    : event.description,
                style: textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
            ),
          ),
          if (event.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: event.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
          ],
          if (_detailAttributes(event.attributes).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _Panel(
              child: _DetailSection(
                title: l10n.eventStructuredDetailsTitle,
                child: _AttributeList(
                  attributes: _detailAttributes(event.attributes),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (event.source == EventSource.aiDocument && !event.isConfirmed) ...[
            FilledButton.icon(
              onPressed: () => _confirmEvent(context, ref),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(l10n.eventConfirmAction),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/events/${event.id}/edit'),
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l10n.eventEditAction),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.eventDeleteAction),
                ),
              ),
            ],
          ),
          ..._bottomAttributePanels(context, event.attributes),
          if (event.source == EventSource.aiDocument) ...[
            const SizedBox(height: AppSpacing.md),
            _AiSourcePanel(event: event),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.deepClinicalBlue,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(l10n.eventBoundaryNote)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.eventDeleteConfirmTitle),
        content: Text(l10n.eventDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.eventCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.eventDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(eventFormControllerProvider.notifier).delete(event.id);
    if (context.mounted) {
      context.go('/timeline');
    }
  }

  Future<void> _confirmEvent(BuildContext context, WidgetRef ref) async {
    await ref.read(eventFormControllerProvider.notifier).confirm(event.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.eventConfirmedMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

List<Widget> _bottomAttributePanels(
  BuildContext context,
  Map<String, dynamic> attributes,
) {
  final l10n = context.l10n;
  final panels = <Widget>[];
  final result = attributes['result'];
  final notes = attributes['notes'];
  if (_hasAttributeValue(result)) {
    panels.addAll([
      const SizedBox(height: AppSpacing.md),
      _Panel(
        child: _DetailSection(
          title: l10n.eventResultTitle,
          child: Text(_formatAttributeValue(result)),
        ),
      ),
    ]);
  }
  if (_hasAttributeValue(notes)) {
    panels.addAll([
      const SizedBox(height: AppSpacing.md),
      _Panel(
        child: _DetailSection(
          title: l10n.eventNotesTitle,
          child: Text(_formatAttributeValue(notes)),
        ),
      ),
    ]);
  }
  return panels;
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
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

class _AttributeList extends StatelessWidget {
  const _AttributeList({required this.attributes});

  final Map<String, dynamic> attributes;

  @override
  Widget build(BuildContext context) {
    final entries = attributes.entries.toList(growable: false);
    return Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          if (index > 0) const Divider(height: AppSpacing.lg),
          _AttributeRow(entry: entries[index]),
        ],
      ],
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({required this.entry});

  final MapEntry<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            _humanizeAttributeKey(entry.key),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 3,
          child: Text(
            _formatAttributeValue(entry.value),
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.patientInk,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiSourcePanel extends StatelessWidget {
  const _AiSourcePanel({required this.event});

  final MedicalEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final confidence = event.confidence;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.deepClinicalBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  event.isConfirmed
                      ? l10n.eventAiConfirmedNote
                      : l10n.eventAiSuggestedNote,
                  style: textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ),
            ],
          ),
          if (confidence != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.eventConfidenceValue('${(confidence * 100).round()}%'),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryInk,
              ),
            ),
          ],
          if (event.sourceDocumentId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () =>
                  context.push('/documents/${event.sourceDocumentId}'),
              icon: const Icon(Icons.description_outlined),
              label: Text(l10n.eventOpenSourceDocumentAction),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.clinicalLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

String _humanizeAttributeKey(String key) {
  final words = key
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) {
    return key;
  }
  return words
      .map(
        (word) => word.length == 1
            ? word.toUpperCase()
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

Map<String, dynamic> _detailAttributes(Map<String, dynamic> attributes) {
  return Map.fromEntries(
    attributes.entries.where(
      (entry) =>
          entry.key != 'result' &&
          entry.key != 'notes' &&
          _hasAttributeValue(entry.value),
    ),
  );
}

bool _hasAttributeValue(Object? value) {
  if (value == null) {
    return false;
  }
  if (value is String) {
    return value.trim().isNotEmpty;
  }
  if (value is Iterable) {
    return value.any(_hasAttributeValue);
  }
  if (value is Map) {
    return value.values.any(_hasAttributeValue);
  }
  return true;
}

String _formatAttributeValue(Object? value) {
  if (value == null) {
    return 'Not specified';
  }
  if (value is Iterable) {
    return value.map(_formatAttributeValue).join(', ');
  }
  if (value is Map) {
    return value.entries
        .map((entry) {
          final key = _humanizeAttributeKey(entry.key.toString());
          return '$key: ${_formatAttributeValue(entry.value)}';
        })
        .join('\n');
  }
  if (value is bool) {
    return value ? 'Yes' : 'No';
  }
  return value.toString();
}
