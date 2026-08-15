import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/profile_bootstrap.dart';
import 'package:lokalny_koszyk/core/supabase/seller_public_lookup.dart';
import 'package:lokalny_koszyk/domain/models/cart_item.dart';
import 'package:lokalny_koszyk/domain/models/place_order_result.dart';
import 'package:lokalny_koszyk/domain/repositories/cart_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCartRepository implements CartRepository {
  const SupabaseCartRepository(this._supabase);

  final SupabaseClient _supabase;

  static const String _cartsTable = 'carts';
  static const String _cartItemsTable = 'cart_items';

  @override
  Future<void> addToCart({
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

    final user = _supabase.auth.currentUser;
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

  @override
  Future<List<CartItem>> getCartItemsForCurrentUser() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }

    final existingCart = await _supabase
        .from(_cartsTable)
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    final cartId = existingCart?['id']?.toString();
    if (cartId == null || cartId.isEmpty) {
      return const <CartItem>[];
    }

    final rows = await _supabase
        .from(_cartItemsTable)
        .select(
          'id, quantity, product_id, unit_price_gross, '
          'products(name, unit, currency, seller_id, package_size)',
        )
        .eq('cart_id', cartId)
        .order('id', ascending: true);

    final parsedRows = (rows as List<dynamic>)
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final sellerRawIds = <String>{};
    for (final map in parsedRows) {
      final productMap = map['products'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(map['products'] as Map);
      final raw = (productMap['seller_id'] ?? '').toString().trim();
      if (raw.isNotEmpty) sellerRawIds.add(raw);
    }
    final sellerByNorm = await fetchSellerPublicByIds(sellerRawIds);

    return parsedRows.map<CartItem>((Map<String, dynamic> map) {
      final productMap = map['products'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(map['products'] as Map);
      final quantity = (map['quantity'] as num?)?.toDouble() ?? 0;
      final unitGrosze = parsePennies(map['unit_price_gross']);
      final price = plnFromPennies(unitGrosze);
      final unit = (productMap['unit'] ?? '').toString();
      final currency = (productMap['currency'] ?? 'PLN').toString();
      final sellerIdRaw = (productMap['seller_id'] ?? '').toString().trim();
      final seller = sellerByNorm[normalizeUuidKey(sellerIdRaw)];
      final sellerName = (seller?.name.trim().isNotEmpty ?? false)
          ? seller!.name
          : 'Sprzedawca';
      final unitKey = unit.trim().toLowerCase();
      return CartItem(
        id: (map['id'] ?? '').toString(),
        productId: (map['product_id'] ?? '').toString(),
        name: (productMap['name'] ?? 'Produkt').toString(),
        unit: unit,
        currency: currency,
        quantity: quantity,
        price: price,
        sellerId: sellerIdRaw.isEmpty ? null : sellerIdRaw,
        producer: sellerName,
        unitKey: unitKey.isEmpty ? null : unitKey,
        packageQuantity: (productMap['package_size'] as num?)?.toDouble(),
      );
    }).toList();
  }

  @override
  Future<void> removeCartItem({required String cartItemId}) async {
    if (cartItemId.trim().isEmpty) {
      throw ArgumentError.value(cartItemId, 'cartItemId', 'Brak id pozycji koszyka.');
    }
    await _supabase.from(_cartItemsTable).delete().eq('id', cartItemId);
  }

  @override
  Future<PlaceOrderResult> placeOrderFromCurrentCart({required String status}) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }
    await ProfileBootstrap.ensureRowForAuthUser(user);

    final dynamic raw = await _supabase.rpc(
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

  Future<String> _getOrCreateCartIdForUser(String userId) async {
    final existingCart = await _supabase
        .from(_cartsTable)
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    final existingId = existingCart?['id']?.toString();
    if (existingId != null && existingId.isNotEmpty) return existingId;

    final inserted = await _supabase.from(_cartsTable).insert(<String, dynamic>{
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').single();
    final insertedId = inserted['id']?.toString();
    if (insertedId == null || insertedId.isEmpty) {
      throw StateError('Nie udało się utworzyć koszyka.');
    }
    return insertedId;
  }

  Future<void> _addOrIncreaseCartItem({
    required String cartId,
    required String productId,
    required int quantityToAdd,
  }) async {
    final existingRow = await _supabase
        .from(_cartItemsTable)
        .select('id, quantity')
        .eq('cart_id', cartId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existingRow == null) {
      final productRow = await _supabase
          .from('products')
          .select('price_gross_amount')
          .eq('product_id', productId)
          .maybeSingle();
      final unitGrosze = parsePennies(productRow?['price_gross_amount']);
      await _supabase.from(_cartItemsTable).insert(<String, dynamic>{
        'cart_id': cartId,
        'product_id': productId,
        'quantity': quantityToAdd,
        'unit_price_gross': unitGrosze,
      });
      return;
    }

    final rowId = existingRow['id'];
    final existingQuantity = (existingRow['quantity'] as num?)?.toInt() ?? 0;
    await _supabase.from(_cartItemsTable).update(<String, dynamic>{
      'quantity': existingQuantity + quantityToAdd,
    }).eq('id', rowId);
  }
}
