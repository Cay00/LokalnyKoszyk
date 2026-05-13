import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/data/dto/seller_dto.dart';
import 'package:lokalny_koszyk/domain/models/seller.dart';

Seller mapSellerForHome({
  required String rawSellerId,
  required SellerDto? dto,
}) {
  final normalized = normalizeUuidKey(rawSellerId);
  final hasName = dto != null && dto.name.trim().isNotEmpty;
  return Seller(
    id: rawSellerId,
    name: hasName ? dto.name : 'Sprzedawca',
    subtitle: hasName
        ? null
        : (normalized.isNotEmpty ? 'UUID sprzedawcy: $normalized' : null),
    distance: '',
    rating: '0.0',
    reviews: '0',
    isVerified: dto?.isVerified ?? false,
    hasResolvedName: hasName,
  );
}
