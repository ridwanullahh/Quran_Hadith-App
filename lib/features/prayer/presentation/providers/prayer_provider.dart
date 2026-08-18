import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

import '../../../../core/services/location/location_service.dart';

// ── Models ─────────────────────────────────────────────────────────────

enum AsrMethod { shafii, hanafi }

class PrayerLocation {
  final String name;
  final String nameAr;
  final double latitude;
  final double longitude;

  const PrayerLocation({
    required this.name,
    required this.nameAr,
    required this.latitude,
    required this.longitude,
  });
}

class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<({String name, String nameAr, DateTime time})> get list => [
        (name: 'Fajr', nameAr: 'الفجر', time: fajr),
        (name: 'Sunrise', nameAr: 'الشروق', time: sunrise),
        (name: 'Dhuhr', nameAr: 'الظهر', time: dhuhr),
        (name: 'Asr', nameAr: 'العصر', time: asr),
        (name: 'Maghrib', nameAr: 'المغرب', time: maghrib),
        (name: 'Isha', nameAr: 'العشاء', time: isha),
      ];
}

class PrayerSettings {
  final PrayerLocation location;
  final AsrMethod asrMethod;
  final int fajrAngle;
  final int ishaAngle;
  final int fajrOffset;
  final int sunriseOffset;
  final int dhuhrOffset;
  final int asrOffset;
  final int maghribOffset;
  final int ishaOffset;

  const PrayerSettings({
    this.location = _defaultMecca,
    this.asrMethod = AsrMethod.shafii,
    this.fajrAngle = 18,
    this.ishaAngle = 17,
    this.fajrOffset = 0,
    this.sunriseOffset = 0,
    this.dhuhrOffset = 0,
    this.asrOffset = 0,
    this.maghribOffset = 0,
    this.ishaOffset = 0,
  });

  PrayerSettings copyWith({
    PrayerLocation? location,
    AsrMethod? asrMethod,
    int? fajrAngle,
    int? ishaAngle,
    int? fajrOffset,
    int? sunriseOffset,
    int? dhuhrOffset,
    int? asrOffset,
    int? maghribOffset,
    int? ishaOffset,
  }) {
    return PrayerSettings(
      location: location ?? this.location,
      asrMethod: asrMethod ?? this.asrMethod,
      fajrAngle: fajrAngle ?? this.fajrAngle,
      ishaAngle: ishaAngle ?? this.ishaAngle,
      fajrOffset: fajrOffset ?? this.fajrOffset,
      sunriseOffset: sunriseOffset ?? this.sunriseOffset,
      dhuhrOffset: dhuhrOffset ?? this.dhuhrOffset,
      asrOffset: asrOffset ?? this.asrOffset,
      maghribOffset: maghribOffset ?? this.maghribOffset,
      ishaOffset: ishaOffset ?? this.ishaOffset,
    );
  }

  /// Serialize to a JSON map for Hive persistence.
  Map<String, dynamic> toJson() => {
        'location_name': location.name,
        'location_name_ar': location.nameAr,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'asr_method': asrMethod.index,
        'fajr_angle': fajrAngle,
        'isha_angle': ishaAngle,
        'fajr_offset': fajrOffset,
        'sunrise_offset': sunriseOffset,
        'dhuhr_offset': dhuhrOffset,
        'asr_offset': asrOffset,
        'maghrib_offset': maghribOffset,
        'isha_offset': ishaOffset,
      };

  /// Deserialize from a JSON map. Falls back to defaults for missing fields.
  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    final asrIdx = json['asr_method'] as int? ?? 0;
    return PrayerSettings(
      location: PrayerLocation(
        name: json['location_name'] as String? ?? _defaultMecca.name,
        nameAr:
            json['location_name_ar'] as String? ?? _defaultMecca.nameAr,
        latitude: (json['latitude'] as num?)?.toDouble() ??
            _defaultMecca.latitude,
        longitude: (json['longitude'] as num?)?.toDouble() ??
            _defaultMecca.longitude,
      ),
      asrMethod: asrIdx >= 0 && asrIdx < AsrMethod.values.length
          ? AsrMethod.values[asrIdx]
          : AsrMethod.shafii,
      fajrAngle: json['fajr_angle'] as int? ?? 18,
      ishaAngle: json['isha_angle'] as int? ?? 17,
      fajrOffset: json['fajr_offset'] as int? ?? 0,
      sunriseOffset: json['sunrise_offset'] as int? ?? 0,
      dhuhrOffset: json['dhuhr_offset'] as int? ?? 0,
      asrOffset: json['asr_offset'] as int? ?? 0,
      maghribOffset: json['maghrib_offset'] as int? ?? 0,
      ishaOffset: json['isha_offset'] as int? ?? 0,
    );
  }
}

// ── Pre-defined Cities ────────────────────────────────────────────────

const _defaultMecca = PrayerLocation(
  name: 'Mecca',
  nameAr: 'مكة المكرمة',
  latitude: 21.4225,
  longitude: 39.8262,
);

const predefinedCities = <PrayerLocation>[
  PrayerLocation(name: 'Mecca', nameAr: 'مكة المكرمة', latitude: 21.4225, longitude: 39.8262),
  PrayerLocation(name: 'Medina', nameAr: 'المدينة المنورة', latitude: 24.4672, longitude: 39.6024),
  PrayerLocation(name: 'Cairo', nameAr: 'القاهرة', latitude: 30.0444, longitude: 31.2357),
  PrayerLocation(name: 'Istanbul', nameAr: 'إسطنبول', latitude: 41.0082, longitude: 28.9784),
  PrayerLocation(name: 'London', nameAr: 'لندن', latitude: 51.5074, longitude: -0.1278),
  PrayerLocation(name: 'New York', nameAr: 'نيويورك', latitude: 40.7128, longitude: -74.0060),
  PrayerLocation(name: 'Dubai', nameAr: 'دبي', latitude: 25.2048, longitude: 55.2708),
  PrayerLocation(name: 'Kuala Lumpur', nameAr: 'كوالالمبور', latitude: 3.1390, longitude: 101.6869),
  PrayerLocation(name: 'Jakarta', nameAr: 'جاكرتا', latitude: -6.2088, longitude: 106.8456),
  PrayerLocation(name: 'Riyadh', nameAr: 'الرياض', latitude: 24.7136, longitude: 46.6753),
  PrayerLocation(name: 'Karachi', nameAr: 'كراتشي', latitude: 24.8607, longitude: 67.0011),
  PrayerLocation(name: 'Dhaka', nameAr: 'دكا', latitude: 23.8103, longitude: 90.4125),
  PrayerLocation(name: 'Los Angeles', nameAr: 'لوس أنجلوس', latitude: 34.0522, longitude: -118.2437),
  PrayerLocation(name: 'Toronto', nameAr: 'تورنتو', latitude: 43.6532, longitude: -79.3832),
  PrayerLocation(name: 'Paris', nameAr: 'باريس', latitude: 48.8566, longitude: 2.3522),
  PrayerLocation(name: 'Sana\'a', nameAr: 'صنعاء', latitude: 15.3694, longitude: 44.1910),
];

// ── Prayer Calculator (Offline, Muslim World League method) ────────────

class PrayerCalculator {
  /// Calculate prayer times for a given date and location.
  static PrayerTimes calculate({
    required DateTime date,
    required PrayerLocation location,
    required AsrMethod asrMethod,
    required int fajrAngle,
    required int ishaAngle,
    required int fajrOffset,
    required int sunriseOffset,
    required int dhuhrOffset,
    required int asrOffset,
    required int maghribOffset,
    required int ishaOffset,
  }) {
    final lat = location.latitude;
    final lng = location.longitude;

    // Julian day number at noon UT
    final jd = _julianDay(date);

    // Julian centuries from J2000.0
    final t = (jd - 2451545.0) / 36525.0;

    // Solar position
    final l0 = _normalizeAngle(280.46646 + t * (36000.76983 + t * 0.0003032));
    final m = _normalizeAngle(357.52911 + t * (35999.05029 - t * 0.0001537));
    final e = 0.016708634 - t * (0.000042037 + t * 0.0000001267);
    final mRad = _degToRad(m);

    // Sun's equation of center
    final c = _radToDeg(
      (1.914602 - t * (0.004817 + t * 0.000014)) * math.sin(mRad) +
          (0.019993 - t * 0.000101) * math.sin(2 * mRad) +
          0.000289 * math.sin(3 * mRad),
    );

    // Sun's true longitude
    final sunLng = _normalizeAngle(l0 + c);

    // Sun's apparent longitude
    final omega = 125.04 - 1934.136 * t;
    final lambda = _normalizeAngle(sunLng - 0.00569 - 0.00478 * math.sin(_degToRad(omega)));

    // Mean obliquity of the ecliptic
    final obliq0 = 23.0 + (26.0 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60.0) / 60.0;
    final obliq = _radToDeg(
      _degToRad(obliq0) + 0.00256 * math.cos(_degToRad(omega)),
    );

    // Solar declination
    final decl = _radToDeg(
      math.asin(math.sin(_degToRad(obliq)) * math.sin(_degToRad(lambda))),
    );

    // Equation of time (minutes)
    final y = math.tan(_degToRad(obliq) / 2) * math.tan(_degToRad(obliq) / 2);
    final l0Rad = _degToRad(_normalizeAngle(l0));
    final eqTime =
        4.0 * _radToDeg(y * math.sin(2 * l0Rad) - 2 * e * math.sin(mRad) + 4 * e * y * math.sin(mRad) * math.cos(2 * l0Rad) - 0.5 * y * y * math.sin(4 * l0Rad) - 1.25 * e * e * math.sin(2 * mRad));

    // Solar noon (in hours, local)
    final solarNoon = 12.0 - eqTime / 60.0 - lng / 15.0;

    // Helper: compute hour angle for a given sun altitude angle
    double hourAngle(double angle) {
      final latRad = _degToRad(lat);
      final declRad = _degToRad(decl);
      final angleRad = _degToRad(angle);
      final cosHa = (math.cos(angleRad) - math.sin(latRad) * math.sin(declRad)) /
          (math.cos(latRad) * math.cos(declRad));
      if (cosHa < -1) return 24.0; // Sun never reaches this angle
      if (cosHa > 1) return 0.0;   // Sun never dips below this angle
      return _radToDeg(math.acos(cosHa)) / 15.0;
    }

    // Fajr: sun at -fajrAngle below horizon
    final fajrHa = hourAngle(-fajrAngle.toDouble());
    final fajrTime = solarNoon - fajrHa;

    // Sunrise: sun at -0.8333 below horizon (accounts for refraction)
    final sunriseHa = hourAngle(-0.8333);
    final sunriseTime = solarNoon - sunriseHa;

    // Dhuhr: solar noon + 1 minute safety
    final dhuhrTime = solarNoon + 1.0 / 60.0;

    // Asr
    final declRad = _degToRad(decl);
    final latRad = _degToRad(lat);
    final asrFactor = asrMethod == AsrMethod.hanafi ? 2.0 : 1.0;
    final noonAlt = _radToDeg(
      math.asin(
        math.sin(latRad) * math.sin(declRad) +
            math.cos(latRad) * math.cos(declRad),
      ),
    );
    final asrAltRad = _degToRad(
      _radToDeg(math.atan(1.0 / (asrFactor + math.tan(_degToRad((90.0 - noonAlt).abs().clamp(0.1, 90.0)))))),
    );
    final asrCosHa = (math.sin(asrAltRad) - math.sin(latRad) * math.sin(declRad)) /
        (math.cos(latRad) * math.cos(declRad));
    final asrHa = asrCosHa.abs() > 1.0 ? 0.0 : _radToDeg(math.acos(asrCosHa)) / 15.0;
    final asrTime = solarNoon + asrHa;

    // Maghrib: sun at -0.8333 below horizon
    final maghribTime = solarNoon + sunriseHa;

    // Isha: sun at -ishaAngle below horizon
    final ishaHa = hourAngle(-ishaAngle.toDouble());
    final ishaTime = solarNoon + ishaHa;

    // Apply offsets (in minutes)
    final baseDate = DateTime(date.year, date.month, date.day);

    return PrayerTimes(
      fajr: _hoursToDateTime(baseDate, fajrTime + fajrOffset / 60.0),
      sunrise: _hoursToDateTime(baseDate, sunriseTime + sunriseOffset / 60.0),
      dhuhr: _hoursToDateTime(baseDate, dhuhrTime + dhuhrOffset / 60.0),
      asr: _hoursToDateTime(baseDate, asrTime + asrOffset / 60.0),
      maghrib: _hoursToDateTime(baseDate, maghribTime + maghribOffset / 60.0),
      isha: _hoursToDateTime(baseDate, ishaTime + ishaOffset / 60.0),
    );
  }

  static DateTime _hoursToDateTime(DateTime base, double hours) {
    hours = hours % 24.0;
    if (hours < 0) hours += 24.0;
    final totalMinutes = (hours * 60).round();
    return base.add(Duration(minutes: totalMinutes));
  }

  static double _degToRad(double deg) => deg * math.pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / math.pi;

  static double _normalizeAngle(double a) {
    a = a % 360.0;
    if (a < 0) a += 360.0;
    return a;
  }

  /// Julian Day Number for a given DateTime (at noon UT).
  static double _julianDay(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day + (date.hour - 12.0) / 24.0;
    var a = (14 - m) ~/ 12;
    final y1 = y + 4800 - a;
    final m1 = m + 12 * a - 3;
    return d + (153 * m1 + 2) ~/ 5 + 365 * y1 + y1 ~/ 4 - y1 ~/ 100 + y1 ~/ 400 - 32045.5;
  }
}

// ── Providers ───────────────────────────────────────────────────────────

/// Hive-backed StateNotifier for [PrayerSettings].
///
/// Loads the previously-saved settings from Hive on construction (falling
/// back to defaults if the box is missing or corrupt), and writes every
/// state change back to Hive so the user's chosen city and calculation
/// method survive app restarts.
class PrayerSettingsNotifier extends StateNotifier<PrayerSettings> {
  static const _boxName = 'prayer_settings';
  static const _key = 'settings';
  Box? _box;

  PrayerSettingsNotifier() : super(const PrayerSettings()) {
    _load();
  }

  Future<void> _load() async {
    try {
      _box = await Hive.openBox(_boxName);
      final raw = _box!.get(_key);
      if (raw is Map) {
        state = PrayerSettings.fromJson(
          raw.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
    } catch (e, st) {
      debugPrint('[PrayerSettingsNotifier] load failed: $e\n$st');
      // Keep default state on error.
    }
  }

  Future<void> _persist() async {
    try {
      await _box?.put(_key, state.toJson());
    } catch (e, st) {
      debugPrint('[PrayerSettingsNotifier] persist failed: $e\n$st');
    }
  }

  void update(PrayerSettings settings) {
    state = settings;
    _persist();
  }

  void updateLocation(PrayerLocation location) {
    state = state.copyWith(location: location);
    _persist();
  }

  void updateAsrMethod(AsrMethod method) {
    state = state.copyWith(asrMethod: method);
    _persist();
  }

  /// Use the device GPS to get the current location and update settings.
  ///
  /// Returns a human-readable status message suitable for showing in a
  /// SnackBar:
  ///   - "Using your location: <city>" on success
  ///   - "Location permission denied" / "Location services disabled" on failure
  ///
  /// The caller (UI) is responsible for showing a loading indicator while
  /// this Future is pending and a SnackBar with the returned message when
  /// it completes.
  Future<String> useDeviceLocation() async {
    final result = await LocationService.instance.getCurrentLocation();
    if (result == null) {
      // Distinguish between "services disabled" and "permission denied"
      // for a more helpful error message.
      final enabled = await LocationService.instance.isLocationServiceEnabled();
      if (!enabled) {
        return 'Location services are disabled. Enable GPS in device settings.';
      }
      final permission = await LocationService.instance.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'Location permission denied. Grant location access in app settings.';
      }
      return 'Could not determine your location. Try again.';
    }

    final displayName = result.cityName ?? 'Current Location';
    state = state.copyWith(
      location: PrayerLocation(
        name: displayName,
        nameAr: result.cityName ?? 'موقعك الحالي',
        latitude: result.latitude,
        longitude: result.longitude,
      ),
    );
    await _persist();
    return 'Using your location: $displayName';
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}

final prayerSettingsProvider =
    StateNotifierProvider<PrayerSettingsNotifier, PrayerSettings>(
  (ref) => PrayerSettingsNotifier(),
);

final prayerTimesProvider = Provider<PrayerTimes>((ref) {
  final settings = ref.watch(prayerSettingsProvider);
  final now = DateTime.now();
  return PrayerCalculator.calculate(
    date: now,
    location: settings.location,
    asrMethod: settings.asrMethod,
    fajrAngle: settings.fajrAngle,
    ishaAngle: settings.ishaAngle,
    fajrOffset: settings.fajrOffset,
    sunriseOffset: settings.sunriseOffset,
    dhuhrOffset: settings.dhuhrOffset,
    asrOffset: settings.asrOffset,
    maghribOffset: settings.maghribOffset,
    ishaOffset: settings.ishaOffset,
  );
});

final nextPrayerProvider = Provider<({String name, String nameAr, DateTime time, Duration remaining})?>((ref) {
  final times = ref.watch(prayerTimesProvider);
  final now = DateTime.now();

  for (final prayer in times.list) {
    if (prayer.time.isAfter(now)) {
      return (
        name: prayer.name,
        nameAr: prayer.nameAr,
        time: prayer.time,
        remaining: prayer.time.difference(now),
      );
    }
  }
  // All prayers have passed; next is tomorrow's Fajr
  final tomorrowFajr = times.fajr.add(const Duration(days: 1));
  return (
    name: 'Fajr',
    nameAr: 'الفجر',
    time: tomorrowFajr,
    remaining: tomorrowFajr.difference(now),
  );
});

class CurrentTimeNotifier extends StateNotifier<DateTime> {
  CurrentTimeNotifier() : super(DateTime.now()) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = DateTime.now();
    });
  }

  late final Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

final currentTimeProvider = StateNotifierProvider<CurrentTimeNotifier, DateTime>(
  (ref) => CurrentTimeNotifier(),
);
