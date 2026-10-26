import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.normal),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              enabled: enabled,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              onChanged: onChanged,
              style: AppTypography.normal,
              cursorColor: AppColors.textPrimary,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.normal.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
