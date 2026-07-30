import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';

class ProductTileSmall extends StatelessWidget {
  const ProductTileSmall({
    super.key,
    required this.name,
    required this.distance,
    required this.priceWithUnitLabel,
    required this.verified,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 8),
  });

  final String name;
  final String distance;

  /// Np. `12,99 zł/kg` — zgodnie z jednostką i ilością z bazy.
  final String priceWithUnitLabel;
  final bool verified;
  final VoidCallback? onTap;

  /// Margines na zewnątrz kafelka (np. odstęp na liście). Domyślnie 8 px na dole.
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.normal),
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Container(
          margin: margin,
          padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.normal),
            border: Border.all(color: AppColors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Center(
                          child: SvgPicture.asset(
                            'assets/icons/farm.svg',
                            width: 28,
                            height: 28,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Image.asset(
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
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.header,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                priceWithUnitLabel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.header,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/icons/caret-right.svg',
                          width: 12,
                          height: 12,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
