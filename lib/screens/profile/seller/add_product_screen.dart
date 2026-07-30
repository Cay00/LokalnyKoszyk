import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const _tableName = 'products';
  /// Zgodne z seedem w Supabase (kolejność: nazwa → UUID).
  static const List<_CategoryOption> _fallbackCategoryOptions = [
    _CategoryOption(id: '01a39bd2-829c-4496-ae79-640b43475568', label: 'Bakery'),
    _CategoryOption(id: '071af01c-7f1c-4688-8964-ae1d00e1d9c5', label: 'Dairy'),
    _CategoryOption(id: '323724f0-9b85-4af2-b92e-a8558504d945', label: 'Meat'),
    _CategoryOption(id: '3c3d0ffc-dc2e-4f83-8ff0-7c9bbe65763a', label: 'Vegetables'),
    _CategoryOption(id: '4fe783ee-3139-4f6b-b0b8-e7b7a2025c14', label: 'Fruits'),
    _CategoryOption(id: '8a271f6c-79ea-4962-8008-84624f4bc40a', label: 'Beverages'),
    _CategoryOption(id: 'bdee19be-124b-4fbe-b06b-fbd52318ce1e', label: 'Frozen Food'),
    _CategoryOption(id: 'd4ac2bc0-ef10-4811-b706-a98798cdbea4', label: 'Snacks'),
    _CategoryOption(id: 'f3d7e3e6-0938-47ec-ab5c-f7578de938d6', label: 'Grains & Cereals'),
    _CategoryOption(id: 'f87022cc-037c-4aa6-be42-e9619eb3e9ca', label: 'Condiments'),
  ];
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final priceController = TextEditingController();
  final unitController = TextEditingController(text: 'piece');
  final quantityController = TextEditingController(text: '1');
  final stockController = TextEditingController(text: '1');
  final tagsController = TextEditingController();

  List<_CategoryOption> _categoryOptions = const [];
  String? _selectedCategoryId;
  bool _isLoadingCategories = true;
  String? _categoriesError;
  bool _isProcessed = false;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    priceController.dispose();
    unitController.dispose();
    quantityController.dispose();
    stockController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });
    try {
      final rows = await supabase.from('categories').select().limit(200);
      final options = <_CategoryOption>[];
      for (final row in rows) {
        final rawId = row['category_id'] ?? row['id'];
        final rawLabel = row['name'] ?? row['title'] ?? row['slug'];
        if (rawId == null) continue;
        options.add(
          _CategoryOption(
            id: rawId.toString(),
            label: (rawLabel ?? rawId).toString(),
          ),
        );
      }
      if (!mounted) return;
      final effectiveOptions =
          options.isNotEmpty ? options : _fallbackCategoryOptions;
      setState(() {
        _categoryOptions = effectiveOptions;
        _selectedCategoryId = effectiveOptions.first.id;
        _isLoadingCategories = false;
        _categoriesError = options.isNotEmpty
            ? null
            : 'Brak kategorii w bazie - użyto wbudowanej listy (10 kategorii).';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoryOptions = _fallbackCategoryOptions;
        _selectedCategoryId = _fallbackCategoryOptions.first.id;
        _isLoadingCategories = false;
        _categoriesError =
            'Nie udało się pobrać kategorii z bazy - użyto wbudowanej listy (10 kategorii).';
      });
    }
  }

  Future<String?> _sellerRecordIdForCurrentUser() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return null;
    final row = await supabase
        .from('sellers')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    return row?['id'] as String?;
  }

  Future<void> _submit() async {
    final userId = supabase.auth.currentUser?.id;
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final categoryId = _selectedCategoryId;
    final image = imageController.text.trim();
    final unit = unitController.text.trim().toLowerCase();
    final price = double.tryParse(priceController.text.trim());
    final quantity = double.tryParse(quantityController.text.trim());
    final stock = double.tryParse(stockController.text.trim());
    final tags = tagsController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (name.isEmpty ||
        description.isEmpty ||
        categoryId == null ||
        image.isEmpty ||
        unit.isEmpty ||
        price == null ||
        quantity == null ||
        stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uzupełnij wszystkie wymagane pola produktu.')),
      );
      return;
    }
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brak zalogowanego użytkownika. Zaloguj się ponownie.'),
        ),
      );
      return;
    }

    final sellerRecordId = await _sellerRecordIdForCurrentUser();
    if (!mounted) return;
    if (sellerRecordId == null || sellerRecordId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Najpierw zarejestruj konto sprzedawcy (Profil → Zostań sprzedawcą).',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await supabase.from(_tableName).insert({
        'seller_id': sellerRecordId,
        'name': name,
        'description': description,
        'category_id': categoryId,
        'is_processed': _isProcessed,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': _isActive,
        'product_image': image,
        'price': price,
        'unit': unit,
        'quantity': quantity,
        'currency': 'PLN',
        'stock_quantity': stock,
        'tags': tags,
        'ingredients': <Map<String, dynamic>>[],
        'average_rating': 0,
        'reviews_count': 0,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produkt dodany do tabeli $_tableName.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      final userMessage = message.contains('invalid input syntax for type uuid')
          ? 'Błąd UUID: sprawdź category_id (i ewentualnie inne pola referencyjne).'
          : 'Nie udało się dodać produktu: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nowy produkt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'seller_id: rekord z tabeli sellers dla Twojego user_id',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DialogField(controller: nameController, label: 'name *'),
            _DialogField(
              controller: descriptionController,
              label: 'description *',
              maxLines: 3,
            ),
            _CategoryDropdown(
              isLoading: _isLoadingCategories,
              errorText: _categoriesError,
              options: _categoryOptions,
              selectedId: _selectedCategoryId,
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              onRetry: _loadCategories,
            ),
            _DialogField(
              controller: imageController,
              label: 'product_image *',
              hint: 'np. assets/images/food_default.png',
            ),
            _DialogField(
              controller: priceController,
              label: 'price *',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            _DialogField(
              controller: unitController,
              label: 'unit *',
              hint: 'piece/kilogram/gram/liter/milliliter',
            ),
            _DialogField(
              controller: quantityController,
              label: 'quantity *',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            _DialogField(
              controller: stockController,
              label: 'stock_quantity *',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            _DialogField(
              controller: tagsController,
              label: 'tags (opcjonalnie)',
              hint: 'np. lokalne,sezonowe',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('is_processed'),
              value: _isProcessed,
              onChanged: (newValue) => setState(() => _isProcessed = newValue),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('is_active'),
              value: _isActive,
              onChanged: (newValue) => setState(() => _isActive = newValue),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Zapisz produkt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
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

class _CategoryOption {
  const _CategoryOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.isLoading,
    required this.errorText,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorText;
  final List<_CategoryOption> options;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: LinearProgressIndicator(),
      );
    }
    if (options.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                errorText ?? 'Brak kategorii do wyboru.',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Ponów'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (errorText != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    errorText!,
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Ponów'),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          DropdownButtonFormField<String>(
            key: ValueKey<String?>(selectedId),
            initialValue: selectedId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Kategoria *',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: options
                .map(
                  (option) => DropdownMenuItem<String>(
                    value: option.id,
                    child: Text(option.label),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

