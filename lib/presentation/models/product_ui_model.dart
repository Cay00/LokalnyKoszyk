import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/formatting/product_price_per_label.dart';

class ProductUiModel {
  const ProductUiModel({
    required this.id,
    required this.name,
    required this.producer,
    required this.price,
    required this.unit,
    required this.distance,
    required this.season,
    required this.rating,
    required this.reviews,
    required this.emoji,
    required this.tag,
    required this.bgColor,
    required this.tagColor,
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
  final String season;
  final String rating;
  final String reviews;
  final String emoji;
  final String tag;
  final Color bgColor;
  final Color tagColor;
  final String? sellerId;
  final String? unitKey;
  final double? packageQuantity;
  final String? categoryId;

  ProductUnit? get productUnit {
    final key = unitKey;
    if (key != null) {
      final parsed = ProductUnitParsing.fromSlashUnit(key);
      if (parsed != null) return parsed;
    }
    return ProductUnitParsing.fromSlashUnit(unit);
  }

  String get pricePerOfferLabel => buildProductPricePerLabel(
    priceFormatted: price,
    unit: productUnit,
    quantity: packageQuantity,
  );

  bool get hasKnownDbUnit => productUnit != null;
}
