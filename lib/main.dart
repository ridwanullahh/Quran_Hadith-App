import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'app/shell/mini_audio_player_provider.dart';
import 'app/theme/app_colors.dart';
import 'core/services/audio/audio_player_service.dart';
import 'core/services/audio/audio_session_service.dart';
import 'core/services/database/database.dart';
import 'core/services/popup/popup_service.dart';
import 'data/repositories/audio_repository.dart';
import 'features/engagement/presentation/providers/engagement_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/update/presentation/providers/update_provider.dart';

/// Holds the result of all startup initialization so that
/// downstream widgets can access initialized singletons.
final _initProvider = FutureProvider<_AppInitResult>((ref) async {
  // ── Hive ───────────────────────────────────────────────────────
  await Hive.initFlutter();

  // ── Timezone ────────────────────────────────────────────────────
  tz.initializeTimeZones();
  final settingsBox = await Hive.openBox('settings');
  await Hive.openBox('reading_cache');
  await Hive.openBox('search_cache');
  await Hive.openBox('download_state');

  // ── Open all feature Hive boxes in parallel ──────────────────────
  // Each box open is wrapped in try/catch so a corrupt box doesn't
  // prevent the rest from opening.
  await Future.wait([
    _safeOpenBox('engagement'),
    _safeOpenBox('hadith_bookmarks'),
    _safeOpenBox('hadith_history'),
    _safeOpenBox('hadith_notes'),
    _safeOpenBox('hadith_plans'),
    _safeOpenBox('hadith_daily_tracker'),
    _safeOpenBox('hadith_stats'),
    _safeOpenBox('hadith_bookmark_folders'),
    _safeOpenBox('favorites'),
    _safeOpenBox('prayer_settings'),
  ]);

  // ── Database ──────────────────────────────────────────────────
  // Wrap in try/catch so a corrupt DB doesn't crash the app.
  AudioPlayerService? audioPlayerService;
  try {
    await AppDatabase.ensureInitialized();
    final database = AppDatabase.instance;
    await database.getReadingHistory(limit: 1);
  } catch (e, st) {
    debugPrint('[Startup] AppDatabase init failed (degraded DB): $e\n$st');
  }

  // ── Audio Service ─────────────────────────────────────────────
  // If AudioService.init() fails, the app still starts —
  // AudioPlayerService falls back to a standalone AudioPlayer.
  try {
    await AudioSessionService.init();
  } catch (e, st) {
    debugPrint('[Startup] AudioSessionService.init failed: $e\n$st');
  }
  try {
    final audioRepository = AudioRepository();
    audioPlayerService = AudioPlayerService(audioRepository);
  } catch (e, st) {
    debugPrint('[Startup] AudioPlayerService construction failed: $e\n$st');
  }

  // ── Popup Service ─────────────────────────────────────────────
  try {
    PopupService.instance.isEnabled;
  } catch (e, st) {
    debugPrint('[Startup] PopupService init failed: $e\n$st');
  }

  // ── Background startup hooks (fire-and-forget) ────────────────
  Future<void> _safeStartupHook(String name, Future<void> Function() task) async {
    try {
      await task();
    } catch (e, st) {
      debugPrint('[Startup Hook $name] failed: $e\n$st');
    }
  }

  final hookContainer = ProviderContainer();
  unawaited(_safeStartupHook('autoUpdateCheck', () {
    ref.read(updateProvider.notifier).autoCheckOnStart();
    return Future.value();
  }));
  unawaited(_safeStartupHook('engagementRecordAppOpen', () {
    hookContainer.read(engagementProvider.notifier).recordAppOpen();
    return Future.value();
  }));
  unawaited(_safeStartupHook('scheduleAllNotifications', () async {
    await hookContainer.read(notificationSettingsProvider.notifier).scheduleAll();
  }));

  return _AppInitResult(
    settingsBox: settingsBox,
    audioPlayerService: audioPlayerService,
    onboardingCompleted: settingsBox.get('onboarding_completed', defaultValue: false) as bool,
  );
});

/// Open a Hive box, returning an empty box on failure so a corrupt box
/// doesn't crash the app.
Future<Box> _safeOpenBox(String name) async {
  try {
    return await Hive.openBox(name);
  } catch (e, st) {
    debugPrint('[Startup] Hive.openBox("$name") failed: $e\n$st');
    try {
      return await Hive.openBox(name);
    } catch (_) {
      return Hive.box(name);
    }
  }
}

class _AppInitResult {
  final Box settingsBox;
  final AudioPlayerService? audioPlayerService;
  final bool onboardingCompleted;

  const _AppInitResult({
    required this.settingsBox,
    this.audioPlayerService,
    required this.onboardingCompleted,
  });
}

/// Global Riverpod container reference, used for accessing providers
/// outside the widget tree (e.g. in audio callbacks).
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
        // audio service and persisted theme preference.
        return ProviderScope(
          overrides: [
            audioHandlerProvider.overrideWithValue(result.audioPlayerService),
            themeModeProvider.overrideWith((ref) {
              // Default to light theme. Users can switch to Dark / Amoled
              // from Settings; the choice is persisted to Hive.
              final savedMode = result.settingsBox
                  .get('theme_mode', defaultValue: 'light') as String;
              final notifier = ThemeModeNotifier();
              final initialMode = ThemeModeNotifier.fromString(savedMode);
              notifier.setThemeMode(initialMode);
              // Persist future changes so the choice survives app restarts.
              ref.listen<AppThemeMode>(themeModeProvider, (_, next) {
                result.settingsBox.put('theme_mode', ThemeModeNotifier.toStringValue(next));
              });
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
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = platformBrightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final secondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: platformBrightness, useMaterial3: true),
      home: Scaffold(
        backgroundColor: backgroundColor,
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
                        '\u0645ِنْهَاجُ الْهُدَى',
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
                        color: secondaryColor.withOpacity(0.7),
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
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = platformBrightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: platformBrightness, useMaterial3: true),
      home: Scaffold(
        backgroundColor: backgroundColor,
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
                Text(
                  'Failed to start',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error?.toString() ?? 'An unknown error occurred.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: textSecondary,
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
