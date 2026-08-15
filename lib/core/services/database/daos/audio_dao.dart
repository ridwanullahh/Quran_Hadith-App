import 'dart:io';
import 'package:drift/drift.dart';
import '../tables.dart';
import '../database.dart';

part 'audio_dao.g.dart';

@DriftAccessor(tables: [AudioDownloads])
class AudioDao extends DatabaseAccessor<AppDatabase>
    with _$AudioDaoMixin {
  AudioDao(super.db);

  // ── Create ──────────────────────────────────────────────────────

  Future<int> recordDownload({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
    required String filePath,
    int fileSizeBytes = 0,
    String downloadStatus = 'completed',
    String fileHash = '',
  }) {
    final now = DateTime.now();
    return into(audioDownloads).insertOnConflictUpdate(
      AudioDownloadsCompanion.insert(
        surahNumber: Value(surahNumber),
        ayahNumber: Value(ayahNumber),
        reciterId: Value(reciterId),
        filePath: Value(filePath),
        fileSizeBytes: Value(fileSizeBytes),
        downloadStatus: Value(downloadStatus),
        downloadedAt: Value(now),
        fileHash: Value(fileHash),
        playbackCount: const Value(0),
        lastPlayedAt: const Value.absent(),
      ),
    );
  }

  Future<int> recordDownloadPending({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) {
    final now = DateTime.now();
    return into(audioDownloads).insertOnConflictUpdate(
      AudioDownloadsCompanion.insert(
        surahNumber: Value(surahNumber),
        ayahNumber: Value(ayahNumber),
        reciterId: Value(reciterId),
        filePath: const Value(''),
        fileSizeBytes: const Value(0),
        downloadStatus: const Value('pending'),
        downloadedAt: Value(now),
        fileHash: const Value(''),
        playbackCount: const Value(0),
        lastPlayedAt: const Value.absent(),
      ),
    );
  }

  Future<int> updateDownloadStatus({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
    required String status,
    String? filePath,
    int? fileSizeBytes,
    String? fileHash,
  }) {
    return (update(audioDownloads)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.ayahNumber.equals(ayahNumber) &
                t.reciterId.equals(reciterId),
          ))
        .write(
      AudioDownloadsCompanion(
        downloadStatus: Value(status),
        filePath: filePath != null ? Value(filePath) : const Value.absent(),
        fileSizeBytes: fileSizeBytes != null
            ? Value(fileSizeBytes)
            : const Value.absent(),
        fileHash:
            fileHash != null ? Value(fileHash) : const Value.absent(),
      ),
    );
  }

  // ── Read ────────────────────────────────────────────────────────

  Future<List<AudioDownload>> getAllDownloads() {
    return (select(audioDownloads)
          ..orderBy([
            (t) => OrderingTerm.desc(t.downloadedAt),
          ]))
        .get();
  }

  Future<List<AudioDownload>> getDownloadsByReciter(String reciterId) {
    return (select(audioDownloads)
          ..where((t) => t.reciterId.equals(reciterId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.surahNumber),
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .get();
  }

  Future<List<AudioDownload>> getCompletedDownloads() {
    return (select(audioDownloads)
          ..where((t) => t.downloadStatus.equals('completed'))
          ..orderBy([
            (t) => OrderingTerm.asc(t.surahNumber),
          ]))
        .get();
  }

  Future<List<AudioDownload>> getFailedDownloads() {
    return (select(audioDownloads)
          ..where((t) => t.downloadStatus.equals('failed'))
          ..orderBy([
            (t) => OrderingTerm.desc(t.downloadedAt),
          ]))
        .get();
  }

  Future<AudioDownload?> getDownloadRecord(
    int surahNumber,
    int ayahNumber,
    String reciterId,
  ) {
    return (select(audioDownloads)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.ayahNumber.equals(ayahNumber) &
                t.reciterId.equals(reciterId),
          ))
        .getSingleOrNull();
  }

  Future<AudioDownload?> getSurahDownload(
    int surahNumber,
    String reciterId,
  ) {
    return (select(audioDownloads)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.ayahNumber.equals(0) &
                t.reciterId.equals(reciterId),
          ))
        .getSingleOrNull();
  }

  /// Check if audio file exists on disk and its record is valid
  Future<bool> isAudioFileAvailable(
    int surahNumber,
    int ayahNumber,
    String reciterId,
  ) async {
    final record = await getDownloadRecord(surahNumber, ayahNumber, reciterId);
    if (record == null) return false;
    if (record.downloadStatus != 'completed') return false;
    if (record.filePath.isEmpty) return false;
    return File(record.filePath).existsSync();
  }

  /// Get the file path for a downloaded audio
  Future<String?> getAudioFilePath(
    int surahNumber,
    int ayahNumber,
    String reciterId,
  ) async {
    final record = await getDownloadRecord(surahNumber, ayahNumber, reciterId);
    if (record == null) return null;
    if (record.downloadStatus != 'completed') return null;
    if (record.filePath.isEmpty) return null;
    if (!File(record.filePath).existsSync()) return null;
    return record.filePath;
  }

  /// Get total size of all downloaded audio files in bytes
  Future<int> getTotalDownloadSize() async {
    final completed = await getCompletedDownloads();
    int total = 0;
    for (final d in completed) {
      total += d.fileSizeBytes;
    }
    return total;
  }

  /// Get download count per reciter
  Future<Map<String, int>> getDownloadCountsByReciter() async {
    final all = await getCompletedDownloads();
    final counts = <String, int>{};
    for (final d in all) {
      counts[d.reciterId] = (counts[d.reciterId] ?? 0) + 1;
    }
    return counts;
  }

  /// Get total number of downloaded surahs
  Future<int> getDownloadedSurahCount(String reciterId) async {
    final downloads = await getDownloadsByReciter(reciterId);
    return downloads
        .where((d) => d.ayahNumber == 0 && d.downloadStatus == 'completed')
        .length;
  }

  // ── Playback Tracking ───────────────────────────────────────────

  Future<void> recordPlayback({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    final record = await getDownloadRecord(surahNumber, ayahNumber, reciterId);
    if (record == null) return;
    await (update(audioDownloads)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.ayahNumber.equals(ayahNumber) &
                t.reciterId.equals(reciterId),
          ))
        .write(
      AudioDownloadsCompanion(
        playbackCount: Value(record.playbackCount + 1),
        lastPlayedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<AudioDownload>> getMostPlayed({int limit = 10}) {
    return (select(audioDownloads)
          ..where((t) => t.downloadStatus.equals('completed'))
          ..orderBy([
            (t) => OrderingTerm.desc(t.playbackCount),
          ])
          ..limit(limit))
        .get();
  }

  // ── Delete ──────────────────────────────────────────────────────

  Future<int> removeDownloadRecord(
    int surahNumber,
    int ayahNumber,
    String reciterId,
  ) {
    return (delete(audioDownloads)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.ayahNumber.equals(ayahNumber) &
                t.reciterId.equals(reciterId),
          ))
        .go();
  }

  Future<int> removeDownloadsByReciter(String reciterId) {
    return (delete(audioDownloads)
          ..where((t) => t.reciterId.equals(reciterId)))
        .go();
  }

  Future<int> removeDownloadsBySurah(
    int surahNumber,
    String reciterId,
  ) {
    return (delete(audioDownloads)
          ..where(
            (t) =>
                t.surahNumber.equals(surahNumber) &
                t.reciterId.equals(reciterId),
          ))
        .go();
  }

  Future<int> clearFailedDownloads() {
    return (delete(audioDownloads)
          ..where((t) => t.downloadStatus.equals('failed')))
        .go();
  }

  Future<int> clearAllDownloads() {
    return delete(audioDownloads).go();
  }

  // ── Cleanup ─────────────────────────────────────────────────────

  /// Remove records where the file no longer exists on disk
  Future<int> cleanupOrphanedRecords() async {
    final all = await getAllDownloads();
    int removed = 0;
    for (final d in all) {
      if (d.filePath.isNotEmpty && !File(d.filePath).existsSync()) {
        await removeDownloadRecord(
          d.surahNumber,
          d.ayahNumber,
          d.reciterId,
        );
        removed++;
      }
    }
    return removed;
  }
}
