import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/shell/mini_audio_player_provider.dart';
import 'app/theme/app_colors.dart';
import 'core/services/audio/audio_player_service.dart';
import 'core/services/database/database.dart';
import 'data/repositories/audio_repository.dart';

/// Holds the result of all startup initialization so that
/// downstream widgets can access initialized singletons.
final _initProvider = FutureProvider<_AppInitResult>((ref) async {
  // ── Hive ───────────────────────────────────────────────────────
  await Hive.initFlutter();
  final settingsBox = await Hive.openBox('settings');
  await Hive.openBox('reading_cache');
  await Hive.openBox('search_cache');
  await Hive.openBox('download_state');

  // ── Database ──────────────────────────────────────────────────
  final database = AppDatabase.instance;
  await database.select(database.readingHistory).get();

  // ── Audio Service ─────────────────────────────────────────────
  final audioRepository = AudioRepository();
  final audioHandler = await AudioService.init<QuranAudioHandler>(
    create: () => QuranAudioHandler(audioRepository),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.minhaajulhudaa.audio',
      androidNotificationChannelName: 'Quran Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      notificationColor: Color(0xFF0D6E5B),
    ),
  );

  return _AppInitResult(
    settingsBox: settingsBox,
    audioHandler: audioHandler,
  );
});

class _AppInitResult {
  final Box settingsBox;
  final QuranAudioHandler audioHandler;

  const _AppInitResult({
    required this.settingsBox,
    required this.audioHandler,
  });
}

/// Global Riverpod container reference, used for accessing providers
/// outside the widget tree (e.g. in audio_service callbacks).
late ProviderContainer globalProviderContainer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the root Riverpod container with overrides for
  // providers that need initialized singletons.
  globalProviderContainer = ProviderContainer(
    observers: [_ProviderLogger()],
  );

  runApp(
    UncontrolledProviderScope(
      container: globalProviderContainer,
      child: const _InitGateway(),
    ),
  );
}

/// The very first widget mounted. It awaits [_initProvider] in a
/// [FutureBuilder] and shows a branded splash while services boot.
/// Once ready it creates a new [ProviderContainer] with the
/// required overrides and renders [MinhaajulHudaaApp].
class _InitGateway extends ConsumerWidget {
  const _InitGateway();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(_initProvider);

    return initAsync.when<Widget>(
      loading: () => const _SplashScreen(),
      error: (error, stack) => _ErrorScreen(error: error),
      data: (result) {
        // Build the real app with overrides for the initialized
        // audio handler and persisted theme preference.
        return ProviderScope(
          overrides: [
            audioHandlerProvider.overrideWithValue(result.audioHandler),
            themeModeProvider.overrideWith((ref) {
              final savedMode =
                  result.settingsBox.get('theme_mode', defaultValue: 'dark') as String;
              final notifier = ThemeModeNotifier();
              final initialMode = switch (savedMode) {
                'light' => ThemeMode.light,
                'system' => ThemeMode.system,
                _ => ThemeMode.dark,
              };
              notifier.setThemeMode(initialMode);
              return notifier;
            }),
          ],
          child: const MinhaajulHudaaApp(),
        );
      },
    );
  }
}

/// Branded splash screen shown while the app initializes.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: 0.7 + 0.3 * _pulseAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App logo placeholder – Bismillah text.
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.goldGradient
                          .createShader(bounds),
                      child: const Text(
                        'مِنْهَاجُ الْهُدَى',
                        style: TextStyle(
                          fontFamily: 'ScheherazadeNew',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // App name in Latin.
                    Text(
                      'MinhaajulHudaa',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.0,
                        color: AppColors.darkTextSecondary
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Shown when initialization fails catastrophically.
class _ErrorScreen extends StatelessWidget {
  final Object? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to start',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error?.toString() ?? 'An unknown error occurred.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.darkTextSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A Riverpod observer that logs provider errors in debug mode.
class _ProviderLogger extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint('[Provider Error] ${provider.name}: $error');
  }
}
