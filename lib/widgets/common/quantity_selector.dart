import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    this.onIncrease,
    this.onDecrease,
    this.minQuantity = 1,
    this.maxQuantity = 99,
  });

  static const double buttonSize = 50;
  static const double iconSize = 22;
  static const double quantityWidth = 40;

  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final int minQuantity;
  final int maxQuantity;

  @override
  Widget build(BuildContext context) {
    final bool canDecrease = onDecrease != null && quantity > minQuantity;
    final bool canIncrease = onIncrease != null && quantity < maxQuantity;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _QuantityCircleButton(
          icon: Icons.remove,
          filled: false,
          onPressed: canDecrease ? onDecrease : null,
        ),
        SizedBox(
          width: quantityWidth,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: AppTypography.header,
          ),
        ),
        _QuantityCircleButton(
          icon: Icons.add,
          filled: true,
          onPressed: canIncrease ? onIncrease : null,
        ),
      ],
    );
  }
}

class _QuantityCircleButton extends StatelessWidget {
  const _QuantityCircleButton({
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: QuantitySelector.buttonSize,
      height: QuantitySelector.buttonSize,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: filled
              ? AppColors.textTertiary
              : Colors.transparent,
          disabledForegroundColor: filled
              ? AppColors.textSecondary
              : AppColors.textTertiary,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 0,
          overlayColor: Colors.transparent,
          shadowColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(
          side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (filled) {
              return BorderSide.none;
            }
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: AppColors.textTertiary);
            }
            return const BorderSide(color: AppColors.textPrimary);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            if (!filled) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.textTertiary;
              }
              return Colors.transparent;
            }
            if (states.contains(WidgetState.disabled)) {
              return AppColors.textTertiary;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentAction;
            }
            return AppColors.accent;
          }),
        ),
        child: Icon(
          icon,
          size: QuantitySelector.iconSize,
          color: onPressed != null
              ? AppColors.textPrimary
              : filled
              ? AppColors.textSecondary
              : AppColors.textTertiary,
        ),
      ),
    );
  }
}
