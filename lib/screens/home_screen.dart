import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/supabase/cart_repository.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/widgets/common/search_bar.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_map_preview.dart';
import 'package:lokalny_koszyk/screens/producer/producer_tile.dart';
import 'package:lokalny_koszyk/widgets/common/section_header.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenProductDetails,
    this.onOpenProducerDetails,
  });

  final ValueChanged<ProductData>? onOpenProductDetails;
  final ValueChanged<String>? onOpenProducerDetails;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cartCount = 0;
  final Set<String> _liked = <String>{};
  bool _isAddingToCart = false;
  bool _isLoadingSellers = true;
  String? _sellersError;
  List<_ProducerItem> _nearbySellers = const <_ProducerItem>[];

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
      bgColor: AppColors.background,
      tagColor: AppColors.warmBrown,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadNearbySellers();
  }

  Future<void> _loadNearbySellers() async {
    setState(() {
      _isLoadingSellers = true;
      _sellersError = null;
    });
    try {
      final rows = await supabase
          .from('sellers')
          .select('id, name, is_verified')
          .order('created_at', ascending: false)
          .limit(20);

      final mapped = rows.map<_ProducerItem>((dynamic row) {
        final map = Map<String, dynamic>.from(row as Map);
        return _ProducerItem(
          id: (map['id'] ?? '').toString(),
          name: (map['name'] ?? 'Sprzedawca').toString(),
          dist: '',
          rating: '0.0',
          reviews: '0',
          verified: map['is_verified'] == true,
        );
      }).where((seller) => seller.id.isNotEmpty).toList();

      if (!mounted) return;
      setState(() {
        _nearbySellers = mapped;
        _isLoadingSellers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingSellers = false;
        _sellersError = 'Nie udało się pobrać sprzedawców: $e';
      });
    }
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
          content: Text('Dodano do koszyka: ${product.name} (razem: $_cartCount)'),
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
        _HomeHeader(cartCount: _cartCount),
        const _SeasonalBanner(),
        const _NearbyProducersHeader(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: DiscoverMapPreview(),
        ),
        _NearbyProducersList(
          producers: _nearbySellers,
          isLoading: _isLoadingSellers,
          errorText: _sellersError,
          onRetry: _loadNearbySellers,
          onOpenProducerDetails: widget.onOpenProducerDetails,
        ),
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
          onAddToCart: _addToCart,
        ),
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
                            color: AppColors.background,
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
                        AppColors.background,
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
              const SizedBox(height: 16),
              const _HeaderLocationRow(),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderLocationRow extends StatelessWidget {
  const _HeaderLocationRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SvgPicture.asset(
          'assets/icons/map-pin-area.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Wrocław, Dolnośląskie',
            style: TextStyle(
              color: AppColors.textOnDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          'Zmień',
          style: TextStyle(
            color: AppColors.textOnDark,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        SvgPicture.asset(
          'assets/icons/caret-right.svg',
          width: 12,
          height: 12,
          colorFilter: const ColorFilter.mode(
            AppColors.textOnDark,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }
}

class _SeasonalBanner extends StatelessWidget {
  const _SeasonalBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
  final ValueChanged<ProductData> onAddToCart;

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
                onAddToCart: () => onAddToCart(product),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NearbyProducersHeader extends StatelessWidget {
  const _NearbyProducersHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SectionHeader(
        title: 'Sprzedawcy w pobliżu',
        actionLabel: 'Zobacz wszystkich',
      ),
    );
  }
}

class _NearbyProducersList extends StatelessWidget {
  const _NearbyProducersList({
    required this.producers,
    required this.isLoading,
    required this.errorText,
    required this.onRetry,
    this.onOpenProducerDetails,
  });

  final List<_ProducerItem> producers;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onRetry;
  final ValueChanged<String>? onOpenProducerDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(),
            )
          else if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      errorText!,
                      style: AppTypography.body,
                    ),
                  ),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Ponów'),
                  ),
                ],
              ),
            )
          else if (producers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Brak sprzedawców do wyświetlenia.',
                style: AppTypography.body,
              ),
            )
          else
            ...producers.map((prod) {
              return ProducerTile(
                name: prod.name,
                distance: prod.dist,
                rating: prod.rating,
                reviews: prod.reviews,
                verified: prod.verified,
                onTap: () => onOpenProducerDetails?.call(prod.id),
              );
            }),
        ],
      ),
    );
  }
}

class _ProducerItem {
  const _ProducerItem({
    required this.id,
    required this.name,
    required this.dist,
    required this.rating,
    required this.reviews,
    required this.verified,
  });

  final String id;
  final String name;
  final String dist;
  final String rating;
  final String reviews;
  final bool verified;
}
