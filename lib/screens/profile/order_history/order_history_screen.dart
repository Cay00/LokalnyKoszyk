import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/order_summary.dart';
import 'package:lokalny_koszyk/presentation/my_orders_bloc.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/screens/profile/order_history/order_history_tile.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({
    super.key,
    this.onBack,
    this.onOpenOrderDetails,
  });

  final VoidCallback? onBack;
  final ValueChanged<String>? onOpenOrderDetails;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyOrdersBloc, MyOrdersState>(
      builder: (BuildContext context, MyOrdersState state) {
        return DefaultScreen(
          title: 'Moje zamówienia',
          onBack: onBack,
          body: RefreshIndicator(
            onRefresh: () {
              final bloc = context.read<MyOrdersBloc>();
              final done = bloc.stream.firstWhere(
                (MyOrdersState s) => !s.isLoading,
              );
              bloc.add(const MyOrdersLoadRequested());
              return done;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: DefaultScreen.bodyPadding(context),
              children: <Widget>[
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.errorText != null)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          state.errorText!,
                          style: AppTypography.normal,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.read<MyOrdersBloc>().add(
                          const MyOrdersLoadRequested(),
                        ),
                        child: const Text('Ponów'),
                      ),
                    ],
                  )
                else if (state.orders.isEmpty)
                  Text(
                    'Nie masz jeszcze żadnych zamówień.',
                    style: AppTypography.normal,
                  )
                else
                  for (final OrderSummary order in state.orders)
                    OrderHistoryTile(
                      orderNumber: order.orderNumber,
                      status: orderStatusLabel(order.rawStatus),
                      date: formatOrderDate(order.createdAt),
                      total: formatMoney(order.totalAmount, order.currency),
                      onTap: onOpenOrderDetails != null
                          ? () => onOpenOrderDetails!(order.id)
                          : null,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
