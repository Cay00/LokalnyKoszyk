import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class OrderHistoryDetailScreen extends StatefulWidget {
  const OrderHistoryDetailScreen({
    super.key,
    required this.orderId,
    this.onBack,
  });

  final String orderId;
  final VoidCallback? onBack;

  @override
  State<OrderHistoryDetailScreen> createState() => _OrderHistoryDetailScreenState();
}

class _OrderHistoryDetailScreenState extends State<OrderHistoryDetailScreen> {
  bool _isLoading = true;
  String? _errorText;
  String _orderNumber = '';
  String _orderStatus = '';
  String _orderTotal = '';
  List<_OrderProductItem> _items = const <_OrderProductItem>[];

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      final orderRow = await supabase
          .from('orders')
          .select('id, order_number, status, total_amount, currency')
          .eq('id', widget.orderId)
          .maybeSingle();
      if (orderRow == null) {
        throw StateError('Nie znaleziono zamówienia.');
      }
      final orderMap = Map<String, dynamic>.from(orderRow as Map);

      final itemRows = await supabase
          .from('order_items')
          .select('quantity, price, products(name, unit)')
          .eq('order_id', widget.orderId);
      final items = (itemRows as List<dynamic>).map<_OrderProductItem>((row) {
        final map = Map<String, dynamic>.from(row as Map);
        final productMap = map['products'] == null
            ? const <String, dynamic>{}
            : Map<String, dynamic>.from(map['products'] as Map);
        final qty = (map['quantity'] as num?)?.toDouble() ?? 0;
        final unitPriceGrosze = parsePennies(map['price']);
        final unit = (productMap['unit'] ?? '').toString();
        return _OrderProductItem(
          name: (productMap['name'] ?? 'Produkt').toString(),
          quantityLabel: '$qty $unit',
          lineTotal: _formatMoney(
            plnFromPennies(unitPriceGrosze) * qty,
            (orderMap['currency'] ?? 'PLN').toString(),
          ),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _orderNumber = (orderMap['order_number'] ?? widget.orderId).toString();
        _orderStatus = _statusLabel((orderMap['status'] ?? '').toString());
        _orderTotal = _formatMoney(
          plnFromPennies(parsePennies(orderMap['total_amount'])),
          (orderMap['currency'] ?? 'PLN').toString(),
        );
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Nie udało się pobrać szczegółów zamówienia: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: _orderNumber.isEmpty ? 'Zamówienie' : 'Zamówienie $_orderNumber',
          onBack: widget.onBack,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorText != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.normal),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Status: $_orderStatus',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _orderTotal,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kupione produkty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_items.isEmpty)
                      const Text(
                        'Brak pozycji w tym zamówieniu.',
                        style: TextStyle(color: AppColors.textLight),
                      )
                    else
                      ..._items.map((item) => _OrderProductTile(item: item)),
                  ],
                ),
        ),
      ],
    );
  }
}

class _OrderProductTile extends StatelessWidget {
  const _OrderProductTile({required this.item});

  final _OrderProductItem item;

  @override
  Widget build(BuildContext context) {
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
          const Text('🧾', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.quantityLabel,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.lineTotal,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderProductItem {
  const _OrderProductItem({
    required this.name,
    required this.quantityLabel,
    required this.lineTotal,
  });

  final String name;
  final String quantityLabel;
  final String lineTotal;
}

String _statusLabel(String rawStatus) {
  switch (rawStatus) {
    case 'placed':
      return 'Złożone';
    case 'in_progress':
      return 'W realizacji';
    case 'rejected':
      return 'Odrzucone';
    case 'sent':
      return 'Wysłane';
    case 'delivered':
      return 'Dostarczone';
    case 'received':
      return 'Odebrane';
    default:
      return rawStatus.isEmpty ? 'Nieznany' : rawStatus;
  }
}

String _formatMoney(double value, String currency) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return '$formatted $currency';
}
