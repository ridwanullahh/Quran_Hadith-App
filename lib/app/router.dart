import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import 'shell/app_shell.dart';
import 'theme/app_colors.dart';

// Feature screens
import '../../features/quran/presentation/screens/surah_list_screen.dart';
import '../../features/quran/presentation/screens/mushaf_screen.dart';
import '../../features/quran/presentation/screens/surah_reading_screen.dart';
import '../../features/quran/presentation/screens/quran_search_screen.dart';
import '../../features/quran/presentation/screens/juz_reading_screen.dart';
import '../../features/quran/presentation/screens/tafseer_screen.dart';
import '../../features/quran/presentation/screens/bookmark_folders_screen.dart';
import '../../features/quran/presentation/screens/recitation_tracker_screen.dart';
import '../../features/quran/presentation/screens/surah_info_screen.dart';
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
import '../../features/hadith/presentation/screens/hadith_of_day_screen.dart';
import '../../features/hadith/presentation/screens/hadith_favorites_screen.dart';
import '../../features/hadith/presentation/screens/hadith_collection_detail_screen.dart';
import '../../features/hadith/presentation/screens/narrator_screen.dart';
import '../../features/hadith/presentation/screens/grading_screen.dart';
import '../../features/hadith/presentation/screens/hadith_search_screen.dart';
import '../../features/hadith/presentation/screens/hadith_notes_screen.dart';
import '../../features/hadith/presentation/screens/hadith_bookmarks_screen.dart';
import '../../features/hadith/presentation/screens/hadith_topics_screen.dart';
import '../../features/hadith/presentation/screens/hadith_settings_screen.dart';
import '../../features/hadith/presentation/screens/hadith_random_screen.dart';
import '../../features/hadith/presentation/screens/hadith_isnad_visualizer_screen.dart';
import '../../features/hadith/presentation/screens/hadith_comparison_screen.dart';
import '../../features/hadith/presentation/screens/hadith_statistics_screen.dart';
import '../../features/hadith/presentation/screens/hadith_glossary_screen.dart';
import '../../features/hadith/presentation/screens/hadith_study_planner_screen.dart';
import '../../features/hadith/presentation/screens/hadith_daily_tracker_screen.dart';
import '../../features/hadith/presentation/screens/hadith_bookmark_folders_screen.dart';
import '../../features/hadith/presentation/screens/hadith_chain_narrators_screen.dart';
import '../../features/hadith/presentation/screens/hadith_collection_overview_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/engagement/presentation/screens/engagement_screen.dart';
import '../../features/engagement/presentation/screens/weekly_digest_screen.dart';
import '../../features/update/presentation/screens/update_screen.dart';
import '../../features/reciters/presentation/screens/full_audio_player_screen.dart';
import '../../features/reciters/presentation/screens/audio_download_manager_screen.dart';
import '../../features/reciters/presentation/screens/queue_screen.dart';
import '../../features/reciters/presentation/screens/audio_settings_screen.dart';

/// Top-level route paths used throughout the app.
abstract class AppRoutes {
  static const String quran = '/quran';
  static const String quranMushaf = '/quran/mushaf';
  static const String quranSurah = '/quran/:surahNumber';
  static const String quranSearch = '/quran/search';
  static const String quranJuz = '/quran/juz';
  static const String quranTafseer = '/quran/tafseer/:surahNumber';
  static const String quranBookmarkFolders = '/quran/bookmark-folders';
  static const String quranProgress = '/quran/progress';
  static const String quranSurahInfo = '/quran/:surahNumber/info';
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
  static const String dua = '/dua';
  static const String asma = '/asma';
  static const String dailyVerse = '/daily';
  static const String hadithOfDay = '/hadith/daily';
  static const String hadithFavorites = '/hadith/favorites';
  static const String hadithCollectionDetail = '/hadith/detail/:collectionId';
  static const String hadithNarrators = '/hadith/narrators';
  static const String hadithNarratorDetail = '/hadith/narrators/:narratorId';
  static const String hadithGrading = '/hadith/grading';
  static const String hadithSearch = '/hadith/search';
  static const String hadithNotes = '/hadith/notes';
  static const String hadithBookmarks = '/hadith/bookmarks';
  static const String hadithTopics = '/hadith/topics';
  static const String hadithSettings = '/hadith/settings';
  static const String hadithRandom = '/hadith/random';
  static const String hadithIsnad = '/hadith/isnad';
  static const String hadithComparison = '/hadith/comparison';
  static const String hadithStatistics = '/hadith/statistics';
  static const String hadithGlossary = '/hadith/glossary';
  static const String hadithStudyPlanner = '/hadith/study-planner';
  static const String hadithDailyTracker = '/hadith/daily-tracker';
  static const String hadithBookmarkFolders = '/hadith/bookmark-folders';
  static const String hadithChainNarrators = '/hadith/chain-narrators';
  static const String hadithCollectionOverview = '/hadith/collection-overview';
  static const String notifications = '/notifications';
  static const String engagement = '/engagement';
  static const String weeklyDigest = '/weekly-digest';
  static const String update = '/update';
  static const String audioPlayer = '/audio/player';
  static const String audioDownloads = '/audio/downloads';
  static const String audioQueue = '/audio/queue';
  static const String audioSettings = '/audio/settings';
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

          // Juz Reading
          GoRoute(
            path: '/quran/juz',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JuzListScreen(),
            ),
            routes: [
              GoRoute(
                path: ':juzNumber',
                pageBuilder: (context, state) {
                  final juzNumber =
                      int.tryParse(state.pathParameters['juzNumber'] ?? '') ?? 1;
                  return NoTransitionPage(
                    child: JuzReadingScreen(juzNumber: juzNumber),
                  );
                },
              ),
            ],
          ),

          // Tafseer Screen
          GoRoute(
            path: '/quran/tafseer/:surahNumber',
            pageBuilder: (context, state) {
              final surahNumber =
                  int.tryParse(state.pathParameters['surahNumber'] ?? '') ?? 1;
              return NoTransitionPage(
                child: TafseerScreen(surahNumber: surahNumber),
              );
            },
          ),

          // Bookmark Folders
          GoRoute(
            path: '/quran/bookmark-folders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookmarkFoldersScreen(),
            ),
          ),

          // Recitation Progress Tracker
          GoRoute(
            path: '/quran/progress',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RecitationTrackerScreen(),
            ),
          ),

          // Surah Info Screen
          GoRoute(
            path: '/quran/:surahNumber/info',
            pageBuilder: (context, state) {
              final surahNumber =
                  int.tryParse(state.pathParameters['surahNumber'] ?? '') ?? 1;
              return NoTransitionPage(
                child: SurahInfoScreen(surahNumber: surahNumber),
              );
            },
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

          // Hadith of the Day
          GoRoute(
            path: '/hadith/daily',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithOfDayScreen(),
            ),
          ),

          // Hadith Favorites
          GoRoute(
            path: '/hadith/favorites',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithFavoritesScreen(),
            ),
          ),

          // Hadith Collection Detail
          GoRoute(
            path: '/hadith/detail/:collectionId',
            pageBuilder: (context, state) {
              final collectionId =
                  state.pathParameters['collectionId'] ?? 'bukhari';
              return NoTransitionPage(
                child: HadithCollectionDetailScreen(collectionId: collectionId),
              );
            },
          ),

          // Hadith Narrators
          GoRoute(
            path: '/hadith/narrators',
            pageBuilder: (context, state) {
              // If there's a narratorId path segment, show detail
              final uri = state.uri;
              final pathSegments = uri.pathSegments;
              // /hadith/narrators => list, /hadith/narrators/:id => detail
              return NoTransitionPage(
                child: NarratorScreen(),
              );
            },
            routes: [
              GoRoute(
                path: ':narratorId',
                pageBuilder: (context, state) {
                  final narratorId =
                      state.pathParameters['narratorId'] ?? '';
                  return NoTransitionPage(
                    child: NarratorDetailScreen(narratorId: narratorId),
                  );
                },
              ),
            ],
          ),

          // Hadith Grading
          GoRoute(
            path: '/hadith/grading',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GradingScreen(),
            ),
          ),

          // Hadith Search
          GoRoute(
            path: '/hadith/search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithSearchScreen(),
            ),
          ),

          // Hadith Notes
          GoRoute(
            path: '/hadith/notes',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithNotesScreen(),
            ),
          ),

          // Hadith Bookmarks
          GoRoute(
            path: '/hadith/bookmarks',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithBookmarksScreen(),
            ),
          ),

          // Hadith Topics
          GoRoute(
            path: '/hadith/topics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithTopicsScreen(),
            ),
          ),

          // Hadith Settings
          GoRoute(
            path: '/hadith/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithSettingsScreen(),
            ),
          ),

          // Hadith Random Explorer
          GoRoute(
            path: '/hadith/random',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithRandomScreen(),
            ),
          ),

          // Hadith Isnad Visualizer
          GoRoute(
            path: '/hadith/isnad',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithIsnadVisualizerScreen(),
            ),
          ),

          // Hadith Comparison
          GoRoute(
            path: '/hadith/comparison',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithComparisonScreen(),
            ),
          ),

          // Hadith Statistics
          GoRoute(
            path: '/hadith/statistics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithStatisticsScreen(),
            ),
          ),

          // Hadith Glossary
          GoRoute(
            path: '/hadith/glossary',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithGlossaryScreen(),
            ),
          ),

          // Hadith Study Planner
          GoRoute(
            path: '/hadith/study-planner',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithStudyPlannerScreen(),
            ),
          ),

          // Hadith Daily Tracker
          GoRoute(
            path: '/hadith/daily-tracker',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithDailyTrackerScreen(),
            ),
          ),

          // Hadith Bookmark Folders
          GoRoute(
            path: '/hadith/bookmark-folders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithBookmarkFoldersScreen(),
            ),
          ),

          // Hadith Chain Narrators
          GoRoute(
            path: '/hadith/chain-narrators',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithChainNarratorsScreen(),
            ),
          ),

          // Hadith Collection Overview
          GoRoute(
            path: '/hadith/collection-overview',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HadithCollectionOverviewScreen(),
            ),
          ),

          // Notification Settings
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationSettingsScreen(),
            ),
          ),

          // Engagement / Streak Tracker
          GoRoute(
            path: '/engagement',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EngagementScreen(),
            ),
          ),

          // Weekly Digest
          GoRoute(
            path: '/weekly-digest',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WeeklyDigestScreen(),
            ),
          ),

          // Update
          GoRoute(
            path: '/update',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UpdateScreen(),
            ),
          ),
        ],
      ),

      // Audio Player (outside shell - full screen)
      GoRoute(
        path: '/audio/player',
        pageBuilder: (context, state) => const MaterialPage(
          child: FullAudioPlayerScreen(),
        ),
      ),
      GoRoute(
        path: '/audio/downloads',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AudioDownloadManagerScreen(),
        ),
      ),
      GoRoute(
        path: '/audio/queue',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: QueueScreen(),
        ),
      ),
      GoRoute(
        path: '/audio/settings',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AudioSettingsScreen(),
        ),
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
                      color: AppColors.primary.withOpacity(0.1),
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
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
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
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
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
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
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
                      color: AppColors.secondary.withOpacity(0.1),
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
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
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

          // ── Hadith Study Section ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              children: [
                Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  'Hadith Study',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.secondary,
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
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.topic_rounded, size: 18, color: AppColors.secondary),
                  ),
                  title: const Text('Hadith Topics'),
                  subtitle: const Text('Browse hadiths by subject'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/topics'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Hadith Notes'),
                  subtitle: const Text('Your personal hadith notes'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/notes'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.hifdhGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bookmark_rounded, size: 18, color: AppColors.hifdhGreen),
                  ),
                  title: const Text('Hadith Bookmarks'),
                  subtitle: const Text('Saved hadith references'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/bookmarks'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.info),
                  ),
                  title: const Text('Hadith Settings'),
                  subtitle: const Text('Font sizes, display options'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/settings'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.medinanBadge.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.casino_rounded, size: 18, color: AppColors.medinanBadge),
                  ),
                  title: const Text('Random Explorer'),
                  subtitle: const Text('Discover random hadiths'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/random'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_tree_rounded, size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Isnad Visualizer'),
                  subtitle: const Text('Explore narration chains'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/isnad'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.compare_rounded, size: 18, color: AppColors.secondary),
                  ),
                  title: const Text('Hadith Comparison'),
                  subtitle: const Text('Compare across collections'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/comparison'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.success),
                  ),
                  title: const Text('Hadith Statistics'),
                  subtitle: const Text('Your reading progress'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/statistics'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.info),
                  ),
                  title: const Text('Hadith Glossary'),
                  subtitle: const Text('Islamic terminology guide'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/glossary'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_note_rounded, size: 18, color: AppColors.warning),
                  ),
                  title: const Text('Study Planner'),
                  subtitle: const Text('Plan your hadith study'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/study-planner'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.revisionBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.today_rounded, size: 18, color: AppColors.revisionBlue),
                  ),
                  title: const Text('Daily Tracker'),
                  subtitle: const Text('Track daily hadith reading'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/daily-tracker'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.bookmarkGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.folder_special_rounded, size: 18, color: AppColors.bookmarkGold),
                  ),
                  title: const Text('Bookmark Folders'),
                  subtitle: const Text('Organize hadith bookmarks'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/bookmark-folders'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people_rounded, size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Chain Narrators'),
                  subtitle: const Text('Key narrators of hadith'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/chain-narrators'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.library_books_rounded, size: 18, color: AppColors.secondary),
                  ),
                  title: const Text('Collections Overview'),
                  subtitle: const Text('Kutub al-Sittah dashboard'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/hadith/collection-overview'),
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
                      color: AppColors.primary.withOpacity(0.1),
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
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
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
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
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
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_rounded, size: 18, color: AppColors.info),
                  ),
                  title: const Text('Reciters'),
                  subtitle: const Text('Manage audio reciters'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/reciters'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.download_for_offline_rounded, size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Audio Downloads'),
                  subtitle: const Text('Manage downloaded audio files'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/audio/downloads'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.graphic_eq_rounded, size: 18, color: AppColors.secondary),
                  ),
                  title: const Text('Audio Settings'),
                  subtitle: const Text('Playback, downloads, quality'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/audio/settings'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.view_agenda_rounded, size: 18, color: AppColors.primary),
                  ),
                  title: const Text('Juz Reading'),
                  subtitle: const Text('Read Quran by Juz'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/quran/juz'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.success),
                  ),
                  title: const Text('Recitation Progress'),
                  subtitle: const Text('Track your Quran reading'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/quran/progress'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.bookmarkGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.folder_special_rounded, size: 18, color: AppColors.bookmarkGold),
                  ),
                  title: const Text('Bookmark Folders'),
                  subtitle: const Text('Organize your bookmarks'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/quran/bookmark-folders'),
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
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: const Icon(Icons.note_rounded),
                  title: const Text('Notes'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/notes'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart_rounded),
                  title: const Text('Reading Statistics'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/stats'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
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
