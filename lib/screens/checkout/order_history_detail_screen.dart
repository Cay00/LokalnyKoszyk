import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/order_details.dart';
import 'package:lokalny_koszyk/presentation/order_history_detail_bloc.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class OrderHistoryDetailScreen extends StatelessWidget {
  const OrderHistoryDetailScreen({
    super.key,
    required this.orderId,
    this.onBack,
  });

  final String orderId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderHistoryDetailBloc, OrderHistoryDetailState>(
      builder: (BuildContext context, OrderHistoryDetailState state) {
        final order = state.order;
        final orderNumber = order?.orderNumber ?? '';
        final orderStatus = order == null
            ? ''
            : orderStatusLabel(order.rawStatus);
        final orderTotal = order == null
            ? ''
            : formatMoney(order.totalAmount, order.currency);
        final items = order?.items ?? const <OrderDetailsItem>[];
        return Column(
          children: <Widget>[
            ScreenHeader(
              title: orderNumber.isEmpty
                  ? 'Zamówienie'
                  : 'Zamówienie $orderNumber',
              leading: ScreenHeaderBackButton(onPressed: onBack),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.errorText != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          state.errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
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
                            borderRadius: BorderRadius.circular(
                              AppRadius.normal,
                            ),
                            border: Border.all(color: AppColors.background),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'Status: $orderStatus',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                orderTotal,
                                style: const TextStyle(
                                  color: AppColors.accent,
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
                        if (items.isEmpty)
                          const Text(
                            'Brak pozycji w tym zamówieniu.',
                            style: TextStyle(color: AppColors.textSecondary),
                          )
                        else
                          ...items.map(
                            (item) => _OrderProductTile(
                              item: item,
                              currency: order?.currency ?? 'PLN',
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _OrderProductTile extends StatelessWidget {
  const _OrderProductTile({required this.item, required this.currency});

  final OrderDetailsItem item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.normal),
        border: Border.all(color: AppColors.background),
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
                  '${item.quantity} ${item.unit}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatMoney(item.lineTotal, currency),
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
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
