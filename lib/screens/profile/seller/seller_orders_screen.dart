import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/current_seller.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/screens/profile/seller/seller_order_detail_screen.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  bool _loading = true;
  String? _error;
  List<_SellerOrderRow> _orders = const [];

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
          _orders = const [];
          _loading = false;
          _error = 'Brak konta sprzedawcy.';
        });
        return;
      }

      final itemRows = await supabase
          .from('order_items')
          .select(
            'order_id, quantity, price, '
            'orders(id, order_number, status, total_amount, currency, created_at)',
          )
          .eq('seller_id', sellerId);

      final byOrder = <String, _SellerOrderRow>{};
      for (final dynamic raw in itemRows as List<dynamic>) {
        final map = Map<String, dynamic>.from(raw as Map);
        final orderRaw = map['orders'];
        if (orderRaw is! Map) continue;
        final order = Map<String, dynamic>.from(orderRaw);
        final orderId = (order['id'] ?? map['order_id'] ?? '').toString();
        if (orderId.isEmpty) continue;

        final qty = (map['quantity'] as num?)?.toDouble() ?? 0;
        final unitPrice = plnFromPennies(parsePennies(map['price']));
        final line = unitPrice * qty;

        final existing = byOrder[orderId];
        if (existing == null) {
          byOrder[orderId] = _SellerOrderRow(
            id: orderId,
            orderNumber: (order['order_number'] ?? orderId).toString(),
            rawStatus: (order['status'] ?? '').toString(),
            sellerSubtotal: line,
            currency: (order['currency'] ?? 'PLN').toString(),
            createdAt: DateTime.tryParse((order['created_at'] ?? '').toString()),
          );
        } else {
          byOrder[orderId] = existing.copyWith(
            sellerSubtotal: existing.sellerSubtotal + line,
          );
        }
      }

      final list = byOrder.values.toList()
        ..sort((a, b) {
          final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        });

      if (!mounted) return;
      setState(() {
        _orders = list;
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

  Future<void> _openDetail(_SellerOrderRow order) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SellerOrderDetailScreen(
          orderId: order.id,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (changed == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Zamówienia',
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
                  Text(
                    'Przeglądaj i obsługuj zamówienia z Twoimi produktami.',
                    style: AppTypography.normal.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Text(
                      _error!,
                      style: AppTypography.normal.copyWith(
                        color: AppColors.error,
                      ),
                    )
                  else if (_orders.isEmpty)
                    Text(
                      'Brak zamówień dla Twoich produktów.',
                      style: AppTypography.normal.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ..._orders.map((order) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.normal),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppRadius.normal),
                            onTap: () => _openDetail(order),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          order.orderNumber,
                                          style: AppTypography.normalBold,
                                        ),
                                      ),
                                      Text(
                                        orderStatusLabel(order.rawStatus),
                                        style: AppTypography.caption.copyWith(
                                          color: orderStatusColor(
                                            order.rawStatus,
                                          ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatOrderDate(order.createdAt),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMoney(
                                      order.sellerSubtotal,
                                      order.currency,
                                    ),
                                    style: AppTypography.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

class _SellerOrderRow {
  const _SellerOrderRow({
    required this.id,
    required this.orderNumber,
    required this.rawStatus,
    required this.sellerSubtotal,
    required this.currency,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String rawStatus;
  final double sellerSubtotal;
  final String currency;
  final DateTime? createdAt;

  _SellerOrderRow copyWith({double? sellerSubtotal}) {
    return _SellerOrderRow(
      id: id,
      orderNumber: orderNumber,
      rawStatus: rawStatus,
      sellerSubtotal: sellerSubtotal ?? this.sellerSubtotal,
      currency: currency,
      createdAt: createdAt,
    );
  }
}
