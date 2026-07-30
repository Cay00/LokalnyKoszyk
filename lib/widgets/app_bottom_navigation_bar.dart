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

  static const List<({String assetPath, String label})> _navItems = [
    (assetPath: 'assets/icons/barn.svg', label: 'Sklep'),
    (assetPath: 'assets/icons/basket.svg', label: 'Koszyk'),
    (assetPath: 'assets/icons/heart.svg', label: 'Ulubione'),
    (assetPath: 'assets/icons/user.svg', label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: _navItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: _BottomNavItemVisual(
                assetPath: item.assetPath,
                label: item.label,
                isActive: false,
              ),
              activeIcon: _BottomNavItemVisual(
                assetPath: item.assetPath,
                label: item.label,
                isActive: true,
              ),
              label: '',
            ),
          )
          .toList(),
    );
  }
}

class _BottomNavItemVisual extends StatelessWidget {
  const _BottomNavItemVisual({
    required this.assetPath,
    required this.label,
    required this.isActive,
  });

  final String assetPath;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isActive ? AppColors.white : AppColors.textOnDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        SvgPicture.asset(
          assetPath,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: itemColor,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 4),
          child: Container(
            height: 2,
            width: 16,
            color: isActive ? AppColors.white : Colors.transparent,
          ),
        ),
      ],
    );
  }
}
