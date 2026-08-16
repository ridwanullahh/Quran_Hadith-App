import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/app.dart';

/// Whether the user has completed onboarding.
final onboardingCompletedProvider = Provider<bool>((ref) {
  try {
    final box = Hive.box('settings');
    return box.get('onboarding_completed', defaultValue: false) as bool;
  } catch (_) {
    return false;
  }
});

/// A beautiful 3-page onboarding flow shown only on first launch.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _selectedLanguage = 'en';
  ThemeMode _selectedTheme = ThemeMode.dark;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final box = Hive.box('settings');
    await box.put('onboarding_completed', true);
    await box.put('translation_language', _selectedLanguage);
    final modeString = switch (_selectedTheme) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await box.put('theme_mode', modeString);

    // Apply theme immediately
    ref.read(themeModeProvider.notifier).setThemeMode(_selectedTheme);

    if (mounted) {
      context.go('/quran');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip Button ─────────────────────────────────────────
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _currentPage == 2 ? null : _completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),

            // ── Page Content ────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomePage(),
                  _buildFeaturesPage(),
                  _buildSetupPage(),
                ],
              ),
            ),

            // ── Bottom Navigation ─────────────────────────────────
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Page 1: Welcome
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative Islamic pattern circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: Colors.white,
              ),
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

          // App name in Arabic
          ShaderMask(
            shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
            child: const Text(
              '\u0645ِنْهَاجُ الْهُدَى',
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
              color: AppColors.darkTextSecondary.withValues(alpha: 0.7),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms),

          const SizedBox(height: 24),

          Text(
            'Your companion on the path of guidance.\nRead, memorize, and reflect on the\nNoble Quran and authentic Hadith.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 1.7,
              color: AppColors.darkTextSecondary,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Page 2: Features
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildFeaturesPage() {
    final features = [
      _FeatureItem(
        icon: Icons.auto_stories_rounded,
        title: 'Holy Quran',
        description: 'Read the complete Quran with translations,\nword-by-word analysis & tafseer.',
        color: AppColors.primary,
      ),
      _FeatureItem(
        icon: Icons.school_rounded,
        title: 'Hifdh Tracker',
        description: 'Spaced repetition memorization\nwith progress tracking & tests.',
        color: AppColors.hifdhGreen,
      ),
      _FeatureItem(
        icon: Icons.menu_book_rounded,
        title: 'Hadith Library',
        description: 'Authentic collections: Bukhari, Muslim,\nAbu Dawud, Tirmidhi & more.',
        color: AppColors.secondary,
      ),
      _FeatureItem(
        icon: Icons.mosque_rounded,
        title: 'Islamic Tools',
        description: 'Prayer times, Qibla compass,\nHijri calendar & Tasbih counter.',
        color: AppColors.revisionBlue,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything You Need',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text(
            'Comprehensive Islamic tools in one app.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.darkTextSecondary,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 24),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _FeatureCard(
                feature: feature,
                delay: Duration(milliseconds: 200 + index * 100),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Page 3: Quick Setup
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSetupPage() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Setup',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 6),
          Text(
            'Customize your experience.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.darkTextSecondary,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 32),

          // ── Language Selection ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.darkBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Translation Language',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _languageChip('en', 'English'),
                    _languageChip('ur', 'اردو'),
                    _languageChip('hi', 'हिन्दी'),
                    _languageChip('bn', 'বাংলা'),
                    _languageChip('tr', 'Türkçe'),
                    _languageChip('id', 'Indonesia'),
                    _languageChip('fr', 'Français'),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideX(begin: 0.05, end: 0),

          const SizedBox(height: 16),

          // ── Theme Selection ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.darkBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.dark_mode_rounded,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Theme Preference',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _themeOption(
                      ThemeMode.dark,
                      Icons.dark_mode_rounded,
                      'Dark',
                    ),
                    const SizedBox(width: 12),
                    _themeOption(
                      ThemeMode.light,
                      Icons.light_mode_rounded,
                      'Light',
                    ),
                    const SizedBox(width: 12),
                    _themeOption(
                      ThemeMode.system,
                      Icons.brightness_auto_rounded,
                      'Auto',
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(begin: 0.05, end: 0),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Bottom Navigation
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
      child: Row(
        children: [
          // ── Page Dots ──────────────────────────────────────────
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
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

          // ── Button ────────────────────────────────────────────
          FilledButton(
            onPressed: _nextOrStart,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentPage == 2 ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentPage == 2
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  size: 20,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
        ],
      ),
    );
  }

  void _nextOrStart() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Widget _languageChip(String code, String label) {
    final selected = _selectedLanguage == code;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      selected: selected,
      onSelected: (_) => setState(() => _selectedLanguage = code),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
    );
  }

  Widget _themeOption(ThemeMode mode, IconData icon, String label) {
    final selected = _selectedTheme == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTheme = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.darkSurfaceVariant.withValues(alpha: 0.3),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.darkBorder,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: selected ? AppColors.primary : AppColors.darkTextSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.primary : AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Helper Classes
// ═══════════════════════════════════════════════════════════════════════

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;
  final Duration delay;
  const _FeatureCard({required this.feature, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, size: 22, color: feature.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.darkTextSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delay).slideX(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          delay: delay,
        );
  }
}
