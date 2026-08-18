import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';

class ProducerTile extends StatelessWidget {
  const ProducerTile({
    super.key,
    required this.name,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.verified,
    this.onTap,
  });

  final String name;
  final String distance;
  final String rating;
  final String reviews;
  final bool verified;
  final VoidCallback? onTap;

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
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.normal),
            border: Border.all(color: AppColors.background),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.background),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/farm.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.accent,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/farm_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.normalBold,
                          ),
                        ),
                        if (verified) ...<Widget>[
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            'assets/icons/seal-check-fill.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.accent,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons/star-fill.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.accent_2,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: AppTypography.caption,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($reviews)',
                          style: AppTypography.caption,
                        ),
                        // Don't show distance for now, as it's not implemented in the backend yet
                        // const SizedBox(width: 8),
                        // Text(
                        //   "•",
                        //   style: const TextStyle(
                        //     color: AppColors.textSecondary,
                        //     fontSize: 12,
                        //   ),
                        // ),
                        // const SizedBox(width: 8),
                        // Text(
                        //   distance,
                        //   style: const TextStyle(
                        //     color: AppColors.textSecondary,
                        //     fontSize: 12,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/caret-right.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
