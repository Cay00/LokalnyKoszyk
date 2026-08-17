import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Ustawienia',
      message: 'Ustaw swoje preferencje zakupowe, aby lepiej dopasować oferty.',
      onBack: onBack,
    );
  }
}
