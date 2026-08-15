import 'package:drift/drift.dart';
import '../tables.dart' as tbl;
import '../database.dart';
import '../../../../constants/app_constants.dart';

part 'hifdh_dao.g.dart';

@DriftAccessor(
  tables: [tbl.MemorizationProgress, tbl.RevisionSchedule, tbl.MistakeLog],
)
class HifdhDao extends DatabaseAccessor<AppDatabase>
    with _$HifdhDaoMixin {
  HifdhDao(super.db);

  // ═══════════════════════════════════════════════════════════════
  // Memorization Progress
  // ═══════════════════════════════════════════════════════════════

  Future<int> setAyahStatus({
    required int surahNumber,
    required int ayahNumber,
    required String status,
  }) {
    final now = DateTime.now();
    return into(memorizationProgress).insertOnConflictUpdate(
      MemorizationProgressCompanion.insert(
        surahNumber: Value(surahNumber),
        ayahNumber: Value(ayahNumber),
        status: Value(status),
        repetitions: const Value(0),
        easeFactor: const Value(AppConstants.initialEaseFactor),
        intervalDays: const Value(AppConstants.minimumIntervalDays),
        consecutiveCorrect: const Value(0),
        totalAttempts: const Value(0),
        totalCorrect: const Value(0),
        lastReviewed: Value(now),
        nextReviewDate: Value(now.add(const Duration(days: 1))),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Record a review attempt using the SM-2 spaced repetition algorithm
  Future<void> recordReview({
    required int surahNumber,
    required int ayahNumber,
    required int quality,
  }) async {
    // Quality: 0-5 scale (0=complete failure, 5=perfect)
    final existing = await (select(memorizationProgress)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.ayahNumber.equals(ayahNumber),
          ))
        .getSingleOrNull();

    final now = DateTime.now();
    int newInterval;
    double newEase;
    int newRepetitions;
    int newConsecutive;
    String newStatus;

    if (existing == null) {
      // First time reviewing this ayah
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
        // Correct response
        newConsecutive = newConsecutive + 1;

        if (newRepetitions == 1) {
          newInterval = 1;
        } else if (newRepetitions == 2) {
          newInterval = 3;
        } else {
          newInterval = (existing.intervalDays * newEase).round();
        }

        if (quality == 5) {
          // Easy bonus
          newInterval =
              (newInterval * AppConstants.easyBonusMultiplier).round();
        }

        // Update ease factor
        newEase = newEase + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
        if (newEase < AppConstants.minimumEaseFactor / 10) {
          newEase = AppConstants.minimumEaseFactor / 10;
        }
      } else {
        // Incorrect response - reset repetition chain
        newConsecutive = 0;
        newRepetitions = 0;
        newInterval = 1;
        newEase = newEase - 0.2;
        if (newEase < AppConstants.minimumEaseFactor / 10) {
          newEase = AppConstants.minimumEaseFactor / 10;
        }
      }

      // Cap the maximum interval
      if (newInterval > AppConstants.maxRevisionIntervalDays) {
        newInterval = AppConstants.maxRevisionIntervalDays;
      }

      newStatus = _deriveStatus(quality, existing.totalAttempts);
    }

    final nextReview = now.add(Duration(days: newInterval));

    await into(memorizationProgress).insertOnConflictUpdate(
      MemorizationProgressCompanion.insert(
        surahNumber: Value(surahNumber),
        ayahNumber: Value(ayahNumber),
        status: Value(newStatus),
        repetitions: Value(newRepetitions),
        easeFactor: Value(newEase),
        intervalDays: Value(newInterval),
        consecutiveCorrect: Value(newConsecutive),
        totalAttempts: Value((existing?.totalAttempts ?? 0) + 1),
        totalCorrect: Value(
          (existing?.totalCorrect ?? 0) + (quality >= 3 ? 1 : 0),
        ),
        lastReviewed: Value(now),
        nextReviewDate: Value(nextReview),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  String _deriveStatus(int quality, int previousAttempts) {
    if (quality == 5 && previousAttempts >= 7) return 'mastered';
    if (quality >= 4 && previousAttempts >= 4) return 'memorized';
    if (previousAttempts >= 2) return 'review';
    if (previousAttempts >= 1) return 'learning';
    return 'new';
  }

  Future<List<MemorizationProgress>> getProgressBySurah(int surahNumber) {
    return (select(memorizationProgress)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .get();
  }

  Future<List<MemorizationProgress>> getProgressByStatus(String status) {
    return (select(memorizationProgress)
          ..where((t) => t.status.equals(status))
          ..orderBy([
            (t) => OrderingTerm.asc(t.surahNumber),
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .get();
  }

  Future<List<MemorizationProgress>> getDueReviews() {
    final now = DateTime.now();
    return (select(memorizationProgress)
          ..where((t) => t.nextReviewDate.isSmallerThanValue(now)))
        .get();
  }

  Future<List<MemorizationProgress>> getAllProgress() {
    return (select(memorizationProgress)
          ..orderBy([
            (t) => OrderingTerm.asc(t.surahNumber),
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .get();
  }

  Stream<List<MemorizationProgress>> watchDueReviews() {
    final now = DateTime.now();
    return (select(memorizationProgress)
          ..where((t) => t.nextReviewDate.isSmallerThanValue(now))
          ..orderBy([
            (t) => OrderingTerm.asc(t.nextReviewDate),
          ]))
        .watch();
  }

  Stream<List<MemorizationProgress>> watchProgressBySurah(
      int surahNumber) {
    return (select(memorizationProgress)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .watch();
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
    final countExpr = memorizationProgress.id.count();
    final query = selectOnly(memorizationProgress)
      ..addColumns([countExpr])
      ..where(
          memorizationProgress.status.isIn(['memorized', 'mastered']));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<void> deleteProgressForAyah(int surahNumber, int ayahNumber) {
    return (delete(memorizationProgress)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.ayahNumber.equals(ayahNumber),
          ))
        .go()
        .then((_) {});
  }

  Future<int> clearAllProgress() {
    return delete(memorizationProgress).go();
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
  }) {
    final now = DateTime.now();
    return into(revisionSchedule).insert(RevisionScheduleCompanion.insert(
      surahNumber: Value(surahNumber),
      ayahStart: Value(ayahStart),
      ayahEnd: Value(ayahEnd),
      scheduledDate: Value(scheduledDate),
      status: Value(status),
      priority: Value(priority),
      notes: Value(notes),
      completedAt: const Value.absent(),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<List<RevisionSchedule>> getPendingRevisions() {
    final now = DateTime.now();
    return (select(revisionSchedule)
          ..where((t) => t.status.equals('pending') & t.scheduledDate.isSmallerThanValue(now))
          ..orderBy([
            (t) => OrderingTerm.asc(t.scheduledDate),
            (t) => OrderingTerm.desc(t.priority),
          ]))
        .get();
  }

  Future<List<RevisionSchedule>> getRevisionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(revisionSchedule)
          ..where((t) =>
              t.scheduledDate.isBiggerOrEqualValue(start) &
              t.scheduledDate.isSmallerOrEqualValue(end))
          ..orderBy([
            (t) => OrderingTerm.asc(t.scheduledDate),
          ]))
        .get();
  }

  Future<List<RevisionSchedule>> getAllRevisions() {
    return (select(revisionSchedule)
          ..orderBy([
            (t) => OrderingTerm.asc(t.scheduledDate),
          ]))
        .get();
  }

  Stream<List<RevisionSchedule>> watchPendingRevisions() {
    final now = DateTime.now();
    return (select(revisionSchedule)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([
            (t) => OrderingTerm.asc(t.scheduledDate),
          ]))
        .watch();
  }

  Future<bool> completeRevision(int id) {
    return (update(revisionSchedule)..where((t) => t.id.equals(id))).write(
      RevisionScheduleCompanion(
        status: const Value('completed'),
        completedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> skipRevision(int id) {
    return (update(revisionSchedule)..where((t) => t.id.equals(id))).write(
      RevisionScheduleCompanion(
        status: const Value('skipped'),
        updatedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  Future<int> deleteRevision(int id) {
    return (delete(revisionSchedule)..where((t) => t.id.equals(id))).go();
  }

  Future<int> clearCompletedRevisions() {
    return (delete(revisionSchedule)
          ..where((t) => t.status.equals('completed')))
        .go();
  }

  Future<int> clearAllRevisions() {
    return delete(revisionSchedule).go();
  }

  /// Mark overdue revisions as overdue status
  Future<int> markOverdueRevisions() {
    final now = DateTime.now();
    return (update(revisionSchedule)
          ..where((t) =>
              t.status.equals('pending') &
              t.scheduledDate.isSmallerThanValue(now)))
        .write(
      const RevisionScheduleCompanion(
        status: Value('overdue'),
      ),
    );
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
  }) {
    return into(mistakeLog).insert(MistakeLogCompanion.insert(
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      mistakeType: Value(mistakeType),
      mistakenText: Value(mistakenText),
      correctText: Value(correctText),
      context: Value(context),
      reviewCount: const Value(0),
      isResolved: const Value(false),
      createdAt: Value(DateTime.now()),
      resolvedAt: const Value.absent(),
    ));
  }

  Future<List<MistakeLog>> getUnresolvedMistakes() {
    return (select(mistakeLog)
          ..where((t) => t.isResolved.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  Future<List<MistakeLog>> getMistakesBySurah(int surahNumber) {
    return (select(mistakeLog)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .get();
  }

  Future<List<MistakeLog>> getMistakesByType(String mistakeType) {
    return (select(mistakeLog)
          ..where((t) => t.mistakeType.equals(mistakeType))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  Future<List<MistakeLog>> getFrequentMistakes({int limit = 20}) {
    return (select(mistakeLog)
          ..where((t) => t.isResolved.equals(false))
          ..orderBy([
            (t) => OrderingTerm.asc(t.reviewCount),
            (t) => OrderingTerm.desc(t.createdAt),
          ])
          ..limit(limit))
        .get();
  }

  Stream<List<MistakeLog>> watchUnresolvedMistakes() {
    return (select(mistakeLog)
          ..where((t) => t.isResolved.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  Future<bool> resolveMistake(int id) {
    return (update(mistakeLog)..where((t) => t.id.equals(id))).write(
      MistakeLogCompanion(
        isResolved: const Value(true),
        resolvedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> incrementReviewCount(int id) async {
    final existing = await (select(mistakeLog)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) return false;
    return (update(mistakeLog)..where((t) => t.id.equals(id))).write(
      MistakeLogCompanion(
        reviewCount: Value(existing.reviewCount + 1),
      ),
    ).then((rows) => rows > 0);
  }

  Future<int> deleteMistake(int id) {
    return (delete(mistakeLog)..where((t) => t.id.equals(id))).go();
  }

  Future<int> clearResolvedMistakes() {
    return (delete(mistakeLog)
          ..where((t) => t.isResolved.equals(true)))
        .go();
  }

  Future<int> clearAllMistakes() {
    return delete(mistakeLog).go();
  }

  Future<Map<String, int>> getMistakeStats() async {
    final mistakes = await (select(mistakeLog)).get();
    final stats = <String, int>{};
    for (final m in mistakes) {
      stats[m.mistakeType] = (stats[m.mistakeType] ?? 0) + 1;
    }
    stats['total'] = mistakes.length;
    stats['resolved'] = mistakes.where((m) => m.isResolved).length;
    stats['unresolved'] = mistakes.where((m) => !m.isResolved).length;
    return stats;
  }
}
