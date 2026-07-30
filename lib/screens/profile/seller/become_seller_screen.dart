import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';

class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  static const _sellersTable = 'sellers';
  static const _locationsTable = 'seller_locations';

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _qualityController = TextEditingController();
  final _logoController = TextEditingController();
  final _coverController = TextEditingController();

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Polska');
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _pickup = false;
  bool _shipping = false;
  bool _isSaving = false;
  bool _checkingProfile = true;
  String? _existingSellerId;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkExistingSeller();
  }

  Future<void> _checkExistingSeller() async {
    final userId = supabase.auth.currentUser?.id;
    final hasSession = userId != null && userId.isNotEmpty;
    if (!hasSession) {
      if (mounted) {
        setState(() {
          _checkingProfile = false;
          _existingSellerId = null;
          _loggedIn = false;
        });
      }
      return;
    }
    try {
      final row = await supabase
          .from(_sellersTable)
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _existingSellerId = row?['id'] as String?;
        _checkingProfile = false;
        _loggedIn = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkingProfile = false;
        _loggedIn = hasSession;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _qualityController.dispose();
    _logoController.dispose();
    _coverController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zaloguj się, aby zarejestrować konto sprzedawcy.'),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final postal = _postalCodeController.text.trim();
    final country = _countryController.text.trim();

    if (name.isEmpty ||
        address.isEmpty ||
        city.isEmpty ||
        postal.isEmpty ||
        country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Uzupełnij nazwę sprzedawcy oraz adres, miasto, kod i kraj lokalizacji.',
          ),
        ),
      );
      return;
    }

    final latText = _latitudeController.text.trim();
    final lonText = _longitudeController.text.trim();
    double? latitude;
    double? longitude;
    if (latText.isNotEmpty || lonText.isNotEmpty) {
      latitude = double.tryParse(latText.replaceAll(',', '.'));
      longitude = double.tryParse(lonText.replaceAll(',', '.'));
      if (latitude == null || longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Szerokość i długość geograficzną podaj jako liczby (np. 52.23, 21.01).'),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final sellerRow = await supabase.from(_sellersTable).insert({
        'user_id': userId,
        'name': name,
        'description': _nullableTrim(_descriptionController.text),
        'email': _nullableTrim(_emailController.text),
        'phone': _nullableTrim(_phoneController.text),
        'is_pickup_available': _pickup,
        'is_shipping_available': _shipping,
        'quality_description': _nullableTrim(_qualityController.text),
        'logo_image': _nullableTrim(_logoController.text),
        'cover_image': _nullableTrim(_coverController.text),
      }).select('id').single();

      final sellerId = sellerRow['id'] as String;

      await supabase.from(_locationsTable).insert({
        'seller_id': sellerId,
        'address': address,
        'city': city,
        'postal_code': postal,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konto sprzedawcy i lokalizacja zostały zapisane.')),
      );
      Navigator.of(context).pop();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      final message = e.code == '23505'
          ? 'Masz już konto sprzedawcy powiązane z tym profilem.'
          : 'Nie udało się zapisać: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  static String? _nullableTrim(String value) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingProfile) {
      return DefaultScreen(
        title: 'Zostań sprzedawcą',
        onBack: widget.onBack,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_existingSellerId != null) {
      return DefaultScreen(
        title: 'Zostań sprzedawcą',
        onBack: widget.onBack,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront, size: 48, color: AppColors.accent),
                const SizedBox(height: 16),
                const Text(
                  'Masz już konto sprzedawcy powiązane z tym kontem.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: widget.onBack,
                  child: const Text('Wróć'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_loggedIn) {
      return DefaultScreen(
        title: 'Zostań sprzedawcą',
        onBack: widget.onBack,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, size: 48, color: AppColors.accent),
                const SizedBox(height: 16),
                const Text(
                  'Zaloguj się, aby dodać dane sprzedawcy i lokalizacji.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: widget.onBack,
                  child: const Text('Wróć'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultScreen(
      title: 'Zostań sprzedawcą',
      onBack: widget.onBack,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dane sprzedawcy',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Powiązanie z kontem: user_id = zalogowany użytkownik (profiles).',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _SellerFormField(controller: _nameController, label: 'Nazwa / gospodarstwo *'),
            _SellerFormField(
              controller: _descriptionController,
              label: 'Opis',
              maxLines: 3,
            ),
            _SellerFormField(
              controller: _emailController,
              label: 'E-mail',
              keyboardType: TextInputType.emailAddress,
            ),
            _SellerFormField(
              controller: _phoneController,
              label: 'Telefon',
              keyboardType: TextInputType.phone,
            ),
            _SellerFormField(
              controller: _qualityController,
              label: 'Opis jakości / certyfikaty',
              maxLines: 2,
            ),
            _SellerFormField(
              controller: _logoController,
              label: 'logo_image (URL lub ścieżka)',
              hint: 'opcjonalnie',
            ),
            _SellerFormField(
              controller: _coverController,
              label: 'cover_image (URL lub ścieżka)',
              hint: 'opcjonalnie',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Odbiór osobisty'),
              value: _pickup,
              onChanged: (v) => setState(() => _pickup = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Wysyłka'),
              value: _shipping,
              onChanged: (v) => setState(() => _shipping = v),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lokalizacja',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Zapis do tabeli seller_locations z seller_id = nowy rekord sellers.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _SellerFormField(controller: _addressController, label: 'Adres *'),
            _SellerFormField(controller: _cityController, label: 'Miasto *'),
            _SellerFormField(controller: _postalCodeController, label: 'Kod pocztowy *'),
            _SellerFormField(controller: _countryController, label: 'Kraj *'),
            _SellerFormField(
              controller: _latitudeController,
              label: 'Szerokość (latitude)',
              hint: 'opcjonalnie, np. 52.2297',
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
            _SellerFormField(
              controller: _longitudeController,
              label: 'Długość (longitude)',
              hint: 'opcjonalnie, np. 21.0122',
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Zapisz sprzedawcę i lokalizację'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerFormField extends StatelessWidget {
  const _SellerFormField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
