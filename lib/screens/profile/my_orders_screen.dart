import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Moje zamówienia',
      message: 'Nie masz jeszcze żadnych zamówień.',
      onBack: onBack,
    );
  }
}
