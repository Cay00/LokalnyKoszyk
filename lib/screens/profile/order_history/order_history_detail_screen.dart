import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/order_details.dart';
import 'package:lokalny_koszyk/domain/repositories/reviews_repository.dart';
import 'package:lokalny_koszyk/presentation/order_history_detail_bloc.dart';
import 'package:lokalny_koszyk/presentation/orders_bloc.dart';
import 'package:lokalny_koszyk/widgets/common/app_notification.dart';
import 'package:lokalny_koszyk/widgets/common/app_text_field.dart';
import 'package:lokalny_koszyk/widgets/common/default_screen.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

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
        return DefaultScreen(
          title: orderNumber.isEmpty
              ? 'Zamówienie'
              : 'Zamówienie $orderNumber',
          onBack: onBack,
          body: state.isLoading
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
                  padding: DefaultScreen.bodyPadding(context),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.normal),
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
                          canReview: order?.canLeaveReviews ?? false,
                          onReview: () => _openReviewSheet(
                            context,
                            order: order!,
                            item: item,
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _openReviewSheet(
    BuildContext context, {
    required OrderDetails order,
    required OrderDetailsItem item,
  }) async {
    final reviewsRepository = context.read<ReviewsRepository>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return _ReviewSheet(
          productName: item.name,
          initialRating: item.myRating ?? 5,
          initialComment: item.myComment ?? '',
          onSubmit: (int rating, String comment) async {
            await reviewsRepository.submitReview(
              productId: item.productId,
              orderId: order.id,
              rating: rating,
              comment: comment,
            );
          },
        );
      },
    );
    if (saved == true && context.mounted) {
      context.read<OrderHistoryDetailBloc>().add(
        const OrderHistoryDetailLoadRequested(),
      );
      showAppNotification(context, 'Dziękujemy za opinię.');
    }
  }
}

class _OrderProductTile extends StatelessWidget {
  const _OrderProductTile({
    required this.item,
    required this.currency,
    required this.canReview,
    required this.onReview,
  });

  final OrderDetailsItem item;
  final String currency;
  final bool canReview;
  final VoidCallback onReview;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
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
                      ),
                    ),
                    if (item.hasReview) ...<Widget>[
                      const SizedBox(height: 6),
                      _StarsRow(rating: item.myRating!, size: 16),
                    ],
                  ],
                ),
              ),
              Text(
                formatMoney(item.lineTotal, currency),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (canReview) ...<Widget>[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onReview,
                child: Text(
                  item.hasReview ? 'Edytuj opinię' : 'Oceń produkt',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({
    required this.productName,
    required this.initialRating,
    required this.initialComment,
    required this.onSubmit,
  });

  final String productName;
  final int initialRating;
  final String initialComment;
  final Future<void> Function(int rating, String comment) onSubmit;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late int _rating = widget.initialRating.clamp(1, 5);
  late final TextEditingController _comment = TextEditingController(
    text: widget.initialComment,
  );
  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await widget.onSubmit(_rating, _comment.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      showAppNotification(context, 'Nie udało się zapisać opinii: $e');
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Opinia: ${widget.productName}', style: AppTypography.header),
          const SizedBox(height: 12),
          Center(
            child: _StarsRow(
              rating: _rating,
              size: 32,
              onChanged: _saving
                  ? null
                  : (int value) => setState(() => _rating = value),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _comment,
            label: 'Komentarz (opcjonalnie)',
            hint: 'Co warto wiedzieć o produkcie?',
            maxLines: 4,
            enabled: !_saving,
          ),
          const SizedBox(height: 16),
          PrimaryActionButton(
            label: _saving ? 'Zapisywanie…' : 'Zapisz opinię',
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({
    required this.rating,
    required this.size,
    this.onChanged,
  });

  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int i) {
        final star = i + 1;
        final filled = star <= rating;
        return InkWell(
          onTap: onChanged == null ? null : () => onChanged!(star),
          borderRadius: BorderRadius.circular(size),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SvgPicture.asset(
              filled ? 'assets/icons/star-fill.svg' : 'assets/icons/star.svg',
              width: size,
              height: size,
              colorFilter: ColorFilter.mode(
                filled ? AppColors.accent_2 : AppColors.textTertiary,
                BlendMode.srcIn,
              ),
            ),
          ),
        );
      }),
    );
  }
}
