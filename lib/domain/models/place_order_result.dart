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
