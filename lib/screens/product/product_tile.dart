import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/product_info_chip.dart';
import '../../widgets/common/primary_action_button.dart';

typedef ProductData = ProductUiModel;

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
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) => const SizedBox.shrink(),
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
                          color: Colors.white.withValues(alpha: 0.85),
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
                            Text(product.unit, style: AppTypography.caption),
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviews})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
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
