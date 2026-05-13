import 'package:lokalny_koszyk/presentation/models/product_ui_model.dart';

class FavoriteProductUiModel {
  const FavoriteProductUiModel({
    required this.product,
    required this.sellerVerified,
  });

  final ProductUiModel product;
  final bool sellerVerified;
}
