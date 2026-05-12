import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/seller_public_lookup.dart';
import 'package:lokalny_koszyk/core/supabase/cart_repository.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:lokalny_koszyk/widgets/discover/discover_filters.dart';
import 'package:lokalny_koszyk/widgets/home/category_tile.dart';
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
  String? _activeCategoryId;
  final Set<String> _liked = <String>{};
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

  /// Etykiety PL; UUID jak w `public.categories`. Kolejność = wyświetlanie na Odkrywaj.
  static const List<_CategoryCatalogEntry> _categoryCatalog =
      <_CategoryCatalogEntry>[
        _CategoryCatalogEntry(
          id: 'b15939e0-21af-4a14-86fa-d8ee547a07cb',
          icon: '🥕',
          name: 'Warzywa',
        ),
        _CategoryCatalogEntry(
          id: '5a4aaa6c-4e4e-4ac3-9a4a-250f9ce56ebb',
          icon: '🍎',
          name: 'Owoce',
        ),
        _CategoryCatalogEntry(
          id: '411e440c-c826-427b-b6dc-78088aae9da4',
          icon: '🥚',
          name: 'Jaja',
        ),
        _CategoryCatalogEntry(
          id: '0b354b99-6e49-442d-8feb-4f00084f4b7a',
          icon: '🥛',
          name: 'Nabiał',
        ),
        _CategoryCatalogEntry(
          id: '8a2dfe1b-c628-4d26-99fa-94e9db6c90f7',
          icon: '🧀',
          name: 'Sery',
        ),
        _CategoryCatalogEntry(
          id: '8d60ba57-27d0-4311-858f-2bebf56bf3b1',
          icon: '🥩',
          name: 'Mięso',
        ),
        _CategoryCatalogEntry(
          id: '23a2267c-a836-4e6e-b6fa-204583df71c2',
          icon: '🥓',
          name: 'Wędliny',
        ),
        _CategoryCatalogEntry(
          id: '138d5676-9db7-4008-b960-ef69c9d782ac',
          icon: '🍞',
          name: 'Pieczywo',
        ),
        _CategoryCatalogEntry(
          id: 'f3d9f5d1-95c8-4cd3-bcd4-698b4298a22c',
          icon: '🥐',
          name: 'Wypieki',
        ),
        _CategoryCatalogEntry(
          id: '8b65af09-63a9-457f-853b-aa6d523b3085',
          icon: '🌿',
          name: 'Zioła',
        ),
        _CategoryCatalogEntry(
          id: '54c9b906-4298-413f-8feb-1ef722c86f08',
          icon: '🐟',
          name: 'Ryby',
        ),
        _CategoryCatalogEntry(
          id: '1ed9ab83-ba5f-4c34-b553-88f4616c5994',
          icon: '🌾',
          name: 'Mąki i kasze',
        ),
        _CategoryCatalogEntry(
          id: 'd0e76040-0704-43e6-ac87-593e4d3ffa61',
          icon: '🍯',
          name: 'Miody',
        ),
        _CategoryCatalogEntry(
          id: '749b3717-19aa-4deb-baec-624060817ee8',
          icon: '🫒',
          name: 'Oleje i octy',
        ),
        _CategoryCatalogEntry(
          id: 'c0d151a7-c635-4a30-ac02-c2eec2a905a4',
          icon: '🥫',
          name: 'Przetwory',
        ),
        _CategoryCatalogEntry(
          id: 'db3be1cb-1a43-4481-b253-9a0e9ccc3bfb',
          icon: '🥒',
          name: 'Kiszonki',
        ),
        _CategoryCatalogEntry(
          id: '5d538dbd-0d63-4142-b540-6097953d9078',
          icon: '🧃',
          name: 'Soki i napoje',
        ),
        _CategoryCatalogEntry(
          id: 'c39b5581-4ef2-4be9-b42b-6acb6b63ae79',
          icon: '🌶️',
          name: 'Przyprawy',
        ),
        _CategoryCatalogEntry(
          id: 'd4aaac87-9c19-45f7-ac9e-2ba568ca208f',
          icon: '🍱',
          name: 'Dania gotowe',
        ),
        _CategoryCatalogEntry(
          id: '0af8b69d-b4ed-4b3c-8d40-28687e474793',
          icon: '🧺',
          name: 'Rękodzieło',
        ),
        _CategoryCatalogEntry(
          id: 'bb86fb2d-7b8e-4dc4-b22d-0c7dd011a7e4',
          icon: '🪴',
          name: 'Rośliny i ogród',
        ),
      ];

  List<_CategoryItem> get _discoverCategoryItems => _categoryCatalog
      .map(
        (_CategoryCatalogEntry e) => _CategoryItem(
          id: e.id,
          icon: e.icon,
          name: e.name,
          count: _products
              .where((ProductData p) => p.categoryId == e.id)
              .length,
        ),
      )
      .toList();

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
            'product_id, seller_id, category_id, name, price_gross_amount, unit, '
            'package_size, stock_quantity, average_rating, reviews_count, is_active',
          )
          .eq('is_active', true)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      final rows = (productRows as List<dynamic>)
          .map((dynamic row) => Map<String, dynamic>.from(row as Map))
          .toList();

      final sellerRawIds = <String>{};
      for (final map in rows) {
        final raw = (map['seller_id'] ?? '').toString().trim();
        if (raw.isNotEmpty) sellerRawIds.add(raw);
      }
      final sellerByNorm = await fetchSellerPublicByIds(sellerRawIds);

      final products = rows
          .map<ProductData>((Map<String, dynamic> map) {
            final sellerIdRaw = (map['seller_id'] ?? '').toString().trim();
            final sellerKey = normalizeUuidKey(sellerIdRaw);
            final pick = sellerByNorm[sellerKey];
            final sellerName = (pick?.name.trim().isNotEmpty ?? false)
                ? pick!.name
                : 'Sprzedawca';
            final priceGrosze = parsePennies(map['price_gross_amount']);
            final ratingNum = (map['average_rating'] as num?)?.toDouble() ?? 0;
            final reviewsCount = (map['reviews_count'] as num?)?.toInt() ?? 0;
            final rawUnit = (map['unit'] ?? '').toString();
            final unitKey = rawUnit.trim().toLowerCase();
            final qty = (map['package_size'] as num?)?.toDouble();
            final rawCategoryId = map['category_id']?.toString().trim();
            final categoryId = rawCategoryId == null || rawCategoryId.isEmpty
                ? null
                : rawCategoryId;

            return ProductData(
              id: (map['product_id'] ?? '').toString(),
              name: (map['name'] ?? 'Produkt').toString(),
              producer: sellerName,
              price: plnCommaStringFromPennies(priceGrosze),
              unit: '/ ${rawUnit.replaceAll('_', ' ')}',
              distance: '',
              season: 'Cały rok',
              rating: ratingNum.toStringAsFixed(1),
              reviews: reviewsCount.toString(),
              emoji: '🧺',
              tag: 'LOKALNE',
              bgColor: AppColors.background,
              tagColor: AppColors.primaryLight,
              sellerId: sellerIdRaw.isEmpty ? null : sellerIdRaw,
              unitKey: unitKey.isEmpty ? null : unitKey,
              packageQuantity: qty,
              categoryId: categoryId,
            );
          })
          .where((ProductData p) => p.id.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingProducts = false;
        _productsError = 'Nie udało się wczytać produktów: ${e.message}';
        _products = const <ProductData>[];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingProducts = false;
        _productsError =
            'Nie udało się wczytać produktów. Sprawdź połączenie i spróbuj ponownie.';
        _products = const <ProductData>[];
      });
    }
  }

  List<ProductData> get _visibleProducts {
    List<ProductData> list;
    if (_activeFilter == 'Wszystkie') {
      list = _products;
    } else {
      final needle = _activeFilter.toUpperCase();
      list = _products
          .where(
            (ProductData p) =>
                p.tag.contains(needle) || p.name.toUpperCase().contains(needle),
          )
          .toList();
    }
    if (_activeCategoryId != null) {
      list = list
          .where((ProductData p) => p.categoryId == _activeCategoryId)
          .toList();
    }
    return list;
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
              Text('Odkrywaj', style: AppTypography.header),
              SizedBox(height: 16),
              DiscoverSearchBar(),
            ],
          ),
        ),
        _CategoriesSection(
          categories: _discoverCategoryItems,
          activeCategoryId: _activeCategoryId,
          onSelect: (String categoryId) {
            setState(() {
              _activeCategoryId = _activeCategoryId == categoryId
                  ? null
                  : categoryId;
            });
          },
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
                Text(_productsError!, style: AppTypography.body)
              else if (_visibleProducts.isEmpty)
                const Text(
                  'Brak produktów do wyświetlenia.',
                  style: AppTypography.body,
                )
              else
                ProductCardGrid(
                  itemCount: _visibleProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ProductData product = _visibleProducts[index];

                    return ProductCard(
                      image: Image.asset(
                        'assets/images/food_default.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) => ColoredBox(color: product.bgColor),
                      ),
                      name: product.name,
                      price: product.pricePerOfferLabel,
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
                      onTap: () => widget.onOpenProductDetails?.call(product),
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

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({
    required this.categories,
    required this.activeCategoryId,
    required this.onSelect,
  });

  final List<_CategoryItem> categories;
  final String? activeCategoryId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: SectionHeader(
            title: 'Kategorie',
            actionLabel: 'Zobacz wszystkie',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final _CategoryItem category = categories[index];
              final bool active = activeCategoryId == category.id;
              return CategoryTile(
                icon: category.icon,
                name: category.name,
                count: category.count,
                active: active,
                onTap: () => onSelect(category.id),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.id,
    required this.icon,
    required this.name,
    required this.count,
  });

  final String id;
  final String icon;
  final String name;
  final int count;
}

class _CategoryCatalogEntry {
  const _CategoryCatalogEntry({
    required this.id,
    required this.icon,
    required this.name,
  });

  final String id;
  final String icon;
  final String name;
}
