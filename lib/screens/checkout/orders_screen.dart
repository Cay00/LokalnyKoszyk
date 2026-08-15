import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/order_summary.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';
import 'package:lokalny_koszyk/widgets/app_bottom_navigation_bar.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';
import 'package:lokalny_koszyk/widgets/common/section_header.dart';

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
        showAppNotification(context, message);
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
          final cartItems = state.cartItems;
          final hasCartItems = cartItems.isNotEmpty;
          final productsTotal = state.selectedProductsTotal;
          const deliveryFrom = 0.0;
          final totalWithDelivery = productsTotal + deliveryFrom;

          return DefaultScreen(
            title: 'Koszyk',
            showBottomNavPadding: !hasCartItems,
            body: Column(
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () {
                      final bloc = context.read<OrdersBloc>();
                      bloc.add(const OrdersRefreshAllRequested());
                      return bloc.stream.firstWhere(
                        (OrdersState s) =>
                            !s.isLoadingCart && !s.isLoadingOrders,
                      );
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: DefaultScreen.bodyPadding(
                        context,
                      ).copyWith(bottom: hasCartItems ? 16 : null),
                      children: <Widget>[
                        if (state.isLoadingCart)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (!hasCartItems)
                          Text(
                            'Brak produktów w koszyku.',
                            style: AppTypography.normal,
                          )
                        else
                          ..._sellerSections(context, state, cartItems),
                        const SizedBox(height: 16),
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
                          Text(
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
                ),
                if (hasCartItems)
                  _CartTotalsBar(
                    productsTotal: productsTotal,
                    deliveryFrom: deliveryFrom,
                    totalWithDelivery: totalWithDelivery,
                    onBuyNow: state.selectedCartItems.isEmpty
                        ? null
                        : onOpenCheckout,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _sellerSections(
    BuildContext context,
    OrdersState state,
    List<CartItem> items,
  ) {
    final groups = <String, List<CartItem>>{};
    final names = <String, String>{};
    final order = <String>[];
    for (final item in items) {
      final key = item.sellerKey;
      if (!groups.containsKey(key)) {
        order.add(key);
        groups[key] = <CartItem>[];
        names[key] = item.sellerDisplayName;
      }
      groups[key]!.add(item);
    }

    final widgets = <Widget>[];
    for (int i = 0; i < order.length; i++) {
      final key = order[i];
      final sellerItems = groups[key]!;
      final selected = state.isSellerSelected(key);
      if (i > 0) widgets.add(const SizedBox(height: 32));
      widgets.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _SellerIncludeButton(
              selected: selected,
              onTap: () => context.read<OrdersBloc>().add(
                OrdersSellerSelectionToggled(key),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(names[key]!, style: AppTypography.header),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 16));
      for (int j = 0; j < sellerItems.length; j++) {
        if (j > 0) widgets.add(const SizedBox(height: 8));
        final item = sellerItems[j];
        final product = _productFromCartItem(item);
        widgets.add(
          ProductTile(
            product: product,
            onOpenDetails: () => _openProductDetails(context, product),
            onAddToCart: () {
              context.read<OrdersBloc>().add(
                OrdersAddToCartRequested(item.productId),
              );
            },
          ),
        );
      }
    }
    return widgets;
  }

  void _openProductDetails(BuildContext context, ProductUiModel product) {
    final String? sid = product.sellerId?.trim();
    final bool hasSeller = sid != null && sid.isNotEmpty;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => ProductDetailsScreen(
          product: product,
          onBack: () => Navigator.of(context).pop(),
          onOpenProducerDetails: hasSeller
              ? () {
                  Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      pageBuilder: (_, _, _) => ProducerDetailsScreen(
                        sellerId: sid,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              : null,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

class _SellerIncludeButton extends StatelessWidget {
  const _SellerIncludeButton({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 24,
        height: 24,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            border: selected
                ? null
                : Border.all(color: AppColors.textSecondary, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: selected
              ? Center(
                  child: SvgPicture.asset(
                    'assets/icons/check.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

ProductUiModel _productFromCartItem(CartItem item) {
  return ProductUiModel(
    id: item.productId,
    name: item.name,
    producer: item.sellerDisplayName,
    price: item.price.toStringAsFixed(2).replaceAll('.', ','),
    unit: '/ ${item.unit.replaceAll('_', ' ')}',
    distance: '',
    rating: '',
    reviews: '',
    bgColor: AppColors.background,
    sellerId: item.sellerId,
    unitKey: item.unitKey,
    packageQuantity: item.packageQuantity,
  );
}

class _CartTotalsBar extends StatelessWidget {
  const _CartTotalsBar({
    required this.productsTotal,
    required this.deliveryFrom,
    required this.totalWithDelivery,
    this.onBuyNow,
  });

  final double productsTotal;
  final double deliveryFrom;
  final double totalWithDelivery;
  final VoidCallback? onBuyNow;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.accent.withValues(alpha: 0.25),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          AppBottomNavigationBar.contentBottomPadding(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _CartTotalsLine(
              label: 'Wartość produktów',
              value: _formatZl(productsTotal),
            ),
            const SizedBox(height: 16),
            _CartTotalsLine(
              label: 'Dostawa od',
              value: _formatZl(deliveryFrom),
            ),
            const SizedBox(height: 16),
            _CartTotalsLine(
              label: 'Razem',
              value: _formatZl(totalWithDelivery),
            ),
            const SizedBox(height: 16),
            PrimaryActionButton(label: 'Kup teraz', onPressed: onBuyNow),
          ],
        ),
      ),
    );
  }
}

class _CartTotalsLine extends StatelessWidget {
  const _CartTotalsLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: AppTypography.normal)),
        Text(value, style: AppTypography.header),
      ],
    );
  }
}

String _formatZl(double value) {
  return '${value.toStringAsFixed(2).replaceAll('.', ',')} zł';
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
                      Text(order.date, style: AppTypography.caption),
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
                Expanded(child: Text('Łącznie', style: AppTypography.caption)),
                Text(order.total, style: AppTypography.header),
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
