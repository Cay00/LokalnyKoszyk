import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/supabase/cart_repository.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class OrderCheckoutScreen extends StatefulWidget {
  const OrderCheckoutScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> {
  bool _isLoading = true;
  bool _isRemovingItem = false;
  bool _isPaying = false;
  String? _errorText;
  List<CartItemData> _items = const <CartItemData>[];
  DeliveryOption _deliveryOption = DeliveryOption.courier;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      final items = await CartRepository.getCartItemsForCurrentUser();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Nie udało się pobrać koszyka: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(CartItemData item) async {
    if (_isRemovingItem) return;
    setState(() => _isRemovingItem = true);
    try {
      await CartRepository.removeCartItem(cartItemId: item.id);
      if (!mounted) return;
      setState(() {
        _items = _items.where((x) => x.id != item.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usunięto z koszyka: ${item.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się usunąć produktu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isRemovingItem = false);
    }
  }

  Future<void> _pay() async {
    if (_isPaying || _items.isEmpty) return;
    setState(() => _isPaying = true);
    try {
      final result = await CartRepository.placeOrderFromCurrentCart(
        status: 'placed',
      );
      if (!mounted) return;
      setState(() {
        _items = const <CartItemData>[];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Płatność zakończona. Utworzono zamówienie ${result.orderNumber}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się opłacić zamówienia: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: 'Moje zamówienie',
          onBack: widget.onBack,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorText != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Ponów'),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Koszyk jest pusty.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: <Widget>[
                    ..._items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.normal),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Text('🧺', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity} ${item.unit}',
                                    style: const TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatMoney(item.lineTotal, item.currency),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: _isRemovingItem ? null : () => _removeItem(item),
                              child: Icon(
                                Icons.delete_outline,
                                color: _isRemovingItem
                                    ? AppColors.textLight
                                    : AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    const Text(
                      'Opcja dostawy',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...DeliveryOption.values.map((option) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.normal),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: RadioListTile<DeliveryOption>(
                          value: option,
                          groupValue: _deliveryOption,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _deliveryOption = value);
                          },
                          title: Text(option.label),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Razem',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _formatMoney(
                            total,
                            _items.isEmpty ? 'PLN' : _items.first.currency,
                          ),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isPaying ? null : _pay,
                        child: _isPaying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Zapłać'),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

enum DeliveryOption {
  courier('Kurier'),
  pickupPoint('Paczkomat / punkt odbioru'),
  personalPickup('Odbiór osobisty');

  const DeliveryOption(this.label);
  final String label;
}

String _formatMoney(double value, String currency) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return '$formatted $currency';
}
