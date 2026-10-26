import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/payment_method.dart';
import 'package:lokalny_koszyk/presentation/checkout_bloc.dart';
import 'package:lokalny_koszyk/screens/checkout/checkout_delivery_screen.dart';
import 'package:lokalny_koszyk/widgets/common/app_toggle_row.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/default_screen.dart';

class OrderCheckoutScreen extends StatelessWidget {
  const OrderCheckoutScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (BuildContext context, CheckoutState state) {
        final items = state.items;
        return DefaultScreen(
          title: 'Moje zamówienie',
          onBack: onBack,
          showBottomNavPadding: false,
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.errorText != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          state.errorText!,
                          textAlign: TextAlign.center,
                          style: AppTypography.normal.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PrimaryActionButton(
                          label: 'Ponów',
                          onPressed: () => context.read<CheckoutBloc>().add(
                            const CheckoutLoadRequested(),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : items.isEmpty
              ? Center(
                  child: Text(
                    'Koszyk jest pusty.',
                    style: AppTypography.normal.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: <Widget>[
                          Text('Produkty', style: AppTypography.header),
                          const SizedBox(height: 12),
                          ...items.map(_CheckoutProductTile.new),
                          const SizedBox(height: 16),
                          Text('Opcja dostawy', style: AppTypography.header),
                          const SizedBox(height: 8),
                          ...DeliveryOption.values.map((DeliveryOption option) {
                            return AppSelectTile<DeliveryOption>(
                              value: option,
                              groupValue: state.deliveryOption,
                              label: option.label,
                              onChanged: (DeliveryOption value) {
                                context.read<CheckoutBloc>().add(
                                  CheckoutDeliveryOptionChanged(value),
                                );
                              },
                            );
                          }),
                          const SizedBox(height: 8),
                          Text(
                            'Metoda płatności',
                            style: AppTypography.header,
                          ),
                          const SizedBox(height: 8),
                          ...AppPaymentMethod.values.map((
                            AppPaymentMethod method,
                          ) {
                            return AppSelectTile<AppPaymentMethod>(
                              value: method,
                              groupValue: state.paymentMethod,
                              label: method.label,
                              onChanged: (AppPaymentMethod value) {
                                context.read<CheckoutBloc>().add(
                                  CheckoutPaymentMethodChanged(value),
                                );
                              },
                            );
                          }),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text('Razem', style: AppTypography.header),
                              ),
                              Text(
                                _formatMoney(
                                  state.productsTotal,
                                  items.first.currency,
                                ),
                                style: AppTypography.header,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: PrimaryActionButton(
                          label: 'Przejdź dalej',
                          onPressed: () {
                            final checkoutBloc = context.read<CheckoutBloc>();
                            Navigator.of(context).push(
                              PageRouteBuilder<void>(
                                pageBuilder: (_, _, _) => BlocProvider.value(
                                  value: checkoutBloc,
                                  child: CheckoutDeliveryScreen(
                                    onBack: () => Navigator.of(context).pop(),
                                  ),
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _CheckoutProductTile extends StatelessWidget {
  const _CheckoutProductTile(this.item);

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final qtyLabel = item.quantity == item.quantity.roundToDouble()
        ? item.quantity.toInt().toString()
        : item.quantity.toString().replaceAll('.', ',');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.normal),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 88,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 88,
              height: 88,
              child: ColoredBox(
                color: AppColors.background,
                child: Image.asset(
                  'assets/images/food_default.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.normalBold,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.sellerDisplayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '$qtyLabel × ${_formatMoney(item.price, item.currency)}',
                            style: AppTypography.caption,
                          ),
                        ),
                        Text(
                          _formatMoney(item.lineTotal, item.currency),
                          style: AppTypography.normalBold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(double value, String currency) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  final suffix = currency.trim().isEmpty || currency.toUpperCase() == 'PLN'
      ? 'zł'
      : currency;
  return '$formatted $suffix';
}
