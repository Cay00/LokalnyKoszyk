import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/widgets/home/section_header.dart';

import '../../core/themes/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    super.key,
    this.onOpenCheckout,
    this.onOpenOrderDetails,
  });

  final VoidCallback? onOpenCheckout;
  final ValueChanged<String>? onOpenOrderDetails;

  static const List<_OrderItem> _orders = <_OrderItem>[
    _OrderItem(
      id: '#8821',
      status: 'W realizacji',
      date: '18 kwi',
      items: <String>['Pomidory 2kg', 'miód lipowy'],
      total: '62,00 zł',
      color: AppColors.accent,
      iconAsset: 'assets/icons/clock-countdown.svg',
    ),
    _OrderItem(
      id: '#8817',
      status: 'Złożone',
      date: '16 kwi',
      items: <String>['Marchew 1kg', 'Mleko 2l'],
      total: '28,00 zł',
      color: AppColors.primary,
      iconAsset: 'assets/icons/receipt.svg',
    ),
    _OrderItem(
      id: '#8810',
      status: 'Zrealizowane',
      date: '12 kwi',
      items: <String>['Ser owczy', 'Jaja wiejskie'],
      total: '38,00 zł',
      color: AppColors.primaryLight,
      iconAsset: 'assets/icons/package.svg',
    ),
    _OrderItem(
      id: '#8795',
      status: 'Odebrane',
      date: '5 kwi',
      items: <String>['Chleb razowy', 'Masło'],
      total: '24,00 zł',
      color: AppColors.textLight,
      iconAsset: 'assets/icons/check-circle.svg',
    ),
  ];

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
          onOpenCheckout: onOpenCheckout,
        ),
        const SizedBox(height: 32),
        const SectionHeader(
          title: 'Historia zamówień',
          actionLabel: 'Wszystkie',
        ),
        const SizedBox(height: 16),
        ..._orders.asMap().entries.map((entry) {
          final int index = entry.key;
          final _OrderItem order = entry.value;
          return _OrderHistoryTile(
            order: order,
            withBottomSpacing: index < _orders.length - 1,
            onTap: onOpenOrderDetails != null
                ? () => onOpenOrderDetails!(order.id)
                : null,
          );
        }),
      ],
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({
    this.onOpenCheckout,
  });

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
          const Row(
            children: <Widget>[
              Expanded(
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
                '2 produkty',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _CartLineItem(
            emoji: '🍅',
            name: 'Pomidory Malinowe',
            qty: '1 kg',
            price: '12,00 zł',
          ),
          const SizedBox(height: 8),
          const _CartLineItem(
            emoji: '🍯',
            name: 'Miód Lipowy',
            qty: '1 szt',
            price: '38,00 zł',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 8),
            margin: const EdgeInsets.only(top: 0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x40FFFFFF)),
              ),
            ),
            child: const Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Razem',
                    style: TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '50,00 zł',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOpenCheckout,
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
  });

  final String emoji;
  final String name;
  final String qty;
  final String price;

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
        ],
      ),
    );
  }
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
                      'Zamówienie ${order.id}',
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
            Align(
            alignment: Alignment.centerLeft,
            child: Text(
              order.items.join(', '),
              style: const TextStyle(
                fontSize: 12,
                  color: AppColors.textSecondary,
              ),
            ),
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
    required this.status,
    required this.date,
    required this.items,
    required this.total,
    required this.color,
    required this.iconAsset,
  });

  final String id;
  final String status;
  final String date;
  final List<String> items;
  final String total;
  final Color color;
  final String iconAsset;
}
