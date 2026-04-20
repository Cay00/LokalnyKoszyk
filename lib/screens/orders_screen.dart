import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Zamowienia',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
