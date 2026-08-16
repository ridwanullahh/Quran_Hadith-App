import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../tables.dart';

class AudioDao {
  final Database _db;
  AudioDao(this._db);

  // ── Create ──────────────────────────────────────────────────────

  Future<int> recordDownload({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
    required String filePath,
    int fileSizeBytes = 0,
    String downloadStatus = 'completed',
    String fileHash = '',
  }) async {
    final now = DateTime.now();
    return await _db.insert('audio_downloads', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'reciter_id': reciterId,
      'file_path': filePath,
      'file_size_bytes': fileSizeBytes,
      'download_status': downloadStatus,
      'downloaded_at': now.toIso8601String(),
      'file_hash': fileHash,
      'playback_count': 0,
      'last_played_at': null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> recordDownloadPending({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    final now = DateTime.now();
    return await _db.insert('audio_downloads', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'reciter_id': reciterId,
      'file_path': '',
      'file_size_bytes': 0,
      'download_status': 'pending',
      'downloaded_at': now.toIso8601String(),
      'file_hash': '',
      'playback_count': 0,
      'last_played_at': null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateDownloadStatus({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
    required String status,
    String? filePath,
    int? fileSizeBytes,
    String? fileHash,
  }) async {
    final values = <String, dynamic>{'download_status': status};
    if (filePath != null) values['file_path'] = filePath;
    if (fileSizeBytes != null) values['file_size_bytes'] = fileSizeBytes;
    if (fileHash != null) values['file_hash'] = fileHash;
    return await _db.update('audio_downloads', values,
        where: 'surah_number = ? AND ayah_number = ? AND reciter_id = ?',
        whereArgs: [surahNumber, ayahNumber, reciterId]);
  }

  // ── Read ────────────────────────────────────────────────────────

  Future<List<AudioDownload>> getAllDownloads() async {
    final rows = await _db.query('audio_downloads',
        orderBy: 'downloaded_at DESC');
    return rows.map((r) => AudioDownload.fromMap(r)).toList();
  }

  Future<List<AudioDownload>> getDownloadsByReciter(String reciterId) async {
    final rows = await _db.query('audio_downloads',
        where: 'reciter_id = ?',
        whereArgs: [reciterId],
        orderBy: 'surah_number ASC, ayah_number ASC');
    return rows.map((r) => AudioDownload.fromMap(r)).toList();
  }

  Future<List<AudioDownload>> getCompletedDownloads() async {
    final rows = await _db.query('audio_downloads',
        where: "download_status = 'completed'",
        orderBy: 'surah_number ASC');
    return rows.map((r) => AudioDownload.fromMap(r)).toList();
  }

  Future<List<AudioDownload>> getFailedDownloads() async {
    final rows = await _db.query('audio_downloads',
        where: "download_status = 'failed'",
        orderBy: 'downloaded_at DESC');
    return rows.map((r) => AudioDownload.fromMap(r)).toList();
  }

  Future<AudioDownload?> getDownloadRecord(
      int surahNumber, int ayahNumber, String reciterId) async {
    final rows = await _db.query('audio_downloads',
        where:
            'surah_number = ? AND ayah_number = ? AND reciter_id = ?',
        whereArgs: [surahNumber, ayahNumber, reciterId],
        limit: 1);
    if (rows.isEmpty) return null;
    return AudioDownload.fromMap(rows.first);
  }

  Future<AudioDownload?> getSurahDownload(
      int surahNumber, String reciterId) async {
    final rows = await _db.query('audio_downloads',
        where:
            'surah_number = ? AND ayah_number = 0 AND reciter_id = ?',
        whereArgs: [surahNumber, reciterId],
        limit: 1);
    if (rows.isEmpty) return null;
    return AudioDownload.fromMap(rows.first);
  }

  Future<bool> isAudioFileAvailable(
      int surahNumber, int ayahNumber, String reciterId) async {
    final record =
        await getDownloadRecord(surahNumber, ayahNumber, reciterId);
    if (record == null) return false;
    if (record.downloadStatus != 'completed') return false;
    if (record.filePath.isEmpty) return false;
    return File(record.filePath).existsSync();
  }

  Future<String?> getAudioFilePath(
      int surahNumber, int ayahNumber, String reciterId) async {
    final record =
        await getDownloadRecord(surahNumber, ayahNumber, reciterId);
    if (record == null) return null;
    if (record.downloadStatus != 'completed') return null;
    if (record.filePath.isEmpty) return null;
    if (!File(record.filePath).existsSync()) return null;
    return record.filePath;
  }

  Future<int> getTotalDownloadSize() async {
    final completed = await getCompletedDownloads();
    int total = 0;
    for (final d in completed) {
      total += d.fileSizeBytes;
    }
    return total;
  }

  Future<Map<String, int>> getDownloadCountsByReciter() async {
    final all = await getCompletedDownloads();
    final counts = <String, int>{};
    for (final d in all) {
      counts[d.reciterId] = (counts[d.reciterId] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> getDownloadedSurahCount(String reciterId) async {
    final downloads = await getDownloadsByReciter(reciterId);
    return downloads
        .where(
            (d) => d.ayahNumber == 0 && d.downloadStatus == 'completed')
        .length;
  }

  // ── Playback Tracking ───────────────────────────────────────────

  Future<void> recordPlayback({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    final record =
        await getDownloadRecord(surahNumber, ayahNumber, reciterId);
    if (record == null) return;
    await _db.update('audio_downloads', {
      'playback_count': record.playbackCount + 1,
      'last_played_at': DateTime.now().toIso8601String(),
    },
        where:
            'surah_number = ? AND ayah_number = ? AND reciter_id = ?',
        whereArgs: [surahNumber, ayahNumber, reciterId]);
  }

  Future<List<AudioDownload>> getMostPlayed({int limit = 10}) async {
    final rows = await _db.query('audio_downloads',
        where: "download_status = 'completed'",
        orderBy: 'playback_count DESC',
        limit: limit);
    return rows.map((r) => AudioDownload.fromMap(r)).toList();
  }

  // ── Delete ──────────────────────────────────────────────────────

  Future<int> removeDownloadRecord(
      int surahNumber, int ayahNumber, String reciterId) async {
    return await _db.delete('audio_downloads',
        where:
            'surah_number = ? AND ayah_number = ? AND reciter_id = ?',
        whereArgs: [surahNumber, ayahNumber, reciterId]);
  }

  Future<int> removeDownloadsByReciter(String reciterId) async {
    return await _db.delete('audio_downloads',
        where: 'reciter_id = ?', whereArgs: [reciterId]);
  }

  Future<int> removeDownloadsBySurah(
      int surahNumber, String reciterId) async {
    return await _db.delete('audio_downloads',
        where: 'surah_number = ? AND reciter_id = ?',
        whereArgs: [surahNumber, reciterId]);
  }

  Future<int> clearFailedDownloads() async {
    return await _db.delete('audio_downloads',
        where: "download_status = 'failed'");
  }

  Future<int> clearAllDownloads() async {
    return await _db.delete('audio_downloads');
  }

  // ── Cleanup ─────────────────────────────────────────────────────

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
