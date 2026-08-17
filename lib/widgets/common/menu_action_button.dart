import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';

class MenuActionButton extends StatelessWidget {
  const MenuActionButton({
    super.key,
    required this.iconAsset,
    required this.label,
    this.onTap,
    this.backgroundColor = AppColors.white,
  });

  static const double height = 66;
  static const double _circleSize = 50;
  static const double _circleInset = 8;
  static const double _iconSize = 24;
  static const double _trailingInset = 16;

  final String iconAsset;
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppRadius.normal),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.normal),
        child: SizedBox(
          height: height,
          child: Row(
            children: <Widget>[
              const SizedBox(width: _circleInset),
              Container(
                width: _circleSize,
                height: _circleSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconAsset,
                  width: _iconSize,
                  height: _iconSize,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: _circleInset),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.normal,
                ),
              ),
              SvgPicture.asset(
                'assets/icons/caret-right.svg',
                width: _iconSize,
                height: _iconSize,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: _trailingInset),
            ],
          ),
        ),
      ),
    );
  }
}
