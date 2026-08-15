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
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.textTertiary,
          disabledForegroundColor: AppColors.textPrimary,
          shape: const StadiumBorder(),
          padding: EdgeInsets.zero,
          elevation: 0,
          overlayColor: Colors.transparent,
          shadowColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textTertiary;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentAction;
            }
            return AppColors.accent;
          }),
        ),
        child: Text(
          label,
          style: AppTypography.header.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
