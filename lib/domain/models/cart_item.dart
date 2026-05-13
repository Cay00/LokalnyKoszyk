class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unit,
    required this.currency,
    required this.quantity,
    required this.price,
  });

  final String id;
  final String productId;
  final String name;
  final String unit;
  final String currency;
  final double quantity;
  final double price;

  double get lineTotal => quantity * price;
}
