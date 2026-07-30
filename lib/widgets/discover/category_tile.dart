import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.icon,
    required this.name,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String icon;
  final String name;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.accent : AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24, height: 1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(height: 1),
          ),
        ],
      ),
    );
  }
}
