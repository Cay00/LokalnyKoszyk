import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_cart_repository.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/place_order_result.dart' as domain;

class CartRepository {
  const CartRepository._();
  static final SupabaseCartRepository _impl = SupabaseCartRepository(supabase);

  static Future<void> addToCart({
    required String productId,
    int quantityToAdd = 1,
  }) => _impl.addToCart(productId: productId, quantityToAdd: quantityToAdd);

  static Future<List<CartItemData>> getCartItemsForCurrentUser() async {
    final items = await _impl.getCartItemsForCurrentUser();
    return items.map(CartItemData.fromDomain).toList();
  }

  static Future<void> removeCartItem({
    required String cartItemId,
  }) => _impl.removeCartItem(cartItemId: cartItemId);

  static Future<PlaceOrderResult> placeOrderFromCurrentCart({
    required String status,
  }) async {
    final result = await _impl.placeOrderFromCurrentCart(status: status);
    return PlaceOrderResult.fromDomain(result);
  }
}

class CartItemData {
  const CartItemData({
    required this.id,
    required this.productId,
    required this.name,
    required this.unit,
    required this.currency,
    required this.quantity,
    required this.price,
  });

  final String id;
  final String productId;
  final String name;
  final String unit;
  final String currency;
  final double quantity;
  final double price;

  double get lineTotal => quantity * price;

  factory CartItemData.fromDomain(CartItem item) {
    return CartItemData(
      id: item.id,
      productId: item.productId,
      name: item.name,
      unit: item.unit,
      currency: item.currency,
      quantity: item.quantity,
      price: item.price,
    );
  }
}

class PlaceOrderResult {
  const PlaceOrderResult({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.currency,
  });

  final String orderId;
  final String orderNumber;
  final double totalAmount;
  final String currency;

  factory PlaceOrderResult.fromDomain(domain.PlaceOrderResult result) {
    return PlaceOrderResult(
      orderId: result.orderId,
      orderNumber: result.orderNumber,
      totalAmount: result.totalAmount,
      currency: result.currency,
    );
  }
}
