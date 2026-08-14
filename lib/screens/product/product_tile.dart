import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

import '../../core/themes/app_theme.dart';

typedef ProductData = ProductUiModel;

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.onOpenDetails,
    required this.onAddToCart,
  });

  final ProductData product;
  final VoidCallback onOpenDetails;
  final VoidCallback onAddToCart;

  static const double _height = 114;
  static const double _edgePad = 8;
  static const double _addButtonSize = 38;
  static const double _addIconSize = 24;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenDetails,
      child: Container(
        width: double.infinity,
        height: _height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.normal),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.normal),
          border: Border.all(color: AppColors.background),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: _height,
                  height: _height,
                  child: ColoredBox(
                    color: product.bgColor,
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
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      16,
                      _edgePad + _addButtonSize,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.normalBold,
                        ),
                        Text(
                          product.producer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption,
                        ),
                        Text(
                          product.sizeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.tinyCaption,
                        ),
                        Text(
                          product.priceLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.header,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: _edgePad,
              bottom: _edgePad,
              child: GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  width: _addButtonSize,
                  height: _addButtonSize,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/icons/basket.svg',
                    width: _addIconSize,
                    height: _addIconSize,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
