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
  bool _privacyAccepted = false;
  bool _aiConsent = false;
  bool _showPrivacyDetails = false;
  bool _showPrivacyError = false;

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
                        enabled: !isLoading,
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
                    if (_isRegister) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _ConsentOption(
                        value: _privacyAccepted,
                        enabled: !isLoading,
                        title: l10n.authPrivacyConsentTitle,
                        description: l10n.authPrivacyConsentDescription,
                        onChanged: (value) => setState(() {
                          _privacyAccepted = value;
                          if (value) _showPrivacyError = false;
                        }),
                      ),
                      if (_showPrivacyError)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: AppSpacing.md,
                            top: AppSpacing.xs,
                          ),
                          child: Text(
                            l10n.authPrivacyConsentValidation,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.error),
                          ),
                        ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => setState(
                                () =>
                                    _showPrivacyDetails = !_showPrivacyDetails,
                              ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _showPrivacyDetails
                                ? l10n.authPrivacyDetailsHideAction
                                : l10n.authPrivacyDetailsShowAction,
                          ),
                        ),
                      ),
                      if (_showPrivacyDetails)
                        _InlineNotice(
                          title: l10n.authPrivacyDetailsTitle,
                          message: l10n.authPrivacyDetailsMessage,
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      _ConsentOption(
                        value: _aiConsent,
                        enabled: !isLoading,
                        title: l10n.authAiConsentTitle,
                        description: l10n.authAiConsentDescription,
                        onChanged: (value) => setState(() {
                          _aiConsent = value;
                        }),
                      ),
                    ],
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
                    if (!_isRegister)
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go('/forgot-password'),
                        child: Text(l10n.authForgotPasswordAction),
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
    if (error is! AppFailure) {
      return l10n.networkFailedMessage;
    }
    switch (error.message) {
      case 'auth_invalid_credentials':
      case 'auth_failed':
        return l10n.authFailedMessage;
      case 'auth_email_already_exists':
        return l10n.authEmailAlreadyExistsMessage;
      case 'auth_invalid_email':
        return l10n.authInvalidEmailMessage;
      case 'auth_email_required':
        return l10n.authEmailRequiredMessage;
      case 'auth_password_not_accepted':
        return l10n.authPasswordNotAcceptedMessage;
      case 'auth_register_failed':
        return l10n.authRegisterFailedMessage;
      case 'demo_capacity_reached':
        return l10n.authDemoCapacityReachedMessage;
      case 'network_failed':
        return l10n.networkFailedMessage;
      default:
        return l10n.networkFailedMessage;
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_isRegister && !_privacyAccepted) {
      setState(() => _showPrivacyError = true);
      return;
    }

    final locale = Localizations.localeOf(context).languageCode;
    final controller = ref.read(authControllerProvider.notifier);
    if (_isRegister) {
      final email = _emailController.text.trim();
      final result = await controller.register(
        email: email,
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        locale: locale,
        acceptPrivacyNotice: _privacyAccepted,
        aiProcessingConsent: _aiConsent,
      );
      if (result != null && mounted) {
        context.go(
          Uri(
            path: '/verify-email',
            queryParameters: {
              'email': email,
              if (result.emailMasked.isNotEmpty) 'masked': result.emailMasked,
            },
          ).toString(),
        );
      }
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

class _ConsentOption extends StatelessWidget {
  const _ConsentOption({
    required this.value,
    required this.enabled,
    required this.title,
    required this.description,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final String title;
  final String description;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: CheckboxListTile(
        value: value,
        enabled: enabled,
        onChanged: (next) => onChanged(next ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: AppSpacing.sm,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryInk,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.quietSurface,
        border: Border.all(color: AppColors.clinicalLine),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.patientInk,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryInk,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
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
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.quietSurface,
          border: Border.all(color: AppColors.controlledCrimson),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.controlledCrimson,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.patientInk,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
