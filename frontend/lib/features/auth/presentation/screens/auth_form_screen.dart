import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../l10n/l10n.dart';
import '../controllers/auth_controller.dart';

enum AuthFormMode { login, register }

class _RegistrationColors {
  const _RegistrationColors._();

  static const danger = Color(0xFF9F3D00);
  static const dangerSurface = Color(0xFFFFF2E4);
}

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
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _privacyFocusNode = FocusNode();
  bool _privacyAccepted = false;
  bool _showPrivacyDetails = false;
  bool _showPrivacyError = false;
  bool _showPassword = false;
  bool _submitted = false;
  bool _dismissSubmissionError = false;

  bool get _isRegister => widget.mode == AuthFormMode.register;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearSubmissionError);
    _passwordController.addListener(_clearSubmissionError);
    _fullNameController.addListener(_clearSubmissionError);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _privacyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final errorMessage = _dismissSubmissionError
        ? null
        : _errorMessage(authState.error);

    if (_isRegister) {
      return _buildRegistration(
        isLoading: authState.isLoading,
        errorMessage: errorMessage,
      );
    }
    return _buildLogin(
      isLoading: authState.isLoading,
      errorMessage: errorMessage,
    );
  }

  Widget _buildRegistration({
    required bool isLoading,
    required String? errorMessage,
  }) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.quietSurface,
      resizeToAvoidBottomInset: false,
      body: Theme(
        data: _registrationTheme(context),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 480,
              height: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.clinicalWhite,
                  border: Border.symmetric(
                    vertical: BorderSide(color: AppColors.clinicalLine),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SafeArea(
                        bottom: false,
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: _submitted
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _RegistrationHeader(),
                                const SizedBox(height: AppSpacing.xl),
                                Semantics(
                                  container: true,
                                  label: l10n.authAccountDetailsSemanticLabel,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _RegistrationField(
                                        label: l10n.authFullNameLabel,
                                        trailingLabel: l10n.authOptionalLabel,
                                        helperText: l10n.authFullNameHelper,
                                        child: TextFormField(
                                          controller: _fullNameController,
                                          textInputAction: TextInputAction.next,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          autofillHints: const [
                                            AutofillHints.name,
                                          ],
                                          enabled: !isLoading,
                                          decoration: InputDecoration(
                                            hintText: l10n.authFullNameHint,
                                          ),
                                          onFieldSubmitted: (_) =>
                                              _emailFocusNode.requestFocus(),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      _RegistrationField(
                                        label: l10n.authEmailLabel,
                                        child: TextFormField(
                                          controller: _emailController,
                                          focusNode: _emailFocusNode,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          textCapitalization:
                                              TextCapitalization.none,
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          enabled: !isLoading,
                                          decoration: InputDecoration(
                                            hintText: l10n.authEmailHint,
                                          ),
                                          validator: _validateEmail,
                                          onFieldSubmitted: (_) =>
                                              _passwordFocusNode.requestFocus(),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      _RegistrationField(
                                        label: l10n.authPasswordLabel,
                                        helperText: l10n.authPasswordHelper,
                                        child: TextFormField(
                                          controller: _passwordController,
                                          focusNode: _passwordFocusNode,
                                          obscureText: !_showPassword,
                                          textInputAction: TextInputAction.done,
                                          autocorrect: false,
                                          enableSuggestions: false,
                                          autofillHints: const [
                                            AutofillHints.newPassword,
                                          ],
                                          enabled: !isLoading,
                                          decoration: InputDecoration(
                                            hintText: l10n.authPasswordHint,
                                            suffixIcon: IconButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () => setState(
                                                      () => _showPassword =
                                                          !_showPassword,
                                                    ),
                                              constraints: const BoxConstraints(
                                                minWidth: 48,
                                                minHeight: 48,
                                              ),
                                              tooltip: _showPassword
                                                  ? l10n.authHidePasswordAction
                                                  : l10n.authShowPasswordAction,
                                              icon: Icon(
                                                _showPassword
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                              ),
                                            ),
                                          ),
                                          validator: _validatePassword,
                                          onFieldSubmitted: (_) => _submit(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const _SectionRule(),
                                Text(
                                  l10n.authPrivacyAiTitle,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColors.patientInk,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  l10n.authPrivacyAiIntro,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.secondaryInk,
                                        height: 1.35,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _ConsentGroup(
                                  privacyAccepted: _privacyAccepted,
                                  enabled: !isLoading,
                                  showError: _showPrivacyError,
                                  showPrivacyDetails: _showPrivacyDetails,
                                  privacyFocusNode: _privacyFocusNode,
                                  onPrivacyChanged: (value) {
                                    setState(() {
                                      _privacyAccepted = value;
                                      if (value) _showPrivacyError = false;
                                    });
                                    _clearSubmissionError();
                                  },
                                  onTogglePrivacyDetails: () => setState(
                                    () => _showPrivacyDetails =
                                        !_showPrivacyDetails,
                                  ),
                                ),
                                if (_showPrivacyError) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Semantics(
                                    container: true,
                                    liveRegion: true,
                                    child: Text(
                                      l10n.authPrivacyConsentValidation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _RegistrationColors.danger,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                                if (errorMessage != null) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  _AuthErrorBanner(message: errorMessage),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _RegistrationActions(
                      isLoading: isLoading,
                      hasError: errorMessage != null,
                      onSubmit: _submit,
                      onLogin: _switchMode,
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

  Widget _buildLogin({required bool isLoading, required String? errorMessage}) {
    final l10n = context.l10n;

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
                    const _AuthHeader(),
                    const SizedBox(height: AppSpacing.xxl),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: l10n.authEmailLabel,
                      ),
                      validator: _validateEmail,
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
                      ),
                      validator: _validatePassword,
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
                          : Text(l10n.authLoginAction),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go('/forgot-password'),
                      child: Text(l10n.authForgotPasswordAction),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: isLoading ? null : _switchMode,
                      child: Text(l10n.authNeedAccountAction),
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

  ThemeData _registrationTheme(BuildContext context) {
    final base = Theme.of(context);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.clinicalLine, width: 1.5),
    );

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.deepClinicalBlue,
        error: _RegistrationColors.danger,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.deepClinicalBlue,
        selectionColor: Color(0x3363B3FF),
        selectionHandleColor: AppColors.deepClinicalBlue,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.clinicalWhite,
        hintStyle: const TextStyle(color: Color(0xFF8994A6)),
        suffixIconColor: AppColors.secondaryInk,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        constraints: const BoxConstraints(minHeight: 50),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        disabledBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.clinicalLine),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(
            color: AppColors.deepClinicalBlue,
            width: 1.5,
          ),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(
            color: _RegistrationColors.danger,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(
            color: _RegistrationColors.danger,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty || !email.contains('@')) {
      return context.l10n.authEmailValidation;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 8) {
      return context.l10n.authPasswordValidation;
    }
    return null;
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
    if (_isRegister) {
      setState(() {
        _submitted = true;
        _showPrivacyError = !_privacyAccepted;
        _dismissSubmissionError = false;
      });
    }

    final emailInvalid = _validateEmail(_emailController.text) != null;
    final passwordInvalid = _validatePassword(_passwordController.text) != null;
    final formValid = _formKey.currentState?.validate() ?? false;
    final privacyInvalid = _isRegister && !_privacyAccepted;
    if (!formValid || privacyInvalid) {
      if (emailInvalid) {
        _emailFocusNode.requestFocus();
      } else if (passwordInvalid) {
        _passwordFocusNode.requestFocus();
      } else if (privacyInvalid) {
        _privacyFocusNode.requestFocus();
      }
      return;
    }

    FocusScope.of(context).unfocus();
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

  void _clearSubmissionError() {
    if (!mounted || _dismissSubmissionError) {
      return;
    }
    if (ref.read(authControllerProvider).hasError) {
      setState(() => _dismissSubmissionError = true);
    }
  }

  void _switchMode() {
    context.go(_isRegister ? '/login' : '/register');
  }
}

class _RegistrationField extends StatelessWidget {
  const _RegistrationField({
    required this.label,
    required this.child,
    this.trailingLabel,
    this.helperText,
  });

  final String label;
  final String? trailingLabel;
  final String? helperText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.patientInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingLabel != null) ...[
                const SizedBox(width: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Text(
                    trailingLabel!,
                    key: const ValueKey('registration-full-name-optional'),
                    textAlign: TextAlign.end,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(container: true, label: label, child: child),
        if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              helperText!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryInk,
                height: 1.3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConsentGroup extends StatelessWidget {
  const _ConsentGroup({
    required this.privacyAccepted,
    required this.enabled,
    required this.showError,
    required this.showPrivacyDetails,
    required this.privacyFocusNode,
    required this.onPrivacyChanged,
    required this.onTogglePrivacyDetails,
  });

  final bool privacyAccepted;
  final bool enabled;
  final bool showError;
  final bool showPrivacyDetails;
  final FocusNode privacyFocusNode;
  final ValueChanged<bool> onPrivacyChanged;
  final VoidCallback onTogglePrivacyDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      container: true,
      child: Container(
        key: const ValueKey('registration-consent-group'),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.clinicalWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            color: showError
                ? _RegistrationColors.danger
                : AppColors.clinicalLine,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            _ConsentChoice(
              value: privacyAccepted,
              enabled: enabled,
              focusNode: privacyFocusNode,
              title: l10n.authPrivacyConsentTitle,
              meta: l10n.authPrivacyConsentDescription,
              badge: l10n.authRequiredLabel,
              showDetails: showPrivacyDetails,
              detailsAction: l10n.authPrivacyDetailsShowAction,
              detailsParagraphs: [
                l10n.authPrivacyDetailsMessage,
                l10n.authPrivacyDetailsSecondaryMessage,
              ],
              onChanged: onPrivacyChanged,
              onToggleDetails: onTogglePrivacyDetails,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentChoice extends StatelessWidget {
  const _ConsentChoice({
    required this.value,
    required this.enabled,
    required this.title,
    required this.meta,
    required this.showDetails,
    required this.detailsAction,
    required this.detailsParagraphs,
    required this.onChanged,
    required this.onToggleDetails,
    this.focusNode,
    this.badge,
  });

  final bool value;
  final bool enabled;
  final String title;
  final String meta;
  final bool showDetails;
  final String detailsAction;
  final List<String> detailsParagraphs;
  final ValueChanged<bool> onChanged;
  final VoidCallback onToggleDetails;
  final FocusNode? focusNode;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.clinicalWhite,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckboxListTile(
              value: value,
              enabled: enabled,
              focusNode: focusNode,
              activeColor: AppColors.deepClinicalBlue,
              checkColor: AppColors.clinicalWhite,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: const BorderSide(color: AppColors.secondaryInk, width: 1.5),
              onChanged: (next) => onChanged(next ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.fromLTRB(6, 2, 14, 0),
              minVerticalPadding: AppSpacing.sm,
              title: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.patientInk,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (badge != null)
                    Text(
                      badge!,
                      style: textTheme.labelSmall?.copyWith(
                        color: _RegistrationColors.danger,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.45,
                      ),
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  meta,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryInk,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 62, right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: enabled ? onToggleDetails : null,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.controlledCrimson,
                      minimumSize: const Size(48, 48),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.padded,
                      alignment: Alignment.centerLeft,
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: Icon(
                      showDetails
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                    ),
                    label: Text(
                      detailsAction,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (showDetails)
                    _DisclosureNotice(paragraphs: detailsParagraphs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclosureNotice extends StatelessWidget {
  const _DisclosureNotice({required this.paragraphs});

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.secondaryInk,
      height: 1.48,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.quietSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < paragraphs.length; index++) ...[
                if (index > 0) const SizedBox(height: AppSpacing.sm),
                Text(paragraphs[index], style: style),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RegistrationActions extends StatelessWidget {
  const _RegistrationActions({
    required this.isLoading,
    required this.hasError,
    required this.onSubmit,
    required this.onLogin,
  });

  final bool isLoading;
  final bool hasError;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ColoredBox(
      color: AppColors.quietSurface,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.clinicalWhite,
              border: Border(top: BorderSide(color: AppColors.clinicalLine)),
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: isLoading ? null : onSubmit,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading) ...[
                          const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              color: AppColors.clinicalWhite,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Flexible(
                          child: Text(
                            isLoading
                                ? l10n.authCreatingAccountAction
                                : hasError
                                ? l10n.authTryAgainAction
                                : l10n.authCreateAccountAction,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : onLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.controlledCrimson,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(l10n.authAlreadyHaveAccountAction),
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

class _RegistrationHeader extends StatelessWidget {
  const _RegistrationHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authRegisterTitle,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w800,
            height: 1.12,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authRegisterSubtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.secondaryInk,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          container: true,
          label: l10n.authBoundarySemanticLabel,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.quietSurface,
              border: Border(
                left: BorderSide(color: AppColors.clinicalLine, width: 3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              child: Text(
                l10n.authBoundaryNote,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryInk,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionRule extends StatelessWidget {
  const _SectionRule();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 22, bottom: 18),
      child: Divider(height: 1, color: AppColors.clinicalLine),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.authLoginTitle,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.patientInk,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.authLoginSubtitle,
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
            decoration: const BoxDecoration(
              color: AppColors.quietSurface,
              border: Border(
                left: BorderSide(color: AppColors.clinicalLine, width: 3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              child: Text(
                l10n.authBoundaryNote,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryInk,
                  height: 1.4,
                ),
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
    final errorColor = Theme.of(context).colorScheme.error;
    final errorSurface = errorColor == _RegistrationColors.danger
        ? _RegistrationColors.dangerSurface
        : const Color(0xFFFFF6F1);

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: errorSurface,
          border: Border.all(color: const Color(0xFFD6A47A)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded, color: errorColor, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B3626),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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
