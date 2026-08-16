import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/reading_plan_provider.dart';

class ReadingPlanScreen extends ConsumerWidget {
 const ReadingPlanScreen({super.key});

 @override
 Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(readingPlanProvider);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final plan = state.activePlan;

  return Scaffold(
   appBar: AppBar(
    title: const Text('Reading Plan'),
    actions: [
     if (plan != null)
      PopupMenuButton<String>(
       onSelected: (value) {
        if (value == 'reset') {
         _showResetDialog(context, ref);
        }
       },
       itemBuilder: (_) => [
        const PopupMenuItem(value: 'reset', child: Text('Reset Plan')),
       ],
      ),
    ],
   ),
   body: plan == null ? _PlanSelector(isDark: isDark) : _PlanDashboard(state: state, isDark: isDark),
  );
 }

 void _showResetDialog(BuildContext context, WidgetRef ref) {
  showDialog(
   context: context,
   builder: (ctx) => AlertDialog(
    title: const Text('Reset Plan?'),
    content: const Text('This will clear all progress. This action cannot be undone.'),
    actions: [
     TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
     FilledButton(
      onPressed: () {
       ref.read(readingPlanProvider.notifier).resetPlan();
       Navigator.pop(ctx);
      },
      style: FilledButton.styleFrom(backgroundColor: AppColors.error),
      child: const Text('Reset'),
     ),
    ],
   ),
  );
 }
}

// ══════════════════════════════════════════════════════════════════
// Plan Selector (no active plan)
// ══════════════════════════════════════════════════════════════════

class _PlanSelector extends ConsumerWidget {
 final bool isDark;
 const _PlanSelector({required this.isDark});

 @override
 Widget build(BuildContext context, WidgetRef ref) {
  final plans = ref.watch(predefinedPlansProvider);

  return ListView(
   padding: const EdgeInsets.all(16),
   children: [
    Padding(
     padding: const EdgeInsets.only(bottom: 20),
     child: Column(
      children: [
       Icon(Icons.auto_stories_rounded, size: 56, color: AppColors.primary.withOpacity(0.7)),
       const SizedBox(height: 12),
       Text(
        'Choose a Reading Plan',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
       ),
       const SizedBox(height: 6),
       Text(
        'Select a structured plan to complete the Quran',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary),
        textAlign: TextAlign.center,
       ),
      ],
     ),
    )
     .animate()
     .fadeIn(duration: 400.ms),
    ...plans.asMap().entries.map((entry) {
     final index = entry.key;
     final plan = entry.value;
     return _PlanOptionCard(
      plan: plan,
      isDark: isDark,
      onTap: () => ref.read(readingPlanProvider.notifier).startPlan(plan.id),
     )
      .animate(delay: (index * 100 + 200).ms)
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0, duration: 400.ms);
    }),
   ],
  );
 }
}

class _PlanOptionCard extends StatelessWidget {
 final ReadingPlan plan;
 final bool isDark;
 final VoidCallback onTap;

 const _PlanOptionCard({required this.plan, required this.isDark, required this.onTap});

 @override
 Widget build(BuildContext context) {
  return Padding(
   padding: const EdgeInsets.only(bottom: 14),
   child: Material(
    color: Colors.transparent,
    child: InkWell(
     onTap: onTap,
     borderRadius: BorderRadius.circular(16),
     child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(16),
       border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
       color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      ),
      child: Row(
       children: [
        Container(
         width: 56,
         height: 56,
         decoration: BoxDecoration(
          gradient: LinearGradient(
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
           colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(16),
         ),
         child: Center(
          child: Text(
           '${plan.totalDays}',
           style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
         ),
        ),
        const SizedBox(width: 16),
        Expanded(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Text(
            plan.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
           ),
           const SizedBox(height: 4),
           Text(
            plan.description,
            style: TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
           ),
           const SizedBox(height: 6),
           Text(
            '${plan.totalDays} days',
            style: TextStyle(fontSize: 12, color: AppColors.darkTextTertiary),
           ),
          ],
         ),
        ),
        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.darkTextTertiary),
       ],
      ),
     ),
    ),
   ),
  );
 }
}

// ══════════════════════════════════════════════════════════════════
// Plan Dashboard (active plan)
// ══════════════════════════════════════════════════════════════════

class _PlanDashboard extends ConsumerWidget {
 final ReadingPlanState state;
 final bool isDark;

 const _PlanDashboard({required this.state, required this.isDark});

 @override
 Widget build(BuildContext context, WidgetRef ref) {
  final plan = state.activePlan!;
  final notifier = ref.read(readingPlanProvider.notifier);
  final todayAssignment = ref.watch(todayAssignmentProvider);

  return ListView(
   padding: const EdgeInsets.all(16),
   children: [
    // Progress header
    _ProgressHeader(state: state, plan: plan, isDark: isDark)
     .animate()
     .fadeIn(duration: 300.ms),

    const SizedBox(height: 16),

    // Stats row
    Row(
     children: [
      Expanded(child: _StatCard(label: 'Completed', value: '${state.completedCount}', icon: Icons.check_circle_rounded, color: AppColors.success, isDark: isDark)),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(label: 'Remaining', value: '${state.remainingDays}', icon: Icons.schedule_rounded, color: AppColors.info, isDark: isDark)),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(label: 'Streak', value: '${state.streak}', icon: Icons.local_fire_department_rounded, color: AppColors.warning, isDark: isDark)),
     ],
    )
     .animate(delay: 100.ms)
     .fadeIn(duration: 300.ms),

    const SizedBox(height: 16),

    // Today's assignment
    if (todayAssignment != null)
     Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
       gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
       ),
       borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        const Row(
         children: [
          Icon(Icons.today_rounded, color: Colors.white70, size: 18),
          SizedBox(width: 8),
          Text('Today\'s Assignment', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
         ],
        ),
        const SizedBox(height: 10),
        Text(
         'Day ${todayAssignment.dayNumber}: ${todayAssignment.label}',
         style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
         todayAssignment.range,
         style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontFamily: AppTheme.latinFontFamily),
        ),
        const SizedBox(height: 14),
        SizedBox(
         width: double.infinity,
         child: FilledButton.icon(
          onPressed: () => context.push('/quran/${todayAssignment.startSurah}'),
          icon: const Icon(Icons.menu_book_rounded, size: 18),
          label: const Text('Start Reading'),
          style: FilledButton.styleFrom(
           backgroundColor: Colors.white,
           foregroundColor: AppColors.primary,
           padding: const EdgeInsets.symmetric(vertical: 12),
          ),
         ),
        ),
       ],
      ),
     )
      .animate(delay: 200.ms)
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.08, end: 0, duration: 300.ms),

    const SizedBox(height: 20),

    // Reminder settings
    _ReminderSection(state: state, notifier: notifier, isDark: isDark),

    const SizedBox(height: 20),

    // Calendar-style progress view
    Text(
     'Progress Calendar',
     style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
    const SizedBox(height: 12),
    _CalendarGrid(state: state, plan: plan, isDark: isDark),

    const SizedBox(height: 20),

    // Day list
    Text(
     'All Assignments',
     style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
    const SizedBox(height: 12),
    ...plan.assignments.map((assignment) {
     final completed = state.isDayCompleted(plan.id, assignment.dayNumber);
     return _DayListItem(
      assignment: assignment,
      completed: completed,
      isDark: isDark,
      onTap: completed
       ? null
       : () => notifier.toggleDayCompletion(plan.id, assignment.dayNumber),
      onNavigate: () => context.push('/quran/${assignment.startSurah}'),
     );
    }),
    const SizedBox(height: 32),
   ],
  );
 }
}

// ── Progress Header ──────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
 final ReadingPlanState state;
 final ReadingPlan plan;
 final bool isDark;

 const _ProgressHeader({required this.state, required this.plan, required this.isDark});

 @override
 Widget build(BuildContext context) {
  return Container(
   padding: const EdgeInsets.all(20),
   decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
   ),
   child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     Row(
      children: [
       Expanded(
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
          Text(
           plan.name,
           style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(plan.description, style: TextStyle(fontSize: 13, color: AppColors.darkTextSecondary)),
         ],
        ),
       ),
       Text(
        '${(state.progressPercent * 100).toInt()}%',
        style: TextStyle(
         fontSize: 28,
         fontWeight: FontWeight.w800,
         color: AppColors.primary,
        ),
       ),
      ],
     ),
     const SizedBox(height: 14),
     ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
       value: state.progressPercent,
       minHeight: 10,
       backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
       valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
     ),
     const SizedBox(height: 8),
     Text(
      '${state.completedCount} of ${plan.totalDays} days completed',
      style: TextStyle(fontSize: 12, color: AppColors.darkTextTertiary),
     ),
    ],
   ),
  );
 }
}

// ── Stat Card ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
 final String label;
 final String value;
 final IconData icon;
 final Color color;
 final bool isDark;

 const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.isDark});

 @override
 Widget build(BuildContext context) {
  return Container(
   padding: const EdgeInsets.all(14),
   decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
   ),
   child: Column(
    children: [
     Icon(icon, color: color, size: 20),
     const SizedBox(height: 6),
     Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
     const SizedBox(height: 2),
     Text(label, style: TextStyle(fontSize: 11, color: AppColors.darkTextTertiary)),
    ],
   ),
  );
 }
}

// ── Reminder Section ──────────────────────────────────────────────

class _ReminderSection extends StatelessWidget {
 final ReadingPlanState state;
 final ReadingPlanNotifier notifier;
 final bool isDark;

 const _ReminderSection({required this.state, required this.notifier, required this.isDark});

 @override
 Widget build(BuildContext context) {
  return Container(
   padding: const EdgeInsets.all(16),
   decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
   ),
   child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
     Row(
      children: [
       Icon(Icons.notifications_active_rounded, size: 18, color: AppColors.secondary),
       const SizedBox(width: 8),
       Text('Reading Reminder', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
     ),
     const SizedBox(height: 12),
     Wrap(
      spacing: 8,
      children: [
       ChoiceChip(
        label: const Text('Morning', style: TextStyle(fontSize: 12)),
        selected: state.reminder == PlanReminder.morning,
        onSelected: (_) => notifier.setReminder(PlanReminder.morning),
        avatar: Icon(Icons.wb_sunny_rounded, size: 16, color: state.reminder == PlanReminder.morning ? AppColors.warning : AppColors.darkTextTertiary),
        selectedColor: AppColors.warning.withOpacity(0.12),
       ),
       ChoiceChip(
        label: const Text('Evening', style: TextStyle(fontSize: 12)),
        selected: state.reminder == PlanReminder.evening,
        onSelected: (_) => notifier.setReminder(PlanReminder.evening),
        avatar: Icon(Icons.nightlight_round_rounded, size: 16, color: state.reminder == PlanReminder.evening ? AppColors.info : AppColors.darkTextTertiary),
        selectedColor: AppColors.info.withOpacity(0.12),
       ),
       ChoiceChip(
        label: const Text('Off', style: TextStyle(fontSize: 12)),
        selected: state.reminder == PlanReminder.none,
        onSelected: (_) => notifier.setReminder(PlanReminder.none),
       ),
      ],
     ),
    ],
   ),
  );
 }
}

// ── Calendar Grid ────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
 final ReadingPlanState state;
 final ReadingPlan plan;
 final bool isDark;

 const _CalendarGrid({required this.state, required this.plan, required this.isDark});

 @override
 Widget build(BuildContext context) {
  final completedSet = state.completedDays;
  // Determine grid columns: 7 for 7-day plan, 10 for 30-day, 10 for 60-day
  final columns = plan.totalDays <= 7 ? 7 : 10;
  final rows = (plan.totalDays / columns).ceil();

  return Container(
   padding: const EdgeInsets.all(12),
   decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
   ),
   child: Column(
    children: List.generate(rows, (row) {
     final startIdx = row * columns;
     final endIdx = (startIdx + columns > plan.totalDays) ? plan.totalDays : startIdx + columns;

     return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
       children: List.generate(endIdx - startIdx, (col) {
        final dayNum = startIdx + col + 1;
        final completed = completedSet.contains('${plan.id}:$dayNum');
        final isCurrent = dayNum == state.currentDay;

        return Expanded(
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          child: AspectRatio(
           aspectRatio: 1,
           child: Container(
            decoration: BoxDecoration(
             color: completed
              ? AppColors.success
              : isCurrent
               ? AppColors.primary.withOpacity(0.2)
               : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
             borderRadius: BorderRadius.circular(8),
             border: isCurrent && !completed
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
            ),
            child: Center(
             child: Text(
              '$dayNum',
              style: TextStyle(
               fontSize: plan.totalDays > 30 ? 10 : 13,
               fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
               color: completed
                ? Colors.white
                : isCurrent
                 ? AppColors.primary
                 : AppColors.darkTextTertiary,
              ),
             ),
            ),
           ),
          ),
         ),
        );
       }),
      ),
     );
    }),
   ),
  );
 }
}

// ── Day List Item ─────────────────────────────────────────────────

class _DayListItem extends StatelessWidget {
 final DailyAssignment assignment;
 final bool completed;
 final bool isDark;
 final VoidCallback? onTap;
 final VoidCallback onNavigate;

 const _DayListItem({
  required this.assignment,
  required this.completed,
  required this.isDark,
  required this.onTap,
  required this.onNavigate,
 });

 @override
 Widget build(BuildContext context) {
  return Padding(
   padding: const EdgeInsets.only(bottom: 8),
   child: Material(
    color: Colors.transparent,
    child: InkWell(
     onTap: onTap,
     borderRadius: BorderRadius.circular(12),
     child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(12),
       border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 0.5),
       color: completed
        ? AppColors.success.withOpacity(0.06)
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      ),
      child: Row(
       children: [
        // Day number
        Container(
         width: 36,
         height: 36,
         decoration: BoxDecoration(
          color: completed
           ? AppColors.success
           : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
         ),
         child: Center(
          child: completed
           ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
           : Text(
            '${assignment.dayNumber}',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
           ),
         ),
        ),
        const SizedBox(width: 12),
        // Assignment info
        Expanded(
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Text(
            assignment.label,
            style: TextStyle(
             fontSize: 13,
             fontWeight: FontWeight.w600,
             decoration: completed ? TextDecoration.lineThrough : null,
             color: completed
              ? AppColors.darkTextTertiary
              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
           ),
           const SizedBox(height: 2),
           Text(
            assignment.range,
            style: TextStyle(fontSize: 11, color: AppColors.darkTextTertiary, fontFamily: AppTheme.latinFontFamily),
           ),
          ],
         ),
        ),
        // Navigate button
        IconButton(
         icon: const Icon(Icons.arrow_outward_rounded, size: 18),
         color: AppColors.primary,
         onPressed: onNavigate,
         tooltip: 'Read this section',
        ),
       ],
      ),
     ),
    ),
   ),
  );
 }
}
