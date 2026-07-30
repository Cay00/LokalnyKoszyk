import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double height = 60;
  static const double outerPadding = 16;

  /// Dolny clearance treści przy wiszącym barze: 16 + wysokość + 16 (+ safe area).
  static double contentBottomPadding(BuildContext context) {
    return outerPadding +
        height +
        outerPadding +
        MediaQuery.viewPaddingOf(context).bottom;
  }

  static const List<({String assetPath, String label})> _navItems = [
    (assetPath: 'assets/icons/house.svg', label: 'Sklep'),
    (assetPath: 'assets/icons/basket.svg', label: 'Koszyk'),
    (assetPath: 'assets/icons/heart.svg', label: 'Ulubione'),
    (assetPath: 'assets/icons/user.svg', label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        outerPadding,
        0,
        outerPadding,
        outerPadding + bottomInset,
      ),
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                for (int i = 0; i < _navItems.length; i++)
                  Expanded(
                    child: _BottomNavItem(
                      assetPath: _navItems[i].assetPath,
                      label: _navItems[i].label,
                      isActive: currentIndex == i,
                      onTap: () => onTap(i),
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

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.assetPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.accent : Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                assetPath,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(height: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
