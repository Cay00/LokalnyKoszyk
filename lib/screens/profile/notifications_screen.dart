import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Powiadomienia',
      message: 'Nie masz jeszcze żadnych powiadomień.',
      onBack: onBack,
    );
  }
}
