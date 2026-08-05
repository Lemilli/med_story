import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../l10n/l10n.dart';
import '../../data/auth_repository.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;
  bool _resetComplete = false;
  Object? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: _isLoading ? null : () => context.go('/login'),
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
              child: _resetComplete
                  ? _CompleteView(onLogin: () => context.go('/login'))
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.authResetPasswordTitle,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.patientInk,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _codeSent
                                ? l10n.authResetCodeSubtitle(
                                    _emailController.text.trim(),
                                  )
                                : l10n.authResetPasswordSubtitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.secondaryInk,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          TextFormField(
                            controller: _emailController,
                            enabled: !_isLoading && !_codeSent,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: _codeSent
                                ? TextInputAction.next
                                : TextInputAction.done,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              labelText: l10n.authEmailLabel,
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              return email.isNotEmpty && email.contains('@')
                                  ? null
                                  : l10n.authEmailValidation;
                            },
                            onFieldSubmitted: (_) {
                              if (!_codeSent) _requestCode();
                            },
                          ),
                          if (_codeSent) ...[
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _codeController,
                              enabled: !_isLoading,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.authVerificationCodeLabel,
                              ),
                              validator: (value) => (value?.length ?? 0) == 6
                                  ? null
                                  : l10n.authVerificationCodeValidation,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !_isLoading,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              decoration: InputDecoration(
                                labelText: l10n.authNewPasswordLabel,
                                helperText: l10n.authPasswordHelper,
                              ),
                              validator: (value) => (value?.length ?? 0) >= 8
                                  ? null
                                  : l10n.authPasswordValidation,
                              onFieldSubmitted: (_) => _confirmReset(),
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                _errorMessage(context, _error),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          FilledButton(
                            onPressed: _isLoading
                                ? null
                                : (_codeSent ? _confirmReset : _requestCode),
                            child: _isLoading
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.clinicalWhite,
                                    ),
                                  )
                                : Text(
                                    _codeSent
                                        ? l10n.authResetPasswordAction
                                        : l10n.authSendResetCodeAction,
                                  ),
                          ),
                          if (_codeSent)
                            TextButton(
                              onPressed: _isLoading ? null : _requestCode,
                              child: Text(l10n.authResendCodeAction),
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

  Future<void> _requestCode() async {
    if (!_codeSent && !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(_emailController.text.trim());
      if (mounted) setState(() => _codeSent = true);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmReset() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .confirmPasswordReset(
            email: _emailController.text.trim(),
            code: _codeController.text,
            newPassword: _passwordController.text,
          );
      if (mounted) setState(() => _resetComplete = true);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          size: 48,
          color: AppColors.deepClinicalBlue,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.authResetCompleteTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authResetCompleteMessage,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryInk),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: onLogin, child: Text(l10n.authLoginAction)),
      ],
    );
  }
}

String _errorMessage(BuildContext context, Object? error) {
  if (error is AppFailure && error.message == 'throttled') {
    return context.l10n.authTooManyAttemptsMessage;
  }
  return context.l10n.authResetFailedMessage;
}
