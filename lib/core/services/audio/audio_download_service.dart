import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../constants/app_constants.dart';
import '../../../data/repositories/audio_repository.dart';
import '../database/database.dart';
import '../database/daos/audio_dao.dart';

/// Progress data for a single download
class DownloadProgress {
  final String taskId;
  final int surahNumber;
  final int ayahNumber;
  final String reciterId;
  final int bytesReceived;
  final int totalBytes;
  final double progress; // 0.0 to 1.0
  final DownloadStatus status;
  final String? error;

  const DownloadProgress({
    required this.taskId,
    required this.surahNumber,
    required this.ayahNumber,
    required this.reciterId,
    required this.bytesReceived,
    required this.totalBytes,
    required this.progress,
    required this.status,
    this.error,
  });

  int get percent => (progress * 100).round();

  DownloadProgress copyWith({
    int? bytesReceived,
    int? totalBytes,
    double? progress,
    DownloadStatus? status,
    String? error,
  }) {
    return DownloadProgress(
      taskId: taskId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      totalBytes: totalBytes ?? this.totalBytes,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

/// Download status enum
enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  cancelled,
}

/// Download task holder for active downloads
class _DownloadTask {
  CancelToken cancelToken;
  DownloadProgress progress;

  _DownloadTask({
    required this.cancelToken,
    required this.progress,
  });
}

class AudioDownloadService {
  final Dio _dio;
  final AudioRepository _audioRepository;
  final AudioDao _audioDao;

  // ── Active download tracking ───────────────────────────────────
  final Map<String, _DownloadTask> _activeDownloads = {};
  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  // ── Configuration ──────────────────────────────────────────────
  int maxConcurrentDownloads = 3;
  bool autoCacheOnPlay = true;

  AudioDownloadService({
    Dio? dio,
    AudioRepository? audioRepository,
    AudioDao? audioDao,
  })  : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(
                  seconds: AppConstants.downloadTimeoutSeconds),
              receiveTimeout: const Duration(
                  seconds: AppConstants.downloadTimeoutSeconds),
              maxRedirects: 5,
            )),
        _audioRepository = audioRepository ?? AudioRepository(),
        _audioDao = audioDao ?? AppDatabase.instance.audioDao;

  // ═══════════════════════════════════════════════════════════════
  // Stream for UI progress updates
  // ═══════════════════════════════════════════════════════════════

  /// Stream of all download progress updates
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  /// Get progress for a specific task
  DownloadProgress? getProgress(String taskId) {
    return _activeDownloads[taskId]?.progress;
  }

  /// Check if there are any active downloads
  bool get hasActiveDownloads => _activeDownloads.isNotEmpty;

  /// Get all active download task IDs
  List<String> get activeTaskIds => _activeDownloads.keys.toList();

  // ═══════════════════════════════════════════════════════════════
  // Task ID generation
  // ═══════════════════════════════════════════════════════════════

  String _buildTaskId(int surahNumber, int ayahNumber, String reciterId) {
    return '${reciterId}_${surahNumber}_$ayahNumber';
  }

  // ═══════════════════════════════════════════════════════════════
  // Download a full surah
  // ═══════════════════════════════════════════════════════════════

  /// Download all ayahs of a surah.
  /// Returns the task IDs for all individual downloads.
  Future<List<String>> downloadSurah({
    required int surahNumber,
    required int totalAyahs,
    String reciterId = AppConstants.defaultReciterId,
    bool parallel = true,
  }) async {
    final taskIds = <String>[];

    if (parallel) {
      // Run downloads in parallel with concurrency limit
      final futures = <Future<String>>[];
      for (int i = 1; i <= totalAyahs; i++) {
        futures.add(_downloadWithConcurrency(
          surahNumber: surahNumber,
          ayahNumber: i,
          reciterId: reciterId,
          activeCount: () => _activeDownloads.length,
        ));
      }
      taskIds.addAll(await Future.wait(futures));
    } else {
      // Sequential downloads
      for (int i = 1; i <= totalAyahs; i++) {
        final taskId = await downloadAyah(
          surahNumber: surahNumber,
          ayahNumber: i,
          reciterId: reciterId,
        );
        taskIds.add(taskId);
      }
    }

    return taskIds;
  }

  /// Download with concurrency limiting
  Future<String> _downloadWithConcurrency({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
    required int Function() activeCount,
  }) async {
    // Wait if we're at max concurrency
    while (activeCount() >= maxConcurrentDownloads) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return downloadAyah(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Download a single ayah
  // ═══════════════════════════════════════════════════════════════

  /// Download a single ayah audio file.
  /// Returns the task ID.
  Future<String> downloadAyah({
    required int surahNumber,
    required int ayahNumber,
    String reciterId = AppConstants.defaultReciterId,
  }) async {
    final taskId =
        _buildTaskId(surahNumber, ayahNumber, reciterId);

    // Check if already downloaded
    final existingPath = await _audioRepository.getDownloadedAudioPath(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );
    if (existingPath != null) {
      final completedProgress = DownloadProgress(
        taskId: taskId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        reciterId: reciterId,
        bytesReceived: 0,
        totalBytes: 0,
        progress: 1.0,
        status: DownloadStatus.completed,
      );
      _progressController.add(completedProgress);
      return taskId;
    }

    // Check if already downloading
    if (_activeDownloads.containsKey(taskId)) {
      return taskId;
    }

    // Get the download URL and local path
    final url = _audioRepository.getAudioUrl(
      surah: surahNumber,
      ayah: ayahNumber,
      reciter: reciterId,
    );
    final localPath = await _audioRepository.buildLocalPath(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );

    // Create the download task
    final cancelToken = CancelToken();
    final initialProgress = DownloadProgress(
      taskId: taskId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
      bytesReceived: 0,
      totalBytes: 0,
      progress: 0.0,
      status: DownloadStatus.pending,
    );
    _activeDownloads[taskId] = _DownloadTask(
      cancelToken: cancelToken,
      progress: initialProgress,
    );

    // Record pending in database
    await _audioDao.recordDownloadPending(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      reciterId: reciterId,
    );

    // Emit initial state
    _progressController.add(initialProgress);

    try {
      // Update status to downloading
      _emitProgress(taskId, status: DownloadStatus.downloading);

      // Ensure directory exists
      final dir = Directory(p.dirname(localPath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Download with progress tracking
      await _dio.download(
        url,
        localPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final prog = total > 0 ? received / total : 0.0;
          _emitProgress(
            taskId,
            bytesReceived: received,
            totalBytes: total,
            progress: prog,
            status: DownloadStatus.downloading,
          );
        },
        options: Options(
          receiveTimeout: const Duration(
              seconds: AppConstants.downloadTimeoutSeconds),
          sendTimeout: const Duration(
              seconds: AppConstants.downloadTimeoutSeconds),
          receiveDataWhenStatusError: false,
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Verify the file was actually written
      final file = File(localPath);
      if (!await file.exists()) {
        throw FileSystemException('Downloaded file not found', localPath);
      }

      final fileSize = await file.length();

      // Record completed download in database
      await _audioDao.recordDownload(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        reciterId: reciterId,
        filePath: localPath,
        fileSizeBytes: fileSize,
        downloadStatus: 'completed',
      );

      // Emit completion
      _emitProgress(
        taskId,
        bytesReceived: fileSize,
        totalBytes: fileSize,
        progress: 1.0,
        status: DownloadStatus.completed,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _emitProgress(
          taskId,
          status: DownloadStatus.cancelled,
        );
        await _audioDao.updateDownloadStatus(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          reciterId: reciterId,
          status: 'cancelled',
        );
      } else {
        _emitProgress(
          taskId,
          status: DownloadStatus.failed,
          error: _getErrorMessage(e),
        );
        await _audioDao.updateDownloadStatus(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          reciterId: reciterId,
          status: 'failed',
        );
      }
    } catch (e) {
      _emitProgress(
        taskId,
        status: DownloadStatus.failed,
        error: e.toString(),
      );
      await _audioDao.updateDownloadStatus(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        reciterId: reciterId,
        status: 'failed',
      );
    } finally {
      _activeDownloads.remove(taskId);
    }

    return taskId;
  }

  // ═══════════════════════════════════════════════════════════════
  // Cancel
  // ═══════════════════════════════════════════════════════════════

  /// Cancel a specific download by task ID
  Future<void> cancelDownload(String taskId) async {
    final task = _activeDownloads[taskId];
    if (task != null) {
      task.cancelToken.cancel('Download cancelled by user');
    }
  }

  /// Cancel all active downloads
  Future<void> cancelAllDownloads() async {
    for (final task in _activeDownloads.values) {
      task.cancelToken.cancel('All downloads cancelled');
    }
  }

  /// Cancel all downloads for a specific surah
  Future<void> cancelSurahDownloads(int surahNumber) async {
    final toCancel = _activeDownloads.entries
        .where((e) => e.value.progress.surahNumber == surahNumber)
        .map((e) => e.key)
        .toList();
    for (final id in toCancel) {
      await cancelDownload(id);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Auto-cache on play
  // ═══════════════════════════════════════════════════════════════

  /// Auto-download the next ayah in the background when playing.
  /// Call this when an ayah starts playing.
  Future<void> precacheAyahsOnPlay({
    required int surahNumber,
    required int ayahNumber,
    required int totalAyahs,
    required String reciterId,
    int cacheAheadCount = 3,
  }) async {
    if (!autoCacheOnPlay) return;

    // Cache the current ayah + next N ayahs
    for (int offset = 0; offset <= cacheAheadCount; offset++) {
      final targetAyah = ayahNumber + offset;
      if (targetAyah > totalAyahs) break;

      final isDownloaded = await _audioRepository.isAudioDownloaded(
        surahNumber: surahNumber,
        ayahNumber: targetAyah,
        reciterId: reciterId,
      );

      if (!isDownloaded) {
        // Fire and forget - don't await
        downloadAyah(
          surahNumber: surahNumber,
          ayahNumber: targetAyah,
          reciterId: reciterId,
        );
      }
    }
  }

  /// Auto-cache surah when starting playback of any ayah
  Future<void> precacheSurah({
    required int surahNumber,
    required int totalAyahs,
    String reciterId = AppConstants.defaultReciterId,
  }) async {
    if (!autoCacheOnPlay) return;
    await downloadSurah(
      surahNumber: surahNumber,
      totalAyahs: totalAyahs,
      reciterId: reciterId,
      parallel: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Retry failed downloads
  // ═══════════════════════════════════════════════════════════════

  /// Retry all failed downloads for a reciter
  Future<List<String>> retryFailedDownloads({
    required String reciterId,
  }) async {
    final failed = await _audioDao.getFailedDownloads();
    final taskIds = <String>[];

    for (final record in failed) {
      if (record.reciterId == reciterId) {
        // Remove failed record before retrying
        await _audioDao.removeDownloadRecord(
          record.surahNumber,
          record.ayahNumber,
          record.reciterId,
        );

        final taskId = await downloadAyah(
          surahNumber: record.surahNumber,
          ayahNumber: record.ayahNumber,
          reciterId: record.reciterId,
        );
        taskIds.add(taskId);
      }
    }

    return taskIds;
  }

  // ═══════════════════════════════════════════════════════════════
  // Internal helpers
  // ═══════════════════════════════════════════════════════════════

  void _emitProgress(
    String taskId, {
    int? bytesReceived,
    int? totalBytes,
    double? progress,
    DownloadStatus? status,
    String? error,
  }) {
    final task = _activeDownloads[taskId];
    if (task == null) {
      // Task was already removed (completed/cancelled), emit final state
      final fallback = DownloadProgress(
        taskId: taskId,
        surahNumber: 0,
        ayahNumber: 0,
        reciterId: '',
        bytesReceived: bytesReceived ?? 0,
        totalBytes: totalBytes ?? 0,
        progress: progress ?? 0.0,
        status: status ?? DownloadStatus.failed,
        error: error,
      );
      _progressController.add(fallback);
      return;
    }

    final updated = task.progress.copyWith(
      bytesReceived: bytesReceived,
      totalBytes: totalBytes,
      progress: progress,
      status: status,
      error: error,
    );

    // Update the stored progress
    _activeDownloads[taskId] = _DownloadTask(
      cancelToken: task.cancelToken,
      progress: updated,
    );

    _progressController.add(updated);
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out';
      case DioExceptionType.sendTimeout:
        return 'Send timed out';
      case DioExceptionType.receiveTimeout:
        return 'Receive timed out';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        return 'Server error (status $statusCode)';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Download failed: ${e.message ?? "Unknown error"}';
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Resource cleanup
  // ═══════════════════════════════════════════════════════════════

  /// Dispose resources
  void dispose() {
    cancelAllDownloads();
    _progressController.close();
  }
}
