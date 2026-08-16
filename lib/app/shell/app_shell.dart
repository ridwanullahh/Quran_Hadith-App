import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'mini_audio_player.dart';

/// The main application shell with a [BottomNavigationBar] and the
/// persistent [MiniAudioPlayer] bar.
///
/// This widget is used inside a GoRouter [ShellRoute] so that the
/// navigation bar persists across all tab-level routes.
class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  /// The index of the currently selected bottom nav tab.
  int _currentIndex = 0;

  /// Animation controller for the active indicator dot.
  late final AnimationController _indicatorController;
  late final Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOutCubic,
    );
    _indicatorController.forward();
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  /// Map tab index to the root route path used by GoRouter.
  static const _tabPaths = [
    '/quran',
    '/hifdh',
    '/hadith',
    '/more',
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    // Animate the indicator out, switch, then animate in.
    _indicatorController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _currentIndex = index);
      _indicatorController.forward();
    });

    // Navigate to the tab's root path without pushing onto the stack.
    final path = _tabPaths[index];
    context.go(path);
  }

  // Determines the current tab index based on the current GoRouter location.
  int _resolveTabIndex(String location) {
    if (location.startsWith('/hifdh')) return 1;
    if (location.startsWith('/hadith')) return 2;
    if (location.startsWith('/settings') ||
        location.startsWith('/bookmarks') ||
        location.startsWith('/notes') ||
        location.startsWith('/more') ||
        location.startsWith('/prayer') ||
        location.startsWith('/qibla') ||
        location.startsWith('/calendar')) {
      return 3;
    }
    return 0; // Default to Quran tab for all other routes.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colorScheme = Theme.of(context).colorScheme;

    // Sync the current tab index with the router location.
    final currentLocation = GoRouterState.of(context).uri.path;
    final resolvedIndex = _resolveTabIndex(currentLocation);
    if (resolvedIndex != _currentIndex) {
      _currentIndex = resolvedIndex;
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini audio player (shows only when audio is active).
          const MiniAudioPlayer(),
          // Bottom navigation bar.
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _buildBottomNav(
                context,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context, {
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          _buildNavItem(
            context,
            index: 0,
            icon: Icons.menu_book_rounded,
            activeIcon: Icons.menu_book_rounded,
            label: 'Quran',
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          _buildNavItem(
            context,
            index: 1,
            icon: Icons.school_rounded,
            activeIcon: Icons.school_rounded,
            label: 'Hifdh',
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.auto_stories_rounded,
            activeIcon: Icons.auto_stories_rounded,
            label: 'Hadith',
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          _buildNavItem(
            context,
            index: 3,
            icon: Icons.more_horiz_rounded,
            activeIcon: Icons.more_horiz_rounded,
            label: 'More',
            colorScheme: colorScheme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final selectedColor = isDark
        ? AppColors.navItemDarkSelected
        : AppColors.navItemSelected;
    final unselectedColor = isDark
        ? AppColors.navItemDarkUnselected
        : AppColors.navItemUnselected;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon + active indicator
            AnimatedBuilder(
              animation: _indicatorAnimation,
              builder: (context, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Active background pill.
                    if (isSelected)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: -4,
                        child: Transform.scale(
                          scale: _indicatorAnimation.value,
                          child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: selectedColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    // Icon.
                    SizedBox(
                      width: 40,
                      height: 28,
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        color: isSelected ? selectedColor : unselectedColor,
                        size: isSelected ? 24 : 22,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 3),
            // Label.
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isSelected ? 11.5 : 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
                letterSpacing: isSelected ? 0.3 : 0.2,
              ),
            ),
            // Active dot indicator.
            const SizedBox(height: 2),
            AnimatedBuilder(
              animation: _indicatorAnimation,
              builder: (context, child) {
                if (!isSelected) return const SizedBox(height: 4);
                return Transform.scale(
                  scale: _indicatorAnimation.value,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
          curve: Curves.easeOutCubic,
        );
  }
}


