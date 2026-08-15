import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/supabase/profile_bootstrap.dart';
import 'package:lokalny_koszyk/core/supabase/seller_public_lookup.dart';
import 'package:lokalny_koszyk/data/product_from_row.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_products_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseWatchedProductsRepository implements WatchedProductsRepository {
  const SupabaseWatchedProductsRepository(this._supabase);

  final SupabaseClient _supabase;
  static const String _junctionTable = 'user_favorite_products';

  @override
  bool get isUserSignedIn {
    final user = _supabase.auth.currentUser;
    return user != null && user.id.isNotEmpty;
  }

  @override
  Future<bool> isFavoriteForCurrentUser(String productId) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) return false;
    final pid = productId.trim();
    if (pid.isEmpty) return false;
    try {
      final row = await _supabase
          .from(_junctionTable)
          .select('id')
          .eq('user_id', user.id)
          .eq('product_id', pid)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> addFavoriteForCurrentUser(String productId) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }
    await ProfileBootstrap.ensureRowForAuthUser(user);
    final pid = productId.trim();
    if (pid.isEmpty) {
      throw ArgumentError.value(
        productId,
        'productId',
        'Pusty identyfikator produktu.',
      );
    }
    await _supabase.from(_junctionTable).insert(<String, dynamic>{
      'user_id': user.id,
      'product_id': pid,
    });
  }

  @override
  Future<void> removeFavoriteForCurrentUser(String productId) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }
    final pid = productId.trim();
    if (pid.isEmpty) return;
    await _supabase
        .from(_junctionTable)
        .delete()
        .eq('user_id', user.id)
        .eq('product_id', pid);
  }

  @override
  Future<List<Product>> fetchProductsForCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      return const <Product>[];
    }

    await ProfileBootstrap.ensureRowForAuthUser(user);
    final userId = user.id;

    final dynamic junction = await _supabase
        .from(_junctionTable)
        .select('product_id, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    if (junction is! List<dynamic> || junction.isEmpty) {
      return const <Product>[];
    }

    final orderedIds = <String>[];
    final seen = <String>{};
    for (final dynamic row in junction) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = (map['product_id'] ?? '').toString().trim();
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      orderedIds.add(id);
    }
    if (orderedIds.isEmpty) return const <Product>[];

    final productRows = await _supabase
        .from('products')
        .select(
          'product_id, seller_id, category_id, name, price_gross_amount, unit, '
          'package_size, stock_quantity, average_rating, reviews_count, is_active',
        )
        .inFilter('product_id', orderedIds)
        .eq('is_active', true)
        .isFilter('deleted_at', null);

    final rows = (productRows as List<dynamic>)
        .map((dynamic row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final sellerRawIds = <String>{};
    for (final map in rows) {
      final raw = (map['seller_id'] ?? '').toString().trim();
      if (raw.isNotEmpty) sellerRawIds.add(raw);
    }
    final sellerByNorm = await fetchSellerPublicByIds(sellerRawIds);

    final byId = <String, Product>{};
    for (final map in rows) {
      final id = (map['product_id'] ?? '').toString().trim();
      if (id.isEmpty) continue;

      final sellerIdRaw = (map['seller_id'] ?? '').toString().trim();
      final pick = sellerByNorm[normalizeUuidKey(sellerIdRaw)];
      final sellerName = (pick?.name.trim().isNotEmpty ?? false)
          ? pick!.name
          : 'Sprzedawca';

      byId[id] = productFromSupabaseRow(map, producer: sellerName);
    }

    return orderedIds
        .map((String id) => byId[id])
        .whereType<Product>()
        .toList();
  }
}
