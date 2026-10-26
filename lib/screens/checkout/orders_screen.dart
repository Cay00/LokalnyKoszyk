import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';
import 'package:lokalny_koszyk/widgets/app_bottom_navigation_bar.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    super.key,
    this.onOpenCheckout,
    this.onOpenOrderDetails,
  });

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
                      final done = bloc.stream.firstWhere(
                        (OrdersState s) => !s.isLoadingCart,
                      );
                      bloc.add(const OrdersLoadCartRequested());
                      return done;
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
          Dismissible(
            key: ValueKey<String>('cart-item-${item.id}'),
            direction: DismissDirection.startToEnd,
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.normal),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.delete_outline, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Usuń',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (_) async {
              if (state.isRemovingItem) return false;
              final bloc = context.read<OrdersBloc>();
              bloc.add(OrdersRemoveItemRequested(item));
              final OrdersState next = await bloc.stream.firstWhere(
                (OrdersState s) => !s.isRemovingItem,
              );
              return !next.cartItems.any((CartItem x) => x.id == item.id);
            },
            child: ProductTile(
              product: product,
              onOpenDetails: () => _openProductDetails(context, product),
              onAddToCart: () {
                context.read<OrdersBloc>().add(
                  OrdersAddToCartRequested(item.productId),
                );
              },
            ),
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
