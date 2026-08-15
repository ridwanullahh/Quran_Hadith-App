import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../../constants/app_constants.dart';
import '../../../data/repositories/audio_repository.dart';
import '../../database/database.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final AudioRepository _audioRepository;

  // ── Playback queue ─────────────────────────────────────────────
  List<MediaItem> _queue = [];
  int _currentIndex = 0;
  String _currentReciterId = AppConstants.defaultReciterId;
  int _currentSurahNumber = 0;

  // ── State subjects for UI binding ───────────────────────────────
  final _repeatModeSubject = BehaviorSubject<RepeatMode>.seeded(
    RepeatMode.none,
  );
  final _surahProgressSubject = BehaviorSubject<Map<String, int>>.seeded(
    const {'currentAyah': 0, 'totalAyahs': 0},
  );

  QuranAudioHandler(this._audioRepository) {
    _listenToPlayerState();
    _listenToCurrentPosition();
    _listenToPlaybackEvent();
  }

  // ═══════════════════════════════════════════════════════════════
  // Audio Source Setup
  // ═══════════════════════════════════════════════════════════════

  void _listenToPlayerState() {
    _player.playerStateStream.map(_transformState).pipe(playbackState);
  }

  void _listenToCurrentPosition() {
    Rx.combineLatest2<Duration, Duration, Map<String, dynamic>>(
      _player.positionStream,
      _player.bufferedPositionStream,
      (position, bufferedPosition) => {
        'position': position,
        'bufferedPosition': bufferedPosition,
      },
    ).pipe(position);
  }

  void _listenToPlaybackEvent() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackEvent);
  }

  PlaybackState _transformState(PlayerState playerState) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: _mapProcessingState(playerState.processingState),
      playing: playerState.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    );
  }

  PlaybackEvent _transformEvent(PlaybackEvent event) {
    return PlaybackEvent(
      updateTime: event.updateTime,
      processingState: _mapProcessingState(
        _player.processingState,
      ),
      duration: _player.duration,
      bufferedPosition: _player.bufferedPosition,
      updatePosition: _player.position,
      icyMetadata: null,
      label: null,
    );
  }

  AudioProcessingState _mapProcessingState(
    AudioProcessingState state,
  ) {
    switch (state) {
      case AudioProcessingState.idle:
        return AudioProcessingState.idle;
      case AudioProcessingState.loading:
        return AudioProcessingState.loading;
      case AudioProcessingState.buffering:
        return AudioProcessingState.buffering;
      case AudioProcessingState.ready:
        return AudioProcessingState.ready;
      case AudioProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Queue Management
  // ═══════════════════════════════════════════════════════════════

  /// Build queue for a full surah
  Future<void> buildSurahQueue({
    required int surahNumber,
    required int totalAyahs,
    String reciterId = AppConstants.defaultReciterId,
    int startAyah = 1,
  }) async {
    _currentReciterId = reciterId;
    _currentSurahNumber = surahNumber;
    _queue = [];

    for (int i = startAyah; i <= totalAyahs; i++) {
      final playableSource = await _audioRepository.getPlayableSource(
        surahNumber: surahNumber,
        ayahNumber: i,
        reciterId: reciterId,
      );

      _queue.add(
        MediaItem(
          id: playableSource,
          title: 'Surah $surahNumber - Ayah $i',
          album: 'Quran',
          artist: _getReciterName(reciterId),
          extras: {
            'surahNumber': surahNumber,
            'ayahNumber': i,
            'reciterId': reciterId,
          },
        ),
      );
    }

    _currentIndex = 0;
    queue.add(ListQueue.of(_queue));
    mediaItem.add(_queue.isNotEmpty ? _queue[0] : null);

    _surahProgressSubject.add({
      'currentAyah': startAyah,
      'totalAyahs': totalAyahs,
    });
  }

  /// Build queue for a range of ayahs
  Future<void> buildAyahRangeQueue({
    required int surahNumber,
    required int ayahStart,
    required int ayahEnd,
    String reciterId = AppConstants.defaultReciterId,
  }) async {
    _currentReciterId = reciterId;
    _currentSurahNumber = surahNumber;
    _queue = [];

    for (int i = ayahStart; i <= ayahEnd; i++) {
      final playableSource = await _audioRepository.getPlayableSource(
        surahNumber: surahNumber,
        ayahNumber: i,
        reciterId: reciterId,
      );

      _queue.add(
        MediaItem(
          id: playableSource,
          title: 'Surah $surahNumber - Ayah $i',
          album: 'Quran',
          artist: _getReciterName(reciterId),
          extras: {
            'surahNumber': surahNumber,
            'ayahNumber': i,
            'reciterId': reciterId,
          },
        ),
      );
    }

    _currentIndex = 0;
    queue.add(ListQueue.of(_queue));
    mediaItem.add(_queue.isNotEmpty ? _queue[0] : null);

    _surahProgressSubject.add({
      'currentAyah': ayahStart,
      'totalAyahs': ayahEnd - ayahStart + 1,
    });
  }

  String _getReciterName(String reciterId) {
    for (final r in AppConstants.reciters) {
      if (r['id'] == reciterId) {
        return r['name']!;
      }
    }
    return reciterId;
  }

  // ═══════════════════════════════════════════════════════════════
  // Playback Controls
  // ═══════════════════════════════════════════════════════════════

  /// Play the queue starting from the current index
  Future<void> play() async {
    if (_queue.isEmpty) return;

    final item = _queue[_currentIndex];
    try {
      final isLocal = item.id.startsWith('/');
      late AudioSource source;
      if (isLocal) {
        source = DeviceFileSource(item.id);
      } else {
        source = AudioSource.uri(Uri.parse(item.id));
      }

      await _player.setAudioSource(source, preload: true);
      await _player.play();

      mediaItem.add(item);
    } catch (e) {
      // On error, try to skip to next
      await skipToNext();
    }
  }

  /// Play a specific surah from the beginning
  Future<void> playSurah({
    required int surahNumber,
    required int totalAyahs,
    String reciterId = AppConstants.defaultReciterId,
  }) async {
    await buildSurahQueue(
      surahNumber: surahNumber,
      totalAyahs: totalAyahs,
      reciterId: reciterId,
    );
    await play();
  }

  /// Play a specific ayah
  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required int totalAyahs,
    String reciterId = AppConstants.defaultReciterId,
  }) async {
    await buildSurahQueue(
      surahNumber: surahNumber,
      totalAyahs: totalAyahs,
      reciterId: reciterId,
      startAyah: ayahNumber,
    );
    _currentIndex = ayahNumber - 1;
    await play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() async {
    if (_queue.isEmpty) return;
    if (_player.processingState == AudioProcessingState.ready) {
      await _player.play();
    } else {
      await play();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _queue = [];
    _currentIndex = 0;
    mediaItem.add(null);
    queue.add(ListQueue.of([]));
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await play();
    } else {
      // End of queue - loop or stop based on repeat mode
      if (_repeatModeSubject.value == RepeatMode.all) {
        _currentIndex = 0;
        await play();
      } else {
        await stop();
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // If more than 3 seconds into the ayah, restart it
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
      await play();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Seek to a specific ayah in the current surah queue
  Future<void> seekToAyah(int ayahNumber) async {
    final targetIndex = ayahNumber - 1;
    if (targetIndex >= 0 && targetIndex < _queue.length) {
      _currentIndex = targetIndex;
      await play();
    }
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setRepeatMode(RepeatMode repeatMode) {
    _repeatModeSubject.add(repeatMode);

    switch (repeatMode) {
      case RepeatMode.none:
        _player.setLoopMode(LoopMode.none);
        break;
      case RepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }

    return Future.value();
  }

  // ═══════════════════════════════════════════════════════════════
  // Getters / Streams
  // ═══════════════════════════════════════════════════════════════

  Stream<Duration> get durationStream => _player.durationStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration> get bufferedPositionStream =>
      _player.bufferedPositionStream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<RepeatMode> get repeatModeStream => _repeatModeSubject.stream;

  Stream<Map<String, int>> get surahProgressStream =>
      _surahProgressSubject.stream;

  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  Duration get bufferedPosition => _player.bufferedPosition;
  bool get isPlaying => _player.playing;
  double get speed => _player.speed;
  RepeatMode get repeatMode => _repeatModeSubject.value;
  int get currentSurahNumber => _currentSurahNumber;
  int get currentAyahNumber =>
      _currentIndex + 1; // 1-indexed
  int get totalQueueItems => _queue.length;
  bool get hasQueue => _queue.isNotEmpty;

  Map<String, int> get surahProgress => _surahProgressSubject.value;

  // ═══════════════════════════════════════════════════════════════
  // Resource cleanup
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<void> dispose() async {
    await _player.dispose();
    await _repeatModeSubject.close();
    await _surahProgressSubject.close();
    super.dispose();
  }
}
