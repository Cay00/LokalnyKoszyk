import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';

enum DiscoverFulfillmentMode { delivery, pickup }

class DiscoverFulfillmentToggle extends StatelessWidget {
  const DiscoverFulfillmentToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DiscoverFulfillmentMode value;
  final ValueChanged<DiscoverFulfillmentMode> onChanged;

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
              Expanded(
                child: _FulfillmentButton(
                  label: 'Dostawa',
                  selected: value == DiscoverFulfillmentMode.delivery,
                  onTap: () => onChanged(DiscoverFulfillmentMode.delivery),
                ),
              ),
              Expanded(
                child: _FulfillmentButton(
                  label: 'Odbiór',
                  selected: value == DiscoverFulfillmentMode.pickup,
                  onTap: () => onChanged(DiscoverFulfillmentMode.pickup),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FulfillmentButton extends StatelessWidget {
  const _FulfillmentButton({
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
              SvgPicture.asset(
                'assets/icons/package.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(label, style: AppTypography.normal),
            ],
          ),
        ),
      ),
    );
  }
}
