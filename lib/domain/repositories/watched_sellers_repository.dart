import 'package:lokalny_koszyk/domain/models/favorite_seller.dart';

abstract class WatchedSellersRepository {
  bool get isUserSignedIn;

  Future<bool> isFavoriteForCurrentUser(String sellerId);

  Future<void> addFavoriteForCurrentUser(String sellerId);

  Future<void> removeFavoriteForCurrentUser(String sellerId);

  Future<List<FavoriteSeller>> fetchSellersForCurrentUser();
}
