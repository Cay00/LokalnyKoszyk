class Product {
  const Product({
    required this.id,
    required this.name,
    required this.producer,
    required this.price,
    required this.unit,
    required this.distance,
    required this.rating,
    required this.reviews,
    this.sellerId,
    this.unitKey,
    this.packageQuantity,
    this.categoryId,
  });

  final String id;
  final String name;
  final String producer;
  final String price;
  final String unit;
  final String distance;
  final String rating;
  final String reviews;
  final String? sellerId;
  final String? unitKey;
  final double? packageQuantity;
  final String? categoryId;
}
