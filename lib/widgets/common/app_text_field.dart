import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';

class AppTextField extends StatefulWidget {
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
    this.obscureText = false,
    this.inputFormatters,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final bool isPassword = widget.obscureText;
    final bool obscure = isPassword && _obscured;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.label, style: AppTypography.caption),
          const SizedBox(height: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.normal),
            ),
            child: TextField(
              controller: widget.controller,
              maxLines: isPassword ? 1 : widget.maxLines,
              enabled: widget.enabled,
              obscureText: obscure,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              onChanged: widget.onChanged,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              style: AppTypography.normal,
              cursorColor: AppColors.textPrimary,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.normal.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        onPressed: () =>
                            setState(() => _obscured = !_obscured),
                        icon: SvgPicture.asset(
                          _obscured
                              ? 'assets/icons/eye-slash.svg'
                              : 'assets/icons/eye.svg',
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
