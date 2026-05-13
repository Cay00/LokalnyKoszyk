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
        .select('quantity, price, products(name, unit)')
        .eq('order_id', orderId);
    final items = (itemRows as List<dynamic>).map<OrderDetailsItem>((
      dynamic row,
    ) {
      final map = Map<String, dynamic>.from(row as Map);
      final productMap = map['products'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(map['products'] as Map);
      final qty = (map['quantity'] as num?)?.toDouble() ?? 0;
      final unitPrice = plnFromPennies(parsePennies(map['price']));
      return OrderDetailsItem(
        name: (productMap['name'] ?? 'Produkt').toString(),
        quantity: qty,
        unit: (productMap['unit'] ?? '').toString(),
        lineTotal: unitPrice * qty,
      );
    }).toList();

    return OrderDetails(
      orderNumber: (orderMap['order_number'] ?? orderId).toString(),
      rawStatus: (orderMap['status'] ?? '').toString(),
      totalAmount: plnFromPennies(parsePennies(orderMap['total_amount'])),
      currency: (orderMap['currency'] ?? 'PLN').toString(),
      items: items,
    );
  }
}
