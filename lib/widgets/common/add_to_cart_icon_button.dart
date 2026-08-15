import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/themes/app_theme.dart';

class AddToCartIconButton extends StatefulWidget {
  const AddToCartIconButton({
    super.key,
    this.onPressed,
  });

  static const double size = 38;
  static const double iconSize = 24;

  final VoidCallback? onPressed;

  @override
  State<AddToCartIconButton> createState() => _AddToCartIconButtonState();
}

class _AddToCartIconButtonState extends State<AddToCartIconButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    return Listener(
      onPointerDown: enabled ? (_) => _setPressed(true) : null,
      onPointerUp: enabled ? (_) => _setPressed(false) : null,
      onPointerCancel: enabled ? (_) => _setPressed(false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: AddToCartIconButton.size,
          height: AddToCartIconButton.size,
          decoration: BoxDecoration(
            color: _pressed ? AppColors.accentAction : AppColors.accent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icons/basket.svg',
            width: AddToCartIconButton.iconSize,
            height: AddToCartIconButton.iconSize,
            colorFilter: const ColorFilter.mode(
              AppColors.textPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
