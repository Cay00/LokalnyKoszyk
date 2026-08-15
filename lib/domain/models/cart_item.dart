class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unit,
    required this.currency,
    required this.quantity,
    required this.price,
    this.sellerId,
    this.producer = 'Sprzedawca',
    this.unitKey,
    this.packageQuantity,
  });

  final String id;
  final String productId;
  final String name;
  final String unit;
  final String currency;
  final double quantity;
  final double price;
  final String? sellerId;
  final String producer;
  final String? unitKey;
  final double? packageQuantity;

  double get lineTotal => quantity * price;

  String get sellerKey {
    final id = sellerId?.trim() ?? '';
    if (id.isNotEmpty) return id;
    final name = producer.trim();
    return name.isEmpty ? 'Sprzedawca' : name;
  }

  String get sellerDisplayName {
    final name = producer.trim();
    return name.isEmpty ? 'Sprzedawca' : name;
  }
}
