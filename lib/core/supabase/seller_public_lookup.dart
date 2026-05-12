import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';

/// Minimalne dane sprzedawcy do UI (klucz mapy = [normalizeUuidKey] na `sellers.id`).
class SellerPublicInfo {
  const SellerPublicInfo({required this.name, required this.isVerified});

  final String name;
  final bool isVerified;
}

/// Pobiera sprzedawców z `public.sellers`: najpierw [inFilter], potem pojedyncze [.eq]
/// dla brakujących (obejście problemów z listą UUID w PostgREST).
Future<Map<String, SellerPublicInfo>> fetchSellerPublicByIds(
  Set<String> rawSellerIds,
) async {
  final trimmed = rawSellerIds
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toSet();
  if (trimmed.isEmpty) return <String, SellerPublicInfo>{};

  final byNorm = <String, SellerPublicInfo>{};

  Future<void> absorbRows(dynamic rows) async {
    if (rows is! List<dynamic>) return;
    for (final dynamic r in rows) {
      final m = Map<String, dynamic>.from(r as Map);
      final k = normalizeUuidKey((m['id'] ?? '').toString());
      final n = (m['name'] ?? '').toString().trim();
      if (k.isEmpty || n.isEmpty) continue;
      byNorm[k] = SellerPublicInfo(
        name: n,
        isVerified: m['is_verified'] == true,
      );
    }
  }

  try {
    final batch = await supabase
        .from('sellers')
        .select('id, name, is_verified')
        .inFilter('id', trimmed.toList())
        .isFilter('deleted_at', null);
    await absorbRows(batch);
  } catch (_) {}

  for (final String raw in trimmed) {
    final k = normalizeUuidKey(raw);
    if (k.isEmpty || byNorm.containsKey(k)) continue;
    try {
      final row = await supabase
          .from('sellers')
          .select('id, name, is_verified')
          .eq('id', raw)
          .isFilter('deleted_at', null)
          .maybeSingle();
      if (row == null) continue;
      final m = Map<String, dynamic>.from(row as Map);
      final n = (m['name'] ?? '').toString().trim();
      if (n.isEmpty) continue;
      byNorm[k] = SellerPublicInfo(
        name: n,
        isVerified: m['is_verified'] == true,
      );
    } catch (_) {}
  }

  return byNorm;
}
