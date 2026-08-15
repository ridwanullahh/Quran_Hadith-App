import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/app_constants.dart';
import '../../core/services/database/database.dart';
import '../../core/services/database/daos/audio_dao.dart';

class AudioRepository {
  static const String _audioDirName = 'quran_audio';

  final AudioDao _audioDao;
  String? _audioBaseDirPath;

  AudioRepository({AudioDao? audioDao})
      : _audioDao = audioDao ?? AppDatabase.instance.audioDao;

  // ═══════════════════════════════════════════════════════════════
  // Path Helpers
  // ═══════════════════════════════════════════════════════════════

  /// Get the base audio directory path, creating it if needed
  Future<String> getAudioBaseDirectory() async {
    if (_audioBaseDirPath != null) {
      final dir = Directory(_audioBaseDirPath!);
      if (await dir.exists()) return _audioBaseDirPath!;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(appDir.path, _audioDirName));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    _audioBaseDirPath = audioDir.path;
    return audioDir.path;
  }

  /// Build the expected local file path for an audio file
  Future<String> buildLocalPath({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    final baseDir = await getAudioBaseDirectory();
    final reciterDir = p.join(baseDir, reciterId);
    final reciterDirectory = Directory(reciterDir);
    if (!await reciterDirectory.exists()) {
      await reciterDirectory.create(recursive: true);
    }

    if (ayahNumber == 0) {
      // Full surah file
      final padded = surahNumber.toString().padLeft(3, '0');
      return p.join(reciterDir, '${padded}${AppConstants.audioFileExtension}');
    } else {
      // Single ayah file
      final paddedSurah = surahNumber.toString().padLeft(3, '0');
      final paddedAyah = ayahNumber.toString().padLeft(3, '0');
      return p.join(
        reciterDir,
        '${paddedSurah}_${paddedAyah}${AppConstants.audioFileExtension}',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Audio URL Generation
  // ═══════════════════════════════════════════════════════════════

  /// Get the remote URL for an audio file
  String getAudioUrl({
    required int surah,
    required int ayah,
    required String reciter,
  }) {
    if (ayah == 0) {
      // Full surah URL
      final padded = surah.toString().padLeft(3, '0');
      return '${AppConstants.audioBaseUrls.replaceAll('{reciter}', reciter)}$padded${AppConstants.audioFileExtension}';
    } else {
      final paddedSurah = surah.toString().padLeft(3, '0');
      final paddedAyah = ayah.toString().padLeft(3, '0');
      return '${AppConstants.audioBaseUrls.replaceAll('{reciter}', reciter)}$paddedSurah/$paddedAyah${AppConstants.audioFileExtension}';
    }
  }

  /// Get URLs for a full surah (all ayahs)
  List<String> getSurahAudioUrls({
    required int surah,
    required String reciter,
    required int totalAyahs,
  }) {
    final urls = <String>[];
    for (int i = 1; i <= totalAyahs; i++) {
      urls.add(getAudioUrl(surah: surah, ayah: i, reciter: reciter));
    }
    return urls;
  }

  // ═══════════════════════════════════════════════════════════════
  // Downloaded Audio Access
  // ═══════════════════════════════════════════════════════════════

  /// Get the local file path for downloaded audio
  Future<String?> getDownloadedAudioPath({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    // First check the database record
    final dbPath = await _audioDao.getAudioFilePath(
      surahNumber,
      ayahNumber,
      reciterId,
    );
    if (dbPath != null) return dbPath;

    // Fallback: check if the expected file exists on disk
    final expectedPath = await buildLocalPath(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );
    if (await File(expectedPath).exists()) {
      return expectedPath;
    }
    return null;
  }

  /// Check if audio is downloaded and available locally
  Future<bool> isAudioDownloaded({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    return await _audioDao.isAudioFileAvailable(
      surahNumber,
      ayahNumber,
      reciterId,
    );
  }

  /// Check if a full surah is downloaded
  Future<bool> isSurahDownloaded({
    required int surahNumber,
    required String reciterId,
    required int totalAyahs,
  }) async {
    // Check the full surah file first
    final surahPath = await getDownloadedAudioPath(
      surahNumber: surahNumber,
      ayahNumber: 0,
      reciterId: reciterId,
    );
    if (surahPath != null) return true;

    // Otherwise check individual ayah files
    for (int i = 1; i <= totalAyahs; i++) {
      final downloaded = await isAudioDownloaded(
        surahNumber: surahNumber,
        ayahNumber: i,
        reciterId: reciterId,
      );
      if (!downloaded) return false;
    }
    return true;
  }

  /// Get the playable source - local file if available, otherwise remote URL
  Future<String> getPlayableSource({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    final localPath = await getDownloadedAudioPath(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );
    if (localPath != null) return localPath;

    return getAudioUrl(
      surah: surahNumber,
      ayah: ayahNumber,
      reciter: reciterId,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Delete
  // ═══════════════════════════════════════════════════════════════

  /// Delete a downloaded audio file
  Future<bool> deleteAudio({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    final filePath = await getDownloadedAudioPath(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );

    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await _audioDao.removeDownloadRecord(
      surahNumber,
      ayahNumber,
      reciterId,
    );
    return true;
  }

  /// Delete all ayahs of a downloaded surah
  Future<int> deleteSurahAudio({
    required int surahNumber,
    required String reciterId,
  }) async {
    // Delete all individual ayah files
    final downloads = await _audioDao.getDownloadsByReciter(reciterId);
    int deleted = 0;
    for (final d in downloads) {
      if (d.surahNumber == surahNumber) {
        final file = File(d.filePath);
        if (await file.exists()) {
          await file.delete();
        }
        deleted++;
      }
    }

    // Delete the full surah file too
    final surahPath = await buildLocalPath(
      surahNumber: surahNumber,
      ayahNumber: 0,
      reciterId: reciterId,
    );
    final surahFile = File(surahPath);
    if (await surahFile.exists()) {
      await surahFile.delete();
      deleted++;
    }

    await _audioDao.removeDownloadsBySurah(surahNumber, reciterId);
    return deleted;
  }

  /// Delete all downloaded audio for a reciter
  Future<void> deleteAllAudioForReciter(String reciterId) async {
    final downloads = await _audioDao.getDownloadsByReciter(reciterId);
    for (final d in downloads) {
      final file = File(d.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _audioDao.removeDownloadsByReciter(reciterId);

    // Also try to delete the reciter directory
    try {
      final baseDir = await getAudioBaseDirectory();
      final reciterDir = Directory(p.join(baseDir, reciterId));
      if (await reciterDir.exists()) {
        await reciterDir.delete(recursive: true);
      }
    } catch (_) {
      // Directory deletion is best-effort
    }
  }

  /// Delete all downloaded audio
  Future<void> deleteAllAudio() async {
    try {
      final baseDir = await getAudioBaseDirectory();
      final dir = Directory(baseDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      _audioBaseDirPath = null;
    } catch (_) {
      // Best-effort
    }
    await _audioDao.clearAllDownloads();
  }

  // ═══════════════════════════════════════════════════════════════
  // Storage Info
  // ═══════════════════════════════════════════════════════════════

  /// Get total size of downloaded audio files
  Future<int> getTotalDownloadSize() async {
    return await _audioDao.getTotalDownloadSize();
  }

  /// Get the size of a specific downloaded file
  Future<int> getFileSize({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    final path = await getDownloadedAudioPath(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );
    if (path == null) return 0;
    final file = File(path);
    if (!await file.exists()) return 0;
    return await file.length();
  }

  /// Format bytes into human-readable string
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Get list of all downloaded files with metadata
  Future<List<AudioDownload>> getAllDownloads() async {
    return await _audioDao.getCompletedDownloads();
  }

  /// Get number of downloaded surahs for a reciter
  Future<int> getDownloadedCount(String reciterId) async {
    return await _audioDao.getDownloadedSurahCount(reciterId);
  }

  /// Cleanup orphaned database records (files that no longer exist)
  Future<int> cleanupOrphanedRecords() async {
    return await _audioDao.cleanupOrphanedRecords();
  }
}
