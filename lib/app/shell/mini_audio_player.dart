import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import 'mini_audio_player_provider.dart';

/// A compact, persistent audio player bar that sits just above the
/// bottom navigation bar.
///
/// Shows:
/// - Current surah / ayah info
/// - A thin progress bar
/// - Play/pause, previous, next buttons
///
/// Tapping anywhere on the bar (except the buttons) expands to a
/// full-screen audio player (navigation to a dedicated route).
class MiniAudioPlayer extends ConsumerWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(miniAudioPlayerProvider);
    final state = playerState.valueOrNull ?? const MiniAudioPlayerState();
    final controller = ref.read(miniAudioPlayerControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Don't show the bar if nothing is playing.
    if (!state.isActive) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? AppColors.audioBarBackground : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thin progress bar spanning the full width.
          SizedBox(
            height: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Track
                    Container(
                      height: 3,
                      width: constraints.maxWidth,
                      color: isDark
                          ? AppColors.audioProgressTrack
                          : AppColors.lightSurfaceVariant,
                    ),
                    // Buffered
                    if (state.duration.inMilliseconds > 0)
                      FractionallySizedBox(
                        widthFactor: (state.bufferedPosition.inMilliseconds /
                                state.duration.inMilliseconds)
                            .clamp(0.0, 1.0),
                        child: Container(
                          height: 3,
                          color: (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)
                              .withOpacity(0.3),
                        ),
                      ),
                    // Progress
                    if (state.duration.inMilliseconds > 0)
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: state.progress,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.audioProgressBar,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                    // Scrub handle
                    if (state.duration.inMilliseconds > 0)
                      Positioned(
                        left: (state.progress * constraints.maxWidth) - 5,
                        top: -2,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.audioProgressBar,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.audioProgressBar
                                    .withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // Controls row.
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigate to full audio player (expand).
                // In a production app this would navigate to a dedicated
                // audio player screen.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Full audio player: ${state.surahName} - ${state.ayahProgressLabel}',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Previous button.
                    _ControlButton(
                      icon: Icons.skip_previous_rounded,
                      onPressed: controller.previous,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 4),
                    // Play / Pause button.
                    _PlayPauseButton(
                      isPlaying: state.isPlaying,
                      isBuffering: state.isBuffering,
                      onPressed: controller.playPause,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 4),
                    // Next button.
                    _ControlButton(
                      icon: Icons.skip_next_rounded,
                      onPressed: controller.next,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 14),
                    // Surah info.
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Surah name
                          Text(
                            state.surahName.isNotEmpty
                                ? state.surahName
                                : 'Surah ${state.currentAyah}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Ayah progress & time.
                          Text(
                            '${state.ayahProgressLabel}  ·  '
                            '${state.formattedPosition} / ${state.formattedDuration}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Reciter name (if available).
                    if (state.reciterName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          state.reciterName,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 250.ms);
  }
}

// ── Play / Pause Button ────────────────────────────────────────────

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onPressed;
  final bool isDark;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isBuffering,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: isBuffering ? null : onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(maxWidth: 40, maxHeight: 40),
        icon: isBuffering
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark
                      ? AppColors.navItemDarkSelected
                      : AppColors.navItemSelected,
                ),
              )
            : Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: isDark
                    ? AppColors.navItemDarkSelected
                    : AppColors.navItemSelected,
                size: 28,
              ),
      ),
    );
  }
}

// ── Generic Control Button ─────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
        icon: Icon(
          icon,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          size: 22,
        ),
      ),
    );
  }
}
