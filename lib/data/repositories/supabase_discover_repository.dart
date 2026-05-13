import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/seller_public_lookup.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';
import 'package:lokalny_koszyk/domain/repositories/discover_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDiscoverRepository implements DiscoverRepository {
  const SupabaseDiscoverRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<Product>> getActiveProducts() async {
    final productRows = await _supabase
        .from('products')
        .select(
          'product_id, seller_id, category_id, name, price_gross_amount, unit, '
          'package_size, average_rating, reviews_count, is_active',
        )
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    final rows = (productRows as List<dynamic>)
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final sellerRawIds = <String>{};
    for (final map in rows) {
      final raw = (map['seller_id'] ?? '').toString().trim();
      if (raw.isNotEmpty) sellerRawIds.add(raw);
    }
    final sellerByNorm = await fetchSellerPublicByIds(sellerRawIds);

    return rows.map<Product>((Map<String, dynamic> map) {
      final sellerIdRaw = (map['seller_id'] ?? '').toString().trim();
      final sellerKey = normalizeUuidKey(sellerIdRaw);
      final pick = sellerByNorm[sellerKey];
      final sellerName =
          (pick?.name.trim().isNotEmpty ?? false) ? pick!.name : 'Sprzedawca';
      final priceGrosze = parsePennies(map['price_gross_amount']);
      final ratingNum = (map['average_rating'] as num?)?.toDouble() ?? 0;
      final reviewsCount = (map['reviews_count'] as num?)?.toInt() ?? 0;
      final rawUnit = (map['unit'] ?? '').toString();
      final unitKey = rawUnit.trim().toLowerCase();
      final qty = (map['package_size'] as num?)?.toDouble();
      final rawCategoryId = map['category_id']?.toString().trim();
      final categoryId =
          rawCategoryId == null || rawCategoryId.isEmpty ? null : rawCategoryId;

      return Product(
        id: (map['product_id'] ?? '').toString(),
        name: (map['name'] ?? 'Produkt').toString(),
        producer: sellerName,
        price: plnCommaStringFromPennies(priceGrosze),
        unit: '/ ${rawUnit.replaceAll('_', ' ')}',
        distance: '',
        season: 'Cały rok',
        rating: ratingNum.toStringAsFixed(1),
        reviews: reviewsCount.toString(),
        sellerId: sellerIdRaw.isEmpty ? null : sellerIdRaw,
        unitKey: unitKey.isEmpty ? null : unitKey,
        packageQuantity: qty,
        categoryId: categoryId,
      );
    }).where((Product p) => p.id.isNotEmpty).toList();
  }
}
