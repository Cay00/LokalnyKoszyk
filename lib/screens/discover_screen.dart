import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/widgets/product_tile.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _cartCount = 0;
  final Set<String> _liked = <String>{};

  static const List<ProductData> _products = <ProductData>[
    ProductData(
      id: 'p1',
      name: 'Pomidory malinowe',
      producer: 'Gospodarstwo Kwiatowe',
      price: '12,99',
      unit: '/ kg',
      distance: '4 km',
      season: 'Wiosna',
      rating: '4.9',
      reviews: '124',
      emoji: '🍅',
      tag: 'SWIEZE',
      bgColor: Color(0xFFF8E7DE),
      tagColor: Color(0xFF4A7C59),
    ),
    ProductData(
      id: 'p2',
      name: 'Ser korycinski',
      producer: 'Mleczarnia Podlaska',
      price: '15,00',
      unit: '/ 200 g',
      distance: '7 km',
      season: 'Caly rok',
      rating: '4.8',
      reviews: '89',
      emoji: '🧀',
      tag: 'LOKALNE',
      bgColor: Color(0xFFF7F2D9),
      tagColor: Color(0xFF9C6B30),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: _products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (BuildContext context, int index) {
          final ProductData product = _products[index];
          return ProductTile(
            product: product,
            isLiked: _liked.contains(product.id),
            onToggleLike: () {
              setState(() {
                if (_liked.contains(product.id)) {
                  _liked.remove(product.id);
                } else {
                  _liked.add(product.id);
                }
              });
            },
            onAddToCart: () {
              setState(() {
                _cartCount++;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 700),
                  content: Text('Koszyk: $_cartCount'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
