import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class BecomeSellerScreen extends StatelessWidget {
  const BecomeSellerScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: 'Zostań sprzedawcą',
          onBack: onBack,
        ),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Rozpocznij sprzedaż swoich produktów lokalnie. Wypełnij formularz, aby założyć konto sprzedawcy.',
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
