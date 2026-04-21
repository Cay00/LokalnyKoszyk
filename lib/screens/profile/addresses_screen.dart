import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Adresy dostawy',
      message: 'Nie masz jeszcze zapisanych adresów dostawy.',
      onBack: onBack,
    );
  }
}
