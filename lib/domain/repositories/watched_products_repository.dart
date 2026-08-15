import 'package:lokalny_koszyk/domain/models/product.dart';

abstract class WatchedProductsRepository {
  bool get isUserSignedIn;

  Future<bool> isFavoriteForCurrentUser(String productId);

  Future<void> addFavoriteForCurrentUser(String productId);

  Future<void> removeFavoriteForCurrentUser(String productId);

  Future<List<Product>> fetchProductsForCurrentUser();
}
