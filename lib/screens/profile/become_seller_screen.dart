import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class BecomeSellerScreen extends StatelessWidget {
  const BecomeSellerScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Zostań sprzedawcą',
      message:
          'Rozpocznij sprzedaż swoich produktów lokalnie. Wypełnij formularz, aby założyć konto sprzedawcy.',
      onBack: onBack,
    );
  }
}
