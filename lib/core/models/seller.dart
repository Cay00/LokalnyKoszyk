enum SellerDeliveryType {
  pickup,
  localDelivery,
  courier,
}

class Seller {
  const Seller({
    required this.sellerId,
    required this.name,
    required this.description,
    required this.email,
    required this.phone,
    required this.isVerified,
    required this.createdAt,
    this.location,
    this.availability = const [],
    this.deliveries = const [],
    this.certifications = const [],
    this.images = const [],
  });

  // UUID represented as String.
  final String sellerId;
  final String name;
  final String description;
  final String email;
  final String phone;
  final bool isVerified;
  final DateTime createdAt;
  final SellerLocation? location;
  final List<SellerAvailability> availability;
  final List<SellerDelivery> deliveries;
  final List<SellerCertification> certifications;
  final List<SellerImage> images;

  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'location': location?.toJson(),
      'availability': availability.map((item) => item.toJson()).toList(),
      'deliveries': deliveries.map((item) => item.toJson()).toList(),
      'certifications': certifications.map((item) => item.toJson()).toList(),
      'images': images.map((item) => item.toJson()).toList(),
    };
  }

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      sellerId: json['seller_id'] as String? ?? '',
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
      availability: (json['availability'] as List<dynamic>? ?? [])
          .map((item) => SellerAvailability.fromJson(item as Map<String, dynamic>))
          .toList(),
      deliveries: (json['deliveries'] as List<dynamic>? ?? [])
          .map((item) => SellerDelivery.fromJson(item as Map<String, dynamic>))
          .toList(),
      certifications: (json['certifications'] as List<dynamic>? ?? [])
          .map((item) => SellerCertification.fromJson(item as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>? ?? [])
          .map((item) => SellerImage.fromJson(item as Map<String, dynamic>))
          .toList(),
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

class SellerAvailability {
  const SellerAvailability({
    required this.availabilityId,
    required this.sellerId,
    required this.dayOfWeek,
    required this.fromHour,
    required this.toHour,
  });

  final String availabilityId;
  final String sellerId;
  final String dayOfWeek;
  final String fromHour;
  final String toHour;

  Map<String, dynamic> toJson() {
    return {
      'availability_id': availabilityId,
      'seller_id': sellerId,
      'day_of_week': dayOfWeek,
      'from_hour': fromHour,
      'to_hour': toHour,
    };
  }

  factory SellerAvailability.fromJson(Map<String, dynamic> json) {
    return SellerAvailability(
      availabilityId: json['availability_id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? '',
      fromHour: json['from_hour'] as String? ?? '',
      toHour: json['to_hour'] as String? ?? '',
    );
  }
}

class SellerDelivery {
  const SellerDelivery({
    required this.deliveryId,
    required this.sellerId,
    required this.type,
    required this.price,
    this.freeFromAmount,
  });

  final String deliveryId;
  final String sellerId;
  final SellerDeliveryType type;
  final double price;
  final double? freeFromAmount;

  Map<String, dynamic> toJson() {
    return {
      'delivery_id': deliveryId,
      'seller_id': sellerId,
      'type': type.name,
      'price': price,
      'free_from_amount': freeFromAmount,
    };
  }

  factory SellerDelivery.fromJson(Map<String, dynamic> json) {
    final typeValue = (json['type'] as String?) ?? SellerDeliveryType.pickup.name;

    return SellerDelivery(
      deliveryId: json['delivery_id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      type: SellerDeliveryType.values.firstWhere(
        (value) => value.name == typeValue,
        orElse: () => SellerDeliveryType.pickup,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      freeFromAmount: (json['free_from_amount'] as num?)?.toDouble(),
    );
  }
}

class SellerCertification {
  const SellerCertification({
    required this.certId,
    required this.sellerId,
    required this.name,
    required this.issuer,
    this.validUntil,
  });

  final String certId;
  final String sellerId;
  final String name;
  final String issuer;
  final DateTime? validUntil;

  Map<String, dynamic> toJson() {
    return {
      'cert_id': certId,
      'seller_id': sellerId,
      'name': name,
      'issuer': issuer,
      'valid_until': validUntil?.toIso8601String(),
    };
  }

  factory SellerCertification.fromJson(Map<String, dynamic> json) {
    return SellerCertification(
      certId: json['cert_id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
      validUntil: DateTime.tryParse(json['valid_until'] as String? ?? ''),
    );
  }
}

class SellerImage {
  const SellerImage({
    required this.imageId,
    required this.sellerId,
    required this.url,
  });

  final String imageId;
  final String sellerId;
  final String url;

  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'seller_id': sellerId,
      'url': url,
    };
  }

  factory SellerImage.fromJson(Map<String, dynamic> json) {
    return SellerImage(
      imageId: json['image_id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
