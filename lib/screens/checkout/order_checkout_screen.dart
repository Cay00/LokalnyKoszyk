import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/presentation/checkout_cubit.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class OrderCheckoutScreen extends StatelessWidget {
  const OrderCheckoutScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (BuildContext context, CheckoutState state) {
        final items = state.items;
        final total = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
        return Column(
          children: <Widget>[
            ScreenHeader(
              title: 'Moje zamówienie',
              leading: ScreenHeaderBackButton(onPressed: onBack),
            ),
            Expanded(
              child: state.isLoading
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
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () =>
                                  context.read<CheckoutCubit>().load(),
                              child: const Text('Ponów'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : items.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Koszyk jest pusty.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: <Widget>[
                        ...items.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppRadius.normal,
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Text('🧺', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity} ${item.unit}',
                                        style: const TextStyle(
                                          color: AppColors.textLight,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatMoney(item.lineTotal, item.currency),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: state.isRemovingItem
                                      ? null
                                      : () => _removeItem(context, item),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: state.isRemovingItem
                                        ? AppColors.textLight
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        const Text(
                          'Opcja dostawy',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RadioGroup<DeliveryOption>(
                          groupValue: state.deliveryOption,
                          onChanged: (DeliveryOption? value) {
                            if (value == null) return;
                            context.read<CheckoutCubit>().setDeliveryOption(
                              value,
                            );
                          },
                          child: Column(
                            children: DeliveryOption.values.map((
                              DeliveryOption option,
                            ) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.normal,
                                  ),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: RadioListTile<DeliveryOption>(
                                  value: option,
                                  title: Text(option.label),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                'Razem',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              _formatMoney(
                                total,
                                items.isEmpty ? 'PLN' : items.first.currency,
                              ),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: state.isPaying
                                ? null
                                : () => _pay(context),
                            child: state.isPaying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Zapłać'),
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

Future<void> _removeItem(BuildContext context, CartItem item) async {
  final err = await context.read<CheckoutCubit>().removeItem(item);
  if (!context.mounted) return;
  if (err == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usunięto z koszyka: ${item.name}')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  }
}

Future<void> _pay(BuildContext context) async {
  final msg = await context.read<CheckoutCubit>().pay();
  if (!context.mounted || msg == null) return;
  final isError = msg.startsWith('Nie udało się');
  if (isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

String _formatMoney(double value, String currency) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return '$formatted $currency';
}
