import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lokalny_koszyk/core/formatting/distance_label.dart';

void main() {
  group('formatDistanceLabelFromMeters', () {
    test('rounds to nearest 5 km', () {
      expect(formatDistanceLabelFromMeters(0), '0 km');
      expect(formatDistanceLabelFromMeters(2400), '0 km');
      expect(formatDistanceLabelFromMeters(2500), '5 km');
      expect(formatDistanceLabelFromMeters(7400), '5 km');
      expect(formatDistanceLabelFromMeters(7500), '10 km');
      expect(formatDistanceLabelFromMeters(12000), '10 km');
      expect(formatDistanceLabelFromMeters(12500), '15 km');
    });
  });

  group('Geolocator.distanceBetween (geolokalizacja)', () {
    test('Warszawa–Kraków is about 250 km', () {
      // Przybliżone współrzędne centrów miast.
      const warsawLat = 52.2297;
      const warsawLon = 21.0122;
      const krakowLat = 50.0647;
      const krakowLon = 19.9450;

      final meters = Geolocator.distanceBetween(
        warsawLat,
        warsawLon,
        krakowLat,
        krakowLon,
      );
      final km = meters / 1000.0;

      expect(km, greaterThan(240));
      expect(km, lessThan(270));
      expect(formatDistanceLabelFromMeters(meters), '250 km');
    });

    test('same point yields 0 km label', () {
      final meters = Geolocator.distanceBetween(52.0, 21.0, 52.0, 21.0);
      expect(meters, 0);
      expect(formatDistanceLabelFromMeters(meters), '0 km');
    });
  });
}
