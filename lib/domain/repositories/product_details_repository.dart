abstract class ProductDetailsRepository {
  bool get isUserSignedIn;

  Future<bool> isFavoriteForCurrentUser(String productId);

  Future<bool> toggleFavoriteForCurrentUser({
    required String productId,
    required bool currentlyFavorite,
  });

  Future<String?> resolveSellerName({
    required String productId,
    required String? sellerId,
    required String currentProducerLabel,
  });

  Future<void> addToCart({
    required String productId,
    required int quantityToAdd,
  });
}
