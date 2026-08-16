import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/notification_provider.dart';
import '../widgets/popup_settings_widget.dart';

// ═══════════════════════════════════════════════════════════════════
// Notification Settings Screen
// ═══════════════════════════════════════════════════════════════════

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Permission status banner
          if (!settings.permissionsGranted)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_off_rounded, color: AppColors.warning, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications Not Enabled',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                        Text(
                          'Grant notification permission to receive daily reminders.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await ref.read(notificationSettingsProvider.notifier).requestPermissions();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Enable', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms),

          // ── Morning Notification ─────────────────────────────
          _SectionTitle(title: 'Morning Reminder', icon: Icons.wb_sunny_rounded),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: IconswbSunny(),
                iconColor: AppColors.secondary,
                title: 'Ayah of the Day',
                subtitle: 'Receive a Quran verse every morning',
                trailing: Switch(
                  value: settings.morningEnabled,
                  onChanged: (val) => ref.read(notificationSettingsProvider.notifier).toggleMorning(val),
                  activeColor: AppColors.primary,
                ),
              ),
              if (settings.morningEnabled) ...[
                const _Divider(),
                _SettingsTile(
                  icon: const Icon(Icons.schedule_rounded, size: 18),
                  iconColor: AppColors.secondary,
                  title: 'Time',
                  subtitle: _formatTimeOfDay(settings.morningTime),
                  trailing: TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: settings.morningTime,
                      );
                      if (time != null) {
                        ref.read(notificationSettingsProvider.notifier).setMorningTime(time);
                      }
                    },
                    child: const Text('Change'),
                  ),
                ),
              ],
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 8),

          // ── Evening Notification ─────────────────────────────
          _SectionTitle(title: 'Evening Reminder', icon: Icons.nights_stay_rounded),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: IconMoon(),
                iconColor: AppColors.revisionBlue,
                title: 'Hadith of the Day',
                subtitle: 'Receive a hadith every evening',
                trailing: Switch(
                  value: settings.eveningEnabled,
                  onChanged: (val) => ref.read(notificationSettingsProvider.notifier).toggleEvening(val),
                  activeColor: AppColors.primary,
                ),
              ),
              if (settings.eveningEnabled) ...[
                const _Divider(),
                _SettingsTile(
                  icon: const Icon(Icons.schedule_rounded, size: 18),
                  iconColor: AppColors.revisionBlue,
                  title: 'Time',
                  subtitle: _formatTimeOfDay(settings.eveningTime),
                  trailing: TextButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: settings.eveningTime,
                      );
                      if (time != null) {
                        ref.read(notificationSettingsProvider.notifier).setEveningTime(time);
                      }
                    },
                    child: const Text('Change'),
                  ),
                ),
              ],
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 8),

          // ── Friday Special ──────────────────────────────────
          _SectionTitle(title: 'Friday Special', icon: Icons.mosque_rounded),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: IconMosque(),
                iconColor: AppColors.primary,
                title: 'Surah Al-Kahf Reminder',
                subtitle: 'Reminder to read Surah Al-Kahf every Friday',
                trailing: Switch(
                  value: settings.fridayEnabled,
                  onChanged: (val) => ref.read(notificationSettingsProvider.notifier).toggleFriday(val),
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 8),

          // ── In-App Popup Settings ─────────────────────
          const PopupSettingsWidget(),

          const SizedBox(height: 24),

          // ── Schedule All Button ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: () async {
                await ref.read(notificationSettingsProvider.notifier).scheduleAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications scheduled')),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_rounded, size: 18),
              label: const Text('Reschedule All Notifications'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms),

          const SizedBox(height: 12),

          // ── Re-grant Permissions Button ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final box = Hive.box('settings');
                await box.put('onboarding_completed', false);
                if (context.mounted) {
                  context.go('/onboarding');
                }
              },
              icon: const Icon(Icons.shield_rounded, size: 18),
              label: const Text('Re-grant Permissions'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Icon IconswbSunny() => const Icon(Icons.wb_sunny_rounded, size: 18);
  Icon IconMoon() => const Icon(Icons.nights_stay_rounded, size: 18);
  Icon IconMosque() => const Icon(Icons.mosque_rounded, size: 18);
}

// ═══════════════════════════════════════════════════════════════════
// Reusable Components
// ═══════════════════════════════════════════════════════════════════

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

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

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
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Icon icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle = '',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: icon,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBorder
            : AppColors.lightBorder,
      ),
    );
  }
}
