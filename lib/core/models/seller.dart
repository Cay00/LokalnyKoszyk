class Seller {
  const Seller({
    required this.id, // ID SELLERA (rekord)
    required this.userId, // ID USERA (auth/profile)
    required this.name,
    required this.description,
    required this.email,
    required this.phone,
    required this.isVerified,
    required this.createdAt,
    this.location,
    this.availability,
    this.isPickupAvailable = false,
    this.isShippingAvailable = false,
    this.qualityDescription,
    this.logoImage,
    this.coverImage,
  });

  final String id;
  final String userId;
  final String name;
  final String description;
  final String email;
  final String phone;
  final bool isVerified;
  final DateTime createdAt;
  final SellerLocation? location;
  final String? availability;
  final bool isPickupAvailable;
  final bool isShippingAvailable;
  final String? qualityDescription;
  final String? logoImage;
  final String? coverImage;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'location': location?.toJson(),
      'availability': availability,
      'is_pickup_available': isPickupAvailable,
      'is_shipping_available': isShippingAvailable,
      'quality_description': qualityDescription,
      'logo_image': logoImage,
      'cover_image': coverImage,
    };
  }

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] as String? ?? json['seller_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      location: json['location'] == null
          ? null
          : SellerLocation.fromJson(json['location'] as Map<String, dynamic>),
      availability: json['availability'] as String?,
      isPickupAvailable: json['is_pickup_available'] as bool? ?? false,
      isShippingAvailable: json['is_shipping_available'] as bool? ?? false,
      qualityDescription: json['quality_description'] as String?,
      logoImage: json['logo_image'] as String?,
      coverImage: json['cover_image'] as String?,
    );
  }
}

class SellerLocation {
  const SellerLocation({
    required this.locationId,
    required this.sellerId,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String locationId;
  final String sellerId;
  final String address;
  final String city;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'seller_id': sellerId,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory SellerLocation.fromJson(Map<String, dynamic> json) {
    return SellerLocation(
      locationId: json['location_id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

