import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    required this.title,
    required this.content,
    required this.primaryAction,
    required this.secondaryAction,
    super.key,
  });

  final String title;
  final Widget content;
  final Widget primaryAction;
  final Widget secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.clinicalWhite,
      surfaceTintColor: AppColors.clinicalWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.patientInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                content,
                const SizedBox(height: AppSpacing.lg),
                primaryAction,
                Align(
                  alignment: Alignment.center,
                  child: secondaryAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
