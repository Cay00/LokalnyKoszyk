import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/supabase/cart_repository.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_filters.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_map_preview.dart';
import 'package:lokalny_koszyk/screens/product/product_card.dart';
import 'package:lokalny_koszyk/widgets/common/search_bar.dart';
import 'package:lokalny_koszyk/widgets/common/section_header.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';

import '../core/themes/app_theme.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, this.onOpenProductDetails});

  final ValueChanged<ProductData>? onOpenProductDetails;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _cartCount = 0;
  String _activeFilter = 'Wszystkie';
  bool _isAddingToCart = false;
  bool _isLoadingProducts = true;
  String? _productsError;
  List<ProductData> _products = const <ProductData>[];
  static const List<String> _filters = <String>[
    'Wszystkie',
    'BIO',
    'Regionalne',
    'Sezonowe',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });
    try {
      final productRows = await supabase
          .from('products')
          .select(
            'product_id, seller_id, name, price, unit, quantity, average_rating, reviews_count, tags, is_active',
          )
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final rows = (productRows as List<dynamic>)
          .map((dynamic row) => Map<String, dynamic>.from(row as Map))
          .toList();

      final sellerIds = <String>{};
      for (final map in rows) {
        final sid = (map['seller_id'] ?? '').toString().trim();
        if (sid.isNotEmpty) sellerIds.add(sid);
      }

      final Map<String, String> sellerNameById = <String, String>{};
      if (sellerIds.isNotEmpty) {
        final sellerRows = await supabase
            .from('sellers')
            .select('id, name')
            .inFilter('id', sellerIds.toList());
        for (final dynamic r in sellerRows as List<dynamic>) {
          final sm = Map<String, dynamic>.from(r as Map);
          final id = (sm['id'] ?? '').toString();
          if (id.isEmpty) continue;
          sellerNameById[id] = (sm['name'] ?? 'Sprzedawca').toString();
        }
      }

      final products = rows
          .map<ProductData>((Map<String, dynamic> map) {
            final sellerId = (map['seller_id'] ?? '').toString();
            final sellerName = sellerNameById[sellerId] ?? 'Sprzedawca';
            final priceNum = (map['price'] as num?)?.toDouble() ?? 0;
            final ratingNum = (map['average_rating'] as num?)?.toDouble() ?? 0;
            final reviewsCount = (map['reviews_count'] as num?)?.toInt() ?? 0;
            final rawUnit = (map['unit'] ?? '').toString();
            final unitKey = rawUnit.trim().toLowerCase();
            final qty = (map['quantity'] as num?)?.toDouble();
            final tags = (map['tags'] as List<dynamic>? ?? <dynamic>[]);

            return ProductData(
              id: (map['product_id'] ?? '').toString(),
              name: (map['name'] ?? 'Produkt').toString(),
              producer: sellerName,
              price: priceNum.toStringAsFixed(2).replaceAll('.', ','),
              unit: '/ ${rawUnit.replaceAll('_', ' ')}',
              distance: '',
              season: 'Cały rok',
              rating: ratingNum.toStringAsFixed(1),
              reviews: reviewsCount.toString(),
              emoji: '🧺',
              tag: tags.isNotEmpty
                  ? tags.first.toString().toUpperCase()
                  : 'LOKALNE',
              bgColor: AppColors.background,
              tagColor: AppColors.primaryLight,
              unitKey: unitKey.isEmpty ? null : unitKey,
              packageQuantity: qty,
            );
          })
          .where((ProductData p) => p.id.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingProducts = false;
        _productsError = 'Nie udało się pobrać produktów: $e';
        _products = const <ProductData>[];
      });
    }
  }

  List<ProductData> get _visibleProducts {
    if (_activeFilter == 'Wszystkie') return _products;
    final needle = _activeFilter.toUpperCase();
    return _products
        .where(
          (ProductData p) =>
              p.tag.contains(needle) || p.name.toUpperCase().contains(needle),
        )
        .toList();
  }

  Future<void> _addToCart(ProductData product) async {
    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);
    try {
      await CartRepository.addToCart(productId: product.id);
      if (!mounted) return;
      setState(() => _cartCount++);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text(
            'Dodano do koszyka: ${product.name} (razem: $_cartCount)',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się dodać do koszyka: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionHeader(
                title: 'Wyniki',
                titleCount: _isLoadingProducts ? null : _visibleProducts.length,
              ),
              const SizedBox(height: 16),

              if (_isLoadingProducts)
                const Center(child: CircularProgressIndicator())
              else if (_productsError != null)
                Text(
                  _productsError!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                )
              else if (_visibleProducts.isEmpty)
                const Text(
                  'Brak produktów do wyświetlenia.',
                  style: TextStyle(color: AppColors.textLight, fontSize: 14),
                )
              else
                ProductCardGrid(
                  itemCount: _visibleProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ProductData product = _visibleProducts[index];

                    return ProductCard(
                      image: ColoredBox(
                        color: product.bgColor,
                        child: Center(
                          child: Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                      name: product.name,
                      price: product.pricePerOfferLabel,
                      onTap: () =>
                          widget.onOpenProductDetails?.call(product),
                      onAddToCart: () => _addToCart(product),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
