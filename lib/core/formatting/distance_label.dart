/// Zaokrągla dystans w metrach do etykiety w kilometrach (krok 5 km).
///
/// Przykłady: 0 m → „0 km”, 2,4 km → „0 km”, 2,5 km → „5 km”, 12 km → „10 km”.
String formatDistanceLabelFromMeters(double distanceMeters) {
  final distanceKm = distanceMeters / 1000.0;
  final roundedToFiveKm = (distanceKm / 5).round() * 5;
  return '$roundedToFiveKm km';
}
