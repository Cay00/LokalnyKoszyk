import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/widgets/home/section_header.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const List<_OrderItem> _orders = <_OrderItem>[
    _OrderItem(
      id: '#8821',
      status: 'W realizacji',
      date: '18 kwi',
      items: <String>['Pomidory 2kg', 'ó lipowy'],
      total: '62,00 zł',
      color: Color(0xFFD2A857),
      icon: '🚚',
    ),
    _OrderItem(
      id: '#8810',
      status: 'Zrealizowane',
      date: '12 kwi',
      items: <String>['Ser owczy', 'Jaja wiejskie'],
      total: '38,00 zł',
      color: Color(0xFF4A7C59),
      icon: '✅',
    ),
    _OrderItem(
      id: '#8795',
      status: 'Odebrane',
      date: '5 kwi',
      items: <String>['Chleb razowy', 'Masło'],
      total: '24,00 zł',
      color: Color(0xFF8B8B8B),
      icon: '🏡',
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
            color: Color(0xFF1E3A2F),
          ),
        ),
        const SizedBox(height: 16),
        const _CartSummaryCard(),
        const SizedBox(height: 32),
        const SectionHeader(
          title: 'Historia zamówień',
        ),
        const SizedBox(height: 16),
        ..._orders.asMap().entries.map((entry) {
          final int index = entry.key;
          final _OrderItem order = entry.value;
          return _OrderHistoryTile(
            order: order,
            withBottomSpacing: index < _orders.length - 1,
          );
        }),
      ],
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF1E3A2F), Color(0xFF356C53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          const Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Koszyk',
                  style: TextStyle(
                    color: Color(0xFFF7F1E6),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '2 produkty',
                style: TextStyle(
                  color: Color(0xFFC6D8BC),
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
                top: BorderSide(color: Color(0x26FFFFFF)),
              ),
            ),
            child: const Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Razem',
                    style: TextStyle(
                      color: Color(0xFFC6D8BC),
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '50,00 zł',
                  style: TextStyle(
                    color: Color(0xFFF7F1E6),
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD2A857),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Przejdź do zamówienia ->',
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFFF7F1E6),
                    fontSize: 14,
                  ),
                ),
                Text(
                  qty,
                  style: const TextStyle(
                    color: Color(0xFFC6D8BC),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFFF7F1E6),
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
  });

  final _OrderItem order;
  final bool withBottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: withBottomSpacing ? 8 : 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE6DE)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(order.icon, style: const TextStyle(fontSize: 20)),
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
                        color: Color(0xFF1E3A2F),
                      ),
                    ),
                    Text(
                      order.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B8B8B),
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
                  borderRadius: BorderRadius.circular(8),
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
                color: Color(0xFF6F6F6F),
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
                    color: Color(0xFF8B8B8B),
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                order.total,
                style: const TextStyle(
                  color: Color(0xFF1E3A2F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
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
    required this.icon,
  });

  final String id;
  final String status;
  final String date;
  final List<String> items;
  final String total;
  final Color color;
  final String icon;
}
