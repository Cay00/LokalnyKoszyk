import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/supabase/cart_repository.dart';
import 'package:lokalny_koszyk/core/supabase/seller_public_lookup.dart';
import 'package:lokalny_koszyk/data/repositories/supabase_watched_products_repository.dart';
import 'package:lokalny_koszyk/domain/repositories/product_details_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProductDetailsRepository implements ProductDetailsRepository {
  const SupabaseProductDetailsRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  bool get isUserSignedIn {
    final user = _supabase.auth.currentUser;
    return user != null && user.id.isNotEmpty;
  }

  @override
  Future<bool> isFavoriteForCurrentUser(String productId) {
    return SupabaseWatchedProductsRepository(
      _supabase,
    ).isFavoriteForCurrentUser(productId);
  }

  @override
  Future<bool> toggleFavoriteForCurrentUser({
    required String productId,
    required bool currentlyFavorite,
  }) async {
    if (currentlyFavorite) {
      await SupabaseWatchedProductsRepository(
        _supabase,
      ).removeFavoriteForCurrentUser(productId);
      return false;
    }
    await SupabaseWatchedProductsRepository(
      _supabase,
    ).addFavoriteForCurrentUser(productId);
    return true;
  }

  @override
  Future<String?> resolveSellerName({
    required String productId,
    required String? sellerId,
    required String currentProducerLabel,
  }) async {
    final label = currentProducerLabel.trim();
    if (label.isNotEmpty &&
        label != 'Sprzedawca' &&
        !label.startsWith('Sprzedawca ·')) {
      return null;
    }

    var rawSid = sellerId?.trim() ?? '';
    if (rawSid.isEmpty) {
      final pid = productId.trim();
      if (pid.isEmpty) return null;
      try {
        final row = await _supabase
            .from('products')
            .select('seller_id')
            .eq('product_id', pid)
            .maybeSingle();
        rawSid = (row?['seller_id'] ?? '').toString().trim();
      } catch (_) {
        return null;
      }
    }
    if (rawSid.isEmpty) return null;

    final byNorm = await fetchSellerPublicByIds({rawSid});
    final info = byNorm[normalizeUuidKey(rawSid)];
    final name = info?.name.trim() ?? '';
    return name.isEmpty ? null : name;
  }

  @override
  Future<void> addToCart({
    required String productId,
    required int quantityToAdd,
  }) {
    return CartRepository.addToCart(
      productId: productId,
      quantityToAdd: quantityToAdd,
    );
  }
}
