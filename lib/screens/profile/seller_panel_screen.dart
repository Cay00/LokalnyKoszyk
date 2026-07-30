import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/screens/profile/seller/become_seller_screen.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';

class SellerPanelScreen extends StatefulWidget {
  const SellerPanelScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<SellerPanelScreen> createState() => _SellerPanelScreenState();
}

class _SellerPanelScreenState extends State<SellerPanelScreen> {
  static const _sellersTable = 'sellers';
  static const _locationsTable = 'seller_locations';

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _seller;
  List<Map<String, dynamic>> _locations = const [];

  bool _editing = false;
  bool _saving = false;

  TextEditingController? _nameCtrl;
  TextEditingController? _descriptionCtrl;
  TextEditingController? _phoneCtrl;
  TextEditingController? _qualityCtrl;
  bool _pickup = false;
  bool _shipping = false;

  final List<_LocationDraft> _locationDrafts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _disposeEditControllers();
    super.dispose();
  }

  void _disposeEditControllers() {
    _nameCtrl?.dispose();
    _nameCtrl = null;
    _descriptionCtrl?.dispose();
    _descriptionCtrl = null;
    _phoneCtrl?.dispose();
    _phoneCtrl = null;
    _qualityCtrl?.dispose();
    _qualityCtrl = null;
    for (final d in _locationDrafts) {
      d.dispose();
    }
    _locationDrafts.clear();
  }

  Future<void> _load() async {
    if (!_editing) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final uid = supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      if (mounted) {
        setState(() {
          _seller = null;
          _locations = const [];
          _loading = false;
        });
      }
      return;
    }

    try {
      final seller = await supabase
          .from(_sellersTable)
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (!mounted) return;

      if (seller == null) {
        setState(() {
          _seller = null;
          _locations = const [];
          _loading = false;
        });
        return;
      }

      final sellerId = seller['id'];
      final locs = await supabase
          .from(_locationsTable)
          .select()
          .eq('seller_id', sellerId);

      if (!mounted) return;

      final locList = (locs as List<dynamic>)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();

      setState(() {
        _seller = Map<String, dynamic>.from(seller);
        _locations = locList;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _seller = null;
        _locations = const [];
        _loading = false;
      });
    }
  }

  void _enterEdit() {
    final s = _seller!;
    _disposeEditControllers();

    _nameCtrl = TextEditingController(text: _textOrEmpty(s['name']));
    _descriptionCtrl = TextEditingController(text: _textOrEmpty(s['description']));
    _phoneCtrl = TextEditingController(text: _textOrEmpty(s['phone']));
    _qualityCtrl = TextEditingController(text: _textOrEmpty(s['quality_description']));
    _pickup = s['is_pickup_available'] == true;
    _shipping = s['is_shipping_available'] == true;

    for (final loc in _locations) {
      _locationDrafts.add(_LocationDraft.fromMap(loc));
    }

    setState(() => _editing = true);
  }

  void _cancelEdit() {
    _disposeEditControllers();
    setState(() => _editing = false);
  }

  void _addEmptyLocation() {
    setState(() {
      _locationDrafts.add(_LocationDraft.empty());
    });
  }

  void _removeDraftAt(int index) {
    if (index < 0 || index >= _locationDrafts.length) return;
    setState(() {
      _locationDrafts[index].dispose();
      _locationDrafts.removeAt(index);
    });
  }

  Future<void> _save() async {
    final seller = _seller;
    final nameCtrl = _nameCtrl;
    if (seller == null || nameCtrl == null) return;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;

    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nazwa sprzedawcy jest wymagana.')),
      );
      return;
    }

    final sellerId = seller['id']?.toString();
    if (sellerId == null || sellerId.isEmpty) return;

    for (var i = 0; i < _locationDrafts.length; i++) {
      final d = _locationDrafts[i];
      final err = d.validateOrNull();
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lokalizacja ${i + 1}: $err')),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      await supabase.from(_sellersTable).update({
        'name': name,
        'description': _nullableTrim(_descriptionCtrl?.text),
        'phone': _nullableTrim(_phoneCtrl?.text),
        'is_pickup_available': _pickup,
        'is_shipping_available': _shipping,
        'quality_description': _nullableTrim(_qualityCtrl?.text),
      }).eq('id', sellerId).eq('user_id', uid);

      for (final d in _locationDrafts) {
        final payload = d.toPayload();
        if (d.locationId == null) {
          if (payload == null) continue;
          await supabase.from(_locationsTable).insert({
            'seller_id': sellerId,
            ...payload,
          });
        } else {
          if (payload == null) continue;
          await supabase.from(_locationsTable).update(payload).eq('id', d.locationId!);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zapisano zmiany.')),
      );
      _cancelEdit();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się zapisać: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _textOrEmpty(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  static String? _nullableTrim(String? text) {
    if (text == null) return null;
    final t = text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _openBecomeSeller() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => BecomeSellerScreen(
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return DefaultScreen(
        title: 'Panel sprzedawcy',
        onBack: widget.onBack,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return DefaultScreen(
        title: 'Panel sprzedawcy',
        onBack: widget.onBack,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _load,
                  child: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final uid = supabase.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      return DefaultScreen(
        title: 'Panel sprzedawcy',
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
                  'Zaloguj się, aby zobaczyć panel sprzedawcy.',
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

    if (_seller == null) {
      return DefaultScreen(
        title: 'Panel sprzedawcy',
        onBack: widget.onBack,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront_outlined, size: 48, color: AppColors.accent),
                const SizedBox(height: 16),
                const Text(
                  'Nie masz jeszcze konta sprzedawcy w bazie.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _openBecomeSeller,
                  child: const Text('Zostań sprzedawcą'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onBack,
                  child: const Text('Wróć do profilu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultScreen(
      title: 'Panel sprzedawcy',
      onBack: widget.onBack,
      body: RefreshIndicator(
        onRefresh: (_editing || _saving)
            ? () async {}
            : _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_editing)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: _enterEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: const Text('Edytuj'),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _cancelEdit,
                        child: const Text('Anuluj'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
                const SizedBox(height: 16),
              ],
              const Text(
                'Konto sprzedawcy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _InfoTile(label: 'ID rekordu (sellers.id)', value: _str(_seller!['id'])),
              _InfoTile(label: 'Powiązany użytkownik (user_id)', value: _str(_seller!['user_id'])),
              if (!_editing) ...[
                _InfoTile(label: 'Nazwa', value: _str(_seller!['name'])),
                _InfoTile(label: 'Opis', value: _str(_seller!['description'])),
                _InfoTile(label: 'E-mail', value: _str(_seller!['email'])),
                _InfoTile(label: 'Telefon', value: _str(_seller!['phone'])),
                _InfoTile(label: 'Zweryfikowany', value: _boolPl(_seller!['is_verified'])),
                _InfoTile(label: 'Odbiór osobisty', value: _boolPl(_seller!['is_pickup_available'])),
                _InfoTile(label: 'Wysyłka', value: _boolPl(_seller!['is_shipping_available'])),
                _InfoTile(label: 'Opis jakości', value: _str(_seller!['quality_description'])),
                _InfoTile(label: 'Logo (URL)', value: _str(_seller!['logo_image'])),
                _InfoTile(label: 'Okładka (URL)', value: _str(_seller!['cover_image'])),
                _InfoTile(label: 'Utworzono', value: _formatTs(_seller!['created_at'])),
              ] else ...[
                _PanelField(controller: _nameCtrl!, label: 'Nazwa *'),
                _PanelField(controller: _descriptionCtrl!, label: 'Opis', maxLines: 4),
                _InfoTile(label: 'E-mail', value: _str(_seller!['email'])),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'E-mail zmienisz w ustawieniach konta / profilu (jeśli dodamy edycję).',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                _PanelField(
                  controller: _phoneCtrl!,
                  label: 'Telefon (kontakt / odbiór)',
                  keyboardType: TextInputType.phone,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Odbiór osobisty'),
                  value: _pickup,
                  onChanged: _saving ? null : (v) => setState(() => _pickup = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Wysyłka'),
                  value: _shipping,
                  onChanged: _saving ? null : (v) => setState(() => _shipping = v),
                ),
                _PanelField(
                  controller: _qualityCtrl!,
                  label: 'Opis jakości',
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Lokalizacje',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _editing ? '(${_locationDrafts.length})' : '(${_locations.length})',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!_editing) ...[
                if (_locations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Brak wpisów w seller_locations.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  )
                else
                  ..._locations.asMap().entries.map((e) {
                    final i = e.key + 1;
                    final loc = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.background),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lokalizacja $i',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _InfoTile(label: 'ID', value: _str(loc['id']), dense: true),
                            _InfoTile(label: 'Adres', value: _str(loc['address']), dense: true),
                            _InfoTile(label: 'Miasto', value: _str(loc['city']), dense: true),
                            _InfoTile(label: 'Kod pocztowy', value: _str(loc['postal_code']), dense: true),
                            _InfoTile(label: 'Kraj', value: _str(loc['country']), dense: true),
                            _InfoTile(
                              label: 'Współrzędne',
                              value: _coords(loc['latitude'], loc['longitude']),
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ] else ...[
                if (_locationDrafts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Brak lokalizacji — możesz dodać pierwszą.',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _saving ? null : _addEmptyLocation,
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: const Text('Dodaj lokalizację'),
                        ),
                      ],
                    ),
                  ),
                ..._locationDrafts.asMap().entries.map((e) {
                  final index = e.key;
                  final draft = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.background),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  draft.locationId == null
                                      ? 'Nowa lokalizacja'
                                      : 'Lokalizacja (ID: ${_shortId(draft.locationId!)})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              if (draft.locationId == null)
                                IconButton(
                                  onPressed: _saving ? null : () => _removeDraftAt(index),
                                  icon: const Icon(Icons.close),
                                  tooltip: 'Usuń',
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _PanelField(controller: draft.address, label: 'Adres *'),
                          _PanelField(controller: draft.city, label: 'Miasto *'),
                          _PanelField(controller: draft.postalCode, label: 'Kod pocztowy *'),
                          _PanelField(controller: draft.country, label: 'Kraj *'),
                          _PanelField(
                            controller: draft.latitude,
                            label: 'Szerokość (opcjonalnie)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          _PanelField(
                            controller: draft.longitude,
                            label: 'Długość (opcjonalnie)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (_locationDrafts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: _saving ? null : _addEmptyLocation,
                      icon: const Icon(Icons.add),
                      label: const Text('Kolejna lokalizacja'),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }

  static String _str(dynamic v) {
    if (v == null) return '—';
    final s = v.toString().trim();
    return s.isEmpty ? '—' : s;
  }

  static String _boolPl(dynamic v) {
    if (v is bool) return v ? 'Tak' : 'Nie';
    return '—';
  }

  static String _formatTs(dynamic v) {
    if (v == null) return '—';
    final parsed = DateTime.tryParse(v.toString());
    if (parsed == null) return v.toString();
    return '${parsed.toLocal()}'.split('.').first;
  }

  static String _coords(dynamic lat, dynamic lon) {
    final la = lat == null ? '' : lat.toString();
    final lo = lon == null ? '' : lon.toString();
    if (la.isEmpty && lo.isEmpty) return '—';
    return '$la, $lo';
  }
}

class _LocationDraft {
  _LocationDraft({
    this.locationId,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String? locationId;
  final TextEditingController address;
  final TextEditingController city;
  final TextEditingController postalCode;
  final TextEditingController country;
  final TextEditingController latitude;
  final TextEditingController longitude;

  void dispose() {
    address.dispose();
    city.dispose();
    postalCode.dispose();
    country.dispose();
    latitude.dispose();
    longitude.dispose();
  }

  factory _LocationDraft.fromMap(Map<String, dynamic> loc) {
    String t(dynamic v) => v?.toString() ?? '';
    return _LocationDraft(
      locationId: loc['id']?.toString(),
      address: TextEditingController(text: t(loc['address'])),
      city: TextEditingController(text: t(loc['city'])),
      postalCode: TextEditingController(text: t(loc['postal_code'])),
      country: TextEditingController(text: t(loc['country']).isEmpty ? 'Polska' : t(loc['country'])),
      latitude: TextEditingController(text: loc['latitude'] == null ? '' : '${loc['latitude']}'),
      longitude: TextEditingController(text: loc['longitude'] == null ? '' : '${loc['longitude']}'),
    );
  }

  factory _LocationDraft.empty() {
    return _LocationDraft(
      locationId: null,
      address: TextEditingController(),
      city: TextEditingController(),
      postalCode: TextEditingController(),
      country: TextEditingController(text: 'Polska'),
      latitude: TextEditingController(),
      longitude: TextEditingController(),
    );
  }

  /// null = OK; tekst = błąd walidacji.
  String? validateOrNull() {
    final a = address.text.trim();
    final c = city.text.trim();
    final p = postalCode.text.trim();
    final co = country.text.trim();
    final la = latitude.text.trim();
    final lo = longitude.text.trim();

    if (locationId != null) {
      if (a.isEmpty || c.isEmpty || p.isEmpty || co.isEmpty) {
        return 'wypełnij adres, miasto, kod pocztowy i kraj.';
      }
    } else {
      final any =
          a.isNotEmpty || c.isNotEmpty || p.isNotEmpty || co.isNotEmpty || la.isNotEmpty || lo.isNotEmpty;
      if (!any) return null;
      if (a.isEmpty || c.isEmpty || p.isEmpty || co.isEmpty) {
        return 'wypełnij adres, miasto, kod i kraj albo usuń pustą lokalizację (×).';
      }
    }

    if (la.isNotEmpty || lo.isNotEmpty) {
      final lat = double.tryParse(la.replaceAll(',', '.'));
      final lon = double.tryParse(lo.replaceAll(',', '.'));
      if (lat == null || lon == null) {
        return 'podaj szerokość i długość jako liczby albo oba pola zostaw puste.';
      }
    }
    return null;
  }

  /// null = brak danych do insertu (pusty nowy szkic). Przy update zawsze zwraca mapę.
  Map<String, dynamic>? toPayload() {
    final a = address.text.trim();
    final c = city.text.trim();
    final p = postalCode.text.trim();
    final co = country.text.trim();
    final la = latitude.text.trim();
    final lo = longitude.text.trim();

    double? lat;
    double? lon;
    if (la.isNotEmpty && lo.isNotEmpty) {
      lat = double.tryParse(la.replaceAll(',', '.'));
      lon = double.tryParse(lo.replaceAll(',', '.'));
    }

    if (locationId == null) {
      final any =
          a.isNotEmpty || c.isNotEmpty || p.isNotEmpty || co.isNotEmpty || la.isNotEmpty || lo.isNotEmpty;
      if (!any) return null;
    }

    return <String, dynamic>{
      'address': a.isEmpty ? null : a,
      'city': c.isEmpty ? null : c,
      'postal_code': p.isEmpty ? null : p,
      'country': co.isEmpty ? null : co,
      'latitude': lat,
      'longitude': lon,
    };
  }
}

class _PanelField extends StatelessWidget {
  const _PanelField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
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
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    this.dense = false,
  });

  final String label;
  final String value;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: dense ? 6 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: dense ? 100 : 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: dense ? 12 : 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: dense ? 13 : 14,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
