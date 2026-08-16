import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/shell/mini_audio_player_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/database/database.dart';
import '../../../../data/repositories/quran_repository.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../providers/reciter_provider.dart';

/// Download Manager screen showing all downloaded surah audio.
class AudioDownloadManagerScreen extends ConsumerStatefulWidget {
  const AudioDownloadManagerScreen({super.key});

  @override
  ConsumerState<AudioDownloadManagerScreen> createState() =>
      _AudioDownloadManagerScreenState();
}

class _AudioDownloadManagerScreenState
    extends ConsumerState<AudioDownloadManagerScreen> {
  List<AudioDownload> _downloads = [];
  int _totalSizeBytes = 0;
  bool _isLoading = true;
  String _sortBy = 'recent'; // recent, surah, reciter
  List<SurahInfo> _surahs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dao = AppDatabase.instance.audioDao;
      final downloads = await dao.getCompletedDownloads();
      final totalSize = await dao.getTotalDownloadSize();
      final surahs = await QuranRepository().getAllSurahs();

      if (mounted) {
        setState(() {
          _downloads = _sortDownloads(downloads);
          _totalSizeBytes = totalSize;
          _surahs = surahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<AudioDownload> _sortDownloads(List<AudioDownload> list) {
    switch (_sortBy) {
      case 'recent':
        return List.from(list)
          ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
      case 'surah':
        return List.from(list)
          ..sort((a, b) => a.surahNumber.compareTo(b.surahNumber));
      case 'reciter':
        return List.from(list)
          ..sort((a, b) => a.reciterId.compareTo(b.reciterId));
      default:
        return list;
    }
  }

  String _getSurahName(int surahNumber) {
    final surah = _surahs
        .where((s) => s.number == surahNumber)
        .firstOrNull;
    return surah?.nameEnglish ?? 'Surah $surahNumber';
  }

  String _getReciterName(String reciterId) {
    final reciter = kReciters.where((r) => r.id == reciterId).firstOrNull;
    return reciter?.englishName ?? reciterId;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _deleteDownload(AudioDownload dl) async {
    // Delete the file.
    if (dl.filePath.isNotEmpty) {
      final file = File(dl.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    // Delete the database record.
    await AppDatabase.instance.audioDao.removeDownloadRecord(
      dl.surahNumber,
      dl.ayahNumber,
      dl.reciterId,
    );
    _loadData();
  }

  Future<void> _playDownload(AudioDownload dl) async {
    if (dl.filePath.isEmpty || !File(dl.filePath).existsSync()) return;
    final service = ref.read(audioHandlerProvider);
    if (service == null) return;
    final surah = _surahs
        .where((s) => s.number == dl.surahNumber)
        .firstOrNull;
    final totalAyahs = surah?.totalAyahs ?? 1;
    await service.buildSurahQueue(
      surahNumber: dl.surahNumber,
      totalAyahs: totalAyahs,
      reciterId: dl.reciterId,
      startAyah: dl.ayahNumber > 0 ? dl.ayahNumber : 1,
    );
    await service.play();
    if (mounted) context.push('/audio/player');
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Clear All Downloads?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary,
          ),
        ),
        content: const Text(
          'This will delete all downloaded audio files. This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.darkTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Delete all files.
      for (final dl in _downloads) {
        if (dl.filePath.isNotEmpty) {
          final file = File(dl.filePath);
          if (await file.exists()) await file.delete();
        }
      }
      await AppDatabase.instance.audioDao.clearAllDownloads();
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Downloads'),
        actions: [
          if (_downloads.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort_rounded, size: 22),
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                  _downloads = _sortDownloads(_downloads);
                });
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'recent',
                  child: Text('Sort by Recent'),
                ),
                const PopupMenuItem(
                  value: 'surah',
                  child: Text('Sort by Surah #'),
                ),
                const PopupMenuItem(
                  value: 'reciter',
                  child: Text('Sort by Reciter'),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_downloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download_for_offline_outlined,
              size: 64,
              color: AppColors.darkTextTertiary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No downloads yet',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Downloaded audio files will appear here.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.darkTextTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Storage summary ──────────────────────────────────────
        _buildStorageSummary(),

        const SizedBox(height: 8),

        // ── Download list ────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _downloads.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.darkBorder),
            itemBuilder: (context, index) {
              final dl = _downloads[index];
              return _buildDownloadTile(dl);
            },
          ),
        ),

        // ── Clear all button ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            label: const Text('Clear All Downloads'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSummary() {
    final sizeStr = _formatSize(_totalSizeBytes);
    final surahCount = <int>{};
    for (final dl in _downloads) {
      surahCount.add(dl.surahNumber);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storage_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sizeStr,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                Text(
                  '${_downloads.length} files across ${surahCount.length} surahs',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTile(AudioDownload dl) {
    final surahName = _getSurahName(dl.surahNumber);
    final reciterName = _getReciterName(dl.reciterId);
    final ayahLabel = dl.ayahNumber > 0 ? 'Ayah ${dl.ayahNumber}' : 'Full Surah';

    return Dismissible(
      key: ValueKey('${dl.surahNumber}_${dl.ayahNumber}_${dl.reciterId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => _deleteDownload(dl),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${dl.surahNumber}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        title: Text(
          '$surahName ($ayahLabel)',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '$reciterName  ·  ${_formatSize(dl.fileSizeBytes)}  ·  ${_formatDate(dl.downloadedAt)}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_circle_outline_rounded,
                  color: AppColors.primary, size: 28),
              onPressed: () => _playDownload(dl),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.darkTextTertiary, size: 22),
              onPressed: () => _deleteDownload(dl),
            ),
          ],
        ),
      ),
    );
  }
}
