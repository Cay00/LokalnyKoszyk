class FavoriteSeller {
  const FavoriteSeller({
    required this.id,
    required this.name,
    required this.isVerified,
    this.description = '',
  });

  final String id;
  final String name;
  final bool isVerified;
  final String description;
}
