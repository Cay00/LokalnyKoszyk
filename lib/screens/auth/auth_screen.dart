import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/auth_error_message.dart';
import 'package:lokalny_koszyk/core/supabase/profile_bootstrap.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_config.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';

const int _minPasswordLength = 8;

const String _passwordAllowedChars =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    '!@#\$%^&*()_+-=[]{}|;:,.<>/?`~\\\'"';

final RegExp _emailPattern = RegExp(
  r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
);

bool _isValidEmail(String email) => _emailPattern.hasMatch(email);

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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _isLogin = false;
  bool _loading = false;
  bool _submitAttempted = false;

  static const double _fieldHeight = 50;
  static const double _fieldRadius = 25;
  static const double _fieldGap = 16;
  static const double _sectionGap = 24;

  static final TextStyle _modeLinkStyle = AppTypography.normal.copyWith(
    fontSize: 16,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;

    if (email.isEmpty) {
      _showSnack('Uzupełnij email');
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnack('Podaj poprawny adres email');
      return;
    }
    if (password.length < _minPasswordLength) {
      setState(() => _submitAttempted = true);
      return;
    }
    if (!_hasAllowedPasswordChars(password)) {
      _showSnack(
        'Hasło może zawierać tylko litery, cyfry i znaki specjalne',
      );
      return;
    }

    if (!_isLogin) {
      if (name.isEmpty) {
        _showSnack('Uzupełnij imię');
        return;
      }
      if (repeatPassword.isEmpty) {
        _showSnack('Powtórz hasło');
        return;
      }
      if (password != repeatPassword) {
        _showSnack('Hasła nie są takie same');
        return;
      }
    }

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        final res = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (!mounted) return;
        if (res.user == null || res.session == null) {
          _showSnack('Nie udało się zalogować (brak sesji).');
        } else {
          await ProfileBootstrap.ensureRowForAuthUser(res.user!);
        }
      } else {
        final res = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        );
        if (!mounted) return;
        if (res.user == null) {
          _showSnack('Nie udało się zarejestrować.');
        } else {
          if (res.session != null) {
            await ProfileBootstrap.ensureRowForAuthUser(res.user!);
          }
          if (!mounted) return;
          if (res.session == null) {
            _showSnack(
              'Konto utworzone. Sprawdź email.',
            );
          }
        }
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(
        polishAuthError(
          e,
          fallback: _isLogin
              ? 'Nie udało się zalogować. Spróbuj ponownie.'
              : 'Nie udało się zarejestrować. Spróbuj ponownie.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        polishAuthError(
          e,
          fallback: _isLogin
              ? 'Nie udało się zalogować. Spróbuj ponownie.'
              : 'Nie udało się zarejestrować. Spróbuj ponownie.',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Podaj email, aby zresetować hasło');
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnack('Podaj poprawny adres email');
      return;
    }

    setState(() => _loading = true);
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : SupabaseConfig.passwordResetRedirectTo,
      );
      if (!mounted) return;
      _showSnack('Jeśli konto istnieje, wyślemy link do resetu hasła.');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(
        polishAuthError(
          e,
          fallback: 'Nie udało się wysłać linku. Spróbuj ponownie.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        polishAuthError(
          e,
          fallback: 'Nie udało się wysłać linku. Spróbuj ponownie.',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    showAppNotification(context, msg);
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _submitAttempted = false;
      _passwordController.clear();
      _repeatPasswordController.clear();
    });
  }

  Future<void> _fastLogin() async {
    if (!_isLogin) {
      setState(() => _isLogin = true);
    }
    _emailController.text = 'admin@gmail.com';
    _passwordController.text = 'admin123';
    _repeatPasswordController.clear();
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    if (!_isLogin) ...[
                      _AuthField(
                        key: const ValueKey<String>('auth-name'),
                        controller: _nameController,
                        hint: 'Imię',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: _fieldGap),
                    ],
                    _AuthField(
                      key: const ValueKey<String>('auth-email'),
                      controller: _emailController,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: _fieldGap),
                    _AuthField(
                      key: const ValueKey<String>('auth-password'),
                      controller: _passwordController,
                      hint: 'Hasło',
                      isPassword: true,
                      minLength: _minPasswordLength,
                      forceShowLengthError: _submitAttempted,
                      textInputAction: _isLogin
                          ? TextInputAction.done
                          : TextInputAction.next,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: _isLogin && !_loading
                          ? (_) => _submit()
                          : null,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: _fieldGap),
                      _AuthField(
                        key: const ValueKey<String>('auth-repeat-password'),
                        controller: _repeatPasswordController,
                        hint: 'Powtórz hasło',
                        isPassword: true,
                        minLength: _minPasswordLength,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        onSubmitted: _loading ? null : (_) => _submit(),
                      ),
                    ],
                    if (_isLogin) ...[
                      const SizedBox(height: _fieldGap),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _AuthTextAction(
                          label: 'Nie pamiętam hasła',
                          style: AppTypography.normal,
                          onPressed: _loading ? null : _forgotPassword,
                        ),
                      ),
                    ],
                    const SizedBox(height: _sectionGap),
                    SizedBox(
                      height: _fieldHeight,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textPrimary,
                          disabledBackgroundColor: AppColors.accent.withValues(
                            alpha: 0.6,
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_fieldRadius),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textPrimary,
                                ),
                              )
                            : Text(
                                _isLogin ? 'Zaloguj się' : 'Zarejestruj się',
                                style: AppTypography.header,
                              ),
                      ),
                    ),
                    const SizedBox(height: _sectionGap),
                    Center(
                      child: _AuthTextAction(
                        label: _isLogin ? 'Zarejestruj się' : 'Zaloguj się',
                        style: _modeLinkStyle,
                        onPressed: _loading ? null : _toggleMode,
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: _sectionGap),
                      SizedBox(
                        height: _fieldHeight,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _loading ? null : _fastLogin,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            padding: EdgeInsets.zero,
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_fieldRadius),
                            ),
                          ),
                          child: Text(
                            'FastLogin',
                            style: AppTypography.header.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}

class _AuthTextAction extends StatelessWidget {
  const _AuthTextAction({
    required this.label,
    required this.style,
    required this.onPressed,
  });

  final String label;
  final TextStyle style;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}

class _AuthField extends StatefulWidget {
  const _AuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.isPassword = false,
    this.minLength,
    this.forceShowLengthError = false,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool isPassword;
  final int? minLength;
  final bool forceShowLengthError;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(_AuthField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _tooShort {
    final int? minLength = widget.minLength;
    if (minLength == null) return false;
    final int length = widget.controller.text.length;
    if (length >= minLength) return false;
    return length > 0 || widget.forceShowLengthError;
  }

  @override
  Widget build(BuildContext context) {
    final bool obscureText = widget.isPassword && _obscured;
    final bool tooShort = _tooShort;
    final TextStyle fieldStyle = AppTypography.normal.copyWith(
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Material(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_AuthScreenState._fieldRadius),
            side: tooShort
                ? const BorderSide(color: AppColors.error)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: _AuthScreenState._fieldHeight,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    widget.isPassword ? 52 : 20,
                    0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: widget.controller,
                      keyboardType: widget.keyboardType,
                      obscureText: obscureText,
                      autofillHints: widget.autofillHints,
                      textInputAction: widget.textInputAction,
                      onSubmitted: widget.onSubmitted,
                      inputFormatters: widget.isPassword
                          ? const <TextInputFormatter>[_PasswordCharsFormatter()]
                          : null,
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
                if (widget.isPassword)
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
