import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/current_seller.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/screens/profile/seller/seller_product_form_screen.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  bool _loading = true;
  String? _error;
  String? _sellerId;
  List<Map<String, dynamic>> _products = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sellerId = await currentSellerId();
      if (sellerId == null) {
        if (!mounted) return;
        setState(() {
          _sellerId = null;
          _products = const [];
          _loading = false;
          _error = 'Brak konta sprzedawcy.';
        });
        return;
      }

      final rows = await supabase
          .from('products')
          .select(
            'product_id, name, price_gross_amount, unit, is_active, deleted_at, updated_at',
          )
          .eq('seller_id', sellerId)
          .isFilter('deleted_at', null)
          .order('updated_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _sellerId = sellerId;
        _products = (rows as List<dynamic>)
            .map((dynamic r) => Map<String, dynamic>.from(r as Map))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openForm({String? productId}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SellerProductFormScreen(
          productId: productId,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (changed == true) await _load();
  }

  Future<void> _confirmDelete(Map<String, dynamic> product) async {
    final id = (product['product_id'] ?? '').toString();
    final name = (product['name'] ?? 'Produkt').toString();
    if (id.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Usunąć ogłoszenie?'),
          content: Text('„$name” zostanie usunięte z katalogu.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;

    try {
      await supabase.from('products').update(<String, dynamic>{
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
        'is_active': false,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('product_id', id);
      if (!mounted) return;
      showAppNotification(context, 'Usunięto ogłoszenie.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      showAppNotification(context, 'Nie udało się usunąć: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Moje ogłoszenia',
      onBack: widget.onBack,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentAction),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: DefaultScreen.bodyPadding(context),
                children: <Widget>[
                  PrimaryActionButton(
                    label: 'Dodaj ogłoszenie',
                    onPressed: _sellerId == null ? null : () => _openForm(),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Text(
                      _error!,
                      style: AppTypography.normal.copyWith(
                        color: AppColors.error,
                      ),
                    )
                  else if (_products.isEmpty)
                    Text(
                      'Nie masz jeszcze ogłoszeń. Dodaj pierwsze.',
                      style: AppTypography.normal.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ..._products.map(_productTile),
                ],
              ),
            ),
    );
  }

  Widget _productTile(Map<String, dynamic> product) {
    final name = (product['name'] ?? 'Produkt').toString();
    final unit = (product['unit'] ?? '').toString();
    final price = plnCommaStringFromPennies(
      parsePennies(product['price_gross_amount']),
    );
    final active = product['is_active'] != false;
    final id = (product['product_id'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.normal),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(name, style: AppTypography.normalBold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.accent.withValues(alpha: 0.35)
                          : AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      active ? 'Aktywne' : 'Ukryte',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$price zł · $unit',
                style: AppTypography.normal.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openForm(productId: id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.accent),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Edytuj'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmDelete(product),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Usuń'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
