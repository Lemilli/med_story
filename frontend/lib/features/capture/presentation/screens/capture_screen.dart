import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/med_story_action_row.dart';
import '../../../../l10n/l10n.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.captureHeadline,
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.patientInk,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                height: 1.05,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.captureSubtitle,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.secondaryInk,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            MedStoryActionRow(
              icon: Icons.mic_none_rounded,
              title: l10n.recordVoiceTitle,
              description: l10n.recordVoiceDescription,
              isPrimary: true,
              semanticHint: l10n.recordVoiceSemanticHint,
              onTap: () => _showPendingAction(
                context,
                title: l10n.voiceCaptureTitle,
                message: l10n.voiceCaptureMessage,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            MedStoryActionRow(
              icon: Icons.document_scanner_outlined,
              title: l10n.scanDocumentTitle,
              description: l10n.scanDocumentDescription,
              isPrimary: true,
              semanticHint: l10n.scanDocumentSemanticHint,
              onTap: () => _showPendingAction(
                context,
                title: l10n.documentScanTitle,
                message: l10n.documentScanMessage,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            MedStoryActionRow(
              icon: Icons.edit_note_rounded,
              title: l10n.writeNoteTitle,
              description: l10n.writeNoteDescription,
              semanticHint: l10n.writeNoteSemanticHint,
              onTap: () => _showPendingAction(
                context,
                title: l10n.textNoteTitle,
                message: l10n.textNoteMessage,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            MedStoryActionRow(
              icon: Icons.add_photo_alternate_outlined,
              title: l10n.addPhotoTitle,
              description: l10n.addPhotoDescription,
              semanticHint: l10n.addPhotoSemanticHint,
              onTap: () => _showPendingAction(
                context,
                title: l10n.photoOrFileTitle,
                message: l10n.photoOrFileMessage,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _PrivacyPanel(),
            const SizedBox(height: AppSpacing.lg),
            const _BoundaryNote(),
          ],
        ),
      ),
    );
  }

  void _showPendingAction(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final l10n = context.l10n;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.pendingActionMessage(title, message)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PrivacyPanel extends StatelessWidget {
  const _PrivacyPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Semantics(
      container: true,
      label: l10n.privacyPanelSemanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.quietSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.clinicalLine),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.deepClinicalBlue,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.privacyPanelTitle,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.patientInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.privacyPanelDescription,
                      style: textTheme.bodyMedium?.copyWith(
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
      ),
    );
  }
}

class _BoundaryNote extends StatelessWidget {
  const _BoundaryNote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

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
            l10n.boundaryNote,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
