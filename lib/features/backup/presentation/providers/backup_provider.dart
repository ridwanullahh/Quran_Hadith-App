import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive/hive_flutter.dart';

import '../../../../core/services/database/database.dart';

/// Holds the state of a backup / restore operation.
class BackupState {
  final bool isExporting;
  final bool isImporting;
  final String? lastBackupDate;
  final String? lastBackupPath;
  final String? lastBackupSize;
  final BackupSummary? lastSummary;
  final String? error;
  final String? successMessage;

  const BackupState({
    this.isExporting = false,
    this.isImporting = false,
    this.lastBackupDate,
    this.lastBackupPath,
    this.lastBackupSize,
    this.lastSummary,
    this.error,
    this.successMessage,
  });

  BackupState copyWith({
    bool? isExporting,
    bool? isImporting,
    String? lastBackupDate,
    String? lastBackupPath,
    String? lastBackupSize,
    BackupSummary? lastSummary,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BackupState(
      isExporting: isExporting ?? this.isExporting,
      isImporting: isImporting ?? this.isImporting,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      lastBackupPath: lastBackupPath ?? this.lastBackupPath,
      lastBackupSize: lastBackupSize ?? this.lastBackupSize,
      lastSummary: lastSummary ?? this.lastSummary,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Summary of the backup data contents.
class BackupSummary {
  final int bookmarkCount;
  final int noteCount;
  final int memorizationCount;
  final int revisionCount;
  final int readingHistoryCount;
  final int audioDownloadCount;

  const BackupSummary({
    required this.bookmarkCount,
    required this.noteCount,
    required this.memorizationCount,
    required this.revisionCount,
    required this.readingHistoryCount,
    required this.audioDownloadCount,
  });

  int get totalItems =>
      bookmarkCount +
      noteCount +
      memorizationCount +
      revisionCount +
      readingHistoryCount +
      audioDownloadCount;
}

/// Provider that handles export and import of user data.
class BackupNotifier extends StateNotifier<BackupState> {
  BackupNotifier() : super(const BackupState()) {
    _loadLastBackupInfo();
  }

  Future<void> _loadLastBackupInfo() async {
    final box = Hive.box('settings');
    final lastDate = box.get('last_backup_date') as String?;
    final lastPath = box.get('last_backup_path') as String?;
    final lastSize = box.get('last_backup_size') as String?;
    if (lastDate != null) {
      state = state.copyWith(
        lastBackupDate: lastDate,
        lastBackupPath: lastPath,
        lastBackupSize: lastSize,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Export
  // ═══════════════════════════════════════════════════════════════════

  Future<void> exportBackup() async {
    state =
        state.copyWith(isExporting: true, clearError: true, clearSuccess: true);
    try {
      final db = AppDatabase.instance;

      // Gather all data
      final bookmarks = await db.bookmarkDao.getAllBookmarks();
      final notes = await db.notesDao.getAllNotes();
      final memorization = await db.hifdhDao.getAllProgress();
      final revisions = await db.hifdhDao.getAllRevisions();
      final readingHistory = await db.getReadingHistory(limit: 10000);
      final audioDownloads = await db.audioDao.getAllDownloads();
      final settingsBox = Hive.box('settings');
      final settingsMap = Map<String, dynamic>.from(settingsBox.toMap());

      // Build backup JSON
      final backup = {
        'app': 'MinhaajulHudaa',
        'version': '0.1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'settings': settingsMap,
        'data': {
          'bookmarks': bookmarks.map((b) => _bookmarkToJson(b)).toList(),
          'notes': notes.map((n) => _noteToJson(n)).toList(),
          'memorization_progress':
              memorization.map((m) => _memorizationToJson(m)).toList(),
          'revision_schedule':
              revisions.map((r) => _revisionToJson(r)).toList(),
          'reading_history':
              readingHistory.map((r) => _readingHistoryToJson(r)).toList(),
          'audio_downloads':
              audioDownloads.map((a) => _audioDownloadToJson(a)).toList(),
        },
      };

      final summary = BackupSummary(
        bookmarkCount: bookmarks.length,
        noteCount: notes.length,
        memorizationCount: memorization.length,
        revisionCount: revisions.length,
        readingHistoryCount: readingHistory.length,
        audioDownloadCount: audioDownloads.length,
      );

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      final bytes = utf8.encode(jsonString);
      final sizeStr = _formatBytes(bytes.length);

      // Pick save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName: 'minhaajulhudaa_backup_${_dateStamp()}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        state = state.copyWith(
          isExporting: false,
          error: 'Export cancelled',
        );
        return;
      }

      final file = File(result);
      await file.writeAsBytes(bytes);

      // Remember last backup
      final now = DateTime.now();
      await settingsBox.put('last_backup_date', now.toIso8601String());
      await settingsBox.put('last_backup_path', result);
      await settingsBox.put('last_backup_size', sizeStr);

      state = state.copyWith(
        isExporting: false,
        lastBackupDate: now.toIso8601String(),
        lastBackupPath: result,
        lastBackupSize: sizeStr,
        lastSummary: summary,
        successMessage: 'Backup saved successfully ($sizeStr)',
      );
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: 'Export failed: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Import
  // ═══════════════════════════════════════════════════════════════════

  Future<void> importBackup() async {
    state =
        state.copyWith(isImporting: true, clearError: true, clearSuccess: true);
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        state = state.copyWith(
          isImporting: false,
          error: 'Import cancelled',
        );
        return;
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final backup = json.decode(jsonString) as Map<String, dynamic>;

      // Validate
      if (backup['app'] != 'MinhaajulHudaa') {
        state = state.copyWith(
          isImporting: false,
          error: 'Invalid backup file \u2013 not a MinhaajulHudaa backup.',
        );
        return;
      }

      final data = backup['data'] as Map<String, dynamic>;
      final db = AppDatabase.instance;

      // Restore bookmarks
      final bookmarks = data['bookmarks'] as List<dynamic>?;
      if (bookmarks != null) {
        for (final b in bookmarks) {
          await db.bookmarkDao.addBookmark(
            surahNumber: b['surah_number'] as int,
            ayahNumber: b['ayah_number'] as int,
            juzNumber: b['juz_number'] as int? ?? 0,
            page: b['page'] as int? ?? 0,
            surahName: b['surah_name'] as String? ?? '',
            ayahText: b['ayah_text'] as String? ?? '',
            category: b['category'] as String? ?? 'general',
          );
        }
      }

      // Restore notes
      final notes = data['notes'] as List<dynamic>?;
      if (notes != null) {
        for (final n in notes) {
          await db.notesDao.addNote(
            surahNumber: n['surah_number'] as int,
            ayahNumber: n['ayah_number'] as int,
            content: n['content'] as String? ?? '',
            title: n['title'] as String? ?? '',
            colorIndex: n['color_index'] as int? ?? 0,
          );
        }
      }

      // Restore memorization progress
      final mem = data['memorization_progress'] as List<dynamic>?;
      if (mem != null) {
        for (final m in mem) {
          await db.hifdhDao.recordReview(
            surahNumber: m['surah_number'] as int,
            ayahNumber: m['ayah_number'] as int,
            quality: m['total_correct'] != null &&
                    m['total_correct'] > 0
                ? 5
                : 2,
          );
        }
      }

      // Restore reading history
      final history = data['reading_history'] as List<dynamic>?;
      if (history != null) {
        for (final h in history) {
          await db.addReadingHistory(
            surahNumber: h['surah_number'] as int,
            ayahNumber: h['ayah_number'] as int,
            readingMode: h['reading_mode'] as String? ?? 'reading',
            timeSpentSeconds: h['time_spent_seconds'] as int? ?? 0,
          );
        }
      }

      // Restore settings (selective \u2013 don't override last_backup_*)
      final settings = backup['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        final settingsBox = Hive.box('settings');
        for (final entry in settings.entries) {
          if (!entry.key.startsWith('last_backup_')) {
            await settingsBox.put(entry.key, entry.value);
          }
        }
      }

      final summary = BackupSummary(
        bookmarkCount: bookmarks?.length ?? 0,
        noteCount: notes?.length ?? 0,
        memorizationCount: mem?.length ?? 0,
        revisionCount: data['revision_schedule']?.length as int? ?? 0,
        readingHistoryCount: history?.length ?? 0,
        audioDownloadCount: data['audio_downloads']?.length as int? ?? 0,
      );

      state = state.copyWith(
        isImporting: false,
        lastSummary: summary,
        successMessage:
            'Backup restored (${summary.totalItems} items imported)',
      );
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        error: 'Import failed: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Auto-backup check
  // ═══════════════════════════════════════════════════════════════════

  /// Returns true if a backup reminder should be shown (7 days since last backup or never).
  bool shouldShowBackupReminder() {
    final lastDate = state.lastBackupDate;
    if (lastDate == null) return true;
    try {
      final last = DateTime.parse(lastDate);
      return DateTime.now().difference(last).inDays >= 7;
    } catch (_) {
      return true;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // JSON serializers
  // ═══════════════════════════════════════════════════════════════════

  Map<String, dynamic> _bookmarkToJson(Bookmark b) => {
        'surah_number': b.surahNumber,
        'ayah_number': b.ayahNumber,
        'juz_number': b.juzNumber,
        'page': b.page,
        'surah_name': b.surahName,
        'ayah_text': b.ayahText,
        'category': b.category,
        'created_at': b.createdAt.toIso8601String(),
      };

  Map<String, dynamic> _noteToJson(Note n) => {
        'surah_number': n.surahNumber,
        'ayah_number': n.ayahNumber,
        'content': n.content,
        'title': n.title,
        'color_index': n.colorIndex,
        'created_at': n.createdAt.toIso8601String(),
        'updated_at': n.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _memorizationToJson(MemorizationProgress m) => {
        'surah_number': m.surahNumber,
        'ayah_number': m.ayahNumber,
        'status': m.status,
        'repetitions': m.repetitions,
        'ease_factor': m.easeFactor,
        'interval_days': m.intervalDays,
        'consecutive_correct': m.consecutiveCorrect,
        'total_attempts': m.totalAttempts,
        'total_correct': m.totalCorrect,
        'last_reviewed': m.lastReviewed?.toIso8601String(),
        'next_review_date': m.nextReviewDate?.toIso8601String(),
        'created_at': m.createdAt.toIso8601String(),
        'updated_at': m.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _revisionToJson(RevisionSchedule r) => {
        'surah_number': r.surahNumber,
        'ayah_start': r.ayahStart,
        'ayah_end': r.ayahEnd,
        'scheduled_date': r.scheduledDate.toIso8601String(),
        'status': r.status,
        'priority': r.priority,
        'notes': r.notes,
        'completed_at': r.completedAt?.toIso8601String(),
        'created_at': r.createdAt.toIso8601String(),
      };

  Map<String, dynamic> _readingHistoryToJson(ReadingHistory r) => {
        'surah_number': r.surahNumber,
        'ayah_number': r.ayahNumber,
        'reading_mode': r.readingMode,
        'time_spent_seconds': r.timeSpentSeconds,
        'read_at': r.readAt.toIso8601String(),
      };

  Map<String, dynamic> _audioDownloadToJson(AudioDownload a) => {
        'surah_number': a.surahNumber,
        'ayah_number': a.ayahNumber,
        'reciter_id': a.reciterId,
        'file_path': a.filePath,
        'file_size_bytes': a.fileSizeBytes,
        'download_status': a.downloadStatus,
        'downloaded_at': a.downloadedAt.toIso8601String(),
      };

  String _dateStamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}

/// Simple provider for [BackupNotifier] usable without code generation.
final backupProvider =
    StateNotifierProvider.autoDispose<BackupNotifier, BackupState>(
  BackupNotifier.new,
);
