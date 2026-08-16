import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/reciter_provider.dart';

class ReciterScreen extends ConsumerStatefulWidget {
 const ReciterScreen({super.key});

 @override
 ConsumerState<ReciterScreen> createState() => _ReciterScreenState();
}

class _ReciterScreenState extends ConsumerState<ReciterScreen> {
 bool _showFavoritesOnly = false;
 final Map<String, Timer> _downloadTimers = {};

 @override
 void dispose() {
 for (final t in _downloadTimers.values) { t.cancel(); }
 super.dispose();
 }

 void _simulateDownload(String reciterId) {
 final notifier = ref.read(reciterProvider.notifier);
 notifier.startDownload(reciterId);
 _downloadTimers[reciterId]?.cancel();

 int current = 0;
 _downloadTimers[reciterId] = Timer.periodic(const Duration(milliseconds: 80), (timer) {
  current += 1;
  if (!mounted) { timer.cancel(); return; }
  if (current >= 114) {
   timer.cancel();
   notifier.completeDownload(reciterId);
  } else {
   notifier.updateDownloadProgress(reciterId, current, (current / 114) * 720.0);
  }
 });
 }

 @override
 Widget build(BuildContext context) {
 final state = ref.watch(reciterProvider);
 final allReciters = ref.watch(recitersListProvider);
 final isDark = Theme.of(context).brightness == Brightness.dark;

 final displayReciters = _showFavoritesOnly
  ? allReciters.where((r) => state.isFavorite(r.id)).toList()
  : allReciters.toList();

 final totalStorage = state.downloadInfo.values.fold<double>(0, (s, i) => s + i.storageUsedMb);

 return Scaffold(
  appBar: AppBar(
   title: const Text('Reciters'),
   actions: [
    IconButton(
     icon: Icon(
      _showFavoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      color: _showFavoritesOnly ? AppColors.error : null,
     ),
     tooltip: _showFavoritesOnly ? 'Show all' : 'Show favorites',
     onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
    ),
   ],
  ),
  body: Column(
   children: [
    // Summary bar
    if (totalStorage > 0)
     Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
       color: AppColors.primary.withValues(alpha: 0.08),
       borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
       children: [
        Icon(Icons.storage_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
         'Total downloaded: ${totalStorage.toStringAsFixed(1)} MB',
         style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
         ),
        ),
       ],
      ),
     ),

    // Reciter list
    Expanded(
     child: displayReciters.isEmpty
      ? Center(
        child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
          Icon(
           _showFavoritesOnly ? Icons.favorite_border_rounded : Icons.mic_none_rounded,
           size: 64,
           color: AppColors.darkTextTertiary,
          ),
          const SizedBox(height: 12),
          Text(
           _showFavoritesOnly ? 'No favorite reciters yet' : 'No reciters available',
           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.darkTextSecondary,
           ),
          ),
         ],
        ),
       )
      : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayReciters.length,
        itemBuilder: (context, index) {
         final reciter = displayReciters[index];
         final dlInfo = state.getDownloadInfo(reciter.id);
         return _ReciterCard(
          reciter: reciter,
          isFavorite: state.isFavorite(reciter.id),
          isDefault: state.isDefault(reciter.id),
          downloadInfo: dlInfo,
          isDark: isDark,
          onToggleFavorite: () => ref.read(reciterProvider.notifier).toggleFavorite(reciter.id),
          onSetDefault: () => ref.read(reciterProvider.notifier).setDefault(reciter.id),
          onDownload: () => _simulateDownload(reciter.id),
          onCancel: () {
           _downloadTimers[reciter.id]?.cancel();
           ref.read(reciterProvider.notifier).cancelDownload(reciter.id);
          },
         )
          .animate(delay: (index * 40).ms)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.06, end: 0, duration: 300.ms);
        },
       ),
    ),
   ],
  ),
 );
 }
}

// ── Reciter Card ──────────────────────────────────────────────────

class _ReciterCard extends StatelessWidget {
 final Reciter reciter;
 final bool isFavorite;
 final bool isDefault;
 final ReciterDownloadInfo? downloadInfo;
 final bool isDark;
 final VoidCallback onToggleFavorite;
 final VoidCallback onSetDefault;
 final VoidCallback onDownload;
 final VoidCallback onCancel;

 const _ReciterCard({
  required this.reciter,
  required this.isFavorite,
  required this.isDefault,
  required this.downloadInfo,
  required this.isDark,
  required this.onToggleFavorite,
  required this.onSetDefault,
  required this.onDownload,
  required this.onCancel,
 });

 @override
 Widget build(BuildContext context) {
  final isDownloading = downloadInfo?.status == ReciterDownloadStatus.downloading;
  final isDownloaded = downloadInfo?.status == ReciterDownloadStatus.downloaded;

  return Padding(
   padding: const EdgeInsets.only(bottom: 12),
   child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
     borderRadius: BorderRadius.circular(16),
     border: Border.all(
      color: isDefault
       ? AppColors.primary.withValues(alpha: 0.5)
       : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
      width: isDefault ? 1.5 : 0.5,
     ),
     color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    ),
    child: Column(
     children: [
      Row(
       children: [
        // Avatar
        Container(
         width: 48,
         height: 48,
         decoration: BoxDecoration(
          color: isDefault
           ? AppColors.primary.withValues(alpha: 0.12)
           : AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
         ),
         child: Icon(
          Icons.mic_rounded,
          color: isDefault ? AppColors.primary : AppColors.secondary,
          size: 24,
         ),
        ),
        const SizedBox(width: 14),
        // Info
        Expanded(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
            children: [
             Text(
              reciter.englishName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
               fontWeight: FontWeight.w600,
              ),
             ),
             if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
               decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
               ),
               child: const Text(
                'DEFAULT',
                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5),
               ),
              ),
             ],
            ],
           ),
           const SizedBox(height: 2),
           Text(
            reciter.arabicName,
            style: TextStyle(
             fontFamily: AppTheme.arabicFontFamily,
             fontSize: 15,
             color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
           ),
           const SizedBox(height: 4),
           Row(
            children: [
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
               color: reciter.style == 'Mujawwad'
                ? AppColors.secondary.withValues(alpha: 0.1)
                : AppColors.info.withValues(alpha: 0.1),
               borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
               reciter.style,
               style: TextStyle(
                color: reciter.style == 'Mujawwad' ? AppColors.secondary : AppColors.info,
                fontSize: 11,
                fontWeight: FontWeight.w600,
               ),
              ),
             ),
             if (downloadInfo != null && downloadInfo!.storageUsedMb > 0) ...[
              const SizedBox(width: 8),
              Text(
               '${downloadInfo!.storageUsedMb.toStringAsFixed(0)} MB',
               style: TextStyle(
                fontSize: 11,
                color: AppColors.darkTextTertiary,
               ),
              ),
             ],
            ],
           ),
          ],
         ),
        ),
        // Favorite button
        IconButton(
         icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? AppColors.error : AppColors.darkTextTertiary,
          size: 22,
         ),
         onPressed: onToggleFavorite,
        ),
       ],
      ),

      // Download section
      if (isDownloading) ...[
       const SizedBox(height: 12),
       Column(
        children: [
         LinearProgressIndicator(
          value: downloadInfo!.progress,
          backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          borderRadius: BorderRadius.circular(4),
         ),
         const SizedBox(height: 6),
         Row(
          children: [
           Expanded(
            child: Text(
             'Downloading... ${downloadInfo!.downloadedSurahs}/114 surahs',
             style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
            ),
           ),
           TextButton(
            onPressed: onCancel,
            child: const Text('Cancel', style: TextStyle(fontSize: 12, color: AppColors.error)),
           ),
          ],
         ),
        ],
       ),
      ],

      // Action buttons
      const SizedBox(height: 10),
      Row(
       children: [
        if (!isDefault)
         Expanded(
          child: OutlinedButton.icon(
           onPressed: onSetDefault,
           icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
           label: const Text('Set Default'),
           style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
           ),
          ),
         ),
        if (!isDefault) const SizedBox(width: 8),
        Expanded(
         child: FilledButton.icon(
          onPressed: isDownloading ? null : (isDownloaded ? null : onDownload),
          icon: Icon(isDownloaded ? Icons.check_rounded : Icons.download_rounded, size: 16),
          label: Text(isDownloaded ? 'Downloaded' : 'Download All'),
          style: FilledButton.styleFrom(
           padding: const EdgeInsets.symmetric(vertical: 8),
           backgroundColor: isDownloaded ? AppColors.success : null,
          ),
         ),
        ),
       ],
      ),
     ],
    ),
   ),
  );
 }
}
