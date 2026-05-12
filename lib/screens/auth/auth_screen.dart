import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/profile_bootstrap.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';

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

  bool _isLogin = true;
  bool _loading = false;

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

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Uzupełnij email i hasło');
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
              'Konto utworzone. Sprawdź email (potwierdzenie może być wymagane).',
            );
          }
        }
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnack(e.message);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Błąd: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
    final title = _isLogin ? 'Logowanie' : 'Rejestracja';
    final action = _isLogin ? 'Zaloguj' : 'Utwórz konto';
    final switchLabel = _isLogin
        ? 'Nie masz konta? Zarejestruj się'
        : 'Masz konto? Zaloguj się';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supabase Auth',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_isLogin) ...[
                    _Field(
                      controller: _nameController,
                      label: 'Imię',
                      autofillHints: const [AutofillHints.name],
                    ),
                    const SizedBox(height: 16),
                  ],
                  _Field(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    controller: _passwordController,
                    label: 'Hasło',
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    _Field(
                      controller: _repeatPasswordController,
                      label: 'Powtórz hasło',
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.normal),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            action,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  if (kDebugMode && _isLogin) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _loading ? null : _fastLogin,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.normal),
                        ),
                      ),
                      child: const Text(
                        'FastLogin',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() => _isLogin = !_isLogin);
                            _passwordController.clear();
                            _repeatPasswordController.clear();
                          },
                    child: Text(
                      switchLabel,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final List<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.normal),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.normal),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.normal),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

