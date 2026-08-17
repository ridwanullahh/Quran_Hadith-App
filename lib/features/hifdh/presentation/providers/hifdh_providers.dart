import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/database/database.dart';
import '../../../../data/models/quran/ayah_data.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../../../../data/repositories/quran_repository.dart';

// ═══════════════════════════════════════════════════════════════════
// Database & Repository Providers
// ═══════════════════════════════════════════════════════════════════

final hifdhDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final hifdhDaoProvider = Provider<HifdhDao>((ref) {
  return ref.watch(hifdhDatabaseProvider).hifdhDao;
});

final hifdhQuranRepoProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

// ═══════════════════════════════════════════════════════════════════
// Hifzh Statistics Model
// ═══════════════════════════════════════════════════════════════════

class HifzhStats {
  final int totalMemorized;
  final int totalLearning;
  final int totalReview;
  final int totalNew;
  final int totalMastered;
  final int totalDueReviews;
  final int juzCompleted;
  final int currentStreak;
  final double overallAccuracy;
  final Map<String, int> statusBreakdown;
  final List<MemorizationProgress> dueReviewItems;
  final List<MistakeLog> weakAreas;
  final List<RevisionSchedule> pendingRevisions;
  final Map<int, List<MemorizationProgress>> progressBySurah;

  const HifzhStats({
    this.totalMemorized = 0,
    this.totalLearning = 0,
    this.totalReview = 0,
    this.totalNew = 0,
    this.totalMastered = 0,
    this.totalDueReviews = 0,
    this.juzCompleted = 0,
    this.currentStreak = 0,
    this.overallAccuracy = 0.0,
    this.statusBreakdown = const {},
    this.dueReviewItems = const [],
    this.weakAreas = const [],
    this.pendingRevisions = const [],
    this.progressBySurah = const {},
  });

  int get totalTracked => totalMemorized + totalLearning + totalReview + totalNew + totalMastered;
  double get memorizationPercentage {
    if (totalTracked == 0) return 0.0;
    return ((totalMemorized + totalMastered) / 6236) * 100;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Dashboard Stats Provider
// ═══════════════════════════════════════════════════════════════════

final hifzhStatsProvider = FutureProvider<HifzhStats>((ref) async {
  final dao = ref.watch(hifdhDaoProvider);

  final results = await Future.wait([
    dao.getProgressStats(),
    dao.getDueReviews(),
    dao.getFrequentMistakes(limit: 10),
    dao.getPendingRevisions(),
    dao.getAllProgress(),
  ]);

  final statusStats = results[0] as Map<String, int>;
  final dueReviews = results[1] as List<MemorizationProgress>;
  final weakAreas = results[2] as List<MistakeLog>;
  final pendingRevisions = results[3] as List<RevisionSchedule>;
  final allProgress = results[4] as List<MemorizationProgress>;

  // Build progress grouped by surah
  final progressBySurah = <int, List<MemorizationProgress>>{};
  for (final p in allProgress) {
    progressBySurah.putIfAbsent(p.surahNumber, () => []).add(p);
  }

  // Calculate juz completed (all ayahs in a juz are memorized/mastered)
  int juzCompleted = 0;
  for (int juz = 1; juz <= 30; juz++) {
    // Simple heuristic: check if we have enough progress entries
    // that fall within this juz and are all memorized/mastered
    final juzEntries = allProgress.where((p) {
      // Approximate juz membership based on surah number
      return _isInJuz(p.surahNumber, p.ayahNumber, juz);
    }).toList();
    if (juzEntries.isNotEmpty &&
        juzEntries.every((p) => p.status == 'memorized' || p.status == 'mastered')) {
      juzCompleted++;
    }
  }

  // Calculate streak (consecutive days with reviews)
  int streak = 0;
  final reviewDates = allProgress
      .where((p) => p.lastReviewed != null)
      .map((p) => DateTime(
            p.lastReviewed!.year,
            p.lastReviewed!.month,
            p.lastReviewed!.day,
          ))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  if (reviewDates.isNotEmpty) {
    streak = 1;
    for (int i = 1; i < reviewDates.length; i++) {
      final diff = reviewDates[i - 1].difference(reviewDates[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
  }

  // Calculate overall accuracy
  double accuracy = 0.0;
  final entriesWithAttempts = allProgress.where((p) => p.totalAttempts > 0).toList();
  if (entriesWithAttempts.isNotEmpty) {
    final totalCorrect = entriesWithAttempts.fold<int>(
        0, (sum, p) => sum + p.totalCorrect);
    final totalAttempts = entriesWithAttempts.fold<int>(
        0, (sum, p) => sum + p.totalAttempts);
    accuracy = totalAttempts > 0 ? (totalCorrect / totalAttempts) * 100 : 0.0;
  }

  return HifzhStats(
    totalMemorized: statusStats['memorized'] ?? 0,
    totalLearning: statusStats['learning'] ?? 0,
    totalReview: statusStats['review'] ?? 0,
    totalNew: statusStats['new'] ?? 0,
    totalMastered: statusStats['mastered'] ?? 0,
    totalDueReviews: dueReviews.length,
    juzCompleted: juzCompleted,
    currentStreak: streak,
    overallAccuracy: accuracy,
    statusBreakdown: statusStats,
    dueReviewItems: dueReviews,
    weakAreas: weakAreas,
    pendingRevisions: pendingRevisions,
    progressBySurah: progressBySurah,
  );
});

// ═══════════════════════════════════════════════════════════════════
// Surah List (for selector in test/new memorization)
// ═══════════════════════════════════════════════════════════════════

final surahListForHifdhProvider = FutureProvider<List<SurahInfo>>((ref) {
  final repo = ref.watch(hifdhQuranRepoProvider);
  return repo.getAllSurahs();
});

// ═══════════════════════════════════════════════════════════════════
// Per-Surah Progress Provider
// ═══════════════════════════════════════════════════════════════════

final surahHifdhProgressProvider =
    FutureProvider.family<List<MemorizationProgress>, int>((ref, surahNumber) {
  final dao = ref.watch(hifdhDaoProvider);
  return dao.getProgressBySurah(surahNumber);
});

// ═══════════════════════════════════════════════════════════════════
// Hifdh Test State
// ═══════════════════════════════════════════════════════════════════

enum HifdhTestMode { listen, read, hideReveal }

enum HifdhTestPhase { setup, testing, results }

class HifdhTestResult {
  final int surahNumber;
  final int ayahStart;
  final int ayahEnd;
  final int totalAyahs;
  final int correctCount;
  final int mistakeCount;
  final int skippedCount;
  final double score;
  final List<AyahTestResult> ayahResults;
  final Duration testDuration;

  const HifdhTestResult({
    required this.surahNumber,
    required this.ayahStart,
    required this.ayahEnd,
    required this.totalAyahs,
    required this.correctCount,
    required this.mistakeCount,
    required this.skippedCount,
    required this.score,
    required this.ayahResults,
    required this.testDuration,
  });

  String get gradeLetter {
    if (score >= 95) return 'A+';
    if (score >= 90) return 'A';
    if (score >= 85) return 'B+';
    if (score >= 80) return 'B';
    if (score >= 75) return 'C+';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  String get performanceMessage {
    if (score >= 95) return 'Excellent! MashaAllah!';
    if (score >= 85) return 'Great work! Keep it up!';
    if (score >= 75) return 'Good effort. Keep practicing!';
    if (score >= 60) return 'Needs more revision.';
    return 'Focus on weak areas and try again.';
  }
}

class AyahTestResult {
  final int ayahNumber;
  final String textArabic;
  final bool isCorrect;
  final bool wasSkipped;
  final String? userResponse;
  final List<String> mistakes;

  const AyahTestResult({
    required this.ayahNumber,
    required this.textArabic,
    required this.isCorrect,
    this.wasSkipped = false,
    this.userResponse,
    this.mistakes = const [],
  });
}

class HifdhTestState {
  final HifdhTestPhase phase;
  final HifdhTestMode mode;
  final int? selectedSurah;
  final int ayahStart;
  final int ayahEnd;
  final int currentAyahIndex;
  final List<AyahData> ayahs;
  final List<AyahTestResult> results;
  final bool isRevealed;
  final HifdhTestResult? finalResult;
  final DateTime testStartTime;
  final String? lastError;

  HifdhTestState({
    this.phase = HifdhTestPhase.setup,
    this.mode = HifdhTestMode.hideReveal,
    this.selectedSurah,
    this.ayahStart = 1,
    this.ayahEnd = 7,
    this.currentAyahIndex = 0,
    this.ayahs = const [],
    this.results = const [],
    this.isRevealed = false,
    this.finalResult,
    this.lastError,
    DateTime? testStartTime,
  }) : this.testStartTime = testStartTime ?? DateTime.now();

  HifdhTestState copyWith({
    HifdhTestPhase? phase,
    HifdhTestMode? mode,
    int? selectedSurah,
    int? ayahStart,
    int? ayahEnd,
    int? currentAyahIndex,
    List<AyahData>? ayahs,
    List<AyahTestResult>? results,
    bool? isRevealed,
    HifdhTestResult? finalResult,
    DateTime? testStartTime,
    String? lastError,
    bool clearError = false,
  }) {
    return HifdhTestState(
      phase: phase ?? this.phase,
      mode: mode ?? this.mode,
      selectedSurah: selectedSurah ?? this.selectedSurah,
      ayahStart: ayahStart ?? this.ayahStart,
      ayahEnd: ayahEnd ?? this.ayahEnd,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      ayahs: ayahs ?? this.ayahs,
      results: results ?? this.results,
      isRevealed: isRevealed ?? this.isRevealed,
      finalResult: finalResult,
      testStartTime: testStartTime ?? this.testStartTime,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  double get progress {
    if (ayahs.isEmpty) return 0.0;
    return (currentAyahIndex + 1) / ayahs.length;
  }
}

class HifdhTestNotifier extends StateNotifier<HifdhTestState> {
  final HifdhDao _dao;
  final QuranRepository _repo;

  HifdhTestNotifier(this._dao, this._repo) : super(HifdhTestState());

  void setMode(HifdhTestMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setSurah(int surahNumber) {
    state = state.copyWith(selectedSurah: surahNumber);
  }

  void setAyahRange(int start, int end) {
    state = state.copyWith(ayahStart: start, ayahEnd: end);
  }

  Future<void> startTest() async {
    final surah = state.selectedSurah;
    if (surah == null) return;

    try {
      final allAyahs = await _repo.getSurahAyahs(surah);
      final filtered = allAyahs
          .where((a) => a.ayahNumber >= state.ayahStart && a.ayahNumber <= state.ayahEnd)
          .toList();

      if (filtered.isEmpty) {
        state = state.copyWith(
          lastError: 'No ayahs found in the selected range '
              '(${state.ayahStart}-${state.ayahEnd}) for surah $surah.',
        );
        return;
      }

      state = HifdhTestState(
        phase: HifdhTestPhase.testing,
        mode: state.mode,
        selectedSurah: surah,
        ayahStart: state.ayahStart,
        ayahEnd: state.ayahEnd,
        ayahs: filtered,
        testStartTime: DateTime.now(),
      );
    } catch (e, st) {
      // Surface the error to the UI instead of silently no-op'ing so the
      // user knows why the test did not start.
      debugPrint('[HifdhTestNotifier.startTest] failed: $e\n$st');
      state = state.copyWith(
        lastError: 'Failed to load ayahs for surah $surah: $e',
      );
    }
  }

  void revealAyah() {
    state = state.copyWith(isRevealed: true);
  }

  Future<void> markCorrect() async {
    if (state.ayahs.isEmpty) return;
    final ayah = state.ayahs[state.currentAyahIndex];

    final result = AyahTestResult(
      ayahNumber: ayah.ayahNumber,
      textArabic: ayah.textUthmani,
      isCorrect: true,
    );

    // Record review with quality 5 (perfect). Await so DB errors are
    // surfaced and notifyProgressChanged fires before _advanceToNext.
    try {
      await _dao.recordReview(
        surahNumber: state.selectedSurah!,
        ayahNumber: ayah.ayahNumber,
        quality: 5,
      );
    } catch (e, st) {
      debugPrint('[HifdhTestNotifier.markCorrect] DB error: $e\n$st');
    }

    final newResults = [...state.results, result];
    _advanceToNext(newResults);
  }

  Future<void> markMistake({List<String> mistakes = const []}) async {
    if (state.ayahs.isEmpty) return;
    final ayah = state.ayahs[state.currentAyahIndex];

    final result = AyahTestResult(
      ayahNumber: ayah.ayahNumber,
      textArabic: ayah.textUthmani,
      isCorrect: false,
      mistakes: mistakes,
    );

    // Record review with quality 2 (incorrect)
    try {
      await _dao.recordReview(
        surahNumber: state.selectedSurah!,
        ayahNumber: ayah.ayahNumber,
        quality: 2,
      );
    } catch (e, st) {
      debugPrint('[HifdhTestNotifier.markMistake] DB error: $e\n$st');
    }

    // Log mistake
    for (final mistake in mistakes) {
      try {
        await _dao.logMistake(
          surahNumber: state.selectedSurah!,
          ayahNumber: ayah.ayahNumber,
          mistakeType: mistake,
          correctText: ayah.textUthmani,
        );
      } catch (e, st) {
        debugPrint('[HifdhTestNotifier.markMistake] logMistake error: $e\n$st');
      }
    }

    final newResults = [...state.results, result];
    _advanceToNext(newResults);
  }

  void skipAyah() {
    if (state.ayahs.isEmpty) return;
    final ayah = state.ayahs[state.currentAyahIndex];

    final result = AyahTestResult(
      ayahNumber: ayah.ayahNumber,
      textArabic: ayah.textUthmani,
      isCorrect: false,
      wasSkipped: true,
    );

    final newResults = [...state.results, result];
    _advanceToNext(newResults);
  }

  void _advanceToNext(List<AyahTestResult> newResults) {
    final nextIndex = state.currentAyahIndex + 1;
    if (nextIndex >= state.ayahs.length) {
      _finishTest(newResults);
    } else {
      state = state.copyWith(
        results: newResults,
        currentAyahIndex: nextIndex,
        isRevealed: false,
      );
    }
  }

  void _finishTest(List<AyahTestResult> newResults) {
    final correctCount = newResults.where((r) => r.isCorrect).length;
    final mistakeCount = newResults.where((r) => !r.isCorrect && !r.wasSkipped).length;
    final skippedCount = newResults.where((r) => r.wasSkipped).length;
    final score = newResults.isEmpty
        ? 0.0
        : (correctCount / newResults.length) * 100;

    final result = HifdhTestResult(
      surahNumber: state.selectedSurah!,
      ayahStart: state.ayahStart,
      ayahEnd: state.ayahEnd,
      totalAyahs: newResults.length,
      correctCount: correctCount,
      mistakeCount: mistakeCount,
      skippedCount: skippedCount,
      score: score,
      ayahResults: newResults,
      testDuration: DateTime.now().difference(state.testStartTime),
    );

    state = state.copyWith(
      phase: HifdhTestPhase.results,
      results: newResults,
      finalResult: result,
    );
  }

  void reset() {
    state = HifdhTestState();
  }
}

final hifdhTestProvider =
    StateNotifierProvider<HifdhTestNotifier, HifdhTestState>((ref) {
  final dao = ref.watch(hifdhDaoProvider);
  final repo = ref.watch(hifdhQuranRepoProvider);
  return HifdhTestNotifier(dao, repo);
});

// ═══════════════════════════════════════════════════════════════════
// Daily Chart Data Provider
// ═══════════════════════════════════════════════════════════════════

class DailyChartData {
  final DateTime date;
  final int reviewsCompleted;
  final int newAyahs;
  final int correctCount;
  final int totalAttempts;

  const DailyChartData({
    required this.date,
    this.reviewsCompleted = 0,
    this.newAyahs = 0,
    this.correctCount = 0,
    this.totalAttempts = 0,
  });

  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return (correctCount / totalAttempts) * 100;
  }
}

final weeklyChartDataProvider = FutureProvider<List<DailyChartData>>((ref) async {
  final dao = ref.watch(hifdhDaoProvider);
  final allProgress = await dao.getAllProgress();

  final now = DateTime.now();
  final chartData = <DailyChartData>[];

  for (int i = 6; i >= 0; i--) {
    final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));

    int reviews = 0;
    int newAyahs = 0;
    int correct = 0;
    int attempts = 0;

    for (final p in allProgress) {
      if (p.lastReviewed != null) {
        final reviewedDay = DateTime(
          p.lastReviewed!.year,
          p.lastReviewed!.month,
          p.lastReviewed!.day,
        );
        if (reviewedDay == day) {
          reviews++;
          correct += p.totalCorrect;
          attempts += p.totalAttempts;
          if (p.totalAttempts == 1 && p.createdAt != null) {
            final createdDay = DateTime(
              p.createdAt!.year,
              p.createdAt!.month,
              p.createdAt!.day,
            );
            if (createdDay == day) newAyahs++;
          }
        }
      }
    }

    chartData.add(DailyChartData(
      date: day,
      reviewsCompleted: reviews,
      newAyahs: newAyahs,
      correctCount: correct,
      totalAttempts: attempts,
    ));
  }

  return chartData;
});

// ═══════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════

/// Precise juz boundary check using AppConstants.juzBreakdown.
///
/// Each juz boundary is defined by a starting (surah, ayah) tuple in
/// AppConstants.juzBreakdown (30 entries, index j-1 = start of juz j).
/// An ayah at (surahNumber, ayahNumber) belongs to juz j if its position
/// is >= juzBreakdown[j-1] and < juzBreakdown[j] (or juz 30 has no upper
/// bound — it extends to the end of the Quran).
bool _isInJuz(int surahNumber, int ayahNumber, int juz) {
  if (juz < 1 || juz > AppConstants.juzBreakdown.length) return false;

  // Position of the ayah as a comparable (surah, ayah) tuple.
  // We compare by: surah * 1000 + ayah (ayat within a surah are <= 286).
  final ayahPos = surahNumber * 1000 + ayahNumber;

  final startBound = AppConstants.juzBreakdown[juz - 1];
  final startPos = startBound['surah']! * 1000 + startBound['ayah']!;

  if (ayahPos < startPos) return false;

  // Juz 30 has no upper bound — extends to end of Quran.
  if (juz >= AppConstants.juzBreakdown.length) return true;

  final nextStartBound = AppConstants.juzBreakdown[juz];
  final nextPos = nextStartBound['surah']! * 1000 + nextStartBound['ayah']!;

  return ayahPos < nextPos;
}

/// Returns the surah number where juz N starts.
int _juzStartSurah(int juz) {
  if (juz < 1 || juz > AppConstants.juzBreakdown.length) return 114;
  return AppConstants.juzBreakdown[juz - 1]['surah']!;
}
