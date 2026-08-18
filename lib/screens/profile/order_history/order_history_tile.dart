import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/themes/app_theme.dart';

class OrderHistoryTile extends StatelessWidget {
  const OrderHistoryTile({
    super.key,
    required this.orderNumber,
    required this.status,
    required this.date,
    required this.total,
    this.onTap,
  });

  final String orderNumber;
  final String status;
  final String date;
  final String total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.normal),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.normal),
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Zamówienie $orderNumber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.header,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/caret-right.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textSecondary),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(status, style: AppTypography.caption),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Text(date, style: AppTypography.caption),
                    const Spacer(),
                    Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Razem z dostawą: ',
                            style: AppTypography.caption,
                          ),
                          TextSpan(
                            text: total,
                            style: AppTypography.header,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
