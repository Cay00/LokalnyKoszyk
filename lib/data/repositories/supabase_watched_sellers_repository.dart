import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/supabase/profile_bootstrap.dart';
import 'package:lokalny_koszyk/domain/models/favorite_seller.dart';
import 'package:lokalny_koszyk/domain/repositories/watched_sellers_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseWatchedSellersRepository implements WatchedSellersRepository {
  const SupabaseWatchedSellersRepository(this._supabase);

  final SupabaseClient _supabase;
  static const String _junctionTable = 'user_favorite_sellers';

  @override
  bool get isUserSignedIn {
    final user = _supabase.auth.currentUser;
    return user != null && user.id.isNotEmpty;
  }

  @override
  Future<bool> isFavoriteForCurrentUser(String sellerId) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) return false;
    final sid = normalizeUuidKey(sellerId.trim());
    if (sid.isEmpty) return false;
    try {
      final row = await _supabase
          .from(_junctionTable)
          .select('id')
          .eq('user_id', user.id)
          .eq('seller_id', sid)
          .maybeSingle();
      return row != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> addFavoriteForCurrentUser(String sellerId) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }
    await ProfileBootstrap.ensureRowForAuthUser(user);
    final sid = normalizeUuidKey(sellerId.trim());
    if (sid.isEmpty) {
      throw ArgumentError.value(sellerId, 'sellerId', 'Pusty identyfikator.');
    }
    await _supabase.from(_junctionTable).insert(<String, dynamic>{
      'user_id': user.id,
      'seller_id': sid,
    });
  }

  @override
  Future<void> removeFavoriteForCurrentUser(String sellerId) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      throw StateError('Brak zalogowanego użytkownika.');
    }
    final sid = normalizeUuidKey(sellerId.trim());
    if (sid.isEmpty) return;
    await _supabase
        .from(_junctionTable)
        .delete()
        .eq('user_id', user.id)
        .eq('seller_id', sid);
  }

  @override
  Future<List<FavoriteSeller>> fetchSellersForCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.id.isEmpty) {
      return const <FavoriteSeller>[];
    }

    await ProfileBootstrap.ensureRowForAuthUser(user);

    final dynamic junction = await _supabase
        .from(_junctionTable)
        .select('seller_id, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (junction is! List<dynamic> || junction.isEmpty) {
      return const <FavoriteSeller>[];
    }

    final orderedIds = <String>[];
    final seen = <String>{};
    for (final dynamic row in junction) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = normalizeUuidKey((map['seller_id'] ?? '').toString());
      if (id.isEmpty || !seen.add(id)) continue;
      orderedIds.add(id);
    }
    if (orderedIds.isEmpty) return const <FavoriteSeller>[];

    final sellerRows = await _supabase
        .from('sellers')
        .select('id, name, description, is_verified')
        .inFilter('id', orderedIds)
        .isFilter('deleted_at', null);

    final byId = <String, FavoriteSeller>{};
    for (final dynamic row in sellerRows as List<dynamic>) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = normalizeUuidKey((map['id'] ?? '').toString());
      if (id.isEmpty) continue;
      byId[id] = FavoriteSeller(
        id: id,
        name: (map['name'] ?? 'Sprzedawca').toString(),
        description: (map['description'] ?? '').toString(),
        isVerified: map['is_verified'] == true,
      );
    }

    return orderedIds
        .map((String id) => byId[id])
        .whereType<FavoriteSeller>()
        .toList();
  }
}
