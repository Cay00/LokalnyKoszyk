import 'package:lokalny_koszyk/domain/models/product.dart';

class ProducerProfile {
  const ProducerProfile({
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

class ProducerProfileWithProducts {
  const ProducerProfileWithProducts({
    required this.profile,
    required this.products,
  });

  final ProducerProfile profile;
  final List<Product> products;
}
