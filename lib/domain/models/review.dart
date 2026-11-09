class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.orderId,
  });

  final String id;
  final String productId;
  final String productName;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final String? orderId;
}
