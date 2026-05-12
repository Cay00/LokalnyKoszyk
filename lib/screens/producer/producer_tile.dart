import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';

class ProducerTile extends StatelessWidget {
  const ProducerTile({
    super.key,
    required this.name,
    this.subtitle,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.verified,
    this.onTap,
  });

  final String name;
  /// Druga linia pod nazwą (np. UUID lub krótka wskazówka), opcjonalnie.
  final String? subtitle;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.normal),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
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
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/farm_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (verified) ...<Widget>[
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            'assets/icons/seal-check-fill.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                          height: 1.25,
                        ),
                      ),
                    ],
                    Row(
                      children: <Widget>[
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
                          rating,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($reviews)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        // Don't show distance for now, as it's not implemented in the backend yet
                        // const SizedBox(width: 8),
                        // Text(
                        //   "•",
                        //   style: const TextStyle(
                        //     color: AppColors.textLight,
                        //     fontSize: 12,
                        //   ),
                        // ),
                        // const SizedBox(width: 8),
                        // Text(
                        //   distance,
                        //   style: const TextStyle(
                        //     color: AppColors.textLight,
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
    );
  }
}
