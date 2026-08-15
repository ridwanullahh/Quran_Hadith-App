import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'shell/app_shell.dart';
import 'theme/app_colors.dart';

// Feature screens
import '../../features/quran/presentation/screens/surah_list_screen.dart';
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

/// Top-level route paths used throughout the app.
abstract class AppRoutes {
  static const String quran = '/quran';
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
}

/// Provides the [GoRouter] instance for the application.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final path = state.uri.path;
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
        ],
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
          ListTile(
            leading: const Icon(Icons.bookmark_rounded),
            title: const Text('Bookmarks'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/bookmarks'),
          ),
          ListTile(
            leading: const Icon(Icons.note_rounded),
            title: const Text('Notes'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/notes'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/settings'),
          ),
          const Divider(),
          ListTile(
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
