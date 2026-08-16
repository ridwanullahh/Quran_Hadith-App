import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// Live compass bearing stream.
///
/// Wraps flutter_compass and exposes a cleaned-up stream of compass headings
/// in degrees [0, 360) where 0 = magnetic north.
///
/// Used by the Qibla screen to rotate the compass arrow in real time as the
/// user rotates their phone.
class CompassService {
  CompassService._();
  static final CompassService instance = CompassService._();

  /// Whether the device has a magnetometer (compass sensor).
  ///
  /// Returns false if flutter_compass reports null events — this is the case
  /// on devices without a magnetometer, or on emulators.
  Future<bool> isAvailable() async {
    try {
      final events = FlutterCompass.events;
      if (events == null) return false;
      final event = await events.first;
      return event != null && event.heading != null;
    } catch (e) {
      debugPrint('[CompassService] isAvailable: $e');
      return false;
    }
  }

  /// Stream of compass headings in degrees [0, 360).
  ///
  /// Filters out null readings (sensor unavailable) and emits the heading
  /// as a double. Callers should debounce / smooth if they need to dampen
  /// sensor noise.
  Stream<double> get headingStream {
    final events = FlutterCompass.events;
    if (events == null) {
      return const Stream.empty();
    }
    return events
        .where((e) => e != null && e.heading != null)
        .map((e) => (e!.heading! as double).clamp(0.0, 360.0).toDouble());
  }

  /// Compute the Qibla direction (degrees from magnetic north) given:
  ///   - the device's compass heading (degrees from magnetic north)
  ///   - the Qibla bearing from true north (degrees)
  ///
  /// The result is the angle the user should rotate the phone to so the
  /// compass arrow points toward Mecca.
  ///
  /// Note: this ignores magnetic declination. For most populated areas the
  /// declination is < 10° which is acceptable for a Qibla compass. A future
  /// enhancement can use the WMM model + the device location to compensate.
  static double qiblaDirectionFromCompass({
    required double compassHeading,
    required double qiblaBearingFromTrueNorth,
  }) {
    // The arrow on the compass should point in the direction of Mecca
    // relative to where the phone is currently pointing.
    // If the Qibla bearing (from true north) is 118° and the phone is
    // pointing north (heading 0°), the arrow should point 118° clockwise
    // from the phone's top — which we achieve by rotating the arrow by
    // (qiblaBearing - compassHeading).
    return (qiblaBearingFromTrueNorth - compassHeading + 360) % 360;
  }
}
