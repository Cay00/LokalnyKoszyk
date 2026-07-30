import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.titleCount,
    this.actionLabel,
  });

  final String title;
  /// Liczba w nawiasie obok tytułu, kolorem [AppColors.textLight] (null = ukryj).
  final int? titleCount;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                title,
                style: AppTypography.header,
              ),
              if (titleCount != null)
                Text(
                  ' ($titleCount)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
            ],
          ),
        ),
        if (actionLabel != null)
          Row(
            children: <Widget>[
              Text(
                actionLabel!,
                style: AppTypography.caption,
              ),
              const SizedBox(width: 4),
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
      ],
    );
  }
}
