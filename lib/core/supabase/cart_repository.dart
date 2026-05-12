import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/profile_bootstrap.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';

class CartRepository {
  const CartRepository._();

  static const String _cartsTable = 'carts';
  static const String _cartItemsTable = 'cart_items';

  static Future<void> addToCart({
    required String productId,
    int quantityToAdd = 1,
  }) async {
    if (quantityToAdd <= 0) {
      throw ArgumentError.value(
        quantityToAdd,
        'quantityToAdd',
        'Ilość musi być większa od 0.',
      );
    }

    final user = supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }
    await ProfileBootstrap.ensureRowForAuthUser(user);

    final cartId = await _getOrCreateCartIdForUser(user.id);
    await _addOrIncreaseCartItem(
      cartId: cartId,
      productId: productId,
      quantityToAdd: quantityToAdd,
    );
  }

  static Future<List<CartItemData>> getCartItemsForCurrentUser() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }

    final existingCart = await supabase
        .from(_cartsTable)
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    final cartId = existingCart?['id']?.toString();
    if (cartId == null || cartId.isEmpty) {
      return const <CartItemData>[];
    }

    final rows = await supabase
        .from(_cartItemsTable)
        .select(
          'id, quantity, product_id, unit_price_gross, '
          'products(name, unit, currency)',
        )
        .eq('cart_id', cartId)
        .order('id', ascending: true);

    return (rows as List<dynamic>).map<CartItemData>((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      final productMap = map['products'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(map['products'] as Map);
      final quantity = (map['quantity'] as num?)?.toDouble() ?? 0;
      final unitGrosze = parsePennies(map['unit_price_gross']);
      final price = plnFromPennies(unitGrosze);
      final unit = (productMap['unit'] ?? '').toString();
      final currency = (productMap['currency'] ?? 'PLN').toString();
      return CartItemData(
        id: (map['id'] ?? '').toString(),
        productId: (map['product_id'] ?? '').toString(),
        name: (productMap['name'] ?? 'Produkt').toString(),
        unit: unit,
        currency: currency,
        quantity: quantity,
        price: price,
      );
    }).toList();
  }

  static Future<void> removeCartItem({
    required String cartItemId,
  }) async {
    if (cartItemId.trim().isEmpty) {
      throw ArgumentError.value(cartItemId, 'cartItemId', 'Brak id pozycji koszyka.');
    }
    await supabase.from(_cartItemsTable).delete().eq('id', cartItemId);
  }

  static Future<PlaceOrderResult> placeOrderFromCurrentCart({
    required String status,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }
    await ProfileBootstrap.ensureRowForAuthUser(user);

    final dynamic raw = await supabase.rpc(
      'place_order_from_cart',
      params: <String, dynamic>{'p_status': status},
    );
    if (raw is! Map) {
      throw StateError('Nie udało się złożyć zamówienia (brak odpowiedzi).');
    }
    final map = Map<String, dynamic>.from(raw);
    final orderId = (map['order_id'] ?? '').toString();
    if (orderId.isEmpty) {
      throw StateError('Nie udało się złożyć zamówienia.');
    }
    final orderNumber = (map['order_number'] ?? '').toString();
    final totalGrosze = (map['total_amount'] as num?)?.toInt() ?? 0;
    final currency = (map['currency'] ?? 'PLN').toString();

    return PlaceOrderResult(
      orderId: orderId,
      orderNumber: orderNumber,
      totalAmount: plnFromPennies(totalGrosze),
      currency: currency,
    );
  }

  static Future<String> _getOrCreateCartIdForUser(String userId) async {
    final existingCart = await supabase
        .from(_cartsTable)
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    final existingId = existingCart?['id']?.toString();
    if (existingId != null && existingId.isNotEmpty) return existingId;

    final inserted = await supabase.from(_cartsTable).insert(<String, dynamic>{
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').single();
    final insertedId = inserted['id']?.toString();
    if (insertedId == null || insertedId.isEmpty) {
      throw StateError('Nie udało się utworzyć koszyka.');
    }
    return insertedId;
  }

  static Future<void> _addOrIncreaseCartItem({
    required String cartId,
    required String productId,
    required int quantityToAdd,
  }) async {
    final existingRow = await supabase
        .from(_cartItemsTable)
        .select('id, quantity')
        .eq('cart_id', cartId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existingRow == null) {
      final productRow = await supabase
          .from('products')
          .select('price_gross_amount')
          .eq('product_id', productId)
          .maybeSingle();
      final unitGrosze = parsePennies(productRow?['price_gross_amount']);
      await supabase.from(_cartItemsTable).insert(<String, dynamic>{
        'cart_id': cartId,
        'product_id': productId,
        'quantity': quantityToAdd,
        'unit_price_gross': unitGrosze,
      });
      return;
    }

    final rowId = existingRow['id'];
    final existingQuantity = (existingRow['quantity'] as num?)?.toInt() ?? 0;
    await supabase.from(_cartItemsTable).update(<String, dynamic>{
      'quantity': existingQuantity + quantityToAdd,
    }).eq('id', rowId);
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
}
