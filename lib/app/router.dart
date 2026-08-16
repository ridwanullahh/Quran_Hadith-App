import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive_flutter.dart';

import 'shell/app_shell.dart';
import 'theme/app_colors.dart';

// Feature screens
import '../../features/quran/presentation/screens/surah_list_screen.dart';
import '../../features/quran/presentation/screens/mushaf_screen.dart';
import '../../features/quran/presentation/screens/surah_reading_screen.dart';
import '../../features/quran/presentation/screens/quran_search_screen.dart';
import '../../features/hifdh/presentation/screens/hifdh_dashboard_screen.dart';
import '../../features/hifdh/presentation/screens/hifdh_test_screen.dart';
import '../../features/hadith/presentation/screens/hadith_collections_screen.dart';
import '../../features/hadith/presentation/screens/hadith_books_screen.dart';
import '../../features/hadith/presentation/screens/hadith_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/prayer/presentation/screens/prayer_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/calendar/presentation/screens/hijri_calendar_screen.dart';
import '../../features/tasbih/presentation/screens/tasbih_screen.dart';
import '../../features/dua/presentation/screens/dua_screen.dart';
import '../../features/asma/presentation/screens/asma_screen.dart';
import '../../features/daily_verse/presentation/screens/daily_verse_screen.dart';
import '../../features/backup/presentation/screens/backup_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/topics/presentation/screens/topic_screen.dart';
import '../../features/cross_refs/presentation/screens/cross_ref_screen.dart';
import '../../features/reciters/presentation/screens/reciter_screen.dart';
import '../../features/reading_plan/presentation/screens/reading_plan_screen.dart';

/// Top-level route paths used throughout the app.
abstract class AppRoutes {
  static const String quran = '/quran';
  static const String quranMushaf = '/quran/mushaf';
  static const String quranSurah = '/quran/:surahNumber';
  static const String quranSearch = '/quran/search';
  static const String hifdh = '/hifdh';
  static const String hifdhTest = '/hifdh/test';
  static const String hadith = '/hadith';
  static const String hadithCollection = '/hadith/collection/:collectionId';
  static const String hadithBook = '/hadith/book/:bookId';
  static const String settings = '/settings';
  static const String bookmarks = '/bookmarks';
  static const String notes = '/notes';
  static const String more = '/more';
  static const String prayer = '/prayer';
  static const String qibla = '/qibla';
  static const String calendar = '/calendar';
  static const String backup = '/backup';
  static const String stats = '/stats';
  static const String onboarding = '/onboarding';
  static const String topics = '/topics';
  static const String crossRefs = '/cross-refs';
  static const String reciters = '/reciters';
  static const String readingPlan = '/reading-plan';
  static const String tasbih = '/tasbih';
  static const String dua = '/dua';
  static const String asma = '/asma';
  static const String dailyVerse = '/daily';
}

/// Provides the [GoRouter] instance for the application.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final path = state.uri.path;
      // Onboarding check: redirect first-time users
      if (path == '/' || path == '/quran') {
        final box = Hive.box('settings');
        final completed = box.get('onboarding_completed', defaultValue: false) as bool;
        if (!completed && path != '/onboarding') {
          return '/onboarding';
        }
      }
      if (path == '/') return '/quran';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Quran Tab
          GoRoute(
            path: '/quran',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SurahListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'mushaf',
                pageBuilder: (context, state) {
                  final page = int.tryParse(
                    state.uri.queryParameters['page'] ?? '',
                  );
                  return NoTransitionPage(
                    child: MushafScreen(initialPage: page ?? 1),
                  );
                },
              ),
              GoRoute(
                path: ':surahNumber',
                pageBuilder: (context, state) {
                  final surahNumber =
                      int.tryParse(state.pathParameters['surahNumber'] ?? '') ?? 1;
                  return NoTransitionPage(
                    child: SurahReadingScreen(surahNumber: surahNumber),
                  );
                },
              ),
              GoRoute(
                path: 'search',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: QuranSearchScreen(),
                ),
              ),
            ],
          ),

          // Hifdh Tab
          GoRoute(
            path: '/hifdh',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HifdhDashboardScreen(),
            ),
            routes: [
              GoRoute(
                path: 'test',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HifdhTestScreen(),
                ),
              ),
            ],
          ),

          // Hadith Tab
          GoRoute(
            path: '/hadith',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithCollectionsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'collection/:collectionId',
                pageBuilder: (context, state) {
                  final collectionId =
                      state.pathParameters['collectionId'] ?? 'bukhari';
                  return NoTransitionPage(
                    child: HadithBooksScreen(collectionId: collectionId),
                  );
                },
              ),
              GoRoute(
                path: 'book/:bookId',
                pageBuilder: (context, state) {
                  final bookId =
                      state.pathParameters['bookId'] ?? '1';
                  return NoTransitionPage(
                    child: HadithListScreen(bookId: bookId),
                  );
                },
              ),
            ],
          ),

          // More Tab
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _MoreScreen(),
            ),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),

          // Bookmarks
          GoRoute(
            path: '/bookmarks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookmarksScreen(),
            ),
          ),

          // Notes
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotesScreen(),
            ),
          ),

          // Prayer Times
          GoRoute(
            path: '/prayer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerScreen(),
            ),
          ),

          // Qibla Compass
          GoRoute(
            path: '/qibla',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QiblaScreen(),
            ),
          ),

          // Hijri Calendar
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HijriCalendarScreen(),
            ),
          ),

          // Backup & Restore
          GoRoute(
            path: '/backup',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BackupScreen(),
            ),
          ),

          // Reading Statistics
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatsScreen(),
            ),
          ),

          // Quran Topics
          GoRoute(
            path: '/topics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TopicScreen(),
            ),
          ),

          // Cross-References
          GoRoute(
            path: '/cross-refs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CrossRefScreen(),
            ),
          ),

          // Reciters
          GoRoute(
            path: '/reciters',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReciterScreen(),
            ),
          ),

          // Reading Plan
          GoRoute(
            path: '/reading-plan',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReadingPlanScreen(),
            ),
          ),

          // Tasbih Counter
          GoRoute(
            path: '/tasbih',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TasbihScreen(),
            ),
          ),

          // Du'a Collection
          GoRoute(
            path: '/dua',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DuaScreen(),
            ),
          ),

          // Asma ul Husna
          GoRoute(
            path: '/asma',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AsmaScreen(),
            ),
          ),

          // Daily Verse
          GoRoute(
            path: '/daily',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DailyVerseScreen(),
            ),
          ),
        ],
      ),

      // Onboarding (outside shell)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => const MaterialPage(
          child: OnboardingScreen(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: _ErrorScreen(error: state.error),
    ),
  );
});

class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Islamic Tools Section ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Row(
              children: [
                Icon(Icons.mosque_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Islamic Tools',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Prayer Times'),
                  subtitle: const Text('Daily Salah schedule'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/prayer'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.explore_rounded, size: 18, color: AppColors.secondary),
                  ),
                  title: const Text('Qibla Compass'),
                  subtitle: const Text('Direction to Kaaba'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/qibla'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.info),
                  ),
                  title: const Text('Hijri Calendar'),
                  subtitle: const Text('Islamic lunar calendar'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/calendar'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.secondary),
                  ),
                  title: const Text('Daily Verse'),
                  subtitle: const Text('Ayah of the day'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/daily'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Dhikr & Du'a Section ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              children: [
                Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Dhikr & Du\'a',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.touch_app_rounded, size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Tasbih Counter'),
                  subtitle: const Text('Dhikr counter with haptic feedback'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/tasbih'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.secondary),
                  ),
                  title: const Text("Du'a Collection"),
                  subtitle: const Text("Curated supplications"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/dua'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.text_fields_rounded, size: 18, color: AppColors.info),
                  ),
                  title: const Text('Asma ul Husna'),
                  subtitle: const Text('99 Names of Allah'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/asma'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Quran Study Section ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              children: [
                Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Quran Study',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.topic_rounded, size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Quran Topics'),
                  subtitle: const Text('Categorized verse index'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/topics'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.link_rounded, size: 18, color: AppColors.secondary),
                  ),
                  title: const Text('Cross-References'),
                  subtitle: const Text('Quran-Hadith connections'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/cross-refs'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_note_rounded, size: 18, color: AppColors.success),
                  ),
                  title: const Text('Reading Plan'),
                  subtitle: const Text('Structured Khatmah plans'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/reading-plan'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_rounded, size: 18, color: AppColors.info),
                  ),
                  title: const Text('Reciters'),
                  subtitle: const Text('Manage audio reciters'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/reciters'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── General Section ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'General',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmark_rounded),
                  title: const Text('Bookmarks'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/bookmarks'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: const Icon(Icons.note_rounded),
                  title: const Text('Notes'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/notes'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart_rounded),
                  title: const Text('Reading Statistics'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/stats'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.darkBorder),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_upload_rounded),
                  title: const Text('Backup & Restore'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/backup'),
                ),
              ],
            ),
          ),

          // ── About ────────────────────────────────────────────
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'MinhaajulHudaa',
                  applicationVersion: '0.1.0',
                  applicationLegalese: 'A premium Quran and Hadith application.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final Exception? error;
  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Page Not Found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error?.toString() ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/quran'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
