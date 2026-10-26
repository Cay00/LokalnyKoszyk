import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/payment_method.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/app_text_field.dart';
import 'package:lokalny_koszyk/widgets/common/app_toggle_row.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

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
  final Set<AppPaymentMethod> _acceptedPayments = Set<AppPaymentMethod>.of(
    AppPaymentMethod.all,
  );
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
      showAppNotification(
        context,
        'Zaloguj się, aby zarejestrować konto sprzedawcy.',
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
      showAppNotification(
        context,
        'Uzupełnij nazwę sprzedawcy oraz adres, miasto, kod i kraj lokalizacji.',
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
        showAppNotification(
          context,
          'Szerokość i długość geograficzną podaj jako liczby (np. 52.23, 21.01).',
        );
        return;
      }
    }

    if (_acceptedPayments.isEmpty) {
      showAppNotification(
        context,
        'Wybierz co najmniej jedną metodę płatności.',
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final basePayload = <String, dynamic>{
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
      };
      Map<String, dynamic> sellerRow;
      try {
        sellerRow = Map<String, dynamic>.from(
          await supabase
              .from(_sellersTable)
              .insert({
                ...basePayload,
                'accepted_payment_methods': AppPaymentMethod.encodeList(
                  _acceptedPayments,
                ),
              })
              .select('id')
              .single(),
        );
      } catch (_) {
        sellerRow = Map<String, dynamic>.from(
          await supabase
              .from(_sellersTable)
              .insert(basePayload)
              .select('id')
              .single(),
        );
      }

      final sellerId = sellerRow['id'].toString();

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
      showAppNotification(
        context,
        'Konto sprzedawcy i lokalizacja zostały zapisane.',
      );
      Navigator.of(context).pop();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      final message = e.code == '23505'
          ? 'Masz już konto sprzedawcy powiązane z tym profilem.'
          : 'Nie udało się zapisać: ${e.message}';
      showAppNotification(context, message);
    } catch (e) {
      if (!mounted) return;
      showAppNotification(context, 'Nie udało się zapisać: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  static String? _nullableTrim(String value) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  Widget _infoState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48, color: AppColors.accentAction),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.normal.copyWith(height: 1.4),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              label: 'Wróć',
              onPressed: widget.onBack,
            ),
          ],
        ),
      ),
    );
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
        body: _infoState(
          icon: Icons.storefront,
          message: 'Masz już konto sprzedawcy powiązane z tym kontem.',
        ),
      );
    }

    if (!_loggedIn) {
      return DefaultScreen(
        title: 'Zostań sprzedawcą',
        onBack: widget.onBack,
        body: _infoState(
          icon: Icons.login,
          message: 'Zaloguj się, aby dodać dane sprzedawcy i lokalizacji.',
        ),
      );
    }

    return DefaultScreen(
      title: 'Zostań sprzedawcą',
      onBack: widget.onBack,
      body: ListView(
        padding: DefaultScreen.bodyPadding(context),
        children: <Widget>[
          Text('Dane sprzedawcy', style: AppTypography.header),
          const SizedBox(height: 12),
          AppTextField(
            controller: _nameController,
            label: 'Nazwa / gospodarstwo *',
            textCapitalization: TextCapitalization.words,
          ),
          AppTextField(
            controller: _descriptionController,
            label: 'Opis',
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          AppTextField(
            controller: _emailController,
            label: 'E-mail',
            keyboardType: TextInputType.emailAddress,
          ),
          AppTextField(
            controller: _phoneController,
            label: 'Telefon',
            keyboardType: TextInputType.phone,
          ),
          AppTextField(
            controller: _qualityController,
            label: 'Opis jakości / certyfikaty',
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          AppTextField(
            controller: _logoController,
            label: 'Logo (URL)',
            hint: 'opcjonalnie',
          ),
          AppTextField(
            controller: _coverController,
            label: 'Okładka (URL)',
            hint: 'opcjonalnie',
          ),
          AppToggleRow(
            label: 'Odbiór osobisty',
            value: _pickup,
            onChanged: (bool v) => setState(() => _pickup = v),
          ),
          AppToggleRow(
            label: 'Wysyłka',
            value: _shipping,
            onChanged: (bool v) => setState(() => _shipping = v),
          ),
          const SizedBox(height: 8),
          Text('Akceptowane metody płatności', style: AppTypography.normalBold),
          const SizedBox(height: 8),
          ...AppPaymentMethod.values.map((AppPaymentMethod method) {
            return AppCheckTile(
              label: method.label,
              checked: _acceptedPayments.contains(method),
              onChanged: (bool checked) {
                setState(() {
                  if (checked) {
                    _acceptedPayments.add(method);
                  } else {
                    _acceptedPayments.remove(method);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 16),
          Text('Lokalizacja', style: AppTypography.header),
          const SizedBox(height: 12),
          AppTextField(
            controller: _addressController,
            label: 'Adres *',
            textCapitalization: TextCapitalization.sentences,
          ),
          AppTextField(
            controller: _cityController,
            label: 'Miasto *',
            textCapitalization: TextCapitalization.words,
          ),
          AppTextField(
            controller: _postalCodeController,
            label: 'Kod pocztowy *',
          ),
          AppTextField(
            controller: _countryController,
            label: 'Kraj *',
            textCapitalization: TextCapitalization.words,
          ),
          AppTextField(
            controller: _latitudeController,
            label: 'Szerokość geograficzna',
            hint: 'opcjonalnie, np. 52.2297',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
          ),
          AppTextField(
            controller: _longitudeController,
            label: 'Długość geograficzna',
            hint: 'opcjonalnie, np. 21.0122',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
          ),
          const SizedBox(height: 8),
          PrimaryActionButton(
            label: _isSaving ? 'Zapisywanie…' : 'Zapisz sprzedawcę',
            onPressed: _isSaving ? null : _submit,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
