import 'package:lokalny_koszyk/domain/models/product.dart';

class ProductDto {
  const ProductDto({
    required this.id,
    required this.name,
    required this.producer,
    required this.price,
    required this.unit,
    required this.distance,
    required this.season,
    required this.rating,
    required this.reviews,
    this.sellerId,
    this.unitKey,
    this.packageQuantity,
    this.categoryId,
  });

  factory ProductDto.fromSupabaseJson(Map<String, dynamic> json) {
    return ProductDto(
      id: (json['product_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      producer: (json['producer'] ?? '').toString(),
      price: (json['price'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      distance: (json['distance'] ?? '').toString(),
      season: (json['season'] ?? '').toString(),
      rating: (json['rating'] ?? '').toString(),
      reviews: (json['reviews'] ?? '').toString(),
      sellerId: json['seller_id']?.toString(),
      unitKey: json['unit_key']?.toString(),
      packageQuantity: (json['package_quantity'] as num?)?.toDouble(),
      categoryId: json['category_id']?.toString(),
    );
  }

  final String id;
  final String name;
  final String producer;
  final String price;
  final String unit;
  final String distance;
  final String season;
  final String rating;
  final String reviews;
  final String? sellerId;
  final String? unitKey;
  final double? packageQuantity;
  final String? categoryId;

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      producer: producer,
      price: price,
      unit: unit,
      distance: distance,
      season: season,
      rating: rating,
      reviews: reviews,
      sellerId: sellerId,
      unitKey: unitKey,
      packageQuantity: packageQuantity,
      categoryId: categoryId,
    );
  }
}
