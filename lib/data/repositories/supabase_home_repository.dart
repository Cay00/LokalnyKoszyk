import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/supabase/seller_public_lookup.dart';
import 'package:lokalny_koszyk/data/dto/seller_dto.dart';
import 'package:lokalny_koszyk/data/mapper/seller_mapper.dart';
import 'package:lokalny_koszyk/domain/models/seller.dart';
import 'package:lokalny_koszyk/domain/repositories/home_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHomeRepository implements HomeRepository {
  const SupabaseHomeRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<Seller>> getNearbySellers() async {
    final idRows = await _supabase
        .from('products')
        .select('seller_id')
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(120);

    final orderedSellerIds = <String>[];
    final seenKeys = <String>{};
    for (final dynamic row in idRows as List<dynamic>) {
      final map = Map<String, dynamic>.from(row as Map);
      final raw = (map['seller_id'] ?? '').toString().trim();
      final key = normalizeUuidKey(raw);
      if (key.isEmpty || seenKeys.contains(key)) continue;
      seenKeys.add(key);
      orderedSellerIds.add(raw);
      if (orderedSellerIds.length >= 20) break;
    }

    if (orderedSellerIds.isEmpty) return const <Seller>[];

    final sellerByNorm = await fetchSellerPublicByIds(orderedSellerIds.toSet());
    final dtoByNorm = <String, SellerDto>{};
    sellerByNorm.forEach((String key, SellerPublicInfo value) {
      dtoByNorm[key] = SellerDto.fromSupabaseJson(<String, dynamic>{
        'id': key,
        'name': value.name,
        'is_verified': value.isVerified,
      });
    });

    return orderedSellerIds.map((String raw) {
      final key = normalizeUuidKey(raw);
      return mapSellerForHome(rawSellerId: raw, dto: dtoByNorm[key]);
    }).toList();
  }
}
