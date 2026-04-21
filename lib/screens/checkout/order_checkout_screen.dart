import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class OrderCheckoutScreen extends StatelessWidget {
  const OrderCheckoutScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: 'Moje zamówienie',
          onBack: onBack,
        ),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Tutaj będzie podsumowanie i finalizacja zamówienia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
