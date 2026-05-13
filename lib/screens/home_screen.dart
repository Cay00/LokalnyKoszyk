import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/seller.dart';
import 'package:lokalny_koszyk/presentation/home_view_model.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/widgets/common/search_bar.dart';
import 'package:lokalny_koszyk/widgets/discover/discover_map_preview.dart';
import 'package:lokalny_koszyk/screens/producer/producer_tile.dart';
import 'package:lokalny_koszyk/widgets/common/section_header.dart';
import 'package:lokalny_koszyk/screens/product/product_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenProductDetails,
    this.onOpenProducerDetails,
  });

  final ValueChanged<ProductUiModel>? onOpenProductDetails;
  final ValueChanged<String>? onOpenProducerDetails;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  String? _buildAccessHintMessage(int unresolved) {
    if (unresolved == 0) return null;
    return 'Brak nazw sprzedawców — baza zwraca tylko identyfikatory. '
        'Włącz odczyt tabeli `sellers` (oraz opcjonalnie `seller_locations`) w Supabase RLS. '
        'Gotowy skrypt: sql/supabase_sellers_public_read.sql';
  }

  Future<void> _addToCart(ProductUiModel product) async {
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final error = await viewModel.addToCart(product);
    if (!mounted) return;
    final cartCount = ref.read(homeViewModelProvider).cartCount;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text('Dodano do koszyka: ${product.name} (razem: $cartCount)'),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nie udało się dodać do koszyka: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final sellersAsync = state.nearbySellers;
    final sellers = sellersAsync.valueOrNull ?? const <Seller>[];
    final unresolvedCount = sellers.where((Seller s) => !s.hasResolvedName).length;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _HomeHeader(cartCount: state.cartCount),
        const _SeasonalBanner(),
        const _NearbyProducersHeader(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: DiscoverMapPreview(),
        ),
        _NearbyProducersList(
          producers: sellers,
          isLoading: sellersAsync.isLoading,
          errorText: sellersAsync.hasError
              ? 'Nie udało się pobrać sprzedawców: ${sellersAsync.error}'
              : null,
          accessHint: _buildAccessHintMessage(unresolvedCount),
          onRetry: () => ref.read(homeViewModelProvider.notifier).loadSellers(),
          onOpenProducerDetails: widget.onOpenProducerDetails,
        ),
        _FeaturedProductsSection(
          products: state.featuredProducts,
          liked: state.liked,
          onOpenDetails: (ProductUiModel product) {
            widget.onOpenProductDetails?.call(product);
          },
          onToggleLike: (String id) {
            ref.read(homeViewModelProvider.notifier).toggleLike(id);
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
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Expanded(
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
        child: Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  final List<ProductUiModel> products;
  final Set<String> liked;
  final ValueChanged<ProductUiModel> onOpenDetails;
  final ValueChanged<String> onToggleLike;
  final ValueChanged<ProductUiModel> onAddToCart;

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
    required this.accessHint,
    required this.onRetry,
    this.onOpenProducerDetails,
  });

  final List<Seller> producers;
  final bool isLoading;
  final String? errorText;
  final String? accessHint;
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
            else ...<Widget>[
                ...producers.map((prod) {
                  return ProducerTile(
                    name: prod.name,
                    subtitle: prod.subtitle,
                    distance: prod.distance,
                    rating: prod.rating,
                    reviews: prod.reviews,
                    verified: prod.isVerified,
                    onTap: () => onOpenProducerDetails?.call(prod.id),
                  );
                }),
                if (accessHint != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      accessHint!,
                      style: AppTypography.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textLight,
                        height: 1.35,
                      ),
                    ),
                  ),
              ],
        ],
      ),
    );
  }
}
