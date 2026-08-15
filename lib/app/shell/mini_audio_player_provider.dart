import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/services/audio/audio_player_service.dart';

/// Immutable snapshot of the mini audio player UI state.
class MiniAudioPlayerState {
  /// Whether audio playback is currently active (player has a queue).
  final bool isActive;

  /// Whether the audio is currently playing (vs paused).
  final bool isPlaying;

  /// Name of the current surah being played (e.g. "Al-Fatiha").
  final String surahName;

  /// Arabic name of the current surah.
  final String surahNameArabic;

  /// Current ayah number (1-indexed).
  final int currentAyah;

  /// Total number of ayahs in the current surah.
  final int totalAyahs;

  /// Current playback position.
  final Duration position;

  /// Total duration of the current ayah audio.
  final Duration duration;

  /// Buffered position for the current ayah.
  final Duration bufferedPosition;

  /// Reciter name.
  final String reciterName;

  /// Whether the player is in a loading/buffering state.
  final bool isBuffering;

  const MiniAudioPlayerState({
    this.isActive = false,
    this.isPlaying = false,
    this.surahName = '',
    this.surahNameArabic = '',
    this.currentAyah = 0,
    this.totalAyahs = 0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.reciterName = '',
    this.isBuffering = false,
  });

  /// Progress fraction for the current ayah (0.0 to 1.0).
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Formatted position string (MM:SS).
  String get formattedPosition {
    final m = (position.inSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (position.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Formatted duration string (MM:SS).
  String get formattedDuration {
    final m = (duration.inSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Ayah progress label (e.g. "Ayah 5 / 286").
  String get ayahProgressLabel {
    if (!isActive) return '';
    return 'Ayah $currentAyah / $totalAyahs';
  }

  MiniAudioPlayerState copyWith({
    bool? isActive,
    bool? isPlaying,
    String? surahName,
    String? surahNameArabic,
    int? currentAyah,
    int? totalAyahs,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    String? reciterName,
    bool? isBuffering,
  }) {
    return MiniAudioPlayerState(
      isActive: isActive ?? this.isActive,
      isPlaying: isPlaying ?? this.isPlaying,
      surahName: surahName ?? this.surahName,
      surahNameArabic: surahNameArabic ?? this.surahNameArabic,
      currentAyah: currentAyah ?? this.currentAyah,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      reciterName: reciterName ?? this.reciterName,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

/// Provider that exposes a reference to the audio handler via the
/// audio_service singleton, converted to Riverpod's AsyncValue.
///
/// The audio handler is initialized in main.dart and stored in the
/// Riverpod container as an override. This provider reads it back.
final audioHandlerProvider = Provider<QuranAudioHandler?>((ref) {
  // The handler is provided via ProviderScope overrides in main.dart.
  // We expose it here so downstream widgets can call play/pause/seek.
  return null; // Will be overridden at the ProviderScope level.
});

/// Provides a live stream of [MiniAudioPlayerState] derived from
/// the audio handler's reactive streams.
///
/// This combines multiple streams from the audio handler into a single
/// state object, updating the UI at ~10 Hz to stay smooth.
final miniAudioPlayerProvider = StreamProvider<MiniAudioPlayerState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  if (handler == null) {
    return Stream.value(const MiniAudioPlayerState());
  }

  // Build a combined stream from the handler's reactive properties.
  // We sample position every 200ms to avoid excessive rebuilds.
  return Rx.combineLatest6<
      bool,
      Duration,
      Duration,
      Duration,
      bool,
      bool,
      MiniAudioPlayerState>(
    // 1. Is playing
    handler.playbackState.map((s) => s.playing),
    // 2. Position (sampled)
    handler.positionStream.sampleTime(const Duration(milliseconds: 200)),
    // 3. Duration
    handler.durationStream,
    // 4. Buffered position
    handler.bufferedPositionStream.sampleTime(const Duration(milliseconds: 500)),
    // 5. Has queue
    Stream.value(handler.hasQueue),
    // 6. Is buffering
    handler.playerStateStream.map((s) => s.processingState == AudioProcessingState.buffering || s.processingState == AudioProcessingState.loading),
    (
      isPlaying,
      position,
      duration,
      bufferedPosition,
      hasQueue,
      isBuffering,
    ) {
      // Extract surah name from the current media item
      final mediaItem = handler.mediaItem.valueOrNull;
      final surahName = mediaItem?.title ?? '';
      final reciterName = mediaItem?.artist ?? '';

      final progress = handler.surahProgress;
      final currentAyah = progress['currentAyah'] ?? 0;
      final totalAyahs = progress['totalAyahs'] ?? 0;
      final surahNumber = handler.currentSurahNumber;

      // Look up Arabic surah name from the extras or use number.
      // In a production app this would use SurahInfo lookup.
      String surahNameArabic = '';
      if (surahNumber > 0 && surahNumber <= 114) {
        // We rely on a simple mapping here; the full app would
        // inject SurahInfo from the repository.
        surahNameArabic = 'سورة $surahNumber';
      }

      return MiniAudioPlayerState(
        isActive: hasQueue,
        isPlaying: isPlaying,
        surahName: surahName,
        surahNameArabic: surahNameArabic,
        currentAyah: currentAyah,
        totalAyahs: totalAyahs,
        position: position,
        duration: duration,
        bufferedPosition: bufferedPosition,
        reciterName: reciterName,
        isBuffering: isBuffering,
      );
    },
  );
});

/// A simple notifier that provides audio control methods that
/// downstream widgets can call (play, pause, next, previous, seek).
class MiniAudioPlayerController extends Notifier<void> {
  QuranAudioHandler? get _handler {
    return ref.read(audioHandlerProvider);
  }

  @override
  void build() {
    // No-op initialization.
  }

  void play() {
    _handler?.play();
  }

  void pause() {
    _handler?.pause();
  }

  void playPause() {
    final h = _handler;
    if (h == null || !h.hasQueue) return;
    if (h.isPlaying) {
      h.pause();
    } else {
      h.resume();
    }
  }

  void next() {
    _handler?.skipToNext();
  }

  void previous() {
    _handler?.skipToPrevious();
  }

  void seekToPosition(double fraction) {
    final h = _handler;
    if (h == null) return;
    final durationMs = h.duration.inMilliseconds;
    if (durationMs == 0) return;
    final targetMs = (fraction * durationMs).round();
    h.seek(Duration(milliseconds: targetMs));
  }

  void stop() {
    _handler?.stop();
  }
}

final miniAudioPlayerControllerProvider =
    NotifierProvider<MiniAudioPlayerController, void>(
        MiniAudioPlayerController.new);
