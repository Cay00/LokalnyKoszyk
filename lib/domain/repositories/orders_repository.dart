import 'package:lokalny_koszyk/domain/models/order_details.dart';
import 'package:lokalny_koszyk/domain/models/order_summary.dart';

abstract class OrdersRepository {
  Future<List<OrderSummary>> getOrdersForCurrentUser();

  Future<OrderDetails> getOrderDetails(String orderId);
}
