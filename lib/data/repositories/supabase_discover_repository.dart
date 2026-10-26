import 'package:geolocator/geolocator.dart';
import 'package:lokalny_koszyk/core/formatting/distance_label.dart';
import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/location/user_position.dart';
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
    final locationsByNorm = await _fetchSellerLocations(sellerRawIds);
    final userPosition = await tryGetUserPosition();

    return rows
        .map<Product>((Map<String, dynamic> map) {
          final sellerIdRaw = (map['seller_id'] ?? '').toString().trim();
          final sellerKey = normalizeUuidKey(sellerIdRaw);
          final pick = sellerByNorm[sellerKey];
          final sellerName = (pick?.name.trim().isNotEmpty ?? false)
              ? pick!.name
              : 'Sprzedawca';

          double? distanceMeters;
          var distanceLabel = '';
          final loc = locationsByNorm[sellerKey];
          if (userPosition != null && loc != null) {
            distanceMeters = Geolocator.distanceBetween(
              userPosition.latitude,
              userPosition.longitude,
              loc.$1,
              loc.$2,
            );
            distanceLabel = formatDistanceLabelFromMeters(distanceMeters);
          }

          return productFromSupabaseRow(
            map,
            producer: sellerName,
            distance: distanceLabel,
            distanceMeters: distanceMeters,
          );
        })
        .where((Product p) => p.id.isNotEmpty)
        .toList();
  }

  Future<Map<String, (double, double)>> _fetchSellerLocations(
    Set<String> rawSellerIds,
  ) async {
    final trimmed = rawSellerIds
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toSet();
    if (trimmed.isEmpty) return <String, (double, double)>{};

    final byNorm = <String, (double, double)>{};
    try {
      final rows = await _supabase
          .from('seller_locations')
          .select('seller_id, latitude, longitude')
          .inFilter('seller_id', trimmed.toList());
      if (rows is! List<dynamic>) return byNorm;
      for (final dynamic row in rows) {
        final map = Map<String, dynamic>.from(row as Map);
        final key = normalizeUuidKey((map['seller_id'] ?? '').toString());
        final lat = (map['latitude'] as num?)?.toDouble();
        final lon = (map['longitude'] as num?)?.toDouble();
        if (key.isEmpty || lat == null || lon == null) continue;
        byNorm[key] = (lat, lon);
      }
    } catch (_) {}
    return byNorm;
  }
}
