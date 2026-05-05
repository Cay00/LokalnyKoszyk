import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/supabase/cart_repository.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/widgets/home/section_header.dart';

import '../../core/themes/app_theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
    this.onOpenCheckout,
    this.onOpenOrderDetails,
  });

  final VoidCallback? onOpenCheckout;
  final ValueChanged<String>? onOpenOrderDetails;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoadingCart = true;
  bool _isRemovingItem = false;
  bool _isLoadingOrders = true;
  String? _cartError;
  String? _ordersError;
  List<CartItemData> _cartItems = const <CartItemData>[];
  List<_OrderItem> _orders = const <_OrderItem>[];

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadOrders();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoadingCart = true;
      _cartError = null;
    });
    try {
      final items = await CartRepository.getCartItemsForCurrentUser();
      if (!mounted) return;
      setState(() {
        _cartItems = items;
        _isLoadingCart = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cartError = 'Nie udało się pobrać koszyka: $e';
        _isLoadingCart = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoadingOrders = true;
      _ordersError = null;
    });
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null || userId.isEmpty) {
        throw StateError('Brak zalogowanego użytkownika.');
      }
      final rows = await supabase
          .from('orders')
          .select('id, order_number, status, total_amount, currency, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final mapped = (rows as List<dynamic>).map<_OrderItem>((dynamic row) {
        final map = Map<String, dynamic>.from(row as Map);
        final id = (map['id'] ?? '').toString();
        final orderNumber = (map['order_number'] ?? '').toString();
        final rawStatus = (map['status'] ?? '').toString();
        final statusLabel = _statusLabel(rawStatus);
        final statusColor = _statusColor(rawStatus);
        final amount = (map['total_amount'] as num?)?.toDouble() ?? 0;
        final currency = (map['currency'] ?? 'PLN').toString();
        final createdAt = DateTime.tryParse((map['created_at'] ?? '').toString());
        return _OrderItem(
          id: id,
          orderNumber: orderNumber,
          status: statusLabel,
          date: _formatDate(createdAt),
          total: _formatMoney(amount, currency),
          color: statusColor,
          iconAsset: _statusIcon(rawStatus),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _orders = mapped;
        _isLoadingOrders = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ordersError = 'Nie udało się pobrać historii zamówień: $e';
        _isLoadingOrders = false;
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
        _cartItems = _cartItems.where((x) => x.id != item.id).toList();
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'Zamówienia',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _CartSummaryCard(
          isLoading: _isLoadingCart,
          errorText: _cartError,
          cartItems: _cartItems,
          isRemovingItem: _isRemovingItem,
          onRemoveItem: _removeItem,
          onRetry: _loadCart,
          onOpenCheckout: widget.onOpenCheckout,
        ),
        const SizedBox(height: 32),
        const SectionHeader(
          title: 'Historia zamówień',
          actionLabel: 'Wszystkie',
        ),
        const SizedBox(height: 16),
        if (_isLoadingOrders)
          const Center(child: CircularProgressIndicator())
        else if (_ordersError != null)
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _ordersError!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loadOrders,
                child: const Text('Ponów'),
              ),
            ],
          )
        else if (_orders.isEmpty)
          const Text(
            'Brak złożonych zamówień dla tego konta.',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
            ),
          )
        else
          ..._orders.asMap().entries.map((entry) {
            final int index = entry.key;
            final _OrderItem order = entry.value;
            return _OrderHistoryTile(
              order: order,
              withBottomSpacing: index < _orders.length - 1,
              onTap: widget.onOpenOrderDetails != null
                  ? () => widget.onOpenOrderDetails!(order.id)
                  : null,
            );
          }),
      ],
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({
    required this.isLoading,
    required this.errorText,
    required this.cartItems,
    required this.isRemovingItem,
    required this.onRemoveItem,
    required this.onRetry,
    this.onOpenCheckout,
  });

  final bool isLoading;
  final String? errorText;
  final List<CartItemData> cartItems;
  final bool isRemovingItem;
  final ValueChanged<CartItemData> onRemoveItem;
  final VoidCallback onRetry;
  final VoidCallback? onOpenCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.normal),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Koszyk',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${cartItems.length} produkty',
                style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: AppColors.white),
            )
          else if (errorText != null)
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Ponów'),
                ),
              ],
            )
          else if (cartItems.isEmpty)
            const Text(
              'Koszyk jest pusty.',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 13,
              ),
            )
          else ...<Widget>[
            ...cartItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CartLineItem(
                  emoji: '🧺',
                  name: item.name,
                  qty: '${item.quantity} ${item.unit}',
                  price: _formatMoney(item.lineTotal, item.currency),
                  onRemove: isRemovingItem ? null : () => onRemoveItem(item),
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0x40FFFFFF)),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Razem',
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    _formatMoney(
                      cartItems.fold<double>(
                        0,
                        (sum, item) => sum + item.lineTotal,
                      ),
                      cartItems.first.currency,
                    ),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cartItems.isEmpty ? null : onOpenCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.normal),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Przejdź do zamówienia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineItem extends StatelessWidget {
  const _CartLineItem({
    required this.emoji,
    required this.name,
    required this.qty,
    required this.price,
    this.onRemove,
  });

  final String emoji;
  final String name;
  final String qty;
  final String price;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  qty,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatMoney(double value, String currency) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return '$formatted $currency';
}

class _OrderHistoryTile extends StatelessWidget {
  const _OrderHistoryTile({
    required this.order,
    required this.withBottomSpacing,
    this.onTap,
  });

  final _OrderItem order;
  final bool withBottomSpacing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.normal),
      child: Container(
        margin: EdgeInsets.only(bottom: withBottomSpacing ? 8 : 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.normal),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: <Widget>[
            Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                order.iconAsset,
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Zamówienie ${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      order.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: order.color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: order.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            ),
            const SizedBox(height: 8),
            Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Łącznie',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                order.total,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItem {
  const _OrderItem({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.date,
    required this.total,
    required this.color,
    required this.iconAsset,
  });

  final String id;
  final String orderNumber;
  final String status;
  final String date;
  final String total;
  final Color color;
  final String iconAsset;
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

Color _statusColor(String rawStatus) {
  switch (rawStatus) {
    case 'placed':
      return AppColors.primary;
    case 'in_progress':
      return AppColors.accent;
    case 'rejected':
      return Colors.redAccent;
    case 'sent':
      return AppColors.primaryLight;
    case 'delivered':
      return AppColors.primary;
    case 'received':
      return AppColors.textLight;
    default:
      return AppColors.textLight;
  }
}

String _statusIcon(String rawStatus) {
  switch (rawStatus) {
    case 'placed':
      return 'assets/icons/receipt.svg';
    case 'in_progress':
      return 'assets/icons/clock-countdown.svg';
    case 'rejected':
      return 'assets/icons/question.svg';
    case 'sent':
      return 'assets/icons/package.svg';
    case 'delivered':
      return 'assets/icons/check-circle.svg';
    case 'received':
      return 'assets/icons/check-circle.svg';
    default:
      return 'assets/icons/receipt.svg';
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '—';
  final d = date.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd.$mm';
}
