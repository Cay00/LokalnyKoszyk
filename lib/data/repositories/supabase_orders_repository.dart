import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/domain/models/order_details.dart';
import 'package:lokalny_koszyk/domain/models/order_summary.dart';
import 'package:lokalny_koszyk/domain/repositories/orders_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrdersRepository implements OrdersRepository {
  const SupabaseOrdersRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<OrderSummary>> getOrdersForCurrentUser() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }
    final rows = await _supabase
        .from('orders')
        .select('id, order_number, status, total_amount, currency, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>).map<OrderSummary>((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      return OrderSummary(
        id: (map['id'] ?? '').toString(),
        orderNumber: (map['order_number'] ?? '').toString(),
        rawStatus: (map['status'] ?? '').toString(),
        totalAmount: plnFromPennies(parsePennies(map['total_amount'])),
        currency: (map['currency'] ?? 'PLN').toString(),
        createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()),
      );
    }).toList();
  }

  @override
  Future<OrderDetails> getOrderDetails(String orderId) async {
    final userId = _supabase.auth.currentUser?.id;
    final orderRow = await _supabase
        .from('orders')
        .select('id, order_number, status, total_amount, currency')
        .eq('id', orderId)
        .maybeSingle();
    if (orderRow == null) {
      throw StateError('Nie znaleziono zamówienia.');
    }
    final orderMap = Map<String, dynamic>.from(orderRow as Map);

    final itemRows = await _supabase
        .from('order_items')
        .select('product_id, quantity, price, products(name, unit)')
        .eq('order_id', orderId);

    final productIds = <String>[];
    for (final dynamic row in itemRows as List<dynamic>) {
      final map = Map<String, dynamic>.from(row as Map);
      final pid = (map['product_id'] ?? '').toString().trim();
      if (pid.isNotEmpty) productIds.add(pid);
    }

    final ratingsByProduct = <String, ({int rating, String? comment})>{};
    if (userId != null && userId.isNotEmpty && productIds.isNotEmpty) {
      final reviewRows = await _supabase
          .from('reviews')
          .select('product_id, rating, comment')
          .eq('user_id', userId)
          .inFilter('product_id', productIds);
      for (final dynamic row in reviewRows as List<dynamic>) {
        final map = Map<String, dynamic>.from(row as Map);
        final pid = (map['product_id'] ?? '').toString();
        final rating = (map['rating'] as num?)?.toInt();
        if (pid.isEmpty || rating == null) continue;
        ratingsByProduct[pid] = (
          rating: rating,
          comment: map['comment']?.toString(),
        );
      }
    }

    final items = (itemRows as List<dynamic>).map<OrderDetailsItem>((
      dynamic row,
    ) {
      final map = Map<String, dynamic>.from(row as Map);
      final productMap = map['products'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(map['products'] as Map);
      final qty = (map['quantity'] as num?)?.toDouble() ?? 0;
      final unitPrice = plnFromPennies(parsePennies(map['price']));
      final productId = (map['product_id'] ?? '').toString();
      final existing = ratingsByProduct[productId];
      return OrderDetailsItem(
        productId: productId,
        name: (productMap['name'] ?? 'Produkt').toString(),
        quantity: qty,
        unit: (productMap['unit'] ?? '').toString(),
        lineTotal: unitPrice * qty,
        myRating: existing?.rating,
        myComment: existing?.comment,
      );
    }).toList();

    return OrderDetails(
      id: (orderMap['id'] ?? orderId).toString(),
      orderNumber: (orderMap['order_number'] ?? orderId).toString(),
      rawStatus: (orderMap['status'] ?? '').toString(),
      totalAmount: plnFromPennies(parsePennies(orderMap['total_amount'])),
      currency: (orderMap['currency'] ?? 'PLN').toString(),
      items: items,
    );
  }
}
