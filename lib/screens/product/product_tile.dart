import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';
import 'package:lokalny_koszyk/widgets/common/add_to_cart_icon_button.dart';

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

  static const double _height = 120;
  static const double _edgePad = 8;
  static const double _lineGap = 8;
  static const double _producerToSizeGap = _lineGap * 2;

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
                      16,
                      16,
                      _edgePad + AddToCartIconButton.size,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.header.copyWith(height: 1),
                        ),
                        const SizedBox(height: _lineGap),
                        Text(
                          product.producer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(height: 1),
                        ),
                        const SizedBox(height: _producerToSizeGap),
                        Text(
                          product.sizeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(height: 1),
                        ),
                        const SizedBox(height: _lineGap),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                product.priceLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.header.copyWith(height: 1),
                              ),
                            ),
                            if (product.oldPriceLabel != null) ...<Widget>[
                              const SizedBox(width: 8),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  product.oldPriceLabel!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    height: 1,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
              child: AddToCartIconButton(onPressed: onAddToCart),
            ),
          ],
        ),
      ),
    );
  }
}
