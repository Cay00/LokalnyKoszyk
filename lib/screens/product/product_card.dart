import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/widgets/common/add_to_cart_icon_button.dart';

import '../../core/themes/app_theme.dart';

class ProductCardGrid extends StatelessWidget {
  const ProductCardGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxW = constraints.maxWidth;
        final double tileW = (maxW - _gap) / 2;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: List<Widget>.generate(
            itemCount,
            (int index) =>
                SizedBox(width: tileW, child: itemBuilder(context, index)),
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Widget image;
  final String name;
  final String size;
  final String price;
  final String? oldPrice;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.size,
    required this.price,
    this.oldPrice,
    this.onTap,
    this.onAddToCart,
  });

  static const double _edgePad = 8;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.normal),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.normal),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: SizedBox.expand(child: image),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    _edgePad,
                    _edgePad,
                    0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.header.copyWith(
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        size,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: AddToCartIconButton.size,
                          bottom: _edgePad,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                price,
                                style: AppTypography.header,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (oldPrice != null &&
                                oldPrice!.trim().isNotEmpty) ...[
                              const SizedBox(width: 2),
                              Text(
                                oldPrice!,
                                style: AppTypography.tinyCaption.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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
