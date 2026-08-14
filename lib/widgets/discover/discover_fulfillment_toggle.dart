import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/widgets/common/segmented_toggle.dart';

enum DiscoverFulfillmentMode { delivery, pickup }

class DiscoverFulfillmentToggle extends StatelessWidget {
  const DiscoverFulfillmentToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DiscoverFulfillmentMode value;
  final ValueChanged<DiscoverFulfillmentMode> onChanged;

  static const List<SegmentedToggleOption<DiscoverFulfillmentMode>> _options =
      <SegmentedToggleOption<DiscoverFulfillmentMode>>[
        SegmentedToggleOption<DiscoverFulfillmentMode>(
          value: DiscoverFulfillmentMode.delivery,
          label: 'Dostawa',
          iconAsset: 'assets/icons/package.svg',
        ),
        SegmentedToggleOption<DiscoverFulfillmentMode>(
          value: DiscoverFulfillmentMode.pickup,
          label: 'Odbiór',
          iconAsset: 'assets/icons/package.svg',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SegmentedToggle<DiscoverFulfillmentMode>(
      options: _options,
      value: value,
      onChanged: onChanged,
    );
  }
}
