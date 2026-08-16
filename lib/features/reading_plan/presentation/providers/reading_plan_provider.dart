import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

// ── Models ──────────────────────────────────────────────────────────

enum PlanReminder { morning, evening, none }

class DailyAssignment {
 final int dayNumber;
 final int startSurah;
 final int startAyah;
 final int endSurah;
 final int endAyah;
 final String label;

 const DailyAssignment({
  required this.dayNumber,
  required this.startSurah,
  required this.startAyah,
  required this.endSurah,
  required this.endAyah,
  required this.label,
 });

 String get range => 'Surah $startSurah:$startAyah – $endSurah:$endAyah';
}

class ReadingPlan {
 final String id;
 final String name;
 final String description;
 final int totalDays;
 final List<DailyAssignment> assignments;

 const ReadingPlan({
  required this.id,
  required this.name,
  required this.description,
  required this.totalDays,
  required this.assignments,
 });
}

class DayCompletion {
 final DateTime date;
 final String planId;
 final int dayNumber;

 const DayCompletion({
  required this.date,
  required this.planId,
  required this.dayNumber,
 });
}

// ════════════════════════════════════════════════════════════════════
// Pre-defined plans
// ════════════════════════════════════════════════════════════════════

/// 30-day plan: 1 juz per day
List<DailyAssignment> _generate30DayPlan() {
 final List<DailyAssignment> assignments = [];
 final juzBreakdown = AppConstants.juzBreakdown;

 for (int i = 0; i < 30; i++) {
  final start = juzBreakdown[i];
  final end = i < 29 ? juzBreakdown[i + 1] : {'surah': 114, 'ayah': 6};

  // End ayah is one before the next juz start
  final actualEndAyah = end['ayah']! - 1;
  final actualEndSurah = i < 29 ? end['surah']! : 114;
  final adjustedEndAyah = actualEndAyah <= 0 ? 6 : actualEndAyah;

  assignments.add(DailyAssignment(
   dayNumber: i + 1,
   startSurah: start['surah']!,
   startAyah: start['ayah']!,
   endSurah: actualEndSurah,
   endAyah: adjustedEndAyah,
   label: 'Juz ${i + 1}',
  ));
 }
 return assignments;
}

/// 60-day plan: half juz per day
List<DailyAssignment> _generate60DayPlan() {
 final plan30 = _generate30DayPlan();
 final List<DailyAssignment> assignments = [];

 for (int i = 0; i < plan30.length; i++) {
  final juz = plan30[i];
  // Approximate midpoint
  final midSurah = (juz.startSurah + juz.endSurah) ~/ 2;
  final midAyah = (juz.startSurah == juz.endSurah)
   ? (juz.startAyah + juz.endAyah) ~/ 2
   : (juz.startSurah == midSurah ? juz.startAyah : 1);

  assignments.add(DailyAssignment(
   dayNumber: i * 2 + 1,
   startSurah: juz.startSurah,
   startAyah: juz.startAyah,
   endSurah: midSurah,
   endAyah: midAyah,
   label: 'Juz ${i + 1} (Part 1)',
  ));
  assignments.add(DailyAssignment(
   dayNumber: i * 2 + 2,
   startSurah: midSurah,
   startAyah: midAyah + 1,
   endSurah: juz.endSurah,
   endAyah: juz.endAyah,
   label: 'Juz ${i + 1} (Part 2)',
  ));
 }
 return assignments;
}

/// 7-day plan: key surahs summary
const List<DailyAssignment> _7DayPlan = [
 DailyAssignment(dayNumber: 1, startSurah: 1, startAyah: 1, endSurah: 2, endAyah: 141, label: 'Day 1: Al-Fatiha & Al-Baqarah (Part 1)'),
 DailyAssignment(dayNumber: 2, startSurah: 2, startAyah: 142, endSurah: 3, endAyah: 92, label: 'Day 2: Al-Baqarah (Part 2) & Aal-e-Imran'),
 DailyAssignment(dayNumber: 3, startSurah: 4, startAyah: 1, endSurah: 6, endAyah: 151, label: 'Day 3: An-Nisa, Al-Maida, Al-Anam'),
 DailyAssignment(dayNumber: 4, startSurah: 7, startAyah: 1, endSurah: 18, endAyah: 110, label: 'Day 4: Al-Araf through Al-Kahf'),
 DailyAssignment(dayNumber: 5, startSurah: 19, startAyah: 1, endSurah: 36, endAyah: 83, label: 'Day 5: Maryam through Ya-Sin'),
 DailyAssignment(dayNumber: 6, startSurah: 37, startAyah: 1, endSurah: 67, endAyah: 30, label: 'Day 6: As-Saffat through Al-Mulk'),
 DailyAssignment(dayNumber: 7, startSurah: 68, startAyah: 1, endSurah: 114, endAyah: 6, label: 'Day 7: Al-Qalam through An-Nas'),
];

final List<ReadingPlan> kPredefinedPlans = [
 ReadingPlan(
  id: '30day',
  name: '30-Day Khatmah',
  description: 'Complete the Quran in 30 days — 1 Juz per day',
  totalDays: 30,
  assignments: _generate30DayPlan(),
 ),
 ReadingPlan(
  id: '60day',
  name: '60-Day Khatmah',
  description: 'Complete the Quran in 60 days — half Juz per day',
  totalDays: 60,
  assignments: _generate60DayPlan(),
 ),
 ReadingPlan(
  id: '7day',
  name: '7-Day Overview',
  description: 'Read key sections of the Quran in one week',
  totalDays: 7,
  assignments: _7DayPlan,
 ),
];

// ── State ──────────────────────────────────────────────────────────

class ReadingPlanState {
 final String? activePlanId;
 final int currentDay;
 final Set<String> completedDays; // "planId:dayNumber"
 final List<DayCompletion> completionHistory;
 final int streak;
 final PlanReminder reminder;
 final DateTime? planStartDate;

 const ReadingPlanState({
  this.activePlanId,
  this.currentDay = 1,
  this.completedDays = const {},
  this.completionHistory = const [],
  this.streak = 0,
  this.reminder = PlanReminder.none,
  this.planStartDate,
 });

 ReadingPlan? get activePlan =>
  kPredefinedPlans.where((p) => p.id == activePlanId).firstOrNull;

 int get completedCount => completedDays.length;
 double get progressPercent => activePlan != null && activePlan!.totalDays > 0
  ? (completedCount / activePlan!.totalDays).clamp(0.0, 1.0)
  : 0.0;
 int get remainingDays => activePlan != null
  ? activePlan!.totalDays - completedCount
  : 0;

 bool isDayCompleted(String planId, int day) =>
  completedDays.contains('$planId:$day');

 ReadingPlanState copyWith({
  String? activePlanId,
  int? currentDay,
  Set<String>? completedDays,
  List<DayCompletion>? completionHistory,
  int? streak,
  PlanReminder? reminder,
  DateTime? planStartDate,
  bool clearAll = false,
 }) {
  return ReadingPlanState(
   activePlanId: clearAll ? null : (activePlanId ?? this.activePlanId),
   currentDay: clearAll ? 1 : (currentDay ?? this.currentDay),
   completedDays: clearAll ? {} : (completedDays ?? this.completedDays),
   completionHistory: clearAll ? [] : (completionHistory ?? this.completionHistory),
   streak: clearAll ? 0 : (streak ?? this.streak),
   reminder: clearAll ? PlanReminder.none : (reminder ?? this.reminder),
   planStartDate: clearAll ? null : (planStartDate ?? this.planStartDate),
  );
 }
}

// ── Notifier ───────────────────────────────────────────────────────

class ReadingPlanNotifier extends StateNotifier<ReadingPlanState> {
 ReadingPlanNotifier() : super(const ReadingPlanState());

 void startPlan(String planId) {
  state = ReadingPlanState(
   activePlanId: planId,
   currentDay: 1,
   completedDays: {},
   completionHistory: [],
   streak: 0,
   reminder: state.reminder,
   planStartDate: DateTime.now(),
  );
 }

 void toggleDayCompletion(String planId, int day) {
  final key = '$planId:$day';
  final updated = Set<String>.from(state.completedDays);

  if (updated.contains(key)) {
   updated.remove(key);
   state = state.copyWith(
    completedDays: updated,
    streak: state.streak > 0 ? state.streak - 1 : 0,
   );
  } else {
   updated.add(key);
   final newStreak = state.streak + 1;
   state = state.copyWith(
    completedDays: updated,
    completionHistory: [
     ...state.completionHistory,
     DayCompletion(
      date: DateTime.now(),
      planId: planId,
      dayNumber: day,
     ),
    ],
    streak: newStreak,
    currentDay: day + 1,
   );
  }
 }

 void setReminder(PlanReminder reminder) {
  state = state.copyWith(reminder: reminder);
 }

 void resetPlan() {
  state = state.copyWith(clearAll: true);
 }
}

// ── Providers ──────────────────────────────────────────────────────

final readingPlanProvider = StateNotifierProvider<ReadingPlanNotifier, ReadingPlanState>(
 (ref) => ReadingPlanNotifier(),
);

final predefinedPlansProvider = Provider<List<ReadingPlan>>((ref) => kPredefinedPlans);

final todayAssignmentProvider = Provider<DailyAssignment?>((ref) {
 final state = ref.watch(readingPlanProvider);
 final plan = state.activePlan;
 if (plan == null) return null;
 if (state.currentDay > plan.totalDays) return null;
 return plan.assignments.where((a) => a.dayNumber == state.currentDay).firstOrNull;
});
