import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'app/shell/mini_audio_player_provider.dart';
import 'app/theme/app_colors.dart';
import 'core/services/audio/audio_player_service.dart';
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

  // ── Database ──────────────────────────────────────────────────
  await AppDatabase.ensureInitialized();
  final database = AppDatabase.instance;
  await database.getReadingHistory(limit: 1);

  // ── Audio Service ─────────────────────────────────────────────
  final audioRepository = AudioRepository();
  final audioPlayerService = AudioPlayerService(audioRepository);

  // ── Popup Service (ensure defaults are in Hive) ──────────────
  PopupService.instance.isEnabled;

  // ── Background startup hooks (fire-and-forget; do not block UI) ──
  // These providers improve UX but are not required for first paint.
  // Errors are caught and logged so a failing hook never breaks startup.
  Future<void> _safeStartupHook(String name, Future<void> Function() task) async {
    try {
      await task();
    } catch (e, st) {
      debugPrint('[Startup Hook $name] failed: $e\n$st');
    }
  }

  // Use a fresh container for background hooks so they don't block the UI
  // build pipeline. They will be re-evaluated lazily when the user navigates
  // to the corresponding screens.
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

class _AppInitResult {
  final Box settingsBox;
  final AudioPlayerService audioPlayerService;
  final bool onboardingCompleted;

  const _AppInitResult({
    required this.settingsBox,
    required this.audioPlayerService,
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
              final savedMode =
                  result.settingsBox.get('theme_mode', defaultValue: 'dark') as String;
              final notifier = ThemeModeNotifier();
              final initialMode = ThemeModeNotifier.fromString(savedMode);
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
                        color: AppColors.darkTextSecondary
                            .withOpacity(0.7),
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
