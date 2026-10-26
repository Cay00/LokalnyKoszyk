import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/auth_error_message.dart';
import 'package:lokalny_koszyk/core/supabase/profile_write.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/app_text_field.dart';
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

/// Edycja danych profilu: imię, telefon, adres domyślny + zmiana hasła.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _changingPassword = false;
  bool _deletingAccount = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    String name = '';
    String phone = '';
    String address = '';

    final meta = user.userMetadata ?? <String, dynamic>{};
    final metaName = meta['name'];
    if (metaName is String) name = metaName.trim();
    final metaPhone = meta['phone'];
    if (metaPhone is String) phone = metaPhone.trim();
    final metaAddress = meta['default_address'];
    if (metaAddress is String) address = metaAddress.trim();

    try {
      final row = await supabase
          .from('profiles')
          .select('full_name, phone, default_address')
          .eq('id', user.id)
          .maybeSingle();
      if (row != null) {
        final fullName = (row['full_name'] ?? '').toString().trim();
        if (fullName.isNotEmpty) name = fullName;
        final rowPhone = (row['phone'] ?? '').toString().trim();
        if (rowPhone.isNotEmpty) phone = rowPhone;
        final rowAddress = (row['default_address'] ?? '').toString().trim();
        if (rowAddress.isNotEmpty) address = rowAddress;
      }
    } catch (_) {
      // Kolumny phone/default_address mogą jeszcze nie istnieć — zostaje metadata.
    }

    if (!mounted) return;
    _nameController.text = name;
    _phoneController.text = phone;
    _addressController.text = address;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      showAppNotification(context, 'Zaloguj się, aby zapisać profil.');
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty) {
      showAppNotification(context, 'Podaj imię.');
      return;
    }

    setState(() => _saving = true);
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: <String, dynamic>{
            'name': name,
            'phone': phone,
            'default_address': address,
          },
        ),
      );

      try {
        await syncOwnProfileRow(
          userId: user.id,
          fields: <String, dynamic>{
            'full_name': name,
            'phone': phone.isEmpty ? null : phone,
            'default_address': address.isEmpty ? null : address,
          },
        );
      } catch (_) {
        // Metadata Auth już zapisane; profiles może wymagać polityk RLS
        // z sql/supabase_extensions.sql (profiles_update_own / insert_own).
      }

      if (!mounted) return;
      showAppNotification(context, 'Zapisano dane profilu.');
    } catch (e) {
      if (!mounted) return;
      showAppNotification(context, 'Nie udało się zapisać: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final user = supabase.auth.currentUser;
    final email = user?.email?.trim();
    if (user == null || email == null || email.isEmpty) {
      showAppNotification(context, 'Zaloguj się, aby zmienić hasło.');
      return;
    }

    final current = _currentPasswordController.text;
    final next = _newPasswordController.text;
    final repeat = _repeatPasswordController.text;

    if (current.isEmpty) {
      showAppNotification(context, 'Podaj aktualne hasło.');
      return;
    }
    if (next.length < _minPasswordLength) {
      showAppNotification(
        context,
        'Nowe hasło musi mieć co najmniej $_minPasswordLength znaków.',
      );
      return;
    }
    if (!_hasAllowedPasswordChars(next)) {
      showAppNotification(
        context,
        'Hasło może zawierać tylko litery, cyfry i znaki specjalne',
      );
      return;
    }
    if (next != repeat) {
      showAppNotification(context, 'Hasła nie są takie same');
      return;
    }
    if (current == next) {
      showAppNotification(
        context,
        'Nowe hasło musi się różnić od poprzedniego.',
      );
      return;
    }

    setState(() => _changingPassword = true);
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: current,
      );
      await supabase.auth.updateUser(UserAttributes(password: next));

      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _repeatPasswordController.clear();
      showAppNotification(context, 'Hasło zostało zmienione.');
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
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Usunąć konto?'),
          content: const Text(
            'Konto i powiązane dane (profil, koszyk, ulubione, adresy, opinie) '
            'zostaną usunięte. Historia zamówień zostanie zachowana w systemie.\n\n'
            'Tej operacji nie można cofnąć.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Usuń konto'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    if (supabase.auth.currentUser == null) {
      showAppNotification(context, 'Zaloguj się, aby usunąć konto.');
      return;
    }

    setState(() => _deletingAccount = true);
    try {
      await supabase.rpc('delete_own_account');
      await supabase.auth.signOut();
      if (!mounted) return;
      showAppNotification(context, 'Konto zostało usunięte.');
    } on PostgrestException catch (e) {
      if (!mounted) return;
      final hint = (e.message.contains('function') || e.code == 'PGRST202')
          ? 'Uruchom sql/delete_own_account.sql w Supabase (SQL Editor).'
          : e.message;
      showAppNotification(context, 'Nie udało się usunąć konta: $hint');
    } catch (e) {
      if (!mounted) return;
      showAppNotification(
        context,
        polishAuthError(
          e,
          fallback: 'Nie udało się usunąć konta. Spróbuj ponownie.',
        ),
      );
    } finally {
      if (mounted) setState(() => _deletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _saving || _changingPassword || _deletingAccount;

    return DefaultScreen(
      title: 'Ustawienia profilu',
      onBack: widget.onBack,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentAction),
            )
          : ListView(
              padding: DefaultScreen.bodyPadding(context),
              children: <Widget>[
                Text('Dane profilu', style: AppTypography.header),
                const SizedBox(height: 8),
                Text(
                  'Te informacje są widoczne przy zamówieniach i w Twoim profilu.',
                  style: AppTypography.normal.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: 'Imię',
                  hint: 'np. Anna',
                  textCapitalization: TextCapitalization.words,
                ),
                AppTextField(
                  controller: _phoneController,
                  label: 'Numer telefonu',
                  hint: 'np. 500 600 700',
                  keyboardType: TextInputType.phone,
                ),
                AppTextField(
                  controller: _addressController,
                  label: 'Adres domyślny',
                  hint: 'ulica, numer, kod, miasto',
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 8),
                PrimaryActionButton(
                  label: _saving ? 'Zapisywanie…' : 'Zapisz',
                  onPressed: busy ? null : _save,
                ),
                const SizedBox(height: 28),
                Text('Zmiana hasła', style: AppTypography.header),
                const SizedBox(height: 8),
                Text(
                  'Hasło musi mieć co najmniej $_minPasswordLength znaków.',
                  style: AppTypography.normal.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _currentPasswordController,
                  label: 'Aktualne hasło',
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  inputFormatters: const <TextInputFormatter>[
                    _PasswordCharsFormatter(),
                  ],
                ),
                AppTextField(
                  controller: _newPasswordController,
                  label: 'Nowe hasło',
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  inputFormatters: const <TextInputFormatter>[
                    _PasswordCharsFormatter(),
                  ],
                ),
                AppTextField(
                  controller: _repeatPasswordController,
                  label: 'Powtórz nowe hasło',
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  inputFormatters: const <TextInputFormatter>[
                    _PasswordCharsFormatter(),
                  ],
                ),
                const SizedBox(height: 8),
                PrimaryActionButton(
                  label: _changingPassword
                      ? 'Zmienianie…'
                      : 'Zmień hasło',
                  onPressed: busy ? null : _changePassword,
                ),
                const SizedBox(height: 28),
                Text('Konto', style: AppTypography.header),
                const SizedBox(height: 8),
                Text(
                  'Usunięcie konta kasuje dane profilu, koszyk, ulubione i adresy. '
                  'Historia zamówień pozostaje w systemie.',
                  style: AppTypography.normal.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: busy ? null : _confirmDeleteAccount,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: const StadiumBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      _deletingAccount ? 'Usuwanie…' : 'Usuń konto',
                      style: AppTypography.header.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
