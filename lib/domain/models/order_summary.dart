class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.rawStatus,
    required this.totalAmount,
    required this.currency,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String rawStatus;
  final double totalAmount;
  final String currency;
  final DateTime? createdAt;
}
