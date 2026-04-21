import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Metody płatnosci',
      message: 'Nie masz jeszcze dodanych metod płatnosci.',
      onBack: onBack,
    );
  }
}
