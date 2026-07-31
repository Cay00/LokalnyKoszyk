import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';

class DiscoverSortFilterBar extends StatelessWidget {
  const DiscoverSortFilterBar({
    super.key,
    this.onSortTap,
    this.onFilterTap,
  });

  final VoidCallback? onSortTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ActionButton(
              label: 'Sortuj',
              iconAsset: 'assets/icons/arrows-down-up.svg',
              onTap: onSortTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: 'Filtruj',
              iconAsset: 'assets/icons/funnel.svg',
              onTap: onFilterTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.iconAsset,
    this.onTap,
  });

  final String label;
  final String iconAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgPicture.asset(
                iconAsset,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(label, style: AppTypography.normal),
            ],
          ),
        ),
      ),
    );
  }
}
