import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/core/supabase/watched_products_repository.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../core/themes/app_theme.dart';
import '../../widgets/common/screen_header.dart';
import '../product/product_tile.dart';
import '../product/product_tile_small.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<WatchedProductListItem> _items = const <WatchedProductListItem>[];
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = null;
        _items = const <WatchedProductListItem>[];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final list = await WatchedProductsRepository.fetchProductsForUser(user);
      if (!mounted) return;
      setState(() {
        _items = list;
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Nie udało się wczytać listy: ${e.message}';
        _items = const <WatchedProductListItem>[];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Nie udało się wczytać listy: $e';
        _items = const <WatchedProductListItem>[];
      });
    }
  }

  void _openProductDetails(ProductData product) {
    final String? sid = product.sellerId?.trim();
    final bool hasSeller = sid != null && sid.isNotEmpty;

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => ProductDetailsScreen(
          product: product,
          onBack: () => Navigator.of(context).pop(),
          onOpenProducerDetails: hasSeller
              ? () {
                  Navigator.of(context).push(
                    PageRouteBuilder<void>(
                      pageBuilder: (_, _, _) => ProducerDetailsScreen(
                        sellerId: sid,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              : null,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Column(
      children: <Widget>[
        ScreenHeader(
          title: 'Ulubione produkty',
          onBack: widget.onBack,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : user == null
                ? const Center(
                    child: Text(
                      'Zaloguj się, aby zobaczyć obserwowane produkty.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  )
                : _errorText != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Ponów'),
                        ),
                      ],
                    ),
                  )
                : _items.isEmpty
                ? const Center(
                    child: Text(
                      'Nie obserwujesz jeszcze żadnych produktów.\nDodaj obserwację na karcie produktu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final WatchedProductListItem row = _items[index];
                        final ProductData product = row.product;
                        return ProductTileSmall(
                          name: product.name,
                          distance: product.distance,
                          priceWithUnitLabel: product.pricePerOfferLabel,
                          verified: row.sellerVerified,
                          margin: EdgeInsets.zero,
                          onTap: () => _openProductDetails(product),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
