import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// ═══════════════════════════════════════════════════════════════════
// Engagement Data Model
// ═══════════════════════════════════════════════════════════════════

class EngagementData {
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final int totalAyahsRead;
  final int totalHadithsRead;
  final int totalMinutesSpent;
  final DateTime lastActiveDate;
  final List<DailyRecord> dailyRecords;
  final Map<String, int> surahReadCounts;

  const EngagementData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.totalAyahsRead = 0,
    this.totalHadithsRead = 0,
    this.totalMinutesSpent = 0,
    DateTime? lastActiveDate,
    this.dailyRecords = const [],
    this.surahReadCounts = const {},
  }) : lastActiveDate = lastActiveDate ?? DateTime.now();

  EngagementData copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalSessions,
    int? totalAyahsRead,
    int? totalHadithsRead,
    int? totalMinutesSpent,
    DateTime? lastActiveDate,
    List<DailyRecord>? dailyRecords,
    Map<String, int>? surahReadCounts,
  }) {
    return EngagementData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      totalAyahsRead: totalAyahsRead ?? this.totalAyahsRead,
      totalHadithsRead: totalHadithsRead ?? this.totalHadithsRead,
      totalMinutesSpent: totalMinutesSpent ?? this.totalMinutesSpent,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      dailyRecords: dailyRecords ?? this.dailyRecords,
      surahReadCounts: surahReadCounts ?? this.surahReadCounts,
    );
  }
}

class DailyRecord {
  final DateTime date;
  final int ayahsRead;
  final int hadithsRead;
  final int minutesSpent;
  final List<String> surahsRead;

  const DailyRecord({
    required this.date,
    this.ayahsRead = 0,
    this.hadithsRead = 0,
    this.minutesSpent = 0,
    this.surahsRead = const [],
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'ayahs_read': ayahsRead,
        'hadiths_read': hadithsRead,
        'minutes_spent': minutesSpent,
        'surahs_read': surahsRead,
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        date: DateTime.parse(json['date'] as String),
        ayahsRead: json['ayahs_read'] as int? ?? 0,
        hadithsRead: json['hadiths_read'] as int? ?? 0,
        minutesSpent: json['minutes_spent'] as int? ?? 0,
        surahsRead: (json['surahs_read'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}

// ═══════════════════════════════════════════════════════════════════
// Engagement Provider
// ═══════════════════════════════════════════════════════════════════

final engagementProvider =
    StateNotifierProvider<EngagementNotifier, EngagementData>((ref) {
  return EngagementNotifier();
});

class EngagementNotifier extends StateNotifier<EngagementData> {
  EngagementNotifier() : super(const EngagementData()) {
    _loadData();
  }

  void _loadData() {
    try {
      final box = Hive.box('engagement');
      final currentStreak = box.get('current_streak', defaultValue: 0) as int;
      final longestStreak = box.get('longest_streak', defaultValue: 0) as int;
      final totalSessions = box.get('total_sessions', defaultValue: 0) as int;
      final totalAyahsRead = box.get('total_ayahs_read', defaultValue: 0) as int;
      final totalHadithsRead = box.get('total_hadiths_read', defaultValue: 0) as int;
      final totalMinutesSpent = box.get('total_minutes_spent', defaultValue: 0) as int;
      final lastActiveStr = box.get('last_active_date') as String?;
      final lastActiveDate = lastActiveStr != null ? DateTime.parse(lastActiveStr) : DateTime.now();

      final dailyRecordsJson = box.get('daily_records') as String?;
      List<DailyRecord> dailyRecords = [];
      if (dailyRecordsJson != null) {
        final decoded = jsonDecode(dailyRecordsJson) as List;
        dailyRecords = decoded.map((e) => DailyRecord.fromJson(e as Map<String, dynamic>)).toList();
      }

      final surahCounts = Map<String, int>.from(
        box.get('surah_read_counts', defaultValue: <String, int>{}) as Map,
      );

      state = EngagementData(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        totalSessions: totalSessions,
        totalAyahsRead: totalAyahsRead,
        totalHadithsRead: totalHadithsRead,
        totalMinutesSpent: totalMinutesSpent,
        lastActiveDate: lastActiveDate,
        dailyRecords: dailyRecords,
        surahReadCounts: surahCounts,
      );
    } catch (_) {}
  }

  Future<void> _saveData() async {
    final box = Hive.box('engagement');
    await box.put('current_streak', state.currentStreak);
    await box.put('longest_streak', state.longestStreak);
    await box.put('total_sessions', state.totalSessions);
    await box.put('total_ayahs_read', state.totalAyahsRead);
    await box.put('total_hadiths_read', state.totalHadithsRead);
    await box.put('total_minutes_spent', state.totalMinutesSpent);
    await box.put('last_active_date', state.lastActiveDate.toIso8601String());
    await box.put('daily_records', jsonEncode(state.dailyRecords.map((r) => r.toJson()).toList()));
    await box.put('surah_read_counts', state.surahReadCounts);
  }

  Future<void> recordAppOpen() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = DateTime(state.lastActiveDate.year, state.lastActiveDate.month, state.lastActiveDate.day);

    if (today.difference(lastActive).inDays > 1) {
      // Streak broken
      state = state.copyWith(currentStreak: 0);
    }

    if (today.isAfter(lastActive) || today == lastActive) {
      // Same day or new day - update streak
      final newStreak = today.isAfter(lastActive) ? state.currentStreak + 1 : state.currentStreak;
      final newLongest = newStreak > state.longestStreak ? newStreak : state.longestStreak;
      state = state.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        totalSessions: state.totalSessions + 1,
        lastActiveDate: now,
      );
    }

    await _saveData();
  }

  Future<void> recordAyahRead(int count, {String surahName = ''}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Update or create daily record
    final existingIndex = state.dailyRecords.indexWhere(
      (r) => DateTime(r.date.year, r.date.month, r.date.day) == today,
    );
    List<DailyRecord> updatedRecords = List.from(state.dailyRecords);
    if (existingIndex != -1) {
      final existing = updatedRecords[existingIndex];
      updatedRecords[existingIndex] = DailyRecord(
        date: existing.date,
        ayahsRead: existing.ayahsRead + count,
        hadithsRead: existing.hadithsRead,
        minutesSpent: existing.minutesSpent,
        surahsRead: surahName.isNotEmpty && !existing.surahsRead.contains(surahName)
            ? [...existing.surahsRead, surahName]
            : existing.surahsRead,
      );
    } else {
      updatedRecords.add(DailyRecord(
        date: now,
        ayahsRead: count,
        surahsRead: surahName.isNotEmpty ? [surahName] : [],
      ));
    }

    // Update surah counts
    Map<String, int> updatedSurahCounts = Map.from(state.surahReadCounts);
    if (surahName.isNotEmpty) {
      updatedSurahCounts[surahName] = (updatedSurahCounts[surahName] ?? 0) + count;
    }

    state = state.copyWith(
      totalAyahsRead: state.totalAyahsRead + count,
      dailyRecords: updatedRecords,
      surahReadCounts: updatedSurahCounts,
    );

    await _saveData();
  }

  Future<void> recordHadithRead(int count) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final existingIndex = state.dailyRecords.indexWhere(
      (r) => DateTime(r.date.year, r.date.month, r.date.day) == today,
    );
    List<DailyRecord> updatedRecords = List.from(state.dailyRecords);
    if (existingIndex != -1) {
      final existing = updatedRecords[existingIndex];
      updatedRecords[existingIndex] = DailyRecord(
        date: existing.date,
        ayahsRead: existing.ayahsRead,
        hadithsRead: existing.hadithsRead + count,
        minutesSpent: existing.minutesSpent,
        surahsRead: existing.surahsRead,
      );
    } else {
      updatedRecords.add(DailyRecord(
        date: now,
        hadithsRead: count,
      ));
    }

    state = state.copyWith(
      totalHadithsRead: state.totalHadithsRead + count,
      dailyRecords: updatedRecords,
    );

    await _saveData();
  }

  Future<void> recordTimeSpent(int minutes) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final existingIndex = state.dailyRecords.indexWhere(
      (r) => DateTime(r.date.year, r.date.month, r.date.day) == today,
    );
    List<DailyRecord> updatedRecords = List.from(state.dailyRecords);
    if (existingIndex != -1) {
      final existing = updatedRecords[existingIndex];
      updatedRecords[existingIndex] = DailyRecord(
        date: existing.date,
        ayahsRead: existing.ayahsRead,
        hadithsRead: existing.hadithsRead,
        minutesSpent: existing.minutesSpent + minutes,
        surahsRead: existing.surahsRead,
      );
    } else {
      updatedRecords.add(DailyRecord(
        date: now,
        minutesSpent: minutes,
      ));
    }

    state = state.copyWith(
      totalMinutesSpent: state.totalMinutesSpent + minutes,
      dailyRecords: updatedRecords,
    );

    await _saveData();
  }

  List<DailyRecord> getWeeklyRecords() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return state.dailyRecords.where((r) => r.date.isAfter(weekAgo) || r.date.isAtSameMomentAs(weekAgo)).toList();
  }

  String getMostReadSurah() {
    if (state.surahReadCounts.isEmpty) return 'None yet';
    final sorted = state.surahReadCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  String getMotivationalMessage() {
    final streak = state.currentStreak;
    if (streak == 0) return 'Start your journey today! Open the Quran and begin.';
    if (streak < 3) return 'Great start! Keep coming back daily.';
    if (streak < 7) return 'You\'re building a habit! Almost a week!';
    if (streak < 14) return 'Over a week strong! Consistency is key.';
    if (streak < 30) return 'Impressive streak! You\'re dedicated to learning.';
    if (streak < 100) return 'Outstanding! You\'re in the top tier of engagement.';
    return 'Legendary! Over 100 days of consistency. May Allah reward you!';
  }

  List<Milestone> getMilestones() {
    final milestones = <Milestone>[];
    final streak = state.currentStreak;

    if (streak >= 1) milestones.add(Milestone(name: 'First Day', achieved: true, icon: Icons.star_rounded));
    if (streak >= 3) milestones.add(Milestone(name: '3-Day Streak', achieved: true, icon: Icons.local_fire_department_rounded));
    if (streak >= 7) milestones.add(Milestone(name: 'One Week', achieved: true, icon: Icons.emoji_events_rounded));
    if (streak >= 30) milestones.add(Milestone(name: 'One Month', achieved: true, icon: Icons.military_tech_rounded));
    if (streak >= 100) milestones.add(Milestone(name: '100 Days', achieved: true, icon: Icons.workspace_premium_rounded));
    if (streak < 3) milestones.add(Milestone(name: '3-Day Streak', achieved: false, icon: Icons.local_fire_department_rounded));
    if (streak < 7) milestones.add(Milestone(name: 'One Week', achieved: false, icon: Icons.emoji_events_rounded));
    if (streak < 30) milestones.add(Milestone(name: 'One Month', achieved: false, icon: Icons.military_tech_rounded));
    if (streak < 100) milestones.add(Milestone(name: '100 Days', achieved: false, icon: Icons.workspace_premium_rounded));

    return milestones;
  }
}

class Milestone {
  final String name;
  final bool achieved;
  final IconData icon;

  const Milestone({required this.name, required this.achieved, required this.icon});
}
