class Seller {
  const Seller({
    required this.id,
    required this.name,
    required this.isVerified,
    this.distance = '',
    this.rating = '0.0',
    this.reviews = '0',
    this.subtitle,
    this.hasResolvedName = true,
  });

  final String id;
  final String name;
  final bool isVerified;
  final String distance;
  final String rating;
  final String reviews;
  final String? subtitle;
  final bool hasResolvedName;
}
