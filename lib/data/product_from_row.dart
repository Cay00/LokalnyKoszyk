import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';

Product productFromSupabaseRow(
  Map<String, dynamic> map, {
  required String producer,
  String? sellerId,
  String distance = '',
  double? distanceMeters,
}) {
  final sellerIdRaw = (sellerId ?? map['seller_id'] ?? '').toString().trim();
  final rawCategoryId = map['category_id']?.toString().trim();
  final rawUnit = (map['unit'] ?? '').toString();
  final unitKey = rawUnit.trim().toLowerCase();
  final ratingNum = (map['average_rating'] as num?)?.toDouble() ?? 0;
  final reviewsCount = (map['reviews_count'] as num?)?.toInt() ?? 0;

  return Product(
    id: (map['product_id'] ?? '').toString(),
    name: (map['name'] ?? 'Produkt').toString(),
    producer: producer,
    price: plnCommaStringFromPennies(parsePennies(map['price_gross_amount'])),
    unit: '/ ${rawUnit.replaceAll('_', ' ')}',
    distance: distance,
    distanceMeters: distanceMeters,
    rating: ratingNum.toStringAsFixed(1),
    reviews: reviewsCount.toString(),
    sellerId: sellerIdRaw.isEmpty ? null : sellerIdRaw,
    unitKey: unitKey.isEmpty ? null : unitKey,
    packageQuantity: (map['package_size'] as num?)?.toDouble(),
    categoryId: rawCategoryId == null || rawCategoryId.isEmpty
        ? null
        : rawCategoryId,
  );
}
