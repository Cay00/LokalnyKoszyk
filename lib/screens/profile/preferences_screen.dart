import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/screen_header.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ScreenHeader(
          title: 'Moje preferencje',
          onBack: onBack,
        ),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Ustaw swoje preferencje zakupowe, aby lepiej dopasować oferty.',
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
