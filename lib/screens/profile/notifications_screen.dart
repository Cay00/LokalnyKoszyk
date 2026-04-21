import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: 'Powiadomienia',
          onBack: onBack,
        ),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Nie masz jeszcze żadnych powiadomień.',
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
