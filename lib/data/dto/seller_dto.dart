import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/domain/models/seller.dart';

class SellerDto {
  const SellerDto({
    required this.id,
    required this.name,
    required this.isVerified,
  });

  factory SellerDto.fromSupabaseJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? '').toString().trim();
    return SellerDto(
      id: rawId,
      name: (json['name'] ?? '').toString().trim(),
      isVerified: json['is_verified'] == true,
    );
  }

  final String id;
  final String name;
  final bool isVerified;

  String get normalizedId => normalizeUuidKey(id);

  Seller toDomain({
    required String fallbackId,
    required String fallbackName,
    required bool hasResolvedName,
  }) {
    return Seller(
      id: id.isNotEmpty ? id : fallbackId,
      name: name.isNotEmpty ? name : fallbackName,
      isVerified: isVerified,
      subtitle: hasResolvedName
          ? null
          : (normalizeUuidKey(fallbackId).isNotEmpty
                ? 'UUID sprzedawcy: ${normalizeUuidKey(fallbackId)}'
                : null),
      hasResolvedName: hasResolvedName,
    );
  }
}
