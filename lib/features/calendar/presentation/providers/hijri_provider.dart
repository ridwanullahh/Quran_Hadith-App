import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ─────────────────────────────────────────────────────────────

class HijriDate {
  final int day;
  final int month;
  final int year;
  final String monthNameAr;
  final String monthNameEn;
  final DateTime? gregorianEquivalent;

  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthNameAr,
    required this.monthNameEn,
    this.gregorianEquivalent,
  });
}

class HijriMonth {
  final int year;
  final int month;
  final String monthNameAr;
  final String monthNameEn;
  final int daysInMonth;
  final int startDayOfWeek; // 0=Monday, 6=Sunday
  final List<HijriDay> days;

  const HijriMonth({
    required this.year,
    required this.month,
    required this.monthNameAr,
    required this.monthNameEn,
    required this.daysInMonth,
    required this.startDayOfWeek,
    required this.days,
  });
}

class HijriDay {
  final int hijriDay;
  final DateTime gregorianDate;
  final bool isCurrentMonth;
  final bool isToday;
  final String? eventName;
  final Color? eventColor;

  const HijriDay({
    required this.hijriDay,
    required this.gregorianDate,
    required this.isCurrentMonth,
    required this.isToday,
    this.eventName,
    this.eventColor,
  });
}

class CalendarNavigation {
  final int hijriYear;
  final int hijriMonth;

  const CalendarNavigation({required this.hijriYear, required this.hijriMonth});
}

// ── Important Islamic Dates ────────────────────────────────────────────

class ImportantDates {
  /// Returns event info for a given Hijri month and day.
  /// Returns null if no special event.
  static ({String name, String nameAr, Color color})? getEvent(int month, int day) {
    // 1 Muharram - Islamic New Year
    if (month == 1 && day == 1) {
      return (name: 'Islamic New Year', nameAr: 'رأس السنة الهجرية', color: _green);
    }
    // 10 Muharram - Day of Ashura
    if (month == 1 && day == 10) {
      return (name: 'Day of Ashura', nameAr: 'يوم عاشوراء', color: _red);
    }
    // 12 Rabi al-Awwal - Mawlid al-Nabi
    if (month == 3 && day == 12) {
      return (name: 'Mawlid al-Nabi', nameAr: 'المولد النبوي', color: _green);
    }
    // 27 Rajab - Isra and Mi'raj
    if (month == 7 && day == 27) {
      return (name: 'Isra & Mi\'raj', nameAr: 'الإسراء والمعراج', color: _blue);
    }
    // 15 Sha'ban - Shab-e-Barat
    if (month == 8 && day == 15) {
      return (name: 'Shab-e-Barat', nameAr: 'ليلة النصف من شعبان', color: _purple);
    }
    // 1 Ramadan - Start of Ramadan
    if (month == 9 && day == 1) {
      return (name: 'Ramadan Begins', nameAr: 'بداية رمضان', color: _gold);
    }
    // 27 Ramadan - Laylat al-Qadr (commonly observed)
    if (month == 9 && day == 27) {
      return (name: 'Laylat al-Qadr', nameAr: 'ليلة القدر', color: _gold);
    }
    // 1 Shawwal - Eid al-Fitr
    if (month == 10 && day == 1) {
      return (name: 'Eid al-Fitr', nameAr: 'عيد الفطر', color: _green);
    }
    // 9 Dhul Hijjah - Day of Arafah
    if (month == 12 && day == 9) {
      return (name: 'Day of Arafah', nameAr: 'يوم عرفة', color: _green);
    }
    // 10 Dhul Hijjah - Eid al-Adha
    if (month == 12 && day == 10) {
      return (name: 'Eid al-Adha', nameAr: 'عيد الأضحى', color: _green);
    }
    return null;
  }

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);
  static const _purple = Color(0xFF7C3AED);
  static const _gold = Color(0xFFD4A843);
}

// ── Converter ──────────────────────────────────────────────────────────

class HijriCalendar {
  static const double _epoch = 1948439.5;
  static const double _synodicMonth = 29.530588853;

  static const _monthNamesAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static const _monthNamesEn = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhul Qi'dah", 'Dhul Hijjah',
  ];

  static const _monthDays = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];

  /// Check if a Hijri year is a leap year (30-year cycle).
  static bool isLeapYear(int year) {
    final cycle = ((year - 1) % 30 + 30) % 30;
    return [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29].contains(cycle);
  }

  /// Days in a given Hijri month.
  static int daysInMonth(int year, int month) {
    if (month == 12 && isLeapYear(year)) return 30;
    return _monthDays[month - 1];
  }

  /// Convert Gregorian DateTime to HijriDate.
  static HijriDate gregorianToHijri(DateTime date) {
    final jd = _gregorianToJulianDay(date);
    final daysSinceEpoch = jd - _epoch;
    final totalMonths = (daysSinceEpoch / _synodicMonth).floor();
    var year = (totalMonths / 12).floor() + 1;
    var month = totalMonths % 12 + 1;
    var day = (daysSinceEpoch - _floorMonthSum(totalMonths)).floor() + 1;

    final maxDay = daysInMonth(year, month);
    if (day > maxDay) {
      day -= maxDay;
      month++;
      if (month > 12) { month = 1; year++; }
    }
    if (day < 1) {
      month--;
      if (month < 1) { month = 12; year--; }
      day += daysInMonth(year, month);
    }

    return HijriDate(
      day: day,
      month: month,
      year: year,
      monthNameAr: _monthNamesAr[month - 1],
      monthNameEn: _monthNamesEn[month - 1],
      gregorianEquivalent: date,
    );
  }

  /// Convert Hijri date to approximate Gregorian date.
  static DateTime hijriToGregorian(int hYear, int hMonth, int hDay) {
    // Calculate Julian day from Hijri date
    final totalMonths = (hYear - 1) * 12 + (hMonth - 1);
    final jd = _epoch + _floorMonthSum(totalMonths) + (hDay - 1);
    return _julianDayToGregorian(jd);
  }

  /// Get a full HijriMonth grid for a given year and month.
  static HijriMonth getMonthGrid(int hYear, int hMonth) {
    final today = DateTime.now();
    final todayHijri = gregorianToHijri(today);
    final daysCount = daysInMonth(hYear, hMonth);

    // Find the Gregorian date for the 1st of this Hijri month
    final firstOfMonth = hijriToGregorian(hYear, hMonth, 1);
    // What day of week is it? (0=Monday in our grid)
    var weekday = firstOfMonth.weekday - 1; // 0=Mon, 6=Sun
    if (weekday < 0) weekday += 7;

    final days = <HijriDay>[];

    // Previous month fill
    final prevMonth = hMonth == 1 ? 12 : hMonth - 1;
    final prevYear = hMonth == 1 ? hYear - 1 : hYear;
    final prevDays = daysInMonth(prevYear, prevMonth);
    for (int i = weekday - 1; i >= 0; i--) {
      final hDay = prevDays - i;
      final gregDate = firstOfMonth.subtract(Duration(days: weekday - i));
      final evt = ImportantDates.getEvent(prevMonth, hDay);
      days.add(HijriDay(
        hijriDay: hDay,
        gregorianDate: gregDate,
        isCurrentMonth: false,
        isToday: false,
        eventName: evt?.name,
        eventColor: evt?.color,
      ));
    }

    // Current month days
    for (int d = 1; d <= daysCount; d++) {
      final gregDate = firstOfMonth.add(Duration(days: d - 1));
      final isToday = hYear == todayHijri.year &&
          hMonth == todayHijri.month &&
          d == todayHijri.day;
      final evt = ImportantDates.getEvent(hMonth, d);
      days.add(HijriDay(
        hijriDay: d,
        gregorianDate: gregDate,
        isCurrentMonth: true,
        isToday: isToday,
        eventName: evt?.name,
        eventColor: evt?.color,
      ));
    }

    // Next month fill to complete 6 rows (42 cells)
    final nextMonth = hMonth == 12 ? 1 : hMonth + 1;
    final nextYear = hMonth == 12 ? hYear + 1 : hYear;
    var nextDay = 1;
    while (days.length < 42) {
      final gregDate = firstOfMonth.add(Duration(days: days.length - weekday));
      final evt = ImportantDates.getEvent(nextMonth, nextDay);
      days.add(HijriDay(
        hijriDay: nextDay,
        gregorianDate: gregDate,
        isCurrentMonth: false,
        isToday: false,
        eventName: evt?.name,
        eventColor: evt?.color,
      ));
      nextDay++;
    }

    return HijriMonth(
      year: hYear,
      month: hMonth,
      monthNameAr: _monthNamesAr[hMonth - 1],
      monthNameEn: _monthNamesEn[hMonth - 1],
      daysInMonth: daysCount,
      startDayOfWeek: weekday,
      days: days,
    );
  }

  static double _gregorianToJulianDay(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day + (date.hour + date.minute / 60.0 + date.second / 3600.0) / 24.0;
    final a = (14 - m) ~/ 12;
    final y1 = y + 4800 - a;
    final m1 = m + 12 * a - 3;
    return d + (153 * m1 + 2) ~/ 5 + 365 * y1 + y1 ~/ 4 - y1 ~/ 100 + y1 ~/ 400 - 32045.5;
  }

  static DateTime _julianDayToGregorian(double jd) {
 var z = (jd + 0.5).floor();
    var a = z;
    final alpha = ((z - 1867216.25) / 36524.25).floor();
    a = z + 1 + alpha - (alpha ~/ 4);
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();
    final day = b - d - (30.6001 * e).floor();
    var month = e < 14 ? e - 1 : e - 13;
    var year = month > 2 ? c - 4716 : c - 4715;
    return DateTime(year, month, day);
  }

  static double _floorMonthSum(int totalMonths) {
    double sum = 0;
    for (int i = 0; i < totalMonths; i++) {
      sum += (i % 2 == 0) ? 30.0 : 29.0;
    }
    return sum;
  }
}

// ── Providers ───────────────────────────────────────────────────────────

final currentHijriDateProvider = Provider<HijriDate>((ref) {
  return HijriCalendar.gregorianToHijri(DateTime.now());
});

final calendarNavigationProvider =
    StateProvider<CalendarNavigation>((ref) {
  final today = HijriCalendar.gregorianToHijri(DateTime.now());
  return CalendarNavigation(hijriYear: today.year, hijriMonth: today.month);
});

final hijriMonthProvider = Provider<HijriMonth>((ref) {
  final nav = ref.watch(calendarNavigationProvider);
  return HijriCalendar.getMonthGrid(nav.hijriYear, nav.hijriMonth);
});
