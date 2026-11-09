class OrderDetails {
  const OrderDetails({
    required this.id,
    required this.orderNumber,
    required this.rawStatus,
    required this.totalAmount,
    required this.currency,
    required this.items,
  });

  final String id;
  final String orderNumber;
  final String rawStatus;
  final double totalAmount;
  final String currency;
  final List<OrderDetailsItem> items;

  bool get canLeaveReviews =>
      rawStatus == 'delivered' || rawStatus == 'received';
}

class OrderDetailsItem {
  const OrderDetailsItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.lineTotal,
    this.myRating,
    this.myComment,
  });

  final String productId;
  final String name;
  final double quantity;
  final String unit;
  final double lineTotal;
  final int? myRating;
  final String? myComment;

  bool get hasReview => myRating != null && myRating! >= 1;
}
