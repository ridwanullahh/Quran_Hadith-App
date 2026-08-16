import 'package:sqflite/sqflite.dart';

import '../tables.dart';
import '../../../constants/app_constants.dart';
import '../database.dart'
    show
        notifyProgressChanged,
        notifyRevisionsChanged,
        notifyMistakesChanged,
        progressStream,
        revisionsStream,
        mistakesStream;

class HifdhDao {
  final Database _db;
  HifdhDao(this._db);

  // ═══════════════════════════════════════════════════════════════
  // Memorization Progress
  // ═══════════════════════════════════════════════════════════════

  Future<int> setAyahStatus({
    required int surahNumber,
    required int ayahNumber,
    required String status,
  }) async {
    final now = DateTime.now();
    final id = await _db.insert('memorization_progress', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'status': status,
      'repetitions': 0,
      'ease_factor': AppConstants.initialEaseFactor,
      'interval_days': AppConstants.minimumIntervalDays,
      'consecutive_correct': 0,
      'total_attempts': 0,
      'total_correct': 0,
      'last_reviewed': now.toIso8601String(),
      'next_review_date': now.add(const Duration(days: 1)).toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyProgressChanged();
    return id;
  }

  /// Record a review attempt using the SM-2 spaced repetition algorithm
  Future<void> recordReview({
    required int surahNumber,
    required int ayahNumber,
    required int quality,
  }) async {
    final rows = await _db.query('memorization_progress',
        where: 'surah_number = ? AND ayah_number = ?',
        whereArgs: [surahNumber, ayahNumber],
        limit: 1);

    final now = DateTime.now();
    int newInterval;
    double newEase;
    int newRepetitions;
    int newConsecutive;
    String newStatus;

    MemorizationProgress? existing;
    if (rows.isNotEmpty) {
      existing = MemorizationProgress.fromMap(rows.first);
    }

    if (existing == null) {
      newEase = AppConstants.initialEaseFactor;
      newRepetitions = 1;
      newConsecutive = quality >= 3 ? 1 : 0;
      newInterval = 1;
      newStatus = _deriveStatus(quality, 0);
    } else {
      newEase = existing.easeFactor;
      newRepetitions = existing.repetitions + 1;
      newConsecutive = existing.consecutiveCorrect;

      if (quality >= 3) {
        newConsecutive = newConsecutive + 1;
        if (newRepetitions == 1) {
          newInterval = 1;
        } else if (newRepetitions == 2) {
          newInterval = 3;
        } else {
          newInterval = (existing.intervalDays * newEase).round();
        }
        if (quality == 5) {
          newInterval =
              (newInterval * AppConstants.easyBonusMultiplier).round();
        }
        newEase =
            newEase + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
        if (newEase < AppConstants.minimumEaseFactor / 10) {
          newEase = AppConstants.minimumEaseFactor / 10;
        }
      } else {
        newConsecutive = 0;
        newRepetitions = 0;
        newInterval = 1;
        newEase = newEase - 0.2;
        if (newEase < AppConstants.minimumEaseFactor / 10) {
          newEase = AppConstants.minimumEaseFactor / 10;
        }
      }
      if (newInterval > AppConstants.maxRevisionIntervalDays) {
        newInterval = AppConstants.maxRevisionIntervalDays;
      }
      newStatus = _deriveStatus(quality, existing.totalAttempts);
    }

    final nextReview = now.add(Duration(days: newInterval));

    await _db.insert('memorization_progress', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'status': newStatus,
      'repetitions': newRepetitions,
      'ease_factor': newEase,
      'interval_days': newInterval,
      'consecutive_correct': newConsecutive,
      'total_attempts': (existing?.totalAttempts ?? 0) + 1,
      'total_correct':
          (existing?.totalCorrect ?? 0) + (quality >= 3 ? 1 : 0),
      'last_reviewed': now.toIso8601String(),
      'next_review_date': nextReview.toIso8601String(),
      'created_at':
          existing?.createdAt.toIso8601String() ?? now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyProgressChanged();
  }

  String _deriveStatus(int quality, int previousAttempts) {
    if (quality == 5 && previousAttempts >= 7) return 'mastered';
    if (quality >= 4 && previousAttempts >= 4) return 'memorized';
    if (previousAttempts >= 2) return 'review';
    if (previousAttempts >= 1) return 'learning';
    return 'new';
  }

  Future<List<MemorizationProgress>> getProgressBySurah(
      int surahNumber) async {
    final rows = await _db.query('memorization_progress',
        where: 'surah_number = ?',
        whereArgs: [surahNumber],
        orderBy: 'ayah_number ASC');
    return rows.map((r) => MemorizationProgress.fromMap(r)).toList();
  }

  Future<List<MemorizationProgress>> getProgressByStatus(
      String status) async {
    final rows = await _db.query('memorization_progress',
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'surah_number ASC, ayah_number ASC');
    return rows.map((r) => MemorizationProgress.fromMap(r)).toList();
  }

  Future<List<MemorizationProgress>> getDueReviews() async {
    final now = DateTime.now().toIso8601String();
    final rows = await _db.query('memorization_progress',
        where: 'next_review_date IS NOT NULL AND next_review_date <= ?',
        whereArgs: [now]);
    return rows.map((r) => MemorizationProgress.fromMap(r)).toList();
  }

  Future<List<MemorizationProgress>> getAllProgress() async {
    final rows = await _db.query('memorization_progress',
        orderBy: 'surah_number ASC, ayah_number ASC');
    return rows.map((r) => MemorizationProgress.fromMap(r)).toList();
  }

  Stream<List<MemorizationProgress>> watchDueReviews() async* {
    yield await getDueReviews();
    await for (final _ in progressStream) {
      yield await getDueReviews();
    }
  }

  Stream<List<MemorizationProgress>> watchProgressBySurah(
      int surahNumber) async* {
    yield await getProgressBySurah(surahNumber);
    await for (final _ in progressStream) {
      yield await getProgressBySurah(surahNumber);
    }
  }

  Future<Map<String, int>> getProgressStats() async {
    final allProgress = await getAllProgress();
    final stats = <String, int>{
      'new': 0,
      'learning': 0,
      'review': 0,
      'memorized': 0,
      'mastered': 0,
      'total': allProgress.length,
    };
    for (final p in allProgress) {
      if (stats.containsKey(p.status)) {
        stats[p.status] = stats[p.status]! + 1;
      }
    }
    return stats;
  }

  Future<int> getMemorizedAyahCount() async {
    final result = await _db.rawQuery(
        "SELECT COUNT(*) as cnt FROM memorization_progress WHERE status IN ('memorized', 'mastered')");
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteProgressForAyah(int surahNumber, int ayahNumber) async {
    await _db.delete('memorization_progress',
        where: 'surah_number = ? AND ayah_number = ?',
        whereArgs: [surahNumber, ayahNumber]);
    notifyProgressChanged();
  }

  Future<int> clearAllProgress() async {
    final count = await _db.delete('memorization_progress');
    if (count > 0) notifyProgressChanged();
    return count;
  }

  // ═══════════════════════════════════════════════════════════════
  // Revision Schedule
  // ═══════════════════════════════════════════════════════════════

  Future<int> scheduleRevision({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    required DateTime scheduledDate,
    String status = 'pending',
    int priority = 0,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final id = await _db.insert('revision_schedule', {
      'surah_number': surahNumber,
      'ayah_start': ayahStart,
      'ayah_end': ayahEnd,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status,
      'priority': priority,
      'notes': notes,
      'completed_at': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    notifyRevisionsChanged();
    return id;
  }

  Future<List<RevisionSchedule>> getPendingRevisions() async {
    final now = DateTime.now().toIso8601String();
    final rows = await _db.query('revision_schedule',
        where: "status = 'pending' AND scheduled_date <= ?",
        whereArgs: [now],
        orderBy: 'scheduled_date ASC, priority DESC');
    return rows.map((r) => RevisionSchedule.fromMap(r)).toList();
  }

  Future<List<RevisionSchedule>> getRevisionsByDateRange(
      DateTime start, DateTime end) async {
    final rows = await _db.query('revision_schedule',
        where: 'scheduled_date >= ? AND scheduled_date <= ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'scheduled_date ASC');
    return rows.map((r) => RevisionSchedule.fromMap(r)).toList();
  }

  Future<List<RevisionSchedule>> getAllRevisions() async {
    final rows = await _db.query('revision_schedule',
        orderBy: 'scheduled_date ASC');
    return rows.map((r) => RevisionSchedule.fromMap(r)).toList();
  }

  Stream<List<RevisionSchedule>> watchPendingRevisions() async* {
    yield await getPendingRevisions();
    await for (final _ in revisionsStream) {
      yield await getPendingRevisions();
    }
  }

  Future<bool> completeRevision(int id) async {
    final count = await _db.update('revision_schedule', {
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [id]);
    if (count > 0) notifyRevisionsChanged();
    return count > 0;
  }

  Future<bool> skipRevision(int id) async {
    final count = await _db.update('revision_schedule', {
      'status': 'skipped',
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [id]);
    if (count > 0) notifyRevisionsChanged();
    return count > 0;
  }

  Future<int> deleteRevision(int id) async {
    final count =
        await _db.delete('revision_schedule', where: 'id = ?', whereArgs: [id]);
    if (count > 0) notifyRevisionsChanged();
    return count;
  }

  Future<int> clearCompletedRevisions() async {
    final count = await _db.delete('revision_schedule',
        where: "status = 'completed'");
    if (count > 0) notifyRevisionsChanged();
    return count;
  }

  Future<int> clearAllRevisions() async {
    final count = await _db.delete('revision_schedule');
    if (count > 0) notifyRevisionsChanged();
    return count;
  }

  Future<int> markOverdueRevisions() async {
    final now = DateTime.now().toIso8601String();
    final count = await _db.update('revision_schedule', {'status': 'overdue'},
        where: "status = 'pending' AND scheduled_date <= ?",
        whereArgs: [now]);
    if (count > 0) notifyRevisionsChanged();
    return count;
  }

  // ═══════════════════════════════════════════════════════════════
  // Mistake Log
  // ═══════════════════════════════════════════════════════════════

  Future<int> logMistake({
    required int surahNumber,
    required int ayahNumber,
    required String mistakeType,
    String mistakenText = '',
    String correctText = '',
    String context = '',
  }) async {
    final id = await _db.insert('mistake_log', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'mistake_type': mistakeType,
      'mistaken_text': mistakenText,
      'correct_text': correctText,
      'context': context,
      'review_count': 0,
      'is_resolved': 0,
      'created_at': DateTime.now().toIso8601String(),
      'resolved_at': null,
    });
    notifyMistakesChanged();
    return id;
  }

  Future<List<MistakeLog>> getUnresolvedMistakes() async {
    final rows = await _db.query('mistake_log',
        where: 'is_resolved = 0', orderBy: 'created_at DESC');
    return rows.map((r) => MistakeLog.fromMap(r)).toList();
  }

  Future<List<MistakeLog>> getMistakesBySurah(int surahNumber) async {
    final rows = await _db.query('mistake_log',
        where: 'surah_number = ?',
        whereArgs: [surahNumber],
        orderBy: 'ayah_number ASC');
    return rows.map((r) => MistakeLog.fromMap(r)).toList();
  }

  Future<List<MistakeLog>> getMistakesByType(String mistakeType) async {
    final rows = await _db.query('mistake_log',
        where: 'mistake_type = ?',
        whereArgs: [mistakeType],
        orderBy: 'created_at DESC');
    return rows.map((r) => MistakeLog.fromMap(r)).toList();
  }

  Future<List<MistakeLog>> getFrequentMistakes({int limit = 20}) async {
    final rows = await _db.query('mistake_log',
        where: 'is_resolved = 0',
        orderBy: 'review_count ASC, created_at DESC',
        limit: limit);
    return rows.map((r) => MistakeLog.fromMap(r)).toList();
  }

  Stream<List<MistakeLog>> watchUnresolvedMistakes() async* {
    yield await getUnresolvedMistakes();
    await for (final _ in mistakesStream) {
      yield await getUnresolvedMistakes();
    }
  }

  Future<bool> resolveMistake(int id) async {
    final count = await _db.update('mistake_log', {
      'is_resolved': 1,
      'resolved_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [id]);
    if (count > 0) notifyMistakesChanged();
    return count > 0;
  }

  Future<bool> incrementReviewCount(int id) async {
    final rows = await _db.query('mistake_log',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return false;
    final current = rows.first['review_count'] as int? ?? 0;
    final count = await _db.update('mistake_log',
        {'review_count': current + 1},
        where: 'id = ?',
        whereArgs: [id]);
    return count > 0;
  }

  Future<int> deleteMistake(int id) async {
    final count =
        await _db.delete('mistake_log', where: 'id = ?', whereArgs: [id]);
    if (count > 0) notifyMistakesChanged();
    return count;
  }

  Future<int> clearResolvedMistakes() async {
    final count = await _db.delete('mistake_log', where: 'is_resolved = 1');
    if (count > 0) notifyMistakesChanged();
    return count;
  }

  Future<int> clearAllMistakes() async {
    final count = await _db.delete('mistake_log');
    if (count > 0) notifyMistakesChanged();
    return count;
  }

  Future<Map<String, int>> getMistakeStats() async {
    final mistakes = await _db.query('mistake_log');
    final stats = <String, int>{};
    for (final m in mistakes) {
      final ml = MistakeLog.fromMap(m);
      stats[ml.mistakeType] = (stats[ml.mistakeType] ?? 0) + 1;
    }
    stats['total'] = mistakes.length;
    stats['resolved'] =
        mistakes.where((m) => (m['is_resolved'] as int) == 1).length;
    stats['unresolved'] =
        mistakes.where((m) => (m['is_resolved'] as int) == 0).length;
    return stats;
  }
}
