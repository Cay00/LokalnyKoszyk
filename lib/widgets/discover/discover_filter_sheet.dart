import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/presentation/discover_bloc.dart';
import 'package:lokalny_koszyk/widgets/app_bottom_navigation_bar.dart';
import 'package:lokalny_koszyk/widgets/common/app_toggle_row.dart';
import 'package:lokalny_koszyk/widgets/common/primary_action_button.dart';

Future<({DiscoverPriceFilter price, DiscoverSortOption sort})?>
showDiscoverFilterSheet({
  required BuildContext context,
  required DiscoverPriceFilter priceFilter,
  required DiscoverSortOption sortOption,
}) {
  return showModalBottomSheet<
    ({DiscoverPriceFilter price, DiscoverSortOption sort})
  >(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return _DiscoverFilterSheetBody(
        initialPrice: priceFilter,
        initialSort: sortOption,
      );
    },
  );
}

class _DiscoverFilterSheetBody extends StatefulWidget {
  const _DiscoverFilterSheetBody({
    required this.initialPrice,
    required this.initialSort,
  });

  final DiscoverPriceFilter initialPrice;
  final DiscoverSortOption initialSort;

  @override
  State<_DiscoverFilterSheetBody> createState() =>
      _DiscoverFilterSheetBodyState();
}

class _DiscoverFilterSheetBodyState extends State<_DiscoverFilterSheetBody> {
  late DiscoverPriceFilter _price = widget.initialPrice;
  late DiscoverSortOption _sort = widget.initialSort;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.85;
    // Bottom nav jest w Stack nad treścią — sheet musi zostawić mu miejsce.
    final bottomClearance = AppBottomNavigationBar.contentBottomPadding(context);

    return SizedBox(
      height: maxHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomClearance),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filtrowanie i sortowanie', style: AppTypography.header),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Text('Cena', style: AppTypography.normalBold),
                  const SizedBox(height: 8),
                  ...DiscoverPriceFilter.values.map((
                    DiscoverPriceFilter filter,
                  ) {
                    return AppSelectTile<DiscoverPriceFilter>(
                      value: filter,
                      groupValue: _price,
                      label: filter.label,
                      onChanged: (DiscoverPriceFilter v) {
                        setState(() => _price = v);
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                  Text('Sortowanie', style: AppTypography.normalBold),
                  const SizedBox(height: 8),
                  ...DiscoverSortOption.values.map((
                    DiscoverSortOption option,
                  ) {
                    return AppSelectTile<DiscoverSortOption>(
                      value: option,
                      groupValue: _sort,
                      label: option.label,
                      onChanged: (DiscoverSortOption v) {
                        setState(() => _sort = v);
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PrimaryActionButton(
              label: 'Zastosuj',
              onPressed: () {
                Navigator.of(context).pop((price: _price, sort: _sort));
              },
            ),
          ],
        ),
      ),
    );
  }
}
