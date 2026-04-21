import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Wiadomości',
      message: 'Nie masz jeszcze żadnych wiadomości.',
      onBack: onBack,
    );
  }
}
