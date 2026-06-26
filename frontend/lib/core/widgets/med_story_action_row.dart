import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class MedStoryActionRow extends StatelessWidget {
  const MedStoryActionRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isPrimary = false,
    this.semanticHint,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool isPrimary;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accentColor = isPrimary
        ? AppColors.controlledCrimson
        : AppColors.deepClinicalBlue;

    return Semantics(
      button: true,
      label: title,
      hint: semanticHint ?? description,
      child: Material(
        color: AppColors.clinicalWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isPrimary
                ? AppColors.controlledCrimson
                : AppColors.clinicalLine,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(icon, color: accentColor, size: 32),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.patientInk,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryInk,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isPrimary
                        ? AppColors.controlledCrimson
                        : AppColors.patientInk,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
