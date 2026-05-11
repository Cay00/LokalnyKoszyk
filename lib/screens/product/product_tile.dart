import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/formatting/product_price_per_label.dart';
import '../../core/themes/app_theme.dart';
import '../../widgets/common/product_info_chip.dart';

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
    this.unitKey,
    this.packageQuantity,
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

  /// Z bazy: `piece`, `kilogram`, `gram`, `liter`, `milliliter` (null = tylko [unit]).
  final String? unitKey;
  final double? packageQuantity;

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
              children: <Widget>[
                Center(
                  child: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 64),
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
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, top: 64, bottom: 16),
                    decoration: BoxDecoration(
                      color: product.tagColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      product.tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,

                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.producer,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        if (!product.hasKnownDbUnit &&
                            product.unit.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            product.unit,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.normal),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('+'),
                        SizedBox(width: 8),
                        Text(
                          'Dodaj do koszyka',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
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
