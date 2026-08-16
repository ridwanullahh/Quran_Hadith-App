import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// A minimal [BaseAudioHandler] that bridges just_audio's [AudioPlayer] to
/// the Android system media session.
///
/// Design: the [AudioPlayer] is created here and exposed via [player] so the
/// existing [AudioPlayerService] can keep its current API (play, pause, seek,
/// position/duration streams, etc.) while the system media notification,
/// lock-screen controls, Bluetooth media buttons, and Android Auto all stay
/// in sync automatically.
///
/// Call [AudioSessionService.init] once during app startup (before any audio
/// playback) to register this handler with [AudioService.init].
class MinhaajulHudaaAudioHandler extends BaseAudioHandler with SeekHandler {
  /// The single shared [AudioPlayer] instance. [AudioPlayerService] reads
  /// from this getter so there is exactly one player in the whole app.
  final AudioPlayer player = AudioPlayer();

  /// Stream of the current media item (for the system notification).
  Stream<MediaItem?> get mediaItemStream => mediaItem.stream;

  /// Stream of playback state (for the system notification).
  Stream<PlaybackState> get playbackStateStream => playbackState.stream;

  MinhaajulHudaaAudioHandler() {
    _propagateState();
    _propagateQueue();
  }

  /// Forward just_audio events to the system media session so the
  /// notification, lock-screen widget, and Bluetooth media buttons all
  /// reflect the current playback state.
  void _propagateState() {
    player.playbackEventStream.listen((event) {
      final playing = player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[player.processingState]!,
        playing: playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: player.currentIndex,
      ));
    }, onError: (Object e, StackTrace st) {
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        errorMessage: e.toString(),
      ));
    });
  }

  /// Keep the system media queue in sync with just_audio's sequence.
  void _propagateQueue() {
    player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState?.sequence ?? [];
      final items = sequence.map((source) {
        final tag = source.tag as MediaItem?;
        return tag ?? const MediaItem(id: 'unknown', title: 'Unknown');
      }).toList();
      queue.add(items);
      if (sequenceState?.currentIndex != null &&
          sequenceState!.currentIndex! < items.length) {
        mediaItem.add(items[sequenceState.currentIndex!]);
      }
    });
  }

  // ── AudioHandler overrides ────────────────────────────────────────

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() => player.seekToNext();

  @override
  Future<void> skipToPrevious() => player.seekToPrevious();

  @override
  Future<void> setSpeed(double speed) => player.setSpeed(speed);
}

/// One-time initialization helper for the [AudioService] / [AudioHandler].
///
/// Called from [main.dart] during startup. After this returns, the shared
/// [handler] is available for [AudioPlayerService] to use.
class AudioSessionService {
  static MinhaajulHudaaAudioHandler? _handler;

  /// The shared handler. Throws if [init] has not been called yet.
  static MinhaajulHudaaAudioHandler get handler {
    if (_handler == null) {
      throw StateError(
        'AudioSessionService.init() must be called before accessing handler.',
      );
    }
    return _handler!;
  }

  /// True once [init] has completed successfully.
  static bool get isInitialized => _handler != null;

  /// Initialize the audio session and register the media handler.
  ///
  /// This must be called exactly once during app startup, before any audio
  /// playback begins. Safe to call multiple times — subsequent calls are
  /// no-ops.
  static Future<MinhaajulHudaaAudioHandler> init() async {
    if (_handler != null) return _handler!;
    _handler = await AudioService.init(
      builder: () => MinhaajulHudaaAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.minhaajulhudaa.quran.audio',
        androidNotificationChannelName: 'Minhaajulhudaa Audio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidShowNotificationBadge: false,
        notificationColor: const Color(0xFF0A1628),
        artDownscaleWidth: 300,
        artDownscaleHeight: 300,
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
      ),
    );
    return _handler!;
  }
}
