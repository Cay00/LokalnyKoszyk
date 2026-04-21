import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: 'Metody płatnosci',
          onBack: onBack,
        ),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Nie masz jeszcze dodanych metod płatnosci.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
