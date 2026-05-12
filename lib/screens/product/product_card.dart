import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';

class ProductCardGrid extends StatelessWidget {
  const ProductCardGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  static const double _gap = 16;

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
            (int index) => SizedBox(
              width: tileW,
              child: itemBuilder(context, index),
            ),
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Widget image;
  final String name;
  final String price;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isLiked;
  final VoidCallback? onToggleLike;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    this.onTap,
    this.onAddToCart,
    this.isLiked = false,
    this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.normal),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.normal),
                topRight: Radius.circular(AppRadius.normal),
              ),
              child: SizedBox(
                height: 128,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    image,
                    Positioned(
                      top: 8,
                      right: 8,
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
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.productNameTiny,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          style: AppTypography.priceSmall,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
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