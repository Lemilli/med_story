import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../timeline/presentation/controllers/timeline_controller.dart';
import '../../data/document_repository.dart';
import '../../domain/medical_document.dart';
import '../controllers/document_controllers.dart';
import '../document_l10n.dart';

class DocumentDetailScreen extends ConsumerWidget {
  const DocumentDetailScreen({required this.documentId, super.key});

  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(documentDetailProvider(documentId));
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentDetailTitle)),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DocumentError(message: error.toString()),
        data: (document) => _DocumentDetailBody(document: document),
      ),
    );
  }
}

class _DocumentDetailBody extends ConsumerWidget {
  const _DocumentDetailBody({required this.document});

  final MedicalDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final createdAt = document.createdAt;
    final updatedAt = document.updatedAt;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(documentDetailProvider(document.id));
          await ref.read(documentDetailProvider(document.id).future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            Text(
              document.title,
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.patientInk,
                fontWeight: FontWeight.w900,
                height: 1.08,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _StatusBadge(label: document.status.label(l10n)),
                _StatusBadge(label: document.docType.label(l10n)),
              ],
            ),
            if (document.status == DocumentStatus.processed &&
                document.extractedTextAvailable) ...[
              const SizedBox(height: AppSpacing.lg),
              _DocumentExplanationPanel(document: document),
            ],
            const SizedBox(height: AppSpacing.lg),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    label: l10n.documentDateLabel,
                    value: document.documentDate ?? l10n.documentDateUnknown,
                  ),
                  _DetailRow(
                    label: l10n.documentMimeTypeLabel,
                    value: document.mimeType,
                  ),
                  _DetailRow(
                    label: l10n.documentStorageLabel,
                    value: document.localOnly
                        ? l10n.documentLocalOnlyValue
                        : l10n.documentRemoteStorageValue,
                  ),
                  _DetailRow(
                    label: l10n.documentExtractedTextLabel,
                    value: document.extractedTextAvailable
                        ? l10n.documentAvailableValue
                        : l10n.documentNotAvailableValue,
                  ),
                  _DetailRow(
                    label: l10n.documentEventCountLabel,
                    value: l10n.documentEventCountValue(document.eventCount),
                  ),
                  if (createdAt != null)
                    _DetailRow(
                      label: l10n.documentCreatedAtLabel,
                      value: _formatDateTime(context, createdAt),
                    ),
                  if (updatedAt != null)
                    _DetailRow(
                      label: l10n.documentUpdatedAtLabel,
                      value: _formatDateTime(context, updatedAt),
                    ),
                ],
              ),
            ),
            if (document.status == DocumentStatus.processing ||
                document.status == DocumentStatus.pendingIngest) ...[
              const SizedBox(height: AppSpacing.md),
              _Panel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(l10n.documentDetailProcessingNote)),
                  ],
                ),
              ),
            ],
            if (document.status == DocumentStatus.failed) ...[
              const SizedBox(height: AppSpacing.md),
              _Panel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.controlledCrimson,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        document.errorMessage.isEmpty
                            ? l10n.documentProcessingFailedMessage
                            : document.errorMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            _Panel(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.deepClinicalBlue,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(l10n.documentDetailPrivacyNote)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, ref),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.documentDeleteAction),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => context.go('/timeline'),
              icon: const Icon(Icons.timeline_rounded),
              label: Text(l10n.documentOpenTimelineAction),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.documentDeleteConfirmTitle),
        content: Text(l10n.documentDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.eventCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.documentDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(documentRepositoryProvider).deleteDocument(document.id);
    ref.invalidate(timelineControllerProvider);
    if (context.mounted) {
      context.go('/timeline');
    }
  }
}

class _DocumentExplanationPanel extends ConsumerWidget {
  const _DocumentExplanationPanel({required this.document});

  final MedicalDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explanationState = ref.watch(
      documentExplanationProvider(document.id),
    );
    final controllerState = ref.watch(documentExplanationControllerProvider);
    final isRegenerating = controllerState.isLoading;

    return explanationState.when(
      loading: () => _Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExplanationHeader(
              title: context.l10n.documentExplanationTitle,
              trailing: const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.documentExplanationLoading),
          ],
        ),
      ),
      error: (error, _) => _ExplanationErrorPanel(
        message: context.l10n.documentExplanationLoadFailed,
        onRetry: () => ref.invalidate(documentExplanationProvider(document.id)),
      ),
      data: (state) {
        final explanation = state.explanation;
        if (explanation == null) {
          return _ExplanationEmptyPanel(
            isBusy: isRegenerating,
            onGenerate: () => _regenerate(context, ref),
          );
        }
        return _ExplanationContentPanel(
          explanation: explanation,
          isBusy: isRegenerating,
          onRegenerate: () => _regenerate(context, ref),
        );
      },
    );
  }

  Future<void> _regenerate(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      await ref
          .read(documentExplanationControllerProvider.notifier)
          .regenerate(document.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.documentExplanationQueuedMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.documentExplanationRegenerateFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _ExplanationContentPanel extends StatelessWidget {
  const _ExplanationContentPanel({
    required this.explanation,
    required this.isBusy,
    required this.onRegenerate,
  });

  final DocumentExplanation explanation;
  final bool isBusy;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final createdAt = explanation.createdAt;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExplanationHeader(title: l10n.documentExplanationTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.documentExplanationBoundaryNote,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ExplanationSectionTitle(label: l10n.documentExplanationSummaryTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            explanation.summaryText,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.patientInk,
              height: 1.45,
            ),
          ),
          if (explanation.keyPoints.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _ExplanationSectionTitle(
              label: l10n.documentExplanationKeyPointsTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final point in explanation.keyPoints)
              _KeyPointRow(point: point),
          ],
          if (explanation.glossary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _ExplanationSectionTitle(
              label: l10n.documentExplanationGlossaryTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final entry in explanation.glossary.entries)
              _GlossaryRow(term: entry.key, definition: entry.value),
          ],
          if (createdAt != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.documentExplanationGeneratedAt(
                _formatDateTime(context, createdAt),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryInk,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onRegenerate,
            icon: isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            label: Text(
              isBusy
                  ? l10n.documentExplanationQueuedAction
                  : l10n.documentExplanationRegenerateAction,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationEmptyPanel extends StatelessWidget {
  const _ExplanationEmptyPanel({
    required this.isBusy,
    required this.onGenerate,
  });

  final bool isBusy;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExplanationHeader(title: l10n.documentExplanationTitle),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.documentExplanationNotReadyMessage),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.documentExplanationBoundaryNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: isBusy ? null : onGenerate,
            icon: isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_stories_outlined),
            label: Text(
              isBusy
                  ? l10n.documentExplanationQueuedAction
                  : l10n.documentExplanationGenerateAction,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationErrorPanel extends StatelessWidget {
  const _ExplanationErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExplanationHeader(title: context.l10n.documentExplanationTitle),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.deepClinicalBlue,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(message)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.documentExplanationRetryAction),
          ),
        ],
      ),
    );
  }
}

class _ExplanationHeader extends StatelessWidget {
  const _ExplanationHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.auto_stories_outlined,
          color: AppColors.deepClinicalBlue,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

class _ExplanationSectionTitle extends StatelessWidget {
  const _ExplanationSectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.patientInk,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _KeyPointRow extends StatelessWidget {
  const _KeyPointRow({required this.point});

  final String point;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.deepClinicalBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              point,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.patientInk,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlossaryRow extends StatelessWidget {
  const _GlossaryRow({required this.term, required this.definition});

  final String term;
  final String definition;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            term,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.patientInk,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            definition,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.patientInk,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 136,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryInk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.patientInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

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
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(label),
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

class _DocumentError extends StatelessWidget {
  const _DocumentError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime dateTime) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).add_Hm().format(dateTime.toLocal());
}
