import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';

class SegmentedToggleOption<T> {
  const SegmentedToggleOption({
    required this.value,
    required this.label,
    this.iconAsset,
  });

  final T value;
  final String label;
  final String? iconAsset;
}

class SegmentedToggle<T> extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<SegmentedToggleOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(27)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              for (final SegmentedToggleOption<T> option in options)
                Expanded(
                  child: _SegmentedToggleButton(
                    label: option.label,
                    iconAsset: option.iconAsset,
                    selected: value == option.value,
                    onTap: () => onChanged(option.value),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedToggleButton extends StatelessWidget {
  const _SegmentedToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconAsset,
  });

  final String label;
  final String? iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.background : Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (iconAsset != null) ...<Widget>[
                SvgPicture.asset(
                  iconAsset!,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTypography.normal),
            ],
          ),
        ),
      ),
    );
  }
}
