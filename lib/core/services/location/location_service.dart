import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Result of a location request.
class LocationResult {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? countryName;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.countryName,
  });

  @override
  String toString() =>
      'LocationResult($cityName, $countryName @ $latitude,$longitude)';
}

/// Service for getting the device's GPS location and reverse-geocoding it
/// to a human-readable city name.
///
/// Used by:
///   - prayer_provider (GPS-based prayer times)
///   - qibla_provider  (GPS-based Qibla bearing)
///
/// All methods are graceful — they return null rather than throwing when
/// permissions are denied or location services are disabled, so the UI can
/// fall back to the previously-selected city.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Check whether location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('[LocationService] isLocationServiceEnabled: $e');
      return false;
    }
  }

  /// Check the current location permission status.
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      debugPrint('[LocationService] checkPermission: $e');
      return LocationPermission.denied;
    }
  }

  /// Request location permission if not yet granted.
  ///
  /// Returns true if permission is granted (either while in use or always).
  /// Returns false if denied, denied forever, or if location services are
  /// disabled.
  Future<bool> requestPermission() async {
    try {
      if (!await isLocationServiceEnabled()) return false;

      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('[LocationService] requestPermission: $e');
      return false;
    }
  }

  /// Get the current device location with a reverse-geocoded city name.
  ///
  /// Returns null if:
  ///   - location services are disabled
  ///   - permission is denied
  ///   - the device times out getting a fix
  ///
  /// The caller should fall back to a previously-selected city when null.
  Future<LocationResult?> getCurrentLocation({
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    try {
      if (!await isLocationServiceEnabled()) return null;
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: timeLimit,
      );

      // Reverse-geocode to get a city name. Best-effort — don't fail if
      // geocoding is unavailable (e.g. no network).
      String? cityName;
      String? countryName;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          cityName = p.locality ??
              p.subAdministrativeArea ??
              p.administrativeArea ??
              '';
          countryName = p.country ?? '';
        }
      } catch (e) {
        debugPrint('[LocationService] reverse geocode failed: $e');
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName?.isNotEmpty == true ? cityName : null,
        countryName: countryName?.isNotEmpty == true ? countryName : null,
      );
    } on TimeoutException {
      debugPrint('[LocationService] getCurrentLocation timed out');
      return null;
    } catch (e) {
      debugPrint('[LocationService] getCurrentLocation failed: $e');
      return null;
    }
  }

  /// Calculate the great-circle bearing from the device's location to the
  /// Kaaba in Mecca. Used by the Qibla compass.
  ///
  /// Kaaba coordinates: 21.4225° N, 39.8262° E
  static double bearingToKaaba(double lat, double lon) {
    return _bearingBetween(lat, lon, 21.4225, 39.8262);
  }

  /// Great-circle bearing from point A to point B, in degrees [0, 360).
  /// Standard formula using the forward azimuth.
  static double _bearingBetween(
      double lat1, double lon1, double lat2, double lon2) {
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final deltaLambda = (lon2 - lon1) * math.pi / 180;
    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    final theta = math.atan2(y, x);
    return (theta * 180 / math.pi + 360) % 360;
  }
}
