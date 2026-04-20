import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.placeholder,
    this.trailing,
  });

  final String placeholder;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.normal),
        border: Border.all(color: AppColors.border,),
      ),
      child: Row(
        children: <Widget>[
          const Opacity(
            opacity: 0.4,
            child: Text('🔍', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              placeholder,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSearchBar(
      placeholder: 'Szukaj produktów...',
    );
  }
}
