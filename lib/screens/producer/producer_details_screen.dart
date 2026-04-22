import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class ProducerDetailsScreen extends StatelessWidget {
  const ProducerDetailsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Producent',
      message: 'Nie znaleziono producenta.',
      onBack: onBack,
    );
  }
}
