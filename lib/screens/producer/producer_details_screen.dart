import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/common/default_screen.dart';
import '../product/product_details_screen.dart';
import '../product/product_tile.dart';
import '../product/product_tile_small.dart';

class ProducerDetailsScreen extends StatefulWidget {
  const ProducerDetailsScreen({
    super.key,
    this.sellerId,
    this.onBack,
  });

  final String? sellerId;
  final VoidCallback? onBack;

  @override
  State<ProducerDetailsScreen> createState() => _ProducerDetailsScreenState();
}

class _ProducerDetailsScreenState extends State<ProducerDetailsScreen> {
  bool _isLiked = false;
  bool _isLoading = true;
  String? _errorText;
  String _distanceLabel = 'brak danych';
  _SellerDetails? _seller;
  List<ProductData> _products = const <ProductData>[];
  _InfoSection _selectedInfoSection = _InfoSection.address;

  @override
  void initState() {
    super.initState();
    _loadSellerAndProducts();
  }

  Future<void> _loadSellerAndProducts() async {
    final sellerId = widget.sellerId;
    if (sellerId == null || sellerId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorText = 'Brak identyfikatora sprzedawcy.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      final sellerWithLocationRow = await supabase
          .from('sellers')
          .select(
            'id, name, description, email, phone, is_verified, quality_description, '
            'seller_locations(address, city, postal_code, country, latitude, longitude)',
          )
          .eq('id', sellerId)
          .maybeSingle();

      if (sellerWithLocationRow == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorText = 'Nie znaleziono sprzedawcy.';
        });
        return;
      }

      final sellerMap = Map<String, dynamic>.from(sellerWithLocationRow as Map);
      final relatedLocations =
          (sellerMap['seller_locations'] as List<dynamic>? ?? <dynamic>[]);

      // Fallback: jeżeli relacja nie zwróciła danych (np. przez konfigurację),
      // pobierz lokalizacje klasycznym zapytaniem po seller_id.
      final fallbackRows = relatedLocations.isEmpty
          ? await supabase
              .from('seller_locations')
              .select(
                'address, city, postal_code, country, latitude, longitude',
              )
              .eq('seller_id', sellerId)
              .limit(20)
          : <dynamic>[];
      // Dodatkowy fallback: jeśli nadal pusto, pobierz szerszy zestaw i dopasuj seller_id po stronie aplikacji.
      final broadFallbackRows =
          relatedLocations.isEmpty && fallbackRows.isEmpty
          ? await supabase
              .from('seller_locations')
              .select(
                'seller_id, address, city, postal_code, country, latitude, longitude',
              )
              .limit(300)
          : <dynamic>[];

      final parsedLocations = <Map<String, dynamic>>[
        ...relatedLocations.map((row) => Map<String, dynamic>.from(row as Map)),
        ...fallbackRows.map((row) => Map<String, dynamic>.from(row as Map)),
        ...broadFallbackRows
            .map((row) => Map<String, dynamic>.from(row as Map))
            .where((row) => (row['seller_id'] ?? '').toString().trim() == sellerId),
      ];
      final locationMap =
          parsedLocations.firstWhere(
                (location) {
                  final address = (location['address'] ?? '').toString().trim();
                  final city = (location['city'] ?? '').toString().trim();
                  final postalCode =
                      (location['postal_code'] ?? '').toString().trim();
                  final country = (location['country'] ?? '').toString().trim();
                  return address.isNotEmpty ||
                      city.isNotEmpty ||
                      postalCode.isNotEmpty ||
                      country.isNotEmpty ||
                      location['latitude'] != null ||
                      location['longitude'] != null;
                },
                orElse: () =>
                    parsedLocations.isEmpty ? <String, dynamic>{} : parsedLocations.first,
              );
      final sellerEmail = (sellerMap['email'] ?? '').toString().trim();
      final sellerPhone = (sellerMap['phone'] ?? '').toString().trim();
      final seller = _SellerDetails(
        id: sellerMap['id'].toString(),
        name: (sellerMap['name'] ?? 'Sprzedawca').toString(),
        description: (sellerMap['description'] ?? '').toString(),
        email: sellerEmail,
        phone: sellerPhone,
        isVerified: sellerMap['is_verified'] == true,
        qualityDescription: (sellerMap['quality_description'] ?? '').toString(),
        address: (locationMap['address'] ?? '').toString(),
        city: (locationMap['city'] ?? '').toString(),
        postalCode: (locationMap['postal_code'] ?? '').toString(),
        country: (locationMap['country'] ?? '').toString(),
        latitude: (locationMap['latitude'] as num?)?.toDouble(),
        longitude: (locationMap['longitude'] as num?)?.toDouble(),
      );

      final productRows = await supabase
          .from('products')
          .select(
            'product_id, name, price, unit, average_rating, reviews_count, tags, is_active',
          )
          .eq('seller_id', sellerId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final products = productRows.map<ProductData>((dynamic row) {
        final map = Map<String, dynamic>.from(row as Map);
        final priceNum = (map['price'] as num?)?.toDouble() ?? 0;
        final ratingNum = (map['average_rating'] as num?)?.toDouble() ?? 0;
        final reviewsCount = (map['reviews_count'] as num?)?.toInt() ?? 0;
        final rawUnit = (map['unit'] ?? '').toString();
        final tags = (map['tags'] as List<dynamic>? ?? <dynamic>[]);

        return ProductData(
          id: (map['product_id'] ?? '').toString(),
          name: (map['name'] ?? 'Produkt').toString(),
          producer: seller.name,
          price: priceNum.toStringAsFixed(2).replaceAll('.', ','),
          unit: '/ ${rawUnit.replaceAll('_', ' ')}',
          distance: '',
          season: 'Cały rok',
          rating: ratingNum.toStringAsFixed(1),
          reviews: reviewsCount.toString(),
          emoji: '🧺',
          tag: tags.isNotEmpty ? tags.first.toString().toUpperCase() : 'LOKALNE',
          bgColor: AppColors.background,
          tagColor: AppColors.primaryLight,
        );
      }).where((product) => product.id.isNotEmpty).toList();

      setState(() {
        _seller = seller;
        _products = products;
        _isLoading = false;
      });
      _loadDistanceLabelInBackground(seller);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Nie udało się pobrać danych sprzedawcy: $e';
      });
    }
  }

  Future<void> _loadDistanceLabelInBackground(_SellerDetails seller) async {
    final distanceLabel = await _buildDistanceLabelForSeller(seller);
    if (!mounted) return;
    setState(() {
      _distanceLabel = distanceLabel;
    });
  }

  Future<String> _buildDistanceLabelForSeller(_SellerDetails seller) async {
    final sellerLat = seller.latitude;
    final sellerLon = seller.longitude;
    if (sellerLat == null || sellerLon == null) return 'brak danych';

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'brak danych';

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'brak danych';
    }

    Position? userPosition = await Geolocator.getLastKnownPosition();
    userPosition ??= await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
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

  @override
  Widget build(BuildContext context) {
    final seller = _seller;
    return DefaultScreen(
      title: 'Sprzedawca',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorText != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadSellerAndProducts,
                      child: const Text('Ponów'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.lightSage,
                      borderRadius: BorderRadius.circular(AppRadius.normal),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Center(
                          child: SvgPicture.asset(
                            'assets/icons/farm.svg',
                            width: 120,
                            height: 120,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/farm_bg.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: InkWell(
                            onTap: () => setState(() => _isLiked = !_isLiked),
                            borderRadius: BorderRadius.circular(AppRadius.normal),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                _isLiked
                                    ? 'assets/icons/heart-fill.svg'
                                    : 'assets/icons/heart.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  _isLiked ? Colors.redAccent : AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.normal),
                          border: Border.all(color: AppColors.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Center(
                              child: SvgPicture.asset(
                                'assets/icons/farm.svg',
                                width: 36,
                                height: 36,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/farm_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    seller?.name ?? 'Sprzedawca',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (seller?.isVerified == true) ...<Widget>[
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    'assets/icons/seal-check-fill.svg',
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Odległość: $_distanceLabel',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: <Widget>[
                                SvgPicture.asset(
                                  'assets/icons/star-fill.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.accent,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'brak ocen',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.normal),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: <Widget>[
                              _buildInfoTabButton(
                                label: 'Adres',
                                section: _InfoSection.address,
                              ),
                              _buildInfoTabButton(
                                label: 'Kontakt',
                                section: _InfoSection.contact,
                              ),
                              _buildInfoTabButton(
                                label: 'Płatność',
                                section: _InfoSection.payments,
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: AppColors.border),
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _selectedInfoSection.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedInfoSection.contentForSeller(seller),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Opis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (seller?.description ?? '').isEmpty
                        ? 'Ten sprzedawca nie uzupełnił jeszcze opisu.'
                        : seller!.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jakość i certyfikaty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._qualityAndCertificatesForSeller(seller).map(
                    (String item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Wszystkie produkty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_products.isEmpty)
                    const Text(
                      'Ten sprzedawca nie ma aktywnych produktów.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    )
                  else
                    ..._products.map(
                      (ProductData product) => ProductTileSmall(
                        name: product.name,
                        distance: product.distance,
                        price: product.price,
                        unit: product.unit.replaceFirst('/ ', ''),
                        verified: seller?.isVerified == true,
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder<void>(
                              pageBuilder: (_, __, ___) => ProductDetailsScreen(
                                product: product,
                                onBack: () => Navigator.of(context).pop(),
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
      onBack: widget.onBack,
    );
  }

  Widget _buildInfoTabButton({
    required String label,
    required _InfoSection section,
  }) {
    final bool isSelected = _selectedInfoSection == section;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedInfoSection = section),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

enum _InfoSection {
  address(title: 'Adres'),
  contact(title: 'Kontakt'),
  payments(
    title: 'Metody płatności',
    content: 'BLIK\nKarta płatnicza\nGotówka przy odbiorze',
  );

  const _InfoSection({required this.title, this.content = ''});

  final String title;
  final String content;

  String contentForSeller(_SellerDetails? seller) {
    switch (this) {
      case _InfoSection.address:
        final chunks = <String>[
          if (seller != null && seller.address.trim().isNotEmpty)
            seller.address.trim(),
          if (seller != null &&
              (seller.postalCode.trim().isNotEmpty ||
                  seller.city.trim().isNotEmpty))
            '${seller.postalCode.trim()} ${seller.city.trim()}'.trim(),
          if (seller != null && seller.country.trim().isNotEmpty)
            seller.country.trim(),
          if (seller?.latitude != null && seller?.longitude != null)
            'GPS: ${seller!.latitude!.toStringAsFixed(6)}, ${seller.longitude!.toStringAsFixed(6)}',
        ];
        if (chunks.isEmpty) {
          return 'Adres odbioru nie został jeszcze uzupełniony.';
        }
        return chunks.join('\n');
      case _InfoSection.contact:
        final phone = (seller?.phone ?? '').trim();
        final email = (seller?.email ?? '').trim();
        if (phone.isEmpty && email.isEmpty) {
          return 'Dane kontaktowe nie zostały uzupełnione.';
        }
        if (phone.isEmpty) return 'email: $email';
        if (email.isEmpty) return 'tel. $phone';
        return 'tel. $phone\nemail: $email';
      case _InfoSection.payments:
        return content;
    }
  }
}

List<String> _qualityAndCertificatesForSeller(_SellerDetails? seller) {
  final quality = (seller?.qualityDescription ?? '').trim();
  if (quality.isEmpty) {
    return const <String>[
      'Brak dodatkowych informacji o jakości i certyfikatach.',
    ];
  }
  return <String>[quality];
}

class _SellerDetails {
  const _SellerDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.email,
    required this.phone,
    required this.isVerified,
    required this.qualityDescription,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String description;
  final String email;
  final String phone;
  final bool isVerified;
  final String qualityDescription;
  final String address;
  final String city;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
}
