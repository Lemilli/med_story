import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../l10n/l10n.dart';
import '../controllers/auth_controller.dart';

enum AuthFormMode { login, register }

class AuthFormScreen extends ConsumerStatefulWidget {
  const AuthFormScreen({required this.mode, super.key});

  final AuthFormMode mode;

  @override
  ConsumerState<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends ConsumerState<AuthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool get _isRegister => widget.mode == AuthFormMode.register;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final errorMessage = _errorMessage(authState.error);

    return Scaffold(
      body: SafeArea(
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
                    _AuthHeader(isRegister: _isRegister),
                    const SizedBox(height: AppSpacing.xxl),
                    if (_isRegister) ...[
                      TextFormField(
                        controller: _fullNameController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: InputDecoration(
                          labelText: l10n.authFullNameLabel,
                          helperText: l10n.authFullNameHelper,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: l10n.authEmailLabel,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty || !email.contains('@')) {
                          return l10n.authEmailValidation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: l10n.authPasswordLabel,
                        helperText: _isRegister
                            ? l10n.authPasswordHelper
                            : null,
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.length < 8) {
                          return l10n.authPasswordValidation;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (errorMessage != null) ...[
                      _AuthErrorBanner(message: errorMessage),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    FilledButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.clinicalWhite,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isRegister
                                  ? l10n.authCreateAccountAction
                                  : l10n.authLoginAction,
                            ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: isLoading ? null : _switchMode,
                      child: Text(
                        _isRegister
                            ? l10n.authAlreadyHaveAccountAction
                            : l10n.authNeedAccountAction,
                      ),
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

  String? _errorMessage(Object? error) {
    if (error == null) {
      return null;
    }
    final l10n = context.l10n;
    if (error is AppFailure && error.message == 'auth_failed') {
      return l10n.authFailedMessage;
    }
    return l10n.networkFailedMessage;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final locale = Localizations.localeOf(context).languageCode;
    final controller = ref.read(authControllerProvider.notifier);
    if (_isRegister) {
      await controller.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        locale: locale,
      );
    } else {
      await controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _switchMode() {
    context.go(_isRegister ? '/login' : '/register');
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.isRegister});

  final bool isRegister;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRegister ? l10n.authRegisterTitle : l10n.authLoginTitle,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isRegister ? l10n.authRegisterSubtitle : l10n.authLoginSubtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.secondaryInk,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          container: true,
          label: l10n.authBoundarySemanticLabel,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.quietSurface,
              border: Border.all(color: AppColors.clinicalLine),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.deepClinicalBlue,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.authBoundaryNote,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryInk,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        border: Border.all(color: AppColors.controlledCrimson),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.controlledCrimson,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
