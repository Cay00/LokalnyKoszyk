import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/supabase/seller_public_lookup.dart';
import 'package:lokalny_koszyk/data/product_from_row.dart';
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

    return rows
        .map<Product>((Map<String, dynamic> map) {
          final sellerIdRaw = (map['seller_id'] ?? '').toString().trim();
          final pick = sellerByNorm[normalizeUuidKey(sellerIdRaw)];
          final sellerName = (pick?.name.trim().isNotEmpty ?? false)
              ? pick!.name
              : 'Sprzedawca';
          return productFromSupabaseRow(map, producer: sellerName);
        })
        .where((Product p) => p.id.isNotEmpty)
        .toList();
  }
}
