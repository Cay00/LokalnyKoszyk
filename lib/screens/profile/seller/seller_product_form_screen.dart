import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/formatting/product_price_per_label.dart';
import 'package:lokalny_koszyk/core/supabase/current_seller.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/app_text_field.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

/// Tworzenie / edycja ogłoszenia produktowego (opis, zdjęcia, cena).
class SellerProductFormScreen extends StatefulWidget {
  const SellerProductFormScreen({
    super.key,
    this.productId,
    this.onBack,
  });

  /// `null` = nowe ogłoszenie.
  final String? productId;
  final VoidCallback? onBack;

  bool get isEditing => productId != null && productId!.isNotEmpty;

  @override
  State<SellerProductFormScreen> createState() =>
      _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _packageSizeCtrl = TextEditingController(text: '1');
  final _stockCtrl = TextEditingController(text: '1');
  final _imageCtrl = TextEditingController();

  List<_CategoryOption> _categories = const [];
  String? _categoryId;
  ProductUnit _unit = ProductUnit.piece;
  bool _isActive = true;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _packageSizeCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      await _loadCategories();
      if (widget.isEditing) {
        await _loadProduct(widget.productId!);
      }
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCategories() async {
    final rows = await supabase.from('categories').select('category_id, name').limit(200);
    final options = <_CategoryOption>[];
    for (final dynamic row in rows as List<dynamic>) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = (map['category_id'] ?? '').toString();
      final name = (map['name'] ?? id).toString();
      if (id.isEmpty) continue;
      options.add(_CategoryOption(id: id, label: name));
    }
    if (!mounted) return;
    setState(() {
      _categories = options;
      _categoryId ??= options.isEmpty ? null : options.first.id;
    });
  }

  Future<void> _loadProduct(String productId) async {
    final row = await supabase
        .from('products')
        .select(
          'product_id, name, description, category_id, unit, package_size, '
          'stock_quantity, price_gross_amount, is_active',
        )
        .eq('product_id', productId)
        .maybeSingle();
    if (row == null) throw StateError('Nie znaleziono produktu.');
    final map = Map<String, dynamic>.from(row);

    String imagePath = '';
    try {
      final images = await supabase
          .from('product_images')
          .select('path, is_main, position')
          .eq('product_id', productId)
          .order('position');
      final list = (images as List<dynamic>)
          .map((dynamic r) => Map<String, dynamic>.from(r as Map))
          .toList();
      Map<String, dynamic>? main;
      for (final img in list) {
        if (img['is_main'] == true) {
          main = img;
          break;
        }
      }
      main ??= list.isEmpty ? null : list.first;
      imagePath = (main?['path'] ?? '').toString();
    } catch (_) {}

    if (!mounted) return;
    final unitRaw = (map['unit'] ?? 'piece').toString();
    final unit = ProductUnitParsing.fromSlashUnit(unitRaw) ?? ProductUnit.piece;
    _nameCtrl.text = (map['name'] ?? '').toString();
    _descriptionCtrl.text = (map['description'] ?? '').toString();
    _priceCtrl.text = plnCommaStringFromPennies(
      parsePennies(map['price_gross_amount']),
    );
    _packageSizeCtrl.text = ((map['package_size'] as num?) ?? 1).toString();
    _stockCtrl.text = ((map['stock_quantity'] as num?) ?? 0).toString();
    _imageCtrl.text = imagePath;
    setState(() {
      _categoryId = (map['category_id'] ?? '').toString();
      _unit = unit;
      _isActive = map['is_active'] != false;
    });
  }

  Future<void> _save() async {
    final sellerId = await currentSellerId();
    if (!mounted) return;
    if (sellerId == null) {
      showAppNotification(
        context,
        'Brak konta sprzedawcy. Zarejestruj się jako sprzedawca.',
      );
      return;
    }

    final name = _nameCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    final categoryId = _categoryId;
    final pennies = penniesFromPlnInput(_priceCtrl.text);
    final packageSize = double.tryParse(
      _packageSizeCtrl.text.trim().replaceAll(',', '.'),
    );
    final stock = int.tryParse(_stockCtrl.text.trim());
    final imagePath = _imageCtrl.text.trim();

    if (name.isEmpty ||
        description.isEmpty ||
        categoryId == null ||
        categoryId.isEmpty ||
        pennies == null ||
        packageSize == null ||
        packageSize <= 0 ||
        stock == null ||
        stock < 0) {
      showAppNotification(context, 'Uzupełnij poprawnie wszystkie wymagane pola.');
      return;
    }

    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{
        'seller_id': sellerId,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'unit': _unit.name,
        'package_size': packageSize,
        'stock_quantity': stock,
        'price_gross_amount': pennies,
        'currency': 'PLN',
        'is_active': _isActive,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'deleted_at': null,
      };

      String productId;
      if (widget.isEditing) {
        productId = widget.productId!;
        await supabase.from('products').update(payload).eq('product_id', productId);
      } else {
        final inserted = await supabase
            .from('products')
            .insert(payload)
            .select('product_id')
            .single();
        productId = (inserted['product_id'] ?? '').toString();
      }

      if (imagePath.isNotEmpty && productId.isNotEmpty) {
        await _upsertMainImage(productId, imagePath);
      }

      if (!mounted) return;
      showAppNotification(
        context,
        widget.isEditing ? 'Zapisano ogłoszenie.' : 'Dodano ogłoszenie.',
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showAppNotification(context, 'Nie udało się zapisać: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _upsertMainImage(String productId, String path) async {
    try {
      final existing = await supabase
          .from('product_images')
          .select('id')
          .eq('product_id', productId)
          .eq('is_main', true)
          .maybeSingle();
      if (existing != null) {
        await supabase
            .from('product_images')
            .update(<String, dynamic>{'path': path, 'position': 0})
            .eq('id', existing['id']);
      } else {
        await supabase.from('product_images').insert(<String, dynamic>{
          'product_id': productId,
          'path': path,
          'is_main': true,
          'position': 0,
        });
      }
    } catch (_) {
      // Brak RLS / tabeli — produkt i tak zapisany.
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: widget.isEditing ? 'Edytuj ogłoszenie' : 'Nowe ogłoszenie',
      onBack: widget.onBack ?? () => Navigator.of(context).pop(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentAction),
            )
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_loadError!, textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: DefaultScreen.bodyPadding(context),
              children: <Widget>[
                Text(
                  widget.isEditing
                      ? 'Zmień opis, cenę i zdjęcie oferty.'
                      : 'Utwórz nowe ogłoszenie produktowe.',
                  style: AppTypography.normal.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Nazwa *',
                  textCapitalization: TextCapitalization.sentences,
                ),
                AppTextField(
                  controller: _descriptionCtrl,
                  label: 'Opis *',
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),
                Text('Kategoria *', style: AppTypography.caption),
                const SizedBox(height: 6),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.normal),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categories.any((c) => c.id == _categoryId)
                            ? _categoryId
                            : null,
                        isExpanded: true,
                        hint: Text('Wybierz kategorię', style: AppTypography.normal),
                        items: _categories
                            .map(
                              (_CategoryOption c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Text(c.label),
                              ),
                            )
                            .toList(),
                        onChanged: (String? v) => setState(() => _categoryId = v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Jednostka *', style: AppTypography.caption),
                const SizedBox(height: 6),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.normal),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductUnit>(
                        value: _unit,
                        isExpanded: true,
                        items: ProductUnit.values
                            .map(
                              (ProductUnit u) => DropdownMenuItem<ProductUnit>(
                                value: u,
                                child: Text(_unitLabel(u)),
                              ),
                            )
                            .toList(),
                        onChanged: (ProductUnit? v) {
                          if (v != null) setState(() => _unit = v);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _priceCtrl,
                  label: 'Cena brutto (zł) *',
                  hint: 'np. 12,99',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                ),
                AppTextField(
                  controller: _packageSizeCtrl,
                  label: 'Rozmiar opakowania *',
                  hint: 'np. 1',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                AppTextField(
                  controller: _stockCtrl,
                  label: 'Stan magazynowy *',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                AppTextField(
                  controller: _imageCtrl,
                  label: 'Zdjęcie (ścieżka / URL)',
                  hint: 'np. assets/images/food_default.png',
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Aktywne ogłoszenie', style: AppTypography.normal),
                  value: _isActive,
                  activeThumbColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.accent,
                  onChanged: (bool v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 8),
                PrimaryActionButton(
                  label: _saving
                      ? 'Zapisywanie…'
                      : (widget.isEditing ? 'Zapisz zmiany' : 'Dodaj ogłoszenie'),
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }

  String _unitLabel(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.piece:
        return 'szt.';
      case ProductUnit.kilogram:
        return 'kg';
      case ProductUnit.gram:
        return 'g';
      case ProductUnit.liter:
        return 'l';
      case ProductUnit.milliliter:
        return 'ml';
    }
  }
}

class _CategoryOption {
  const _CategoryOption({required this.id, required this.label});
  final String id;
  final String label;
}
