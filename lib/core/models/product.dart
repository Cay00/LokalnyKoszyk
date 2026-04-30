enum ProductUnit {
  piece,
  kilogram,
  gram,
  liter,
  milliliter,
}

enum Currency {
  pln,
}

class Product {
  const Product({
    required this.productId,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.isProcessed,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.productImage,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.currency,
    required this.stockQuantity,
    this.ingredients = const [],
    this.storageCondition,
    this.averageRating = 0,
    this.reviewsCount = 0,
    this.tags = const [],
  });

  // UUID represented as String.
  final String productId;
  final String sellerId;
  final String name;
  final String description;
  final String categoryId;
  final bool isProcessed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String productImage;
  final double price;
  final ProductUnit unit;
  final double quantity;
  final Currency currency;
  final double stockQuantity;
  final List<ProductIngredient> ingredients;
  final StorageCondition? storageCondition;
  final double averageRating;
  final int reviewsCount;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'is_processed': isProcessed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'product_image': productImage,
      'price': price,
      'unit': unit.name,
      'quantity': quantity,
      'currency': currency.name.toUpperCase(),
      'stock_quantity': stockQuantity,
      'ingredients': ingredients.map((item) => item.toJson()).toList(),
      'storage_condition': storageCondition?.toJson(),
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'tags': tags,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final unitValue = (json['unit'] as String?) ?? ProductUnit.piece.name;
    final currencyValue = (json['currency'] as String?) ?? Currency.pln.name;

    return Product(
      productId: json['product_id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      isProcessed: json['is_processed'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isActive: json['is_active'] as bool? ?? true,
      productImage: json['product_image'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unit: ProductUnit.values.firstWhere(
        (value) => value.name == unitValue,
        orElse: () => ProductUnit.piece,
      ),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      currency: Currency.values.firstWhere(
        (value) => value.name.toUpperCase() == currencyValue.toUpperCase(),
        orElse: () => Currency.pln,
      ),
      stockQuantity: (json['stock_quantity'] as num?)?.toDouble() ?? 0,
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((item) =>
              ProductIngredient.fromJson(item as Map<String, dynamic>))
          .toList(),
      storageCondition: json['storage_condition'] == null
          ? null
          : StorageCondition.fromJson(
              json['storage_condition'] as Map<String, dynamic>,
            ),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class ProductIngredient {
  const ProductIngredient({
    required this.description,
    required this.isAllergen,
    this.allergenDescription,
  });

  final String description;
  final bool isAllergen;
  final String? allergenDescription;

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'is_allergen': isAllergen,
      'allergen_description': allergenDescription,
    };
  }

  factory ProductIngredient.fromJson(Map<String, dynamic> json) {
    return ProductIngredient(
      description: json['description'] as String? ?? '',
      isAllergen: json['is_allergen'] as bool? ?? false,
      allergenDescription: json['allergen_description'] as String?,
    );
  }
}

class StorageCondition {
  const StorageCondition({
    required this.storageConditionId,
    required this.name,
  });

  final String storageConditionId;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'storage_condition_id': storageConditionId,
      'name': name,
    };
  }

  factory StorageCondition.fromJson(Map<String, dynamic> json) {
    return StorageCondition(
      storageConditionId: json['storage_condition_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
