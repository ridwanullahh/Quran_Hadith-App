import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/backup_provider.dart';

/// Screen for exporting and importing user data backups.
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Export Section ────────────────────────────────────────
          _SectionTitle(title: 'Create Backup', icon: Icons.cloud_upload_rounded),
          _Card(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Export all your data including bookmarks, notes, '
                    'memorization progress, reading history, and settings '
                    'as a single JSON file.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: backupState.isExporting
                              ? null
                              : () =>
                                  ref.read(backupProvider.notifier).exportBackup(),
                          icon: backupState.isExporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download_rounded),
                          label: Text(backupState.isExporting
                              ? 'Exporting...'
                              : 'Export Backup'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Import Section ────────────────────────────────────────
          _SectionTitle(title: 'Restore Backup', icon: Icons.cloud_download_rounded),
          _Card(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Import a previously exported backup file. '
                    'This will merge imported data with your current data. '
                    'Bookmarks and notes will be overwritten if they exist.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: backupState.isImporting
                              ? null
                              : () =>
                                  ref.read(backupProvider.notifier).importBackup(),
                          icon: backupState.isImporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload_rounded),
                          label: Text(backupState.isImporting
                              ? 'Importing...'
                              : 'Import Backup'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Last Backup Info ───────────────────────────────────────
          _SectionTitle(title: 'Last Backup', icon: Icons.history_rounded),
          _Card(
            child: _buildLastBackupInfo(backupState, theme),
          ),

          // ── Backup Summary ───────────────────────────────────────
          if (backupState.lastSummary != null) ...[
            const SizedBox(height: 16),
            _SectionTitle(title: 'Content Summary', icon: Icons.summarize_rounded),
            _Card(
              child: _buildSummaryGrid(backupState.lastSummary!, theme),
            ),
          ],

          // ── Auto-backup Reminder ──────────────────────────────────
          const SizedBox(height: 16),
          _SectionTitle(title: 'Auto-Backup', icon: Icons.schedule_rounded),
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Reminder',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ref
                                  .read(backupProvider.notifier)
                                  .shouldShowBackupReminder()
                              ? 'You haven\'t backed up recently. Consider creating a backup.'
                              : 'Your backup is up to date.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ref
                                    .read(backupProvider.notifier)
                                    .shouldShowBackupReminder()
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLastBackupInfo(BackupState state, ThemeData theme) {
    if (state.lastBackupDate == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.darkTextTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 18,
                color: AppColors.darkTextTertiary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No backup has been created yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _InfoRow(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.primary,
          label: 'Date',
          value: _formatDate(state.lastBackupDate),
        ),
        const _Divider(),
        if (state.lastBackupSize != null)
          _InfoRow(
            icon: Icons.data_usage_rounded,
            iconColor: AppColors.secondary,
            label: 'Size',
            value: state.lastBackupSize!,
          ),
        if (state.lastBackupPath != null) ...[
          const _Divider(),
          _InfoRow(
            icon: Icons.folder_rounded,
            iconColor: AppColors.info,
            label: 'Location',
            value: _shortenPath(state.lastBackupPath!),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryGrid(BackupSummary summary, ThemeData theme) {
    final items = [
      _SummaryItem(
        icon: Icons.bookmark_rounded,
        color: AppColors.bookmarkGold,
        label: 'Bookmarks',
        count: summary.bookmarkCount,
      ),
      _SummaryItem(
        icon: Icons.note_rounded,
        color: AppColors.primary,
        label: 'Notes',
        count: summary.noteCount,
      ),
      _SummaryItem(
        icon: Icons.school_rounded,
        color: AppColors.hifdhGreen,
        label: 'Hifdh',
        count: summary.memorizationCount,
      ),
      _SummaryItem(
        icon: Icons.history_rounded,
        color: AppColors.revisionBlue,
        label: 'Reading History',
        count: summary.readingHistoryCount,
      ),
      _SummaryItem(
        icon: Icons.event_repeat_rounded,
        color: AppColors.secondary,
        label: 'Revisions',
        count: summary.revisionCount,
      ),
      _SummaryItem(
        icon: Icons.headphones_rounded,
        color: AppColors.medinanBadge,
        label: 'Downloads',
        count: summary.audioDownloadCount,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${summary.totalItems} total items',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: item.color.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 20, color: item.color),
                    const SizedBox(height: 4),
                    Text(
                      '${item.count}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate fadeIn(duration: 300.ms).scale(delay: (index * 50).ms);
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  String _shortenPath(String path) {
    final parts = path.split('/');
    if (parts.length <= 3) return path;
    return '.../${parts.sublist(parts.length - 3).join('/')}';
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Reusable Widgets
// ═══════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
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
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });
}
