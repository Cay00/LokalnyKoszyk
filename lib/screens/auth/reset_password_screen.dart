import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/auth_error_message.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

const int _minPasswordLength = 8;

const String _passwordAllowedChars =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    '!@#\$%^&*()_+-=[]{}|;:,.<>/?`~\\\'"';

bool _hasAllowedPasswordChars(String password) {
  for (int i = 0; i < password.length; i++) {
    if (!_passwordAllowedChars.contains(password[i])) return false;
  }
  return true;
}

class _PasswordCharsFormatter extends TextInputFormatter {
  const _PasswordCharsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final StringBuffer filtered = StringBuffer();
    for (int i = 0; i < newValue.text.length; i++) {
      final String char = newValue.text[i];
      if (_passwordAllowedChars.contains(char)) {
        filtered.write(char);
      }
    }
    final String next = filtered.toString();
    if (next == newValue.text) return newValue;
    return TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }
}

/// Ekran po kliknięciu linku z maila (AuthChangeEvent.passwordRecovery).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.onCompleted,
  });

  final VoidCallback onCompleted;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();

  bool _loading = false;
  bool _submitAttempted = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final repeat = _repeatController.text;

    setState(() => _submitAttempted = true);

    if (password.length < _minPasswordLength) {
      return;
    }
    if (!_hasAllowedPasswordChars(password)) {
      showAppNotification(
        context,
        'Hasło może zawierać tylko litery, cyfry i znaki specjalne',
      );
      return;
    }
    if (repeat.isEmpty) {
      showAppNotification(context, 'Powtórz hasło');
      return;
    }
    if (password != repeat) {
      showAppNotification(context, 'Hasła nie są takie same');
      return;
    }

    setState(() => _loading = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: password),
      );
      if (!mounted) return;
      showAppNotification(context, 'Hasło zostało zmienione.');
      widget.onCompleted();
    } on AuthException catch (e) {
      if (!mounted) return;
      showAppNotification(
        context,
        polishAuthError(
          e,
          fallback: 'Nie udało się zmienić hasła. Spróbuj ponownie.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showAppNotification(
        context,
        polishAuthError(
          e,
          fallback: 'Nie udało się zmienić hasła. Spróbuj ponownie.',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Nowe hasło',
      showBottomNavPadding: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Text(
            'Ustaw nowe hasło do konta',
            style: AppTypography.header,
          ),
          const SizedBox(height: 8),
          Text(
            'Hasło musi mieć co najmniej $_minPasswordLength znaków.',
            style: AppTypography.normal.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          _ResetPasswordField(
            controller: _passwordController,
            hint: 'Nowe hasło',
            forceShowLengthError: _submitAttempted,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _ResetPasswordField(
            controller: _repeatController,
            hint: 'Powtórz hasło',
            forceShowLengthError: _submitAttempted,
            textInputAction: TextInputAction.done,
            onSubmitted: _loading ? null : (_) => _submit(),
          ),
          const SizedBox(height: 24),
          PrimaryActionButton(
            label: _loading ? 'Zapisywanie…' : 'Zapisz hasło',
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordField extends StatefulWidget {
  const _ResetPasswordField({
    required this.controller,
    required this.hint,
    this.forceShowLengthError = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final bool forceShowLengthError;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_ResetPasswordField> createState() => _ResetPasswordFieldState();
}

class _ResetPasswordFieldState extends State<_ResetPasswordField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _tooShort {
    final length = widget.controller.text.length;
    if (length >= _minPasswordLength) return false;
    return length > 0 || widget.forceShowLengthError;
  }

  @override
  Widget build(BuildContext context) {
    final tooShort = _tooShort;
    final fieldStyle = AppTypography.normal.copyWith(
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: tooShort
                ? const BorderSide(color: AppColors.error)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 50,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 52, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: widget.controller,
                      obscureText: _obscured,
                      textInputAction: widget.textInputAction,
                      onSubmitted: widget.onSubmitted,
                      inputFormatters: const <TextInputFormatter>[
                        _PasswordCharsFormatter(),
                      ],
                      autofillHints: const [AutofillHints.newPassword],
                      maxLines: 1,
                      style: fieldStyle,
                      strutStyle: const StrutStyle(
                        fontSize: 14,
                        height: 1,
                        leading: 0,
                        forceStrutHeight: true,
                      ),
                      cursorColor: AppColors.textPrimary,
                      decoration: InputDecoration.collapsed(
                        hintText: widget.hint,
                        hintStyle: fieldStyle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => _obscured = !_obscured),
                      behavior: HitTestBehavior.opaque,
                      child: SvgPicture.asset(
                        _obscured
                            ? 'assets/icons/eye-slash.svg'
                            : 'assets/icons/eye.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textSecondary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (tooShort) ...[
          const SizedBox(height: 8),
          Text(
            'Wartość za krótka',
            style: AppTypography.caption.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
