import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../prayer/presentation/providers/prayer_provider.dart';

// ── Models ─────────────────────────────────────────────────────────────

class QiblaResult {
  /// Qibla direction in degrees from North, clockwise (0-360)
  final double bearing;

  /// Short formatted direction string like "237.5°"
  final String bearingText;

  /// Cardinal direction (e.g. "SE")
  final String cardinalDirection;

  /// Distance to Kaaba in km
  final double distanceKm;

  /// Formatted distance string
  final String distanceText;

  const QiblaResult({
    required this.bearing,
    required this.bearingText,
    required this.cardinalDirection,
    required this.distanceKm,
    required this.distanceText,
  });
}

// ── Calculator ──────────────────────────────────────────────────────────

class QiblaCalculator {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  /// Earth radius in km (mean)
  static const double _earthRadius = 6371.0;

  /// Calculate Qibla direction and distance from a given location.
  static QiblaResult calculate({
    required double latitude,
    required double longitude,
  }) {
    final latRad = _degToRad(latitude);
    final lngRad = _degToRad(longitude);
    const kaabaLatRad = 0.373906251; // 21.4225° in radians
    const kaabaLngRad = 0.695163454; // 39.8262° in radians

    final dLng = kaabaLngRad - lngRad;

    // Qibla bearing: atan2(sin(dLon), cos(lat)*tan(kaabaLat) - sin(lat)*cos(dLon))
    final x = math.sin(dLng);
    final y = math.cos(latRad) * math.tan(kaabaLatRad) - math.sin(latRad) * math.cos(dLng);
    var bearing = _radToDeg(math.atan2(x, y));
    if (bearing < 0) bearing += 360.0;

    // Distance using Haversine formula
    final dLat = kaabaLatRad - latRad;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(latRad) * math.cos(kaabaLatRad) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = _earthRadius * c;

    return QiblaResult(
      bearing: bearing,
      bearingText: '${bearing.toStringAsFixed(1)}°',
      cardinalDirection: _cardinalDirection(bearing),
      distanceKm: distance,
      distanceText: _formatDistance(distance),
    );
  }

  static String _cardinalDirection(double bearing) {
    if (bearing >= 348.75 || bearing < 11.25) return 'N';
    if (bearing < 33.75) return 'NNE';
    if (bearing < 56.25) return 'NE';
    if (bearing < 78.75) return 'ENE';
    if (bearing < 101.25) return 'E';
    if (bearing < 123.75) return 'ESE';
    if (bearing < 146.25) return 'SE';
    if (bearing < 168.75) return 'SSE';
    if (bearing < 191.25) return 'S';
    if (bearing < 213.75) return 'SSW';
    if (bearing < 236.25) return 'SW';
    if (bearing < 258.75) return 'WSW';
    if (bearing < 281.25) return 'W';
    if (bearing < 303.75) return 'WNW';
    if (bearing < 326.25) return 'NW';
    return 'NNW';
  }

  static String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    if (km < 100) return '${km.toStringAsFixed(1)} km';
    return '${km.round().toString()} km';
  }

  static double _degToRad(double deg) => deg * math.pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / math.pi;
}

// ── Providers ───────────────────────────────────────────────────────────

final qiblaProvider = Provider<QiblaResult>((ref) {
  final settings = ref.watch(prayerSettingsProvider);
  return QiblaCalculator.calculate(
    latitude: settings.location.latitude,
    longitude: settings.location.longitude,
  );
});
