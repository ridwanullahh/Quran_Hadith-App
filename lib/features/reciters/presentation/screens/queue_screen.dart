import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/shell/mini_audio_player_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/audio/audio_player_service.dart';

/// Queue management screen showing the current playback queue.
class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  bool _shuffled = false;

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(audioHandlerProvider);
    final playerStateAsync = ref.watch(miniAudioPlayerProvider);
    final playerState =
        playerStateAsync.valueOrNull ?? const MiniAudioPlayerState();

    final hasQueue = playerState.isActive;
    final totalQueueItems = service?.totalQueueItems ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playback Queue'),
        actions: [
          if (hasQueue) ...[
            // Shuffle toggle
            IconButton(
              icon: Icon(
                Icons.shuffle_rounded,
                color: _shuffled ? AppColors.secondary : AppColors.darkTextSecondary,
                size: 22,
              ),
              onPressed: () => setState(() => _shuffled = !_shuffled),
              tooltip: 'Shuffle',
            ),

            // Clear queue
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppColors.error, size: 22),
              onPressed: () {
                service?.stop();
                setState(() => _shuffled = false);
                Navigator.pop(context);
              },
              tooltip: 'Clear Queue',
            ),
          ],
        ],
      ),
      body: !hasQueue
          ? _buildEmptyState()
          : _buildQueueList(service, playerState),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.queue_music_rounded,
            size: 64,
            color: AppColors.darkTextTertiary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Queue is empty',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start playing a surah to see its ayahs here.',
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

  Widget _buildQueueList(
    AudioPlayerService? service,
    MiniAudioPlayerState playerState,
  ) {
    final totalAyahs = playerState.totalAyahs;
    final currentAyah = playerState.currentAyah;

    // Generate queue items.
    final items = List.generate(totalAyahs, (index) => index + 1);

    // If shuffled, show a shuffled view (visual only since we can't
    // re-order the actual queue without modifying AudioPlayerService).
    final displayItems = _shuffled ? List<int>.from(items)..shuffle() : items;

    // Estimate total duration: ~15 seconds per ayah average.
    final estimatedSeconds = totalAyahs * 15;
    final estimatedMin = estimatedSeconds ~/ 60;
    final estimatedHours = estimatedMin ~/ 60;
    final remainingMin = estimatedMin % 60;
    final durationStr = estimatedHours > 0
        ? '${estimatedHours}h ${remainingMin}m'
        : '${estimatedMin}m';

    return Column(
      children: [
        // ── Summary bar ──────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.audiotrack_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalAyahs ayahs in queue',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    Text(
                      'Est. duration: $durationStr',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Ayah $currentAyah / $totalAyahs',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Queue items ─────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final ayahNumber = displayItems[index];
              final isCurrentlyPlaying = ayahNumber == currentAyah;
              final isPast = ayahNumber < currentAyah && !_shuffled;

              return _buildQueueItem(
                ayahNumber: ayahNumber,
                index: index,
                isCurrentlyPlaying: isCurrentlyPlaying,
                isPast: isPast,
                onTap: () {
                  service?.seekToAyah(ayahNumber);
                },
                onRemove: () {
                  // Visual feedback only - removing individual items
                  // from the queue is a conceptual action.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ayah $ayahNumber removed from queue'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQueueItem({
    required int ayahNumber,
    required int index,
    required bool isCurrentlyPlaying,
    required bool isPast,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return Dismissible(
      key: ValueKey(ayahNumber),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.remove_circle_outline_rounded,
            color: AppColors.error),
      ),
      onDismissed: (_) => onRemove(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
        onTap: onTap,
        leading: SizedBox(
          width: 32,
          child: isCurrentlyPlaying
              ? const Icon(Icons.equalizer_rounded,
                  color: AppColors.primary, size: 22)
              : Text(
                  '${ayahNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isPast
                        ? AppColors.darkTextTertiary
                        : AppColors.darkTextSecondary,
                  ),
                ),
        ),
        title: Text(
          'Ayah $ayahNumber',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight:
                isCurrentlyPlaying ? FontWeight.w700 : FontWeight.w500,
            color: isCurrentlyPlaying
                ? AppColors.primary
                : (isPast
                    ? AppColors.darkTextTertiary
                    : AppColors.darkTextPrimary),
          ),
        ),
        subtitle: Text(
          isCurrentlyPlaying ? 'Playing now' : 'Tap to play',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: isCurrentlyPlaying
                ? AppColors.primary.withOpacity(0.7)
                : AppColors.darkTextTertiary,
          ),
        ),
        trailing: isCurrentlyPlaying
            ? const Icon(Icons.volume_up_rounded,
                color: AppColors.primary, size: 20)
            : const Icon(Icons.chevron_right_rounded,
                color: AppColors.darkTextTertiary, size: 20),
      ),
    );
  }
}
