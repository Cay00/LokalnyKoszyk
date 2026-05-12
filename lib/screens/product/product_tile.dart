import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/formatting/product_price_per_label.dart';
import '../../core/themes/app_theme.dart';
import '../../widgets/common/product_info_chip.dart';
import '../../widgets/common/primary_action_button.dart';

class ProductData {
  const ProductData({
    required this.id,
    required this.name,
    required this.producer,
    required this.price,
    required this.unit,
    required this.distance,
    required this.season,
    required this.rating,
    required this.reviews,
    required this.emoji,
    required this.tag,
    required this.bgColor,
    required this.tagColor,
    this.sellerId,
    this.unitKey,
    this.packageQuantity,
    this.categoryId,
  });

  final String id;
  final String name;
  final String producer;
  final String price;
  final String unit;
  final String distance;
  final String season;
  final String rating;
  final String reviews;
  final String emoji;
  final String tag;
  final Color bgColor;
  final Color tagColor;

  /// Identyfikator sprzedawcy (z `products.seller_id`). Może być `null` dla
  /// statycznych danych mockowych — wtedy nawigacja do producenta jest pomijana.
  final String? sellerId;

  /// Z bazy: `piece`, `kilogram`, `gram`, `liter`, `milliliter` (null = tylko [unit]).
  final String? unitKey;
  final double? packageQuantity;

  /// `products.category_id` (UUID z `public.categories`), opcjonalnie.
  final String? categoryId;

  /// Np. `12,99 zł/szt.`, `5,00 zł/litr`, `9,99 zł/100 mg`.
  String get pricePerOfferLabel => buildProductPricePerLabel(
        priceFormatted: price,
        unitKey: unitKey ?? inferProductUnitKeyFromSlashUnit(unit),
        quantity: packageQuantity,
      );

  bool get hasKnownDbUnit =>
      unitKey != null || inferProductUnitKeyFromSlashUnit(unit) != null;
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.isLiked,
    required this.onOpenDetails,
    required this.onToggleLike,
    required this.onAddToCart,
  });

  final ProductData product;
  final bool isLiked;
  final VoidCallback onOpenDetails;
  final VoidCallback onToggleLike;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenDetails,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.normal),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.normal),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Container(
            height: 160,
            width: double.infinity,
            color: product.bgColor,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/food_default.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder:
                        (BuildContext context, Object error, StackTrace? stackTrace) =>
                            const SizedBox.shrink(),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: InkWell(
                    onTap: onToggleLike,
                    borderRadius: BorderRadius.circular(AppRadius.normal),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        isLiked
                            ? 'assets/icons/heart-fill.svg'
                            : 'assets/icons/heart.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          isLiked ? Colors.redAccent : AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.name,
                            style: AppTypography.productNameSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.producer,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          product.pricePerOfferLabel,
                          textAlign: TextAlign.right,
                          style: AppTypography.price,
                        ),
                        if (!product.hasKnownDbUnit &&
                            product.unit.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            product.unit,
                            style: AppTypography.caption,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    ProductInfoChip(
                      text: product.distance,
                      iconAsset: 'assets/icons/map-pin-area.svg',
                    ),
                    const SizedBox(width: 8),
                    ProductInfoChip(
                      text: product.season,
                      iconAsset: 'assets/icons/calendar-check.svg',
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      'assets/icons/star-fill.svg',
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.accent,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviews})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryActionButton(
                  label: 'Dodaj do koszyka',
                  onPressed: onAddToCart,
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
