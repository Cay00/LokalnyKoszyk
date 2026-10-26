import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';

/// Edycja danych profilu: imię, telefon, adres domyślny.
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

  bool _loading = true;
  bool _saving = false;

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
        await supabase.from('profiles').upsert(
          <String, dynamic>{
            'id': user.id,
            'full_name': name,
            'phone': phone.isEmpty ? null : phone,
            'default_address': address.isEmpty ? null : address,
          },
          onConflict: 'id',
        );
      } catch (_) {
        await supabase.from('profiles').upsert(
          <String, dynamic>{
            'id': user.id,
            'full_name': name,
          },
          onConflict: 'id',
        );
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

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Ustawienia',
      onBack: widget.onBack,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: DefaultScreen.bodyPadding(context),
              children: <Widget>[
                const Text(
                  'Dane profilu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Imię',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numer telefonu',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Adres domyślny',
                    hintText: 'ulica, kod, miasto',
                    border: OutlineInputBorder(),
                    isDense: true,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Zapisz'),
                  ),
                ),
              ],
            ),
    );
  }
}
