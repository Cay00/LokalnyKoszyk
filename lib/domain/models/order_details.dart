class OrderDetails {
  const OrderDetails({
    required this.orderNumber,
    required this.rawStatus,
    required this.totalAmount,
    required this.currency,
    required this.items,
  });

  final String orderNumber;
  final String rawStatus;
  final double totalAmount;
  final String currency;
  final List<OrderDetailsItem> items;
}

class OrderDetailsItem {
  const OrderDetailsItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.lineTotal,
  });

  final String name;
  final double quantity;
  final String unit;
  final double lineTotal;
}
