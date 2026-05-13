import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lokalny_koszyk/presentation/models/favorite_product_ui_model.dart';
import 'package:lokalny_koszyk/presentation/favorites_view_model.dart';
import 'package:lokalny_koszyk/screens/producer/producer_details_screen.dart';
import 'package:lokalny_koszyk/screens/product/product_details_screen.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/screen_header.dart';
import '../product/product_tile_small.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesViewModelProvider);
    void openProductDetails(ProductUiModel product) {
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

    return Column(
      children: <Widget>[
        ScreenHeader(title: 'Ulubione produkty', onBack: onBack),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : !state.isSignedIn
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
                : state.errorText != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          state.errorText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => ref
                              .read(favoritesViewModelProvider.notifier)
                              .load(),
                          child: const Text('Ponów'),
                        ),
                      ],
                    ),
                  )
                : state.items.isEmpty
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
                    onRefresh: () =>
                        ref.read(favoritesViewModelProvider.notifier).load(),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.items.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final FavoriteProductUiModel row = state.items[index];
                        final ProductUiModel product = row.product;
                        return ProductTileSmall(
                          name: product.name,
                          distance: product.distance,
                          priceWithUnitLabel: product.pricePerOfferLabel,
                          verified: row.sellerVerified,
                          margin: EdgeInsets.zero,
                          onTap: () => openProductDetails(product),
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
