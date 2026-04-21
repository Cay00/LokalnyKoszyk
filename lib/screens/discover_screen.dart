import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_filters.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_map_preview.dart';
import 'package:lokalny_koszyk/widgets/common/search_bar.dart';
import 'package:lokalny_koszyk/widgets/common/product_tile.dart';

import '../theme/app_theme.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _cartCount = 0;
  String _activeFilter = 'Wszystkie';
  final Set<String> _liked = <String>{};
  static const List<String> _filters = <String>[
    'Wszystkie',
    'BIO',
    'Tradycyjne',
    'Regionalne',
    'Sezonowe',
  ];

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
      tag: 'SWIEŻE',
      bgColor: Color(0xFFF8E7DE),
      tagColor: Color(0xFF4A7C59),
    ),
    ProductData(
      id: 'p2',
      name: 'Ser koryciński',
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
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text(
                'Odkrywaj',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              DiscoverSearchBar(),
              SizedBox(height: 16),
            ],
          ),
        ),
        DiscoverFilters(
          filters: _filters,
          activeFilter: _activeFilter,
          onFilterSelected: (String filter) {
            setState(() {
              _activeFilter = filter;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            children: const <Widget>[
              DiscoverMapPreview(),
              SizedBox(height: 16),
            ],
          ),
        ),
        ..._products.map((ProductData product) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: ProductTile(
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
            ),
          );
        }),
      ],
    );
  }
}
