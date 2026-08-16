import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../constants/app_constants.dart';
import '../../../data/repositories/audio_repository.dart';
import 'audio_session_service.dart';

/// Audio player service that wraps a [just_audio.AudioPlayer] owned by the
/// shared [MinhaajulHudaaAudioHandler].
///
/// By sharing the player instance with the [AudioHandler], every playback
/// action (play, pause, seek, skip) is automatically mirrored to the Android
/// system media session — lock-screen controls, notification media widget,
/// Bluetooth media buttons, and Android Auto all stay in sync with no extra
/// wiring in the UI layer.
///
/// Call [AudioSessionService.init] once during app startup (in main.dart)
/// before constructing this service.
class AudioPlayerService {
  /// The single shared [AudioPlayer] — owned by the [AudioHandler] so the
  /// system media notification stays in sync.
  late final AudioPlayer _player;
  final AudioRepository _audioRepository;

  // ── Playback queue ─────────────────────────────────────────────
  List<_QueueItem> _queue = [];
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

  AudioPlayerService(this._audioRepository) {
    if (!AudioSessionService.isInitialized) {
      // Defensive: this should never happen because main.dart calls
      // AudioSessionService.init() during startup. If it does, we throw
      // immediately so the developer notices.
      throw StateError(
        'AudioSessionService.init() must be called in main.dart before '
        'constructing AudioPlayerService.',
      );
    }
    _player = AudioSessionService.handler.player;
    _listenForTrackChanges();
  }

  /// When just_audio's currentIndex changes (because we set a ConcatenatingAudioSource),
  /// update the system mediaItem so the notification shows the correct track.
  void _listenForTrackChanges() {
    _player.sequenceStateStream.listen((state) {
      final idx = state?.currentIndex;
      if (idx != null && idx >= 0 && idx < _queue.length) {
        final item = _queue[idx];
        final mediaItem = MediaItem(
          id: 'surah_${item.surahNumber}_ayah_${item.ayahNumber}',
          album: 'Surah ${item.surahNumber}',
          title: item.title,
          artist: item.artist,
          artUri: Uri.parse(
            'https://quran.com/favicon.ico',
          ),
        );
        AudioSessionService.handler.mediaItem.add(mediaItem);
      }
    });
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
        _QueueItem(
          source: playableSource,
          title: 'Surah $surahNumber - Ayah $i',
          album: 'Quran',
          artist: _getReciterName(reciterId),
          surahNumber: surahNumber,
          ayahNumber: i,
          reciterId: reciterId,
        ),
      );
    }

    _currentIndex = 0;

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
        _QueueItem(
          source: playableSource,
          title: 'Surah $surahNumber - Ayah $i',
          album: 'Quran',
          artist: _getReciterName(reciterId),
          surahNumber: surahNumber,
          ayahNumber: i,
          reciterId: reciterId,
        ),
      );
    }

    _currentIndex = 0;

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
      final isLocal = item.source.startsWith('/');
      late AudioSource source;
      if (isLocal) {
        source = AudioSource.file(item.source);
      } else {
        source = AudioSource.uri(Uri.parse(item.source));
      }

      await _player.setAudioSource(source, preload: true);
      await _player.play();
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

  Future<void> pause() => _player.pause();

  Future<void> resume() async {
    if (_queue.isEmpty) return;
    if (_player.processingState == ProcessingState.ready) {
      await _player.play();
    } else {
      await play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _queue = [];
    _currentIndex = 0;
  }

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

  Future<void> seek(Duration position) => _player.seek(position);

  /// Seek to a specific ayah in the current surah queue
  Future<void> seekToAyah(int ayahNumber) async {
    final targetIndex = ayahNumber - 1;
    if (targetIndex >= 0 && targetIndex < _queue.length) {
      _currentIndex = targetIndex;
      await play();
    }
  }

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  void setRepeatMode(RepeatMode repeatMode) {
    _repeatModeSubject.add(repeatMode);

    switch (repeatMode) {
      case RepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Getters / Streams
  // ═══════════════════════════════════════════════════════════════

  Stream<Duration> get durationStream => _player.durationStream.map((d) => d ?? Duration.zero);

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
  String get currentTitle =>
      _queue.isNotEmpty && _currentIndex < _queue.length
          ? _queue[_currentIndex].title
          : '';
  String get currentArtist =>
      _queue.isNotEmpty && _currentIndex < _queue.length
          ? _queue[_currentIndex].artist
          : '';

  Map<String, int> get surahProgress => _surahProgressSubject.value;

  // ═══════════════════════════════════════════════════════════════
  // Resource cleanup
  // ═══════════════════════════════════════════════════════════════

  Future<void> dispose() async {
    await _player.dispose();
    await _repeatModeSubject.close();
    await _surahProgressSubject.close();
  }
}

/// Simple repeat mode enum (replaces AudioServiceRepeatMode).
enum RepeatMode { none, one, all }

/// Internal queue item.
class _QueueItem {
  final String source;
  final String title;
  final String album;
  final String artist;
  final int surahNumber;
  final int ayahNumber;
  final String reciterId;

  const _QueueItem({
    required this.source,
    required this.title,
    required this.album,
    required this.artist,
    required this.surahNumber,
    required this.ayahNumber,
    required this.reciterId,
  });
}
