import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/theme/app_theme.dart';

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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 68),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? AppColors.primaryLight : AppColors.border,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: active ? const Color(0x401C3A2A) : const Color(0x12000000),
              blurRadius: active ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color:
                    active ? AppColors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count prod.',
              style: TextStyle(
                fontSize: 10,
                color:
                    active ? AppColors.textOnDark : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
