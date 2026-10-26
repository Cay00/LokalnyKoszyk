import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Najlepsza dostępna pozycja użytkownika albo `null`, gdy GPS/uprawnienia niedostępne.
Future<Position?> tryGetUserPosition({
  Duration timeout = const Duration(seconds: 4),
}) async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // getLastKnownPosition nie jest wspierane na webie.
    Position? position;
    if (!kIsWeb) {
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {
        position = null;
      }
    }

    position ??= await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    ).timeout(timeout, onTimeout: () => throw Exception('Timeout lokalizacji'));
    return position;
  } catch (_) {
    return null;
  }
}
