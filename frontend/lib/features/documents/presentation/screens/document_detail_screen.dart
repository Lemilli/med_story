import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_alert_dialog.dart';
import '../../../../l10n/l10n.dart';
import '../../../../l10n/app_localizations.dart';
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
                    value: document.eventCount == 1
                        ? l10n.documentSingleEventValue
                        : l10n.documentNoEventValue,
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
                        _localizedProcessingError(l10n, document.errorMessage),
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
            if (document.status == DocumentStatus.failed &&
                document.assets.any((asset) => asset.available)) ...[
              FilledButton.tonalIcon(
                onPressed: () async {
                  try {
                    await ref
                        .read(documentRepositoryProvider)
                        .retryProcessing(document.id);
                    ref.invalidate(documentDetailProvider(document.id));
                  } on Object {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.documentProcessingFailedMessage),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.documentRetryAction),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (document.eventId != null) ...[
              FilledButton.icon(
                onPressed: () => context.push('/events/${document.eventId}'),
                icon: const Icon(Icons.timeline_rounded),
                label: Text(l10n.documentViewResultAction),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
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
      builder: (dialogContext) => AppAlertDialog(
        title: l10n.documentDeleteConfirmTitle,
        content: Text(
          l10n.documentDeleteConfirmMessage,
          textAlign: TextAlign.center,
          style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryInk,
            height: 1.35,
          ),
        ),
        primaryAction: FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.documentDeleteAction),
        ),
        secondaryAction: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondaryInk,
            minimumSize: const Size(0, 48),
          ),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.eventCancelAction),
        ),
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

String _localizedProcessingError(AppLocalizations l10n, String errorCode) {
  return switch (errorCode) {
    'document_not_medical' => l10n.documentNotMedicalMessage,
    'document_unreadable' => l10n.documentUnreadableMessage,
    'audio_not_medical' => l10n.audioNotMedicalMessage,
    'audio_unreadable' => l10n.audioUnreadableMessage,
    'medical_events_not_found' => l10n.medicalEventsNotFoundMessage,
    _ => l10n.documentProcessingFailedMessage,
  };
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
