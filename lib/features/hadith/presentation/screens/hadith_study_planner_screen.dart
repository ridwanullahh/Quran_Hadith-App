import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Study Plan Model
// ═══════════════════════════════════════════════════════════════════

class StudyPlan {
  final String id;
  final String title;
  final String description;
  final String collection;
  final int startBook;
  final int endBook;
  final int hadithsPerDay;
  final int totalDays;
  final DateTime startDate;
  final int completedBooks;
  final bool isActive;
  final bool isCompleted;

  const StudyPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.collection,
    required this.startBook,
    required this.endBook,
    required this.hadithsPerDay,
    required this.totalDays,
    required this.startDate,
    this.completedBooks = 0,
    this.isActive = false,
    this.isCompleted = false,
  });

  double get progress {
    final totalBooks = endBook - startBook + 1;
    if (totalBooks == 0) return 0;
    return (completedBooks / totalBooks).clamp(0.0, 1.0);
  }

  int get currentBook => (startBook + completedBooks).clamp(startBook, endBook);

  int get daysRemaining {
    final remainingBooks = (endBook - startBook + 1) - completedBooks;
    return (remainingBooks * 10 ~/ hadithsPerDay).clamp(0, totalDays);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'collection': collection,
        'startBook': startBook,
        'endBook': endBook,
        'hadithsPerDay': hadithsPerDay,
        'totalDays': totalDays,
        'startDate': startDate.toIso8601String(),
        'completedBooks': completedBooks,
        'isActive': isActive,
        'isCompleted': isCompleted,
      };

  factory StudyPlan.fromMap(String id, Map<dynamic, dynamic> map) {
    return StudyPlan(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      collection: map['collection'] as String? ?? 'bukhari',
      startBook: map['startBook'] as int? ?? 1,
      endBook: map['endBook'] as int? ?? 7,
      hadithsPerDay: map['hadithsPerDay'] as int? ?? 10,
      totalDays: map['totalDays'] as int? ?? 30,
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
      completedBooks: map['completedBooks'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? false,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  StudyPlan copyWith({
    int? completedBooks,
    bool? isActive,
    bool? isCompleted,
  }) {
    return StudyPlan(
      id: id,
      title: title,
      description: description,
      collection: collection,
      startBook: startBook,
      endBook: endBook,
      hadithsPerDay: hadithsPerDay,
      totalDays: totalDays,
      startDate: startDate,
      completedBooks: completedBooks ?? this.completedBooks,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Study Planner Screen
// ═══════════════════════════════════════════════════════════════════

class HadithStudyPlannerScreen extends StatefulWidget {
  const HadithStudyPlannerScreen({super.key});

  @override
  State<HadithStudyPlannerScreen> createState() => _HadithStudyPlannerScreenState();
}

class _HadithStudyPlannerScreenState extends State<HadithStudyPlannerScreen> {
  List<StudyPlan> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() {
    try {
      final box = Hive.box('hadith_plans');
      final entries = <StudyPlan>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          entries.add(StudyPlan.fromMap(key as String, val));
        }
      }
      entries.sort((a, b) => b.startDate.compareTo(a.startDate));
      setState(() {
        _plans = entries;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePlan(StudyPlan plan) async {
    try {
      final box = Hive.box('hadith_plans');
      await box.put(plan.id, plan.toMap());
      _loadPlans();
    } catch (_) {}
  }

  Future<void> _deletePlan(String id) async {
    try {
      final box = Hive.box('hadith_plans');
      await box.delete(id);
      _loadPlans();
    } catch (_) {}
  }

  void _showCreateSheet() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String collection = 'bukhari';
    int startBook = 1;
    int endBook = 7;
    int hadithsPerDay = 10;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return DraggableScrollableSheet(
                initialChildSize: 0.75,
                maxChildSize: 0.9,
                minChildSize: 0.5,
                expand: false,
                builder: (ctx, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.darkBorder,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                          ),
                          Text('Create Study Plan',
                              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Plan Name',
                              hintText: 'e.g., Bukhari in 90 Days',
                            ),
                            onChanged: (v) => title = v,
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Description (optional)',
                            ),
                            onChanged: (v) => description = v,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          Text('Collection',
                              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['bukhari', 'muslim', 'tirmidhi', 'abudawud', 'nasai', 'ibnmajah']
                                .map((c) {
                              final label = _formatCollectionName(c);
                              final isSelected = collection == c;
                              return ChoiceChip(
                                label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : null)),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                showCheckmark: false,
                                onSelected: (_) => setSheetState(() => collection = c),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Start Book',
                                  ),
                                  initialValue: '1',
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => startBook = int.tryParse(v) ?? 1,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'End Book',
                                  ),
                                  initialValue: '7',
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => endBook = int.tryParse(v) ?? 7,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Hadiths per Day',
                              hintText: '10',
                            ),
                            initialValue: '10',
                            keyboardType: TextInputType.number,
                            onChanged: (v) => hadithsPerDay = int.tryParse(v) ?? 10,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                if (title.isEmpty) return;
                                final totalBooks = endBook - startBook + 1;
                                final plan = StudyPlan(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  title: title,
                                  description: description,
                                  collection: collection,
                                  startBook: startBook,
                                  endBook: endBook,
                                  hadithsPerDay: hadithsPerDay,
                                  totalDays: totalBooks * 10 ~/ hadithsPerDay,
                                  startDate: DateTime.now(),
                                  isActive: true,
                                );
                                _savePlan(plan);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Create Plan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatCollectionName(String id) {
    const names = {
      'bukhari': 'Bukhari',
      'muslim': 'Muslim',
      'tirmidhi': 'Tirmidhi',
      'abudawud': 'Abu Dawud',
      'nasai': "Nasa'i",
      'ibnmajah': 'Ibn Majah',
    };
    return names[id] ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _plans.isEmpty
              ? _buildEmptyState(theme, isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _plans.length,
                  itemBuilder: (context, index) {
                    final plan = _plans[index];
                    return _PlanCard(
                      plan: plan,
                      index: index,
                      isDark: isDark,
                      onIncrement: () {
                        final updated = plan.copyWith(completedBooks: plan.completedBooks + 1);
                        if (updated.completedBooks >= (plan.endBook - plan.startBook + 1)) {
                          _savePlan(updated.copyWith(isCompleted: true, isActive: false));
                        } else {
                          _savePlan(updated);
                        }
                      },
                      onDelete: () => _deletePlan(plan.id),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.event_note_rounded,
                size: 36,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Study Plans Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a plan to read through hadith collections systematically. Tap the + button to get started.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Plan Card
// ═══════════════════════════════════════════════════════════════════

class _PlanCard extends StatelessWidget {
  final StudyPlan plan;
  final int index;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.index,
    required this.isDark,
    required this.onIncrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(plan.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: plan.isCompleted
                          ? AppColors.hifdhGreen.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      plan.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.auto_stories_rounded,
                      size: 20,
                      color: plan.isCompleted ? AppColors.hifdhGreen : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${_formatCollectionName(plan.collection)} · Books ${plan.startBook}–${plan.endBook}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (plan.isActive && !plan.isCompleted)
                    TextButton.icon(
                      onPressed: onIncrement,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Done'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.hifdhGreen,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                ],
              ),

              // Progress
              if (plan.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  plan.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: plan.progress,
                        minHeight: 8,
                        backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        valueColor: AlwaysStoppedAnimation(
                          plan.isCompleted ? AppColors.hifdhGreen : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(plan.progress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: plan.isCompleted ? AppColors.hifdhGreen : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Stats row
              Row(
                children: [
                  _miniStat(context, Icons.menu_book_rounded, 'Current: Book ${plan.currentBook}'),
                  const SizedBox(width: 16),
                  _miniStat(context, Icons.schedule_rounded, '${plan.daysRemaining} days left'),
                  const SizedBox(width: 16),
                  _miniStat(context, Icons.speed_rounded, '${plan.hadithsPerDay}/day'),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms, duration: 400.ms).slideY(begin: 0.03, end: 0);
  }

  Widget _miniStat(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.darkTextTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.darkTextTertiary,
          ),
        ),
      ],
    );
  }

  String _formatCollectionName(String id) {
    const names = {
      'bukhari': 'Bukhari',
      'muslim': 'Muslim',
      'tirmidhi': 'Tirmidhi',
      'abudawud': 'Abu Dawud',
      'nasai': "Nasa'i",
      'ibnmajah': 'Ibn Majah',
    };
    return names[id] ?? id;
  }
}
