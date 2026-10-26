import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/current_seller.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/app_toggle_row.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  const SellerOrderDetailScreen({
    super.key,
    required this.orderId,
    this.onBack,
  });

  final String orderId;
  final VoidCallback? onBack;

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _orderNumber = '';
  String _status = '';
  String _currency = 'PLN';
  List<_Line> _lines = const [];

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
      if (sellerId == null) throw StateError('Brak konta sprzedawcy.');

      final order = await supabase
          .from('orders')
          .select('id, order_number, status, currency')
          .eq('id', widget.orderId)
          .maybeSingle();
      if (order == null) throw StateError('Nie znaleziono zamówienia.');

      final items = await supabase
          .from('order_items')
          .select('quantity, price, products(name, unit)')
          .eq('order_id', widget.orderId)
          .eq('seller_id', sellerId);

      final lines = <_Line>[];
      for (final dynamic raw in items as List<dynamic>) {
        final map = Map<String, dynamic>.from(raw as Map);
        final product = map['products'] is Map
            ? Map<String, dynamic>.from(map['products'] as Map)
            : const <String, dynamic>{};
        final qty = (map['quantity'] as num?)?.toDouble() ?? 0;
        final unitPrice = plnFromPennies(parsePennies(map['price']));
        lines.add(
          _Line(
            name: (product['name'] ?? 'Produkt').toString(),
            quantity: qty,
            unit: (product['unit'] ?? '').toString(),
            lineTotal: unitPrice * qty,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _orderNumber = (order['order_number'] ?? widget.orderId).toString();
        _status = (order['status'] ?? '').toString();
        _currency = (order['currency'] ?? 'PLN').toString();
        _lines = lines;
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

  Future<void> _saveStatus() async {
    setState(() => _saving = true);
    try {
      await supabase
          .from('orders')
          .update(<String, dynamic>{
            'status': _status,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', widget.orderId);
      if (!mounted) return;
      showAppNotification(context, 'Zaktualizowano status zamówienia.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showAppNotification(
        context,
        'Nie udało się zmienić statusu: $e\n'
        'Jeśli brakuje wartości enum, uruchom sql/seller_order_status.sql',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Zamówienie',
      onBack: widget.onBack,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentAction),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: DefaultScreen.bodyPadding(context),
              children: <Widget>[
                Text(_orderNumber, style: AppTypography.header),
                const SizedBox(height: 16),
                Text('Pozycje', style: AppTypography.normalBold),
                const SizedBox(height: 8),
                ..._lines.map((line) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.normal),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(line.name, style: AppTypography.normal),
                                  Text(
                                    '${line.quantity} ${line.unit}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatMoney(line.lineTotal, _currency),
                              style: AppTypography.normalBold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Text('Status zamówienia', style: AppTypography.normalBold),
                const SizedBox(height: 8),
                ...sellerManageableOrderStatuses.map((String status) {
                  return AppSelectTile<String>(
                    value: status,
                    groupValue: _status,
                    label: orderStatusLabel(status),
                    onChanged: _saving
                        ? (_) {}
                        : (String v) => setState(() => _status = v),
                  );
                }),
                const SizedBox(height: 8),
                PrimaryActionButton(
                  label: _saving ? 'Zapisywanie…' : 'Zapisz status',
                  onPressed: _saving ? null : _saveStatus,
                ),
              ],
            ),
    );
  }
}

class _Line {
  const _Line({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.lineTotal,
  });

  final String name;
  final double quantity;
  final String unit;
  final double lineTotal;
}
