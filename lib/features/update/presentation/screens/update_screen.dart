import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import 'providers/update_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// Update Screen
// ═══════════════════════════════════════════════════════════════════

class UpdateScreen extends ConsumerWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final updateState = ref.watch(updateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Update'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current version info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.system_update_rounded, size: 24, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MinhaajulHudaa',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current Version: ${updateState.currentVersion}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // Check for update button
            if (updateState.isChecking)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (updateState.error != null)
              _ErrorCard(error: updateState.error!, isDark: isDark)
            else if (updateState.hasUpdate && updateState.latestRelease != null)
              _UpdateAvailableCard(release: updateState.latestRelease!, isDark: isDark)
            else
              _UpToDateCard(isDark: isDark),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: !updateState.isChecking
          ? FloatingActionButton.extended(
              onPressed: () => ref.read(updateProvider.notifier).checkForUpdate(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Check Now'),
            )
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Update Available Card
// ═══════════════════════════════════════════════════════════════════

class _UpdateAvailableCard extends ConsumerWidget {
  final GitHubRelease release;
  final bool isDark;

  const _UpdateAvailableCard({required this.release, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final updateState = ref.watch(updateProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.new_releases_rounded, size: 24, color: AppColors.success),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Available!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'Version ${release.tagName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Release notes
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What\'s New',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  release.body.isNotEmpty ? release.body : 'Bug fixes and improvements.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Download button
          if (updateState.isDownloading) ...[
            Column(
              children: [
                LinearProgressIndicator(
                  value: updateState.downloadProgress,
                  backgroundColor: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  'Downloading... ${(updateState.downloadProgress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: release.apkDownloadUrl != null
                  ? () {
                      ref.read(updateProvider.notifier).downloadApk();
                    }
                  : null,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(
                release.apkDownloadUrl != null
                    ? 'Download Update'
                    : 'No APK Available',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            'Published: ${release.publishedAt}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

// ═══════════════════════════════════════════════════════════════════
// Up to Date Card
// ═══════════════════════════════════════════════════════════════════

class _UpToDateCard extends StatelessWidget {
  final bool isDark;

  const _UpToDateCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'You\'re Up to Date!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You are running the latest version of MinhaajulHudaa.\nCheck again later for updates.',
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.6,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Error Card
// ═══════════════════════════════════════════════════════════════════

class _ErrorCard extends StatelessWidget {
  final String error;
  final bool isDark;

  const _ErrorCard({required this.error, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Could Not Check for Updates',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.6,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
