import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../l10n/l10n.dart';
import '../../data/auth_repository.dart';
import '../controllers/auth_controller.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({
    required this.email,
    this.maskedEmail,
    super.key,
  });

  final String email;
  final String? maskedEmail;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isResending = false;
  String? _resendMessage;
  Object? _resendError;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final destination = widget.maskedEmail?.isNotEmpty == true
        ? widget.maskedEmail!
        : widget.email;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: isLoading ? null : () => context.go('/register'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.mark_email_read_outlined,
                      size: 44,
                      color: AppColors.deepClinicalBlue,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.authVerifyTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.patientInk,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.authVerifySubtitle(destination),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryInk,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _codeController,
                      enabled: !isLoading,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.authVerificationCodeLabel,
                        helperText: l10n.authVerificationCodeHelper,
                      ),
                      validator: (value) => (value?.length ?? 0) == 6
                          ? null
                          : l10n.authVerificationCodeValidation,
                      onFieldSubmitted: (_) => _verify(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (authState.hasError) ...[
                      _StatusMessage(
                        message: _messageForError(context, authState.error),
                        isError: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (_resendMessage != null) ...[
                      _StatusMessage(message: _resendMessage!),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (_resendError != null) ...[
                      _StatusMessage(
                        message: _messageForError(context, _resendError),
                        isError: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    FilledButton(
                      onPressed: isLoading ? null : _verify,
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.clinicalWhite,
                              ),
                            )
                          : Text(l10n.authVerifyAction),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: isLoading || _isResending ? null : _resend,
                      child: Text(
                        _isResending
                            ? l10n.authResendingCode
                            : l10n.authResendCodeAction,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () => context.go('/login'),
                      child: Text(l10n.authBackToLoginAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authControllerProvider.notifier)
        .verifyEmail(email: widget.email, code: _codeController.text);
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _resendMessage = null;
      _resendError = null;
    });
    try {
      await ref.read(authRepositoryProvider).resendVerification(widget.email);
      if (!mounted) return;
      setState(() => _resendMessage = context.l10n.authCodeResentMessage);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _resendError = error);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.quietSurface,
          border: Border.all(
            color: isError
                ? AppColors.controlledCrimson
                : AppColors.clinicalLine,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.patientInk,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}

String _messageForError(BuildContext context, Object? error) {
  final l10n = context.l10n;
  if (error is AppFailure) {
    return switch (error.message) {
      'auth_verification_invalid' => l10n.authVerificationInvalidMessage,
      'throttled' => l10n.authTooManyAttemptsMessage,
      'demo_capacity_reached' => l10n.authDemoCapacityReachedMessage,
      _ => l10n.networkFailedMessage,
    };
  }
  return l10n.networkFailedMessage;
}
