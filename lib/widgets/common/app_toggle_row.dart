import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';

/// Wiersz Tak/Nie w stylu aplikacji (biała karta + segmenty).
class AppToggleRow extends StatelessWidget {
  const AppToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.normal),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: AppTypography.normal)),
              _YesNoToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _YesNoToggle extends StatelessWidget {
  const _YesNoToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Chip(
              label: 'Nie',
              selected: !value,
              onTap: () => onChanged(false),
            ),
            _Chip(
              label: 'Tak',
              selected: value,
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        splashFactory: NoSplash.splashFactory,
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(label, style: AppTypography.caption),
            ),
          ),
        ),
      ),
    );
  }
}

class AppCheckTile extends StatelessWidget {
  const AppCheckTile({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.normal),
        child: InkWell(
          onTap: () => onChanged(!checked),
          borderRadius: BorderRadius.circular(AppRadius.normal),
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                SvgPicture.asset(
                  checked
                      ? 'assets/icons/check-square-fill.svg'
                      : 'assets/icons/square.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    checked ? AppColors.accentAction : AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: AppTypography.normal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSelectTile<T> extends StatelessWidget {
  const AppSelectTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
    this.subtitle,
  });

  final T value;
  final T groupValue;
  final String label;
  final String? subtitle;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.normal),
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(AppRadius.normal),
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.accent : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? AppColors.accentAction
                          : AppColors.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Center(
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label, style: AppTypography.normalBold),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!, style: AppTypography.caption),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
