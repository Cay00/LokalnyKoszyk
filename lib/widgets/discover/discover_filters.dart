import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class DiscoverFilters extends StatelessWidget {
  const DiscoverFilters({
    super.key,
    required this.filters,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
          ...filters.map((String filter) {
            final bool isActive = activeFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () => onFilterSelected(filter),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      isActive ? AppColors.accent : Colors.white,
                  side: BorderSide(
                    color: isActive
                        ? AppColors.accent
                        : AppColors.background,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: isActive
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
