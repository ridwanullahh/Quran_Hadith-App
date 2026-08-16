import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Reading History Entry
// ═══════════════════════════════════════════════════════════════════

class HadithHistoryEntry {
  final String collectionId;
  final int bookNumber;
  final int hadithNumber;
  final DateTime readAt;

  const HadithHistoryEntry({
    required this.collectionId,
    required this.bookNumber,
    required this.hadithNumber,
    required this.readAt,
  });

  String get uniqueId => '${collectionId}_${bookNumber}_$hadithNumber';

  Map<String, dynamic> toMap() => {
        'collectionId': collectionId,
        'bookNumber': bookNumber,
        'hadithNumber': hadithNumber,
        'readAt': readAt.toIso8601String(),
      };

  factory HadithHistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    return HadithHistoryEntry(
      collectionId: map['collectionId'] as String? ?? '',
      bookNumber: map['bookNumber'] as int? ?? 0,
      hadithNumber: map['hadithNumber'] as int? ?? 0,
      readAt: map['readAt'] != null
          ? DateTime.tryParse(map['readAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Reading Stats
// ═══════════════════════════════════════════════════════════════════

class HadithReadingStats {
  final int totalHadithsRead;
  final Map<String, int> hadithsByCollection;
  final HadithHistoryEntry? lastRead;
  final int streakDays;

  const HadithReadingStats({
    required this.totalHadithsRead,
    required this.hadithsByCollection,
    this.lastRead,
    required this.streakDays,
  });
}

// ═══════════════════════════════════════════════════════════════════
// History Notifier
// ═══════════════════════════════════════════════════════════════════

class HadithHistoryNotifier extends StateNotifier<List<HadithHistoryEntry>> {
  HadithHistoryNotifier() : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    try {
      final box = Hive.box('hadith_history');
      final entries = <HadithHistoryEntry>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          entries.add(HadithHistoryEntry.fromMap(val));
        }
      }
      entries.sort((a, b) => b.readAt.compareTo(a.readAt));
      state = entries;
    } catch (_) {
      state = [];
    }
  }

  /// Record that a hadith was read. Avoids duplicates.
  Future<void> markAsRead({
    required String collectionId,
    required int bookNumber,
    required int hadithNumber,
  }) async {
    try {
      final box = Hive.box('hadith_history');
      final key = '${collectionId}_${bookNumber}_$hadithNumber';

      // Don't re-record if already read today
      if (box.containsKey(key)) {
        final existing = box.get(key) as Map;
        final prevDate = existing['readAt'] as String;
        final prev = DateTime.tryParse(prevDate);
        if (prev != null) {
          final now = DateTime.now();
          if (prev.year == now.year &&
              prev.month == now.month &&
              prev.day == now.day) {
            return;
          }
        }
      }

      final entry = HadithHistoryEntry(
        collectionId: collectionId,
        bookNumber: bookNumber,
        hadithNumber: hadithNumber,
        readAt: DateTime.now(),
      );

      await box.put(key, entry.toMap());
      state = [entry, ...state.where((e) => e.uniqueId != key)].toList();
    } catch (_) {}
  }

  /// Get reading stats
  HadithReadingStats getStats() {
    final byCollection = <String, int>{};
    for (final entry in state) {
      byCollection[entry.collectionId] =
          (byCollection[entry.collectionId] ?? 0) + 1;
    }

    // Calculate streak days
    int streak = 0;
    final now = DateTime.now();
    final uniqueDays = state
        .map((e) => DateTime(e.readAt.year, e.readAt.month, e.readAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDays.isNotEmpty) {
      var checkDate = DateTime(now.year, now.month, now.day);
      for (final day in uniqueDays) {
        if (day == checkDate) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (day.isBefore(checkDate)) {
          break;
        }
      }
    }

    return HadithReadingStats(
      totalHadithsRead: state.length,
      hadithsByCollection: byCollection,
      lastRead: state.isNotEmpty ? state.first : null,
      streakDays: streak,
    );
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      final box = Hive.box('hadith_history');
      await box.clear();
      state = [];
    } catch (_) {}
  }
}

// ═══════════════════════════════════════════════════════════════════
// Provider
// ═══════════════════════════════════════════════════════════════════

final hadithHistoryProvider =
    StateNotifierProvider<HadithHistoryNotifier, List<HadithHistoryEntry>>((
  ref,
) {
  return HadithHistoryNotifier();
});

final hadithReadingStatsProvider = Provider<HadithReadingStats>((ref) {
  final notifier = ref.watch(hadithHistoryProvider.notifier);
  return notifier.getStats();
});
