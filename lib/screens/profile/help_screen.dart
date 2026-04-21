import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Pomoc i FAQ',
      message: 'Nie znaleziono artykułów pomocy. Wróć później.',
      onBack: onBack,
    );
  }
}
