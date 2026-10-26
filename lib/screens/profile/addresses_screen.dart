import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/profile_write.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/app_text_field.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
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
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    String address = '';
    final metaAddress = user.userMetadata?['default_address'];
    if (metaAddress is String) address = metaAddress.trim();

    try {
      final row = await supabase
          .from('profiles')
          .select('default_address')
          .eq('id', user.id)
          .maybeSingle();
      final fromRow = (row?['default_address'] ?? '').toString().trim();
      if (fromRow.isNotEmpty) address = fromRow;
    } catch (_) {}

    if (!mounted) return;
    _addressController.text = address;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      showAppNotification(context, 'Zaloguj się, aby zapisać adres.');
      return;
    }

    final address = _addressController.text.trim();
    setState(() => _saving = true);
    try {
      final existingMeta = Map<String, dynamic>.from(
        user.userMetadata ?? <String, dynamic>{},
      );
      existingMeta['default_address'] = address;

      await supabase.auth.updateUser(UserAttributes(data: existingMeta));

      try {
        await syncOwnProfileRow(
          userId: user.id,
          fields: <String, dynamic>{
            'default_address': address.isEmpty ? null : address,
          },
        );
      } catch (_) {
        // Kolumna / RLS — sql/supabase_extensions.sql
      }

      if (!mounted) return;
      showAppNotification(
        context,
        address.isEmpty
            ? 'Usunięto adres domyślny.'
            : 'Zapisano adres domyślny.',
      );
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
      title: 'Adresy dostawy',
      onBack: widget.onBack,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentAction),
            )
          : ListView(
              padding: DefaultScreen.bodyPadding(context),
              children: <Widget>[
                Text('Adres domyślny', style: AppTypography.header),
                const SizedBox(height: 8),
                Text(
                  'Używany przy składaniu zamówień z dostawą.',
                  style: AppTypography.normal.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _addressController,
                  label: 'Adres',
                  hint: 'ulica, numer, kod, miasto',
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 8),
                PrimaryActionButton(
                  label: _saving ? 'Zapisywanie…' : 'Zapisz adres',
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }
}
