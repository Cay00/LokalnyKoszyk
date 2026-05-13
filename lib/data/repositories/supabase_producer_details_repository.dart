import 'package:geolocator/geolocator.dart';
import 'package:lokalny_koszyk/core/formatting/entity_keys.dart';
import 'package:lokalny_koszyk/core/formatting/pennies.dart';
import 'package:lokalny_koszyk/core/supabase/nested_row.dart';
import 'package:lokalny_koszyk/core/supabase/seller_public_lookup.dart';
import 'package:lokalny_koszyk/domain/models/producer_profile.dart';
import 'package:lokalny_koszyk/domain/models/product.dart';
import 'package:lokalny_koszyk/domain/repositories/producer_details_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProducerDetailsRepository implements ProducerDetailsRepository {
  const SupabaseProducerDetailsRepository(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<ProducerProfileWithProducts> getSellerAndProducts(String sellerId) async {
    final normalizedSellerId = normalizeUuidKey(sellerId);

    dynamic sellerWithLocationRow = await _supabase
        .from('sellers')
        .select(
          'id, name, description, email, phone, is_verified, quality_description, '
          'seller_locations(address, city, postal_code, country, latitude, longitude)',
        )
        .eq('id', normalizedSellerId)
        .isFilter('deleted_at', null)
        .maybeSingle();

    if (sellerWithLocationRow == null) {
      final byNorm = await fetchSellerPublicByIds({sellerId.trim()});
      final pick = byNorm[normalizedSellerId];
      if (pick != null) {
        sellerWithLocationRow = <String, dynamic>{
          'id': sellerId.trim(),
          'name': pick.name,
          'description': '',
          'email': '',
          'phone': '',
          'is_verified': pick.isVerified,
          'quality_description': '',
          'seller_locations': null,
        };
      }
    }

    if (sellerWithLocationRow == null) {
      throw StateError('Nie znaleziono sprzedawcy.');
    }

    final sellerMap = Map<String, dynamic>.from(sellerWithLocationRow as Map);
    final relatedLocations = supabaseEmbeddedMaps(sellerMap['seller_locations']);

    final fallbackRows = relatedLocations.isEmpty
        ? await _supabase
            .from('seller_locations')
            .select('address, city, postal_code, country, latitude, longitude')
            .eq('seller_id', normalizedSellerId)
            .limit(20)
        : <dynamic>[];
    final broadFallbackRows = relatedLocations.isEmpty && fallbackRows.isEmpty
        ? await _supabase
            .from('seller_locations')
            .select('seller_id, address, city, postal_code, country, latitude, longitude')
            .limit(300)
        : <dynamic>[];

    final parsedLocations = <Map<String, dynamic>>[
      ...relatedLocations,
      ...fallbackRows.map((row) => Map<String, dynamic>.from(row as Map)),
      ...broadFallbackRows
          .map((row) => Map<String, dynamic>.from(row as Map))
          .where(
            (row) => normalizeUuidKey((row['seller_id'] ?? '').toString()) == normalizedSellerId,
          ),
    ];
    final locationMap = parsedLocations.firstWhere(
      (location) {
        final address = (location['address'] ?? '').toString().trim();
        final city = (location['city'] ?? '').toString().trim();
        final postalCode = (location['postal_code'] ?? '').toString().trim();
        final country = (location['country'] ?? '').toString().trim();
        return address.isNotEmpty ||
            city.isNotEmpty ||
            postalCode.isNotEmpty ||
            country.isNotEmpty ||
            location['latitude'] != null ||
            location['longitude'] != null;
      },
      orElse: () => parsedLocations.isEmpty ? <String, dynamic>{} : parsedLocations.first,
    );

    final seller = ProducerProfile(
      id: sellerMap['id'].toString(),
      name: (sellerMap['name'] ?? 'Sprzedawca').toString(),
      description: (sellerMap['description'] ?? '').toString(),
      email: (sellerMap['email'] ?? '').toString().trim(),
      phone: (sellerMap['phone'] ?? '').toString().trim(),
      isVerified: sellerMap['is_verified'] == true,
      qualityDescription: (sellerMap['quality_description'] ?? '').toString(),
      address: (locationMap['address'] ?? '').toString(),
      city: (locationMap['city'] ?? '').toString(),
      postalCode: (locationMap['postal_code'] ?? '').toString(),
      country: (locationMap['country'] ?? '').toString(),
      latitude: (locationMap['latitude'] as num?)?.toDouble(),
      longitude: (locationMap['longitude'] as num?)?.toDouble(),
    );

    final productRows = await _supabase
        .from('products')
        .select(
          'product_id, category_id, name, price_gross_amount, unit, package_size, '
          'stock_quantity, average_rating, reviews_count, is_active',
        )
        .eq('seller_id', normalizedSellerId)
        .eq('is_active', true)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    final products = (productRows as List<dynamic>).map<Product>((dynamic row) {
      final map = Map<String, dynamic>.from(row as Map);
      final priceGrosze = parsePennies(map['price_gross_amount']);
      final ratingNum = (map['average_rating'] as num?)?.toDouble() ?? 0;
      final reviewsCount = (map['reviews_count'] as num?)?.toInt() ?? 0;
      final rawUnit = (map['unit'] ?? '').toString();
      final unitKey = rawUnit.trim().toLowerCase();
      final qty = (map['package_size'] as num?)?.toDouble();
      final rawCategoryId = map['category_id']?.toString().trim();

      return Product(
        id: (map['product_id'] ?? '').toString(),
        name: (map['name'] ?? 'Produkt').toString(),
        producer: seller.name,
        price: plnCommaStringFromPennies(priceGrosze),
        unit: '/ ${rawUnit.replaceAll('_', ' ')}',
        distance: '',
        season: 'Cały rok',
        rating: ratingNum.toStringAsFixed(1),
        reviews: reviewsCount.toString(),
        unitKey: unitKey.isEmpty ? null : unitKey,
        packageQuantity: qty,
        categoryId: rawCategoryId == null || rawCategoryId.isEmpty ? null : rawCategoryId,
      );
    }).where((product) => product.id.isNotEmpty).toList();

    return ProducerProfileWithProducts(
      profile: seller,
      products: products,
    );
  }

  @override
  Future<String> buildDistanceLabel(ProducerProfile seller) async {
    final sellerLat = seller.latitude;
    final sellerLon = seller.longitude;
    if (sellerLat == null || sellerLon == null) return 'brak danych';

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'brak danych';

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return 'brak danych';
    }

    Position? userPosition = await Geolocator.getLastKnownPosition();
    userPosition ??= await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    ).timeout(
      const Duration(seconds: 4),
      onTimeout: () => throw Exception('Timeout lokalizacji'),
    );
    final distanceMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      sellerLat,
      sellerLon,
    );
    final distanceKm = distanceMeters / 1000.0;
    final roundedToFiveKm = (distanceKm / 5).round() * 5;
    return '$roundedToFiveKm km';
  }
}
