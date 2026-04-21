import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/product_tile.dart';

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
  final List<ProductData> _favoriteProducts = <ProductData>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: 'Ulubione produkty',
          onBack: widget.onBack,
        ),
        Expanded(
          child: _favoriteProducts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Nie masz jeszcze ulubionych produktów.\nDodaj je klikając serce na karcie produktu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: _favoriteProducts.map((product) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ProductTile(
                        product: product,
                        isLiked: true,
                        onToggleLike: () {
                          setState(() {
                            _favoriteProducts.removeWhere((p) => p.id == product.id);
                          });
                        },
                        onAddToCart: () {},
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
