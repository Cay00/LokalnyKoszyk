import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/order_summary.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/section_header.dart';

import '../../core/themes/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, this.onOpenCheckout, this.onOpenOrderDetails});

  final VoidCallback? onOpenCheckout;
  final ValueChanged<String>? onOpenOrderDetails;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      listenWhen: (OrdersState previous, OrdersState current) =>
          current.feedbackMessage != null &&
          current.feedbackMessage != previous.feedbackMessage,
      listener: (BuildContext context, OrdersState state) {
        final message = state.feedbackMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      child: BlocBuilder<OrdersBloc, OrdersState>(
      builder: (BuildContext context, OrdersState state) {
        final orders = state.orders
            .map(
              (OrderSummary order) => _OrderItem(
                id: order.id,
                orderNumber: order.orderNumber,
                status: orderStatusLabel(order.rawStatus),
                date: formatOrderDate(order.createdAt),
                total: formatMoney(order.totalAmount, order.currency),
                color: orderStatusColor(order.rawStatus),
                iconAsset: orderStatusIcon(order.rawStatus),
              ),
            )
            .toList();
        return DefaultScreen(
          title: 'Koszyk',
          body: RefreshIndicator(
            onRefresh: () {
              final bloc = context.read<OrdersBloc>();
              bloc.add(const OrdersRefreshAllRequested());
              return bloc.stream.firstWhere(
                (OrdersState s) => !s.isLoadingCart && !s.isLoadingOrders,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: DefaultScreen.bodyPadding(context),
              children: <Widget>[
                _CartSummaryCard(
                  isLoading: state.isLoadingCart,
                  cartItems: state.cartItems,
                  isRemovingItem: state.isRemovingItem,
                  onRemoveItem: (CartItem item) {
                    context.read<OrdersBloc>().add(
                      OrdersRemoveItemRequested(item),
                    );
                  },
                  onOpenCheckout: onOpenCheckout,
                ),
                const SizedBox(height: 32),
                const SectionHeader(
                  title: 'Historia zamówień',
                  actionLabel: 'Wszystkie',
                ),
                const SizedBox(height: 16),
                if (state.isLoadingOrders)
                  const Center(child: CircularProgressIndicator())
                else if (state.ordersError != null)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          state.ordersError!,
                          style: AppTypography.normal,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.read<OrdersBloc>().add(
                          const OrdersLoadOrdersRequested(),
                        ),
                        child: const Text('Ponów'),
                      ),
                    ],
                  )
                else if (orders.isEmpty)
                  const Text(
                    'Brak złożonych zamówień dla tego konta.',
                    style: AppTypography.normal,
                  )
                else
                  ...orders.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final _OrderItem order = entry.value;
                    return _OrderHistoryTile(
                      order: order,
                      withBottomSpacing: index < orders.length - 1,
                      onTap: onOpenOrderDetails != null
                          ? () => onOpenOrderDetails!(order.id)
                          : null,
                    );
                  }),
              ],
            ),
          ),
        );
      },
    ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({
    required this.isLoading,
    required this.cartItems,
    required this.isRemovingItem,
    required this.onRemoveItem,
    this.onOpenCheckout,
  });

  final bool isLoading;
  final List<CartItem> cartItems;
  final bool isRemovingItem;
  final ValueChanged<CartItem> onRemoveItem;
  final VoidCallback? onOpenCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppColors.accent, AppColors.accent],
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
                  color: AppColors.textPrimary,
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
          else if (cartItems.isEmpty)
            const Text(
              'Brak produktów w koszyku.',
              style: TextStyle(color: AppColors.white, fontSize: 13),
            )
          else ...<Widget>[
            ...cartItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CartLineItem(
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
                border: Border(top: BorderSide(color: Color(0x40FFFFFF))),
              ),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Razem',
                      style: TextStyle(
                        color: AppColors.textPrimary,
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
    required this.name,
    required this.qty,
    required this.price,
    this.onRemove,
  });

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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                'assets/images/food_default.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) => const ColoredBox(color: Color(0x33FFFFFF)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                ),
                Text(
                  qty,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
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
          border: Border.all(color: AppColors.background),
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
                    AppColors.accent,
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
                        style: AppTypography.header,
                      ),
                      Text(
                        order.date,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: order.color.withValues(alpha: 0.13),
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
                Expanded(
                  child: Text(
                    'Łącznie',
                    style: AppTypography.caption,
                  ),
                ),
                Text(
                  order.total,
                  style: AppTypography.header,
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
