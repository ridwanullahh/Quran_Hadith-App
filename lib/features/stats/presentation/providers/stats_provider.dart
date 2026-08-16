import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/database/database.dart';

/// Statistics data model for the reading insights screen.
class ReadingStats {
  final int ayahsToday;
  final int ayahsThisWeek;
  final int ayahsThisMonth;
  final int ayahsAllTime;
  final int currentStreak;
  final int longestStreak;
  final double averageDaily;
  final int totalReadingTimeMinutes;
  final List<SurahReadCount> mostReadSurahs;
  final List<DailyReadCount> dailyHistory;

  const ReadingStats({
    this.ayahsToday = 0,
    this.ayahsThisWeek = 0,
    this.ayahsThisMonth = 0,
    this.ayahsAllTime = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.averageDaily = 0.0,
    this.totalReadingTimeMinutes = 0,
    this.mostReadSurahs = const [],
    this.dailyHistory = const [],
  });
}

/// Counts for a single surah.
class SurahReadCount {
  final int surahNumber;
  final String surahName;
  final int ayahsRead;

  const SurahReadCount({
    required this.surahNumber,
    required this.surahName,
    required this.ayahsRead,
  });
}

/// Counts for a single day.
class DailyReadCount {
  final DateTime date;
  final int ayahsRead;

  const DailyReadCount({required this.date, required this.ayahsRead});
}

/// Provider that computes reading statistics from the database.
final statsProvider = FutureProvider.autoDispose<ReadingStats>((ref) async {
  final db = AppDatabase.instance;

  // Get all reading history (up to 10000 entries)
  final allHistory = await db.getReadingHistory(limit: 10000);
  if (allHistory.isEmpty) {
    return const ReadingStats();
  }

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(const Duration(days: 7));
  final monthStart = DateTime(now.year, now.month, 1);

  // ── Count ayahs by time period ────────────────────────────────
  int ayahsToday = 0;
  int ayahsThisWeek = 0;
  int ayahsThisMonth = 0;
  int totalReadingTime = 0;

  // Track unique (surah, ayah) per day for accurate counts
  final todaySet = <String>{};
  final weekSet = <String>{};
  final monthSet = <String>{};
  final allTimeSet = <String>{};

  // Track daily history (last 30 days)
  final dailyMap = <String, int>{};
  final surahMap = <int, int>{};

  for (final entry in allHistory) {
    final key = '${entry.surahNumber}:${entry.ayahNumber}';
    final dayKey =
        '${entry.readAt.year}-${entry.readAt.month}-${entry.readAt.day}';

    totalReadingTime += entry.timeSpentSeconds;
    surahMap[entry.surahNumber] = (surahMap[entry.surahNumber] ?? 0) + 1;

    // Daily history
    dailyMap[dayKey] = (dailyMap[dayKey] ?? 0) + 1;

    if (entry.readAt.isAfter(todayStart) || entry.readAt.isAtSameMomentAs(todayStart)) {
      todaySet.add(key);
    }
    if (entry.readAt.isAfter(weekStart) || entry.readAt.isAtSameMomentAs(weekStart)) {
      weekSet.add(key);
    }
    if (entry.readAt.isAfter(monthStart) || entry.readAt.isAtSameMomentAs(monthStart)) {
      monthSet.add(key);
    }
    allTimeSet.add(key);
  }

  // ── Compute streak ─────────────────────────────────────────────
  int currentStreak = 0;
  int longestStreak = 0;
  int tempStreak = 0;
  DateTime checkDate = todayStart;

  // Collect unique reading dates
  final readingDates = <DateTime>{};
  for (final entry in allHistory) {
    readingDates.add(
      DateTime(entry.readAt.year, entry.readAt.month, entry.readAt.day),
    );
  }

  // Calculate current streak
  for (int i = 0; i < 365; i++) {
    final day = checkDate.subtract(Duration(days: i));
    if (readingDates.contains(day)) {
      if (i == 0) {
        currentStreak++;
      }
      tempStreak++;
    } else if (i == 0) {
      // Today might not have reading yet, check yesterday
      continue;
    } else {
      break;
    }
  }

  // Calculate longest streak
  tempStreak = 0;
  for (int i = 0; i < 365; i++) {
    final day = todayStart.subtract(Duration(days: i));
    if (readingDates.contains(day)) {
      tempStreak++;
      if (tempStreak > longestStreak) longestStreak = tempStreak;
    } else {
      tempStreak = 0;
    }
  }

  // ── Average daily ────────────────────────────────────────────
  final numDays = readingDates.isEmpty
      ? 1
      : todayStart
          .difference(readingDates.reduce(
            (a, b) => a.isBefore(b) ? a : b,
          ))
          .inDays
          .clamp(1, 365);
  final averageDaily = allTimeSet.length / numDays;

  // ── Most read surahs (top 10) ────────────────────────────────
  final sortedSurahs = surahMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final topSurahs = sortedSurahs.take(10).map((e) {
    return SurahReadCount(
      surahNumber: e.key,
      surahName: _surahName(e.key),
      ayahsRead: e.value,
    );
  }).toList();

  // ── Daily history (last 30 days) ──────────────────────────────
  final dailyHistory = <DailyReadCount>[];
  for (int i = 29; i >= 0; i--) {
    final day = todayStart.subtract(Duration(days: i));
    final dayKey =
        '${day.year}-${day.month}-${day.day}';
    dailyHistory.add(
      DailyReadCount(date: day, ayahsRead: dailyMap[dayKey] ?? 0),
    );
  }

  return ReadingStats(
    ayahsToday: todaySet.length,
    ayahsThisWeek: weekSet.length,
    ayahsThisMonth: monthSet.length,
    ayahsAllTime: allTimeSet.length,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    averageDaily: averageDaily,
    totalReadingTimeMinutes: (totalReadingTime / 60).round(),
    mostReadSurahs: topSurahs,
    dailyHistory: dailyHistory,
  );
});

/// Simple surah name lookup (top 114 surahs).
String _surahName(int number) {
  const names = {
    1: 'Al-Fatiha', 2: 'Al-Baqarah', 3: 'Aal-E-Imran', 4: 'An-Nisa',
    5: 'Al-Ma\'idah', 6: 'Al-An\'am', 7: 'Al-A\'raf', 8: 'Al-Anfal',
    9: 'At-Tawbah', 10: 'Yunus', 11: 'Hud', 12: 'Yusuf',
    13: 'Ar-Ra\'d', 14: 'Ibrahim', 15: 'Al-Hijr', 16: 'An-Nahl',
    17: 'Al-Isra', 18: 'Al-Kahf', 19: 'Maryam', 20: 'Ta-Ha',
    21: 'Al-Anbiya', 22: 'Al-Hajj', 23: 'Al-Mu\'minun', 24: 'An-Nur',
    25: 'Al-Furqan', 26: 'Ash-Shu\'ara', 27: 'An-Naml', 28: 'Al-Qasas',
    29: 'Al-Ankabut', 30: 'Ar-Rum', 31: 'Luqman', 32: 'As-Sajdah',
    33: 'Al-Ahzab', 34: 'Saba', 35: 'Fatir', 36: 'Ya-Sin',
    37: 'As-Saffat', 38: 'Sad', 39: 'Az-Zumar', 40: 'Ghafir',
    41: 'Fussilat', 42: 'Ash-Shura', 43: 'Az-Zukhruf', 44: 'Ad-Dukhan',
    45: 'Al-Jathiyah', 46: 'Al-Ahqaf', 47: 'Muhammad', 48: 'Al-Fath',
    49: 'Al-Hujurat', 50: 'Qaf', 51: 'Adh-Dhariyat', 52: 'At-Tur',
    53: 'An-Najm', 54: 'Al-Qamar', 55: 'Ar-Rahman', 56: 'Al-Waqi\'ah',
    57: 'Al-Hadid', 58: 'Al-Mujadilah', 59: 'Al-Hashr', 60: 'Al-Mumtahanah',
    61: 'As-Saf', 62: 'Al-Jumu\'ah', 63: 'Al-Munafiqun', 64: 'At-Taghabun',
    65: 'At-Talaq', 66: 'At-Tahrim', 67: 'Al-Mulk', 68: 'Al-Qalam',
    69: 'Al-Haqqah', 70: 'Al-Ma\'arij', 71: 'Nuh', 72: 'Al-Jinn',
    73: 'Al-Muzzammil', 74: 'Al-Muddaththir', 75: 'Al-Qiyamah', 76: 'Al-Insan',
    77: 'Al-Mursalat', 78: 'An-Naba', 79: 'An-Nazi\'at', 80: 'Abasa',
    81: 'At-Takwir', 82: 'Al-Infitar', 83: 'Al-Mutaffifin', 84: 'Al-Inshiqaq',
    85: 'Al-Buruj', 86: 'At-Tariq', 87: 'Al-A\'la', 88: 'Al-Ghashiyah',
    89: 'Al-Fajr', 90: 'Al-Balad', 91: 'Ash-Shams', 92: 'Al-Lail',
    93: 'Ad-Duha', 94: 'Ash-Sharh', 95: 'At-Tin', 96: 'Al-Alaq',
    97: 'Al-Qadr', 98: 'Al-Bayyinah', 99: 'Az-Zalzalah', 100: 'Al-Adiyat',
    101: 'Al-Qari\'ah', 102: 'At-Takathur', 103: 'Al-Asr', 104: 'Al-Humazah',
    105: 'Al-Fil', 106: 'Quraysh', 107: 'Al-Ma\'un', 108: 'Al-Kawthar',
    109: 'Al-Kafirun', 110: 'An-Nasr', 111: 'Al-Masad', 112: 'Al-Ikhlas',
    113: 'Al-Falaq', 114: 'An-Nas',
  };
  return names[number] ?? 'Surah $number';
}
