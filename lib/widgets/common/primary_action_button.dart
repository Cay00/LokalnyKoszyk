import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.normal),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTypography.header.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
