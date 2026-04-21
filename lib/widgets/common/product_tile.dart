import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';

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
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.isLiked,
    required this.onToggleLike,
    required this.onAddToCart,
  });

  final ProductData product;
  final bool isLiked;
  final VoidCallback onToggleLike;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          '${product.price} zł',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        Text(
                          product.unit,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _MetaChip(
                      text: product.distance,
                      iconAsset: 'assets/icons/map-pin-area.svg',
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
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
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.text,
    this.iconAsset,
  });

  final String text;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (iconAsset != null) ...<Widget>[
            SvgPicture.asset(
              iconAsset!,
              width: 12,
              height: 12,
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
