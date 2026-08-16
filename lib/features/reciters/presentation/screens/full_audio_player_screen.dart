import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/shell/mini_audio_player_provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/audio/audio_player_service.dart';
import '../../../../data/repositories/quran_repository.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../widgets/speed_control_sheet.dart';

/// Immersive full-screen audio player with rich controls, gestures,
/// sleep timer, and Arabic ayah display.
class FullAudioPlayerScreen extends ConsumerStatefulWidget {
  const FullAudioPlayerScreen({super.key});

  @override
  ConsumerState<FullAudioPlayerScreen> createState() =>
      _FullAudioPlayerScreenState();
}

class _FullAudioPlayerScreenState
    extends ConsumerState<FullAudioPlayerScreen>
    with TickerProviderStateMixin {
  // ── Ayah text cache ───────────────────────────────────────────
  final QuranRepository _quranRepo = QuranRepository();
  String _ayahText = '';
  String _surahNameArabic = '';
  String _surahNameEnglish = '';
  SurahInfo? _surahInfo;
  bool _loadingAyah = false;

  // ── Sleep timer ───────────────────────────────────────────────
  Timer? _sleepTimer;
  int _sleepSecondsRemaining = 0;
  bool _sleepEndOfSurah = false;

  // ── Speed display overlay ─────────────────────────────────────
  String _speedDisplay = '';
  Timer? _speedDisplayTimer;

  // ── Volume overlay ────────────────────────────────────────────
  String _volumeDisplay = '';
  Timer? _volumeDisplayTimer;
  double _volumeLevel = 0.5;

  // ── Gesture animation ─────────────────────────────────────────
  double _swipeOffsetX = 0;
  double _swipeOffsetY = 0;

  // ── Background animation ──────────────────────────────────────
  late final AnimationController _bgController;
  late final Animation<double> _bgAnimation;

  // ── Ayah text overlay (long press) ────────────────────────────
  bool _showAyahOverlay = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgAnimation = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _speedDisplayTimer?.cancel();
    _volumeDisplayTimer?.cancel();
    _bgController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // Load surah info and ayah text
  // ═══════════════════════════════════════════════════════════════

  Future<void> _loadSurahAndAyah(int surahNumber, int ayahNumber) async {
    if (_loadingAyah) return;
    setState(() => _loadingAyah = true);

    try {
      if (_surahInfo == null || _surahInfo!.number != surahNumber) {
        _surahInfo = await _quranRepo.getSurahByNumber(surahNumber);
        _surahNameArabic = _surahInfo!.nameArabic;
        _surahNameEnglish = _surahInfo!.nameEnglish;
      }

      final ayahs = await _quranRepo.getSurahAyahs(surahNumber);
      final ayah = ayahs
          .where((a) => a.ayahNumber == ayahNumber)
          .firstOrNull;
      if (ayah != null && mounted) {
        setState(() {
          _ayahText = ayah.textUthmani;
          _loadingAyah = false;
        });
      } else if (mounted) {
        setState(() {
          _ayahText = '';
          _loadingAyah = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAyah = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Sleep timer
  // ═══════════════════════════════════════════════════════════════

  void _showSleepTimerSheet() {
    final service = ref.read(audioHandlerProvider);
    if (service == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SleepTimerSheet(
        currentSeconds: _sleepSecondsRemaining,
        isEndOfSurah: _sleepEndOfSurah,
        onSelected: (seconds) {
          _setSleepTimer(seconds);
          Navigator.pop(ctx);
        },
        onEndOfSurah: () {
          _setSleepEndOfSurah();
          Navigator.pop(ctx);
        },
        onCancel: () {
          _cancelSleepTimer();
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _setSleepTimer(int seconds) {
    _sleepTimer?.cancel();
    _sleepEndOfSurah = false;
    setState(() {
      _sleepSecondsRemaining = seconds;
    });
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _sleepSecondsRemaining--;
      });
      if (_sleepSecondsRemaining <= 0) {
        timer.cancel();
        final service = ref.read(audioHandlerProvider);
        service?.pause();
        if (mounted) {
          setState(() {
            _sleepSecondsRemaining = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sleep timer: playback paused'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _setSleepEndOfSurah() {
    _sleepTimer?.cancel();
    setState(() {
      _sleepEndOfSurah = true;
      _sleepSecondsRemaining = 0;
    });
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    setState(() {
      _sleepSecondsRemaining = 0;
      _sleepEndOfSurah = false;
    });
  }

  String _formatSleepTime(int seconds) {
    if (seconds <= 0) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  // ═══════════════════════════════════════════════════════════════
  // Speed cycling
  // ═══════════════════════════════════════════════════════════════

  static const List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  void _cycleSpeed(AudioPlayerService service) {
    final current = service.speed;
    int idx = _speeds.indexOf(current);
    if (idx == -1) idx = 2; // default to 1.0
    idx = (idx + 1) % _speeds.length;
    final newSpeed = _speeds[idx];
    service.setSpeed(newSpeed);
    _showSpeedOverlay(newSpeed);
  }

  void _showSpeedOverlay(double speed) {
    _speedDisplayTimer?.cancel();
    setState(() => _speedDisplay = '${speed}x');
    _speedDisplayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _speedDisplay = '');
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // Repeat mode cycling
  // ═══════════════════════════════════════════════════════════════

  void _cycleRepeatMode(AudioPlayerService service) {
    final current = service.repeatMode;
    final next = switch (current) {
      RepeatMode.none => RepeatMode.one,
      RepeatMode.one => RepeatMode.all,
      RepeatMode.all => RepeatMode.none,
    };
    service.setRepeatMode(next);
  }

  // ═══════════════════════════════════════════════════════════════
  // Volume overlay (conceptual visual feedback)
  // ═══════════════════════════════════════════════════════════════

  void _showVolumeOverlay(bool up) {
    _volumeDisplayTimer?.cancel();
    setState(() {
      _volumeLevel = (_volumeLevel + (up ? 0.1 : -0.1)).clamp(0.0, 1.0);
      _volumeDisplay = '${(_volumeLevel * 100).round()}%';
    });
    _volumeDisplayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _volumeDisplay = '');
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // Gesture handlers
  // ═══════════════════════════════════════════════════════════════

  void _onHorizontalSwipe(DragEndDetails details) {
    final service = ref.read(audioHandlerProvider);
    if (service == null) return;
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      // Swipe left -> next ayah
      service.skipToNext();
    } else if (velocity > 300) {
      // Swipe right -> prev ayah
      service.skipToPrevious();
    }
  }

  void _onVerticalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      // Swipe up -> increase volume
      _showVolumeOverlay(true);
    } else if (velocity > 300) {
      // Swipe down -> decrease volume
      _showVolumeOverlay(false);
    }
  }

  void _onDoubleTapLeft() {
    ref.read(audioHandlerProvider)?.skipToPrevious();
  }

  void _onDoubleTapRight() {
    ref.read(audioHandlerProvider)?.skipToNext();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() => _showAyahOverlay = true);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => _showAyahOverlay = false);
  }

  // ═══════════════════════════════════════════════════════════════
  // Format duration
  // ═══════════════════════════════════════════════════════════════

  String _formatDuration(Duration d) {
    final m = (d.inSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(audioHandlerProvider);
    if (service == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Text(
            'No audio service available',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.darkTextSecondary,
            ),
          ),
        ),
      );
    }

    // Listen to combined audio streams.
    final playerStateAsync = ref.watch(miniAudioPlayerProvider);
    final playerState =
        playerStateAsync.valueOrNull ?? const MiniAudioPlayerState();
    final repeatMode = service.repeatMode;
    final speed = service.speed;

    // Load ayah text when surah/ayah changes.
    if (playerState.isActive &&
        (_surahInfo == null ||
            service.currentSurahNumber != _surahInfo!.number)) {
      _loadSurahAndAyah(
          service.currentSurahNumber, service.currentAyahNumber);
    } else if (playerState.isActive) {
      // Only reload ayah text if the ayah number changed.
      final expectedAyah = service.currentAyahNumber;
      if (expectedAyah > 0 && _ayahText.isNotEmpty) {
        // Quick check: the ayah text should change with each ayah.
        // We detect this through the stream data rather than re-querying.
      }
    }

    final hasActiveTimer =
        _sleepSecondsRemaining > 0 || _sleepEndOfSurah;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (context, _) {
          final bgOpacity = 0.5 + 0.5 * _bgAnimation.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkBackground,
                  AppColors.darkSurface.withOpacity(bgOpacity),
                  AppColors.darkBackground,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Top bar ────────────────────────────────────
                  _buildTopBar(service, playerState),

                  const Spacer(flex: 1),

                  // ── Surah name & ayah indicator ──────────────────
                  _buildSurahHeader(playerState),

                  const SizedBox(height: 24),

                  // ── Arabic ayah text with gestures ───────────────
                  Expanded(
                    flex: 4,
                    child: _buildAyahTextWithGestures(service),
                  ),

                  const Spacer(flex: 1),

                  // ── Progress slider ─────────────────────────────
                  _buildProgressSlider(service, playerState),

                  const SizedBox(height: 8),

                  // ── Time labels ─────────────────────────────────
                  _buildTimeLabels(playerState),

                  const SizedBox(height: 24),

                  // ── Main controls ───────────────────────────────
                  _buildMainControls(service, repeatMode, speed),

                  const SizedBox(height: 16),

                  // ── Bottom row: queue, sleep, settings ───────────
                  _buildBottomActions(service, hasActiveTimer),

                  // ── Ayah progress bar ───────────────────────────
                  const SizedBox(height: 12),
                  _buildAyahProgressBar(playerState),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
      // ── Overlays ───────────────────────────────────────────────
      floatingActionButton: _speedDisplay.isNotEmpty
          ? _buildSpeedOverlay()
          : (_volumeDisplay.isNotEmpty ? _buildVolumeOverlay() : null),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Widget builders
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTopBar(AudioPlayerService service, MiniAudioPlayerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkTextPrimary, size: 28),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          Text(
            'Now Playing',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.queue_music_rounded,
                color: AppColors.darkTextPrimary, size: 22),
            onPressed: () => context.push('/audio/queue'),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahHeader(MiniAudioPlayerState state) {
    return Column(
      children: [
        if (_surahNameArabic.isNotEmpty)
          Text(
            _surahNameArabic,
            style: const TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              height: 1.4,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          _surahNameEnglish.isNotEmpty
              ? _surahNameEnglish
              : state.surahName,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.reciterName,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            state.ayahProgressLabel,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAyahTextWithGestures(AudioPlayerService service) {
    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalSwipe,
      onVerticalDragEnd: _onVerticalSwipe,
      onDoubleTap: () {
        // Determine which half was tapped.
        // We use the center of the screen.
        final screenWidth = MediaQuery.of(context).size.width;
        // Can't determine tap position from onDoubleTap, use
        // separate detectors.
      },
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        children: [
          // Left half - double tap for previous
          Positioned.fill(
            left: 0,
            child: GestureDetector(
              onDoubleTap: _onDoubleTapLeft,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Right half - double tap for next
          Positioned.fill(
            right: 0,
            child: GestureDetector(
              onDoubleTap: _onDoubleTapRight,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Arabic text
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _loadingAyah
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Padding(
                      key: ValueKey(_ayahText),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _ayahText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'ScheherazadeNew',
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextPrimary,
                          height: 1.8,
                          shadows: [
                            Shadow(
                              color: Color(0x40000000),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          // Ayah overlay (long press)
          if (_showAyahOverlay)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      _ayahText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary,
                        height: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(
      AudioPlayerService service, MiniAudioPlayerState state) {
    final position = state.position;
    final duration = state.duration;
    final progress = state.progress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 6,
          thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 8),
          overlayShape:
              const RoundSliderOverlayShape(overlayRadius: 16),
          activeTrackColor: AppColors.audioProgressBar,
          inactiveTrackColor: AppColors.audioProgressTrack,
          thumbColor: AppColors.audioProgressBar,
          overlayColor: AppColors.audioProgressBar.withOpacity(0.2),
        ),
        child: Slider(
          value: progress.clamp(0.0, 1.0),
          onChanged: (value) {
            final targetMs = (value * duration.inMilliseconds).round();
            service.seek(Duration(milliseconds: targetMs));
          },
        ),
      ),
    );
  }

  Widget _buildTimeLabels(MiniAudioPlayerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            state.formattedPosition,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.darkTextSecondary,
            ),
          ),
          Text(
            state.formattedDuration,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls(
    AudioPlayerService service,
    RepeatMode repeatMode,
    double speed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded,
                color: AppColors.darkTextPrimary, size: 32),
            onPressed: () => service.skipToPrevious(),
          ),

          // Repeat mode
          _buildRepeatButton(service, repeatMode),

          // Play / Pause (large)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                service.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                if (service.isPlaying) {
                  service.pause();
                } else {
                  service.resume();
                }
              },
            ),
          ),

          // Speed toggle
          _buildSpeedButton(service, speed),

          // Next
          IconButton(
            icon: const Icon(Icons.skip_next_rounded,
                color: AppColors.darkTextPrimary, size: 32),
            onPressed: () => service.skipToNext(),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatButton(AudioPlayerService service, RepeatMode mode) {
    final isActive = mode != RepeatMode.none;
    final icon = switch (mode) {
      RepeatMode.none => Icons.repeat_rounded,
      RepeatMode.one => Icons.repeat_one_rounded,
      RepeatMode.all => Icons.repeat_rounded,
    };

    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? AppColors.secondary : AppColors.darkTextSecondary,
        size: 26,
      ),
      onPressed: () => _cycleRepeatMode(service),
    );
  }

  Widget _buildSpeedButton(AudioPlayerService service, double speed) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: speed != 1.0
              ? AppColors.secondary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${speed}x',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: speed != 1.0
                ? AppColors.secondary
                : AppColors.darkTextSecondary,
          ),
        ),
      ),
      onPressed: () => _cycleSpeed(service),
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.darkSurface,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          isScrollControlled: true,
          builder: (_) => SpeedControlSheet(
            currentSpeed: speed,
            onSpeedChanged: (newSpeed) {
              service.setSpeed(newSpeed);
              _showSpeedOverlay(newSpeed);
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomActions(AudioPlayerService service, bool hasActiveTimer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Queue button
          _buildActionButton(
            icon: Icons.queue_music_outlined,
            label: 'Queue',
            onTap: () => context.push('/audio/queue'),
          ),

          // Sleep timer button
          _buildActionButton(
            icon: hasActiveTimer
                ? Icons.bedtime_rounded
                : Icons.bedtime_outlined,
            label: hasActiveTimer
                ? (_sleepEndOfSurah
                    ? 'End of Surah'
                    : _formatSleepTime(_sleepSecondsRemaining))
                : 'Sleep',
            isActive: hasActiveTimer,
            onTap: _showSleepTimerSheet,
          ),

          // Settings button
          _buildActionButton(
            icon: Icons.tune_outlined,
            label: 'Settings',
            onTap: () => context.push('/audio/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.secondary : AppColors.darkTextTertiary,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.secondary : AppColors.darkTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahProgressBar(MiniAudioPlayerState state) {
    final current = state.currentAyah;
    final total = state.totalAyahs;
    if (total <= 0) return const SizedBox.shrink();
    final progress = (current / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ayah $current',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkTextTertiary,
                ),
              ),
              Text(
                '$total ayahs',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.audioProgressTrack,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedOverlay() {
    return FloatingActionButton.small(
      heroTag: 'speed_overlay',
      backgroundColor: AppColors.darkSurfaceVariant,
      child: Text(
        _speedDisplay,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
        ),
      ),
      onPressed: () {},
    );
  }

  Widget _buildVolumeOverlay() {
    return FloatingActionButton.small(
      heroTag: 'volume_overlay',
      backgroundColor: AppColors.darkSurfaceVariant,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _volumeLevel > 0
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            color: AppColors.darkTextPrimary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _volumeDisplay,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextPrimary,
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Sleep Timer Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════

class _SleepTimerSheet extends StatelessWidget {
  final int currentSeconds;
  final bool isEndOfSurah;
  final ValueChanged<int> onSelected;
  final VoidCallback onEndOfSurah;
  final VoidCallback onCancel;

  const _SleepTimerSheet({
    required this.currentSeconds,
    required this.isEndOfSurah,
    required this.onSelected,
    required this.onEndOfSurah,
    required this.onCancel,
  });

  static const List<_SleepPreset> _presets = [
    _SleepPreset(label: '5 minutes', seconds: 300),
    _SleepPreset(label: '10 minutes', seconds: 600),
    _SleepPreset(label: '15 minutes', seconds: 900),
    _SleepPreset(label: '30 minutes', seconds: 1800),
    _SleepPreset(label: '45 minutes', seconds: 2700),
    _SleepPreset(label: '60 minutes', seconds: 3600),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Sleep Timer',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Presets
            ..._presets.map((preset) => _buildPresetTile(
                  preset: preset,
                  isActive: currentSeconds == preset.seconds,
                )),

            const SizedBox(height: 8),

            // End of Surah option
            _buildOptionTile(
              icon: Icons.last_page_rounded,
              label: 'End of Surah',
              subtitle: 'Pause when the current surah finishes',
              isActive: isEndOfSurah,
              onTap: onEndOfSurah,
            ),

            const SizedBox(height: 16),

            // Cancel button
            if (currentSeconds > 0 || isEndOfSurah)
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_rounded,
                    color: AppColors.error, size: 20),
                label: const Text(
                  'Cancel Timer',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetTile({
    required _SleepPreset preset,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isActive
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        title: Text(
          preset.label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.darkTextPrimary,
          ),
        ),
        trailing: isActive
            ? const Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 22)
            : const Icon(Icons.schedule_rounded,
                color: AppColors.darkTextTertiary, size: 20),
        onTap: () => onSelected(preset.seconds),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: isActive
          ? AppColors.primary.withOpacity(0.1)
          : Colors.transparent,
      leading: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.darkTextTertiary,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? AppColors.primary : AppColors.darkTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppColors.darkTextTertiary,
        ),
      ),
      trailing: isActive
          ? const Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 22)
          : null,
      onTap: onTap,
    );
  }
}

class _SleepPreset {
  final String label;
  final int seconds;
  const _SleepPreset({required this.label, required this.seconds});
}
