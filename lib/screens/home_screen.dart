import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/theme/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/search_bar.dart';
import 'package:lokalny_koszyk/widgets/home/category_tile.dart';
import 'package:lokalny_koszyk/widgets/home/producer_tile.dart';
import 'package:lokalny_koszyk/widgets/home/section_header.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenProductDetails,
  });

  final ValueChanged<ProductData>? onOpenProductDetails;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cartCount = 0;
  String? _activeCategoryId;
  final Set<String> _liked = <String>{};

  static const List<_CategoryItem> _categories = <_CategoryItem>[
    _CategoryItem(id: 'warzywa', icon: '🥕', name: 'Warzywa', count: 18),
    _CategoryItem(id: 'nabiał', icon: '🥛', name: 'Nabiał', count: 12),
    _CategoryItem(id: 'pieczywo', icon: '🍞', name: 'Pieczywo', count: 9),
    _CategoryItem(id: 'miód', icon: '🍯', name: 'Miody', count: 7),
    _CategoryItem(id: 'przetwory', icon: '🥫', name: 'Przetwory', count: 14),
  ];

  static const List<ProductData> _products = <ProductData>[
    ProductData(
      id: 'hp1',
      name: 'Rzodkiewka BIO',
      producer: 'Gospodarstwo Zielone Pole',
      price: '7,90',
      unit: '/ pęczek',
      distance: '3 km',
      season: 'Wiosna',
      rating: '4.9',
      reviews: '64',
      emoji: '🌱',
      tag: 'BIO',
      bgColor: AppColors.lightSage,
      tagColor: AppColors.leafGreen,
    ),
    ProductData(
      id: 'hp2',
      name: 'Jajka od szczęśliwych kur',
      producer: 'Farma Pod Lipą',
      price: '13,50',
      unit: '/ 10 szt.',
      distance: '6 km',
      season: 'Cały rok',
      rating: '4.8',
      reviews: '102',
      emoji: '🥚',
      tag: 'REGIONALNE',
      bgColor: AppColors.cream,
      tagColor: AppColors.warmBrown,
    ),
  ];

  static const List<_ProducerItem> _producers = <_ProducerItem>[
    _ProducerItem(
      id: 'pr1',
      name: 'Eko Zagroda Liski',
      type: 'Warzywa i owoce',
      dist: '4 km',
      verified: true,
    ),
    _ProducerItem(
      id: 'pr2',
      name: 'Sery od Braci',
      type: 'Nabiał',
      dist: '9 km',
      verified: true,
    ),
    _ProducerItem(
      id: 'pr3',
      name: 'Piekarnia Królewska',
      type: 'Pieczywo',
      dist: '2 km',
      verified: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _HomeHeader(cartCount: _cartCount),
        const _LocationBanner(),
        _CategoriesSection(
          categories: _categories,
          activeCategoryId: _activeCategoryId,
          onSelect: (String categoryId) {
            setState(() {
              _activeCategoryId =
                  _activeCategoryId == categoryId ? null : categoryId;
            });
          },
        ),
        const _SeasonalBanner(),
        _FeaturedProductsSection(
          products: _products,
          liked: _liked,
          onOpenDetails: (ProductData product) {
            widget.onOpenProductDetails?.call(product);
          },
          onToggleLike: (String id) {
            setState(() {
              if (_liked.contains(id)) {
                _liked.remove(id);
              } else {
                _liked.add(id);
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
        _NearbyProducersSection(producers: _producers),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Znajdź lokalne smaki',
                          style: TextStyle(
                            color: AppColors.cream,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0x1FFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/icons/bell.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.cream,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AppSearchBar(
                placeholder: 'Szukaj produktów, sprzedawców...',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightSage,
          borderRadius: BorderRadius.circular(AppRadius.normal),
          border: Border.all(color: AppColors.softSage),
        ),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              'assets/icons/map-pin-area.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Wrocław, Dolnośląskie',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Produkty w promieniu 15 km',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  'Zmień',
                  style: TextStyle(
                    color: AppColors.leafGreen,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/caret-right.svg',
                  width: 12,
                  height: 12,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 16),
              ...categories.map((category) {
                final bool active = activeCategoryId == category.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryTile(
                    icon: category.icon,
                    name: category.name,
                    count: category.count,
                    active: active,
                    onTap: () => onSelect(category.id),
                  ),
                );
              }),
              const SizedBox(width: 16),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SeasonalBanner extends StatelessWidget {
  const _SeasonalBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[AppColors.accent, AppColors.warmBrown],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.normal),
        ),
        child: Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text('🌱', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sezon wiosenny!',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Świeża bazylia dostepna już teraz',
                        style: TextStyle(
                          color: Color(0xD9F5F0E8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x40FFFFFF),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Text(
                    'Odkryj',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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

class _FeaturedProductsSection extends StatelessWidget {
  const _FeaturedProductsSection({
    required this.products,
    required this.liked,
    required this.onOpenDetails,
    required this.onToggleLike,
    required this.onAddToCart,
  });

  final List<ProductData> products;
  final Set<String> liked;
  final ValueChanged<ProductData> onOpenDetails;
  final ValueChanged<String> onToggleLike;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Polecane',
            actionLabel: 'Wszystkie',
          ),
          const SizedBox(height: 16),
          ...products.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProductTile(
                product: product,
                isLiked: liked.contains(product.id),
                onOpenDetails: () => onOpenDetails(product),
                onToggleLike: () => onToggleLike(product.id),
                onAddToCart: onAddToCart,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NearbyProducersSection extends StatelessWidget {
  const _NearbyProducersSection({required this.producers});

  final List<_ProducerItem> producers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHeader(
            title: 'Sprzedawcy w pobliżu',
            actionLabel: 'Zobacz wszystkich',
          ),
          const SizedBox(height: 8),
          ...producers.map((prod) {
            return ProducerTile(
              name: prod.name,
              type: prod.type,
              distance: prod.dist,
              verified: prod.verified,
            );
          }),
        ],
      ),
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

class _ProducerItem {
  const _ProducerItem({
    required this.id,
    required this.name,
    required this.type,
    required this.dist,
    required this.verified,
  });

  final String id;
  final String name;
  final String type;
  final String dist;
  final bool verified;
}
