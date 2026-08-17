import 'package:flutter/material.dart';
import '../../widgets/common/default_screen.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({
    super.key,
    this.onBack,
  });

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      title: 'Moje opinie',
      message: 'Nie masz jeszcze żadnych opinii.',
      onBack: onBack,
    );
  }
}
