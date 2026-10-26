import 'package:flutter/material.dart';

import 'package:lokalny_koszyk/screens/profile/seller/seller_product_form_screen.dart';

/// Kompatybilność wsteczna — formularz ogłoszenia jest w [SellerProductFormScreen].
class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SellerProductFormScreen(
      onBack: () => Navigator.of(context).pop(),
    );
  }
}
