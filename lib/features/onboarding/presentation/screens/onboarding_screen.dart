import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/app.dart';
import '../../../settings/presentation/providers/theme_provider.dart';

/// Whether the user has completed onboarding.
final onboardingCompletedProvider = Provider<bool>((ref) {
  try {
    final box = Hive.box('settings');
    return box.get('onboarding_completed', defaultValue: false) as bool;
  } catch (_) {
    return false;
  }
});

/// Permission status enum for the onboarding flow.
enum _PermStatus { notAsked, granted, denied }

/// A permission entry shown on the permissions page.
class _PermissionEntry {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Permission permission;

  const _PermissionEntry({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.permission,
  });
}

/// A feature entry shown on the features page.
class _FeatureEntry {
  final String title;
  final String line1;
  final String line2;
  final IconData icon;
  final Color color;

  const _FeatureEntry({
    required this.title,
    required this.line1,
    required this.line2,
    required this.icon,
    required this.color,
  });
}

/// A beautiful 4-page onboarding flow shown on first launch and
/// revisitable from Settings.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// If non-null, the PageView will jump to this page index on init.
  final int? initialPage;

  const OnboardingScreen({super.key, this.initialPage});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Preferences (Page 4)
  AppThemeMode _selectedTheme = AppThemeMode.light;
  double _dailyReadingGoal = 4.0;

  // Permission statuses (Page 3) – keyed by permission index.
  final Map<int, _PermStatus> _permStatuses = {
    0: _PermStatus.notAsked,
    1: _PermStatus.notAsked,
    2: _PermStatus.notAsked,
    3: _PermStatus.notAsked,
  };

  bool _isRequestingPermission = false;

  // Permission definitions (ordered)
  // NOTE: Storage and SystemAlertWindow permissions were REMOVED because:
  //   - Storage is not needed (audio downloads use app-private storage via
  //     path_provider, which requires no runtime permission on Android 10+).
  //     On Android 13+ Permission.storage always returns denied anyway.
  //   - SystemAlertWindow is not needed (the popup feature is an in-app
  //     widget using showDialog, not a system-level overlay).
  // Listing them would mislead users into thinking the app needs them.
  static const List<_PermissionEntry> _permissions = [
    _PermissionEntry(
      title: 'Notifications',
      description: 'To send daily verse reminders and hadith notifications',
      icon: Icons.notifications_rounded,
      color: AppColors.primary,
      permission: Permission.notification,
    ),
    _PermissionEntry(
      title: 'Location',
      description: 'To compute accurate prayer times and Qibla direction',
      icon: Icons.location_on_rounded,
      color: AppColors.secondary,
      permission: Permission.location,
    ),
    _PermissionEntry(
      title: 'Exact Alarms',
      description: 'To schedule precise notification times',
      icon: Icons.alarm_rounded,
      color: AppColors.hifdhGreen,
      permission: Permission.scheduleExactAlarm,
    ),
  ];

  // Feature definitions (2×2 grid)
  static const List<_FeatureEntry> _features = [
    _FeatureEntry(
      title: 'Quran',
      line1: 'Complete Uthmani text, translations,',
      line2: 'word-by-word, tafseer',
      icon: Icons.auto_stories_rounded,
      color: AppColors.primary,
    ),
    _FeatureEntry(
      title: 'Hadith',
      line1: '6 major collections, narrator',
      line2: 'chains, grading',
      icon: Icons.school_rounded,
      color: AppColors.secondary,
    ),
    _FeatureEntry(
      title: 'Hifdh',
      line1: 'SM-2 spaced repetition, mistake',
      line2: 'tracking, revision scheduler',
      icon: Icons.psychology_rounded,
      color: AppColors.hifdhGreen,
    ),
    _FeatureEntry(
      title: 'Audio',
      line1: 'Multiple reciters, background',
      line2: 'playback, download manager',
      icon: Icons.headphones_rounded,
      color: AppColors.revisionBlue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentPreferences();
    // Jump to a specific page if requested (e.g. permissions page from settings).
    if (widget.initialPage != null) {
      _currentPage = widget.initialPage!;
      Future.microtask(() {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    }
  }

  void _loadCurrentPreferences() {
    final box = Hive.box('settings');
    final savedMode = box.get('theme_mode', defaultValue: 'light') as String;
    _selectedTheme = ThemeModeNotifier.fromString(savedMode);
    _dailyReadingGoal =
        box.get('daily_reading_goal', defaultValue: 4.0) as double;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // Permission Handling
  // ═══════════════════════════════════════════════════════════════

  Future<void> _requestPermission(int index) async {
    if (_isRequestingPermission) return;
    setState(() => _isRequestingPermission = true);

    try {
      final status = await _permissions[index].permission.request();
      if (!mounted) return;
      setState(() {
        if (status.isGranted) {
          _permStatuses[index] = _PermStatus.granted;
        } else if (status.isDenied) {
          _permStatuses[index] = _PermStatus.denied;
        } else if (status.isPermanentlyDenied) {
          _permStatuses[index] = _PermStatus.denied;
        } else {
          _permStatuses[index] = _PermStatus.notAsked;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _permStatuses[index] = _PermStatus.denied);
      }
    } finally {
      if (mounted) setState(() => _isRequestingPermission = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Complete Onboarding
  // ═══════════════════════════════════════════════════════════════

  Future<void> _completeOnboarding() async {
    final box = Hive.box('settings');
    await box.put('onboarding_completed', true);
    await box.put('translation_language', 'en');
    await box.put('theme_mode', ThemeModeNotifier.toStringValue(_selectedTheme));
    await box.put('daily_reading_goal', _dailyReadingGoal);

    // Apply theme immediately.
    ref.read(themeModeProvider.notifier).setThemeMode(_selectedTheme);

    if (mounted) context.go('/quran');
  }

  // ═══════════════════════════════════════════════════════════════
  // Navigation
  // ═══════════════════════════════════════════════════════════════

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onButtonPressed() {
    if (_currentPage < _totalPages - 1) {
      _nextPage();
    } else {
      _completeOnboarding();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip Button ─────────────────────────────────────
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed:
                      _currentPage == _totalPages - 1 ? null : _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),

            // ── Page Content ───────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomePage(),
                  _buildFeaturesPage(),
                  _buildPermissionsPage(),
                  _buildPreferencesPage(),
                ],
              ),
            ),

            // ── Bottom Navigation ───────────────────────────────
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Page 1: Welcome
  // ═══════════════════════════════════════════════════════════════

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative pulsing circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.menu_book_rounded, size: 48, color: Colors.white),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                duration: 3000.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: 40),

          // Arabic logo with gold gradient
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.goldGradient.createShader(bounds),
            child: const Text(
              '\u0645\u0650\u0646\u0652\u0647\u064E\u0627\u062C\u064F \u0627\u0644\u0652\u0647\u064F\u062F\u064E\u0649',
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 8),

          Text(
            'MinhaajulHudaa',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.0,
              color: AppColors.darkTextSecondary.withOpacity(0.7),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

          const SizedBox(height: 24),

          Text(
            'Your Premium Quran & Hadith Companion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.7,
              color: AppColors.darkTextSecondary,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 40),

          // 'Get Started' button on Welcome page
          FilledButton(
            onPressed: _nextPage,
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Page 2: Features Overview (2×2 grid)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFeaturesPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything You Need',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text(
            'Comprehensive Islamic tools in one app.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.darkTextSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 24),

          // 2×2 Feature Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(_features.length, (index) {
                final f = _features[index];
                return _FeatureGridCard(
                  feature: f,
                  delay: Duration(milliseconds: 200 + index * 100),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Page 3: Permissions (real permission_handler calls)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPermissionsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permissions',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text(
            'These help us deliver the best experience.\nYou can change them later in Settings.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.darkTextSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 20),

          // Permission cards in a scrollable list
          Expanded(
            child: ListView.separated(
              itemCount: _permissions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final perm = _permissions[index];
                final status = _permStatuses[index] ?? _PermStatus.notAsked;
                return _PermissionCard(
                  entry: perm,
                  status: status,
                  isRequesting: _isRequestingPermission,
                  onRequest: () => _requestPermission(index),
                  delay: Duration(milliseconds: 200 + index * 100),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Page 4: Preferences
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPreferencesPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text(
            'Customize your experience.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.darkTextSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 28),

          // ── Theme Selection ───────────────────────────────────
          Text(
            'Theme',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeCard(AppThemeMode.light, Icons.light_mode_rounded, 'Light',
                  const Color(0xFFF8F6F1), const Color(0xFF1A1A2E)),
              const SizedBox(width: 10),
              _buildThemeCard(AppThemeMode.dark, Icons.dark_mode_rounded, 'Dark',
                  AppColors.darkSurface, AppColors.darkTextPrimary),
              const SizedBox(width: 10),
              _buildThemeCard(AppThemeMode.amoled, Icons.brightness_3_rounded, 'AMOLED',
                  const Color(0xFF000000), AppColors.darkTextPrimary),
            ],
          ),

          const SizedBox(height: 28),

          // ── Default Language (placeholder) ───────────────────
          Text(
            'Default Language',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder, width: 0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.translate_rounded,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text(
                  'English',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'More languages coming soon',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 28),

          // ── Daily Reading Goal ────────────────────────────────
          Text(
            'Daily Reading Goal',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_dailyReadingGoal.round()} pages per day',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
              inactiveTrackColor: AppColors.darkBorder,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _dailyReadingGoal,
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (val) => setState(() => _dailyReadingGoal = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.darkTextTertiary)),
              Text('10',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.darkTextTertiary)),
              Text('20',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.darkTextTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(AppThemeMode mode, IconData icon, String label,
      Color previewBg, Color previewText) {
    final selected = _selectedTheme == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTheme = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.darkSurface,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.darkBorder,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              // Theme preview mini card
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: previewBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 6,
                    decoration: BoxDecoration(
                      color: previewText.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.darkTextSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  // ═══════════════════════════════════════════════════════════════
  // Bottom Navigation (dots + button)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBottomNav() {
    // Hide bottom nav on Welcome page (it has its own button)
    if (_currentPage == 0) return const SizedBox.shrink();

    final isLastPage = _currentPage == _totalPages - 1;
    final buttonText = isLastPage ? 'Complete Setup' : 'Continue';
    final buttonIcon =
        isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
      child: Row(
        children: [
          // ── Page Dots ────────────────────────────────────────
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive ? AppColors.primary : AppColors.darkBorder,
                  ),
                );
              }),
            ),
          ),

          // ── Action Button ────────────────────────────────────
          FilledButton(
            onPressed: _onButtonPressed,
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  buttonText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(buttonIcon, size: 18),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Feature Grid Card (2×2)
// ═══════════════════════════════════════════════════════════════════════

class _FeatureGridCard extends StatelessWidget {
  final _FeatureEntry feature;
  final Duration delay;

  const _FeatureGridCard({required this.feature, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, size: 22, color: feature.color),
          ),
          const SizedBox(height: 12),
          Text(
            feature.title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feature.line1,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.darkTextSecondary,
              height: 1.4,
            ),
          ),
          Text(
            feature.line2,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.darkTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delay).slideY(
          begin: 0.15,
          end: 0,
          duration: 400.ms,
          delay: delay,
        );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Permission Card Widget (with real permission_handler integration)
// ═══════════════════════════════════════════════════════════════════════

class _PermissionCard extends StatelessWidget {
  final _PermissionEntry entry;
  final _PermStatus status;
  final bool isRequesting;
  final VoidCallback onRequest;
  final Duration delay;

  const _PermissionCard({
    required this.entry,
    required this.status,
    required this.isRequesting,
    required this.onRequest,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted = status == _PermStatus.granted;
    final isDenied = status == _PermStatus.denied;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + title + status indicator
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(entry.icon, size: 20, color: entry.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Status indicator
              _StatusIndicator(status: status),
            ],
          ),

          // Action button (only show when not yet granted/denied)
          if (status == _PermStatus.notAsked) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isRequesting ? null : onRequest,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: entry.color,
                  disabledBackgroundColor: entry.color.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isRequesting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Allow',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ] else if (isDenied) ...[
            const SizedBox(height: 8),
            Text(
              'You can enable this later in system Settings.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.darkTextTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delay).slideX(
          begin: 0.08,
          end: 0,
          duration: 400.ms,
          delay: delay,
        );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Permission Status Indicator
// ═══════════════════════════════════════════════════════════════════════

class _StatusIndicator extends StatelessWidget {
  final _PermStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      _PermStatus.granted => Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              size: 16, color: AppColors.success),
        ),
      _PermStatus.denied => Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded,
              size: 16, color: AppColors.error),
        ),
      _PermStatus.notAsked => Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.darkTextTertiary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.remove_rounded,
              size: 16, color: AppColors.darkTextTertiary.withOpacity(0.5)),
        ),
    };
  }
}
