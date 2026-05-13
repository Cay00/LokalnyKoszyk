import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/place_order_result.dart';

abstract class CartRepository {
  Future<void> addToCart({
    required String productId,
    int quantityToAdd = 1,
  });

  Future<List<CartItem>> getCartItemsForCurrentUser();

  Future<void> removeCartItem({
    required String cartItemId,
  });

  Future<PlaceOrderResult> placeOrderFromCurrentCart({
    required String status,
  });
}
