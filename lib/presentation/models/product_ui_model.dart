import 'package:flutter/material.dart';
import 'package:lokalny_koszyk/core/formatting/product_price_per_label.dart';
import 'package:lokalny_koszyk/core/themes/app_theme.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';

class ProductUiModel {
  const ProductUiModel({
    required this.id,
    required this.name,
    required this.producer,
    required this.price,
    required this.unit,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.bgColor,
    this.oldPrice,
    this.sellerId,
    this.unitKey,
    this.packageQuantity,
    this.categoryId,
    this.distanceMeters,
  });

  factory ProductUiModel.fromDomain(Product product) {
    return ProductUiModel(
      id: product.id,
      name: product.name,
      producer: product.producer,
      price: product.price,
      unit: product.unit,
      distance: product.distance,
      distanceMeters: product.distanceMeters,
      rating: product.rating,
      reviews: product.reviews,
      bgColor: AppColors.background,
      sellerId: product.sellerId,
      unitKey: product.unitKey,
      packageQuantity: product.packageQuantity,
      categoryId: product.categoryId,
    );
  }

  final String id;
  final String name;
  final String producer;
  final String price;
  final String? oldPrice;
  final String unit;
  final String distance;
  final String rating;
  final String reviews;
  final Color bgColor;
  final String? sellerId;
  final String? unitKey;
  final double? packageQuantity;
  final String? categoryId;
  final double? distanceMeters;

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

  String get priceLabel => '$price zł';

  String? get oldPriceLabel {
    final String? value = oldPrice?.trim();
    if (value == null || value.isEmpty) return null;
    return '$value zł';
  }

  String get sizeLabel => buildProductSizeLabel(
    unit: productUnit,
    quantity: packageQuantity,
    fallback: unit.replaceFirst(RegExp(r'^/\s*'), ''),
  );

  bool get hasKnownDbUnit => productUnit != null;
}
