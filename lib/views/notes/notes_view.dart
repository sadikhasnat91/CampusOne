import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../controllers/productivity_controller.dart';
import '../../helpers/snackbar_helper.dart';
import '../../models/goal_item_model.dart';
import '../../models/habit_item_model.dart';
import '../../models/task_item_model.dart';
import '../../widgets/animation_widgets.dart';
import '../../widgets/empty_state_widget.dart';
import 'widgets/study_chart_widget.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showWeeklyChart = true;

  static const List<String> _tabs = ['Dashboard', 'Tasks', 'Habits', 'Goals'];
  static const List<IconData> _tabIcons = [
    Icons.dashboard_rounded,
    Icons.task_alt_rounded,
    Icons.loop_rounded,
    Icons.flag_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  // ─── ADD / EDIT TASK DIALOG ────────────────────────────────────────────────
  void _showAddTaskDialog(BuildContext ctx, ProductivityController ctrl,
      {TaskItemModel? existing}) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    String priority = existing?.priority ?? 'medium';
    String category = existing?.category ?? 'Study';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx2, setS) {
          final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
          final border = isDark ? const Color(0xFF1E2D42) : AppColors.lightSurfaceVariant;
          final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
          final textPrimary = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

          return Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx2).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  existing == null ? 'New Task' : 'Edit Task',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: _inputDeco('Task Title (e.g. Study Chapter 5)', isDark, border, accent),
                ),
                const SizedBox(height: 12),
                Text('Priority', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: ['high', 'medium', 'low'].map((p) {
                    final color = _priorityColor(p);
                    final selected = priority == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setS(() => priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? color.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? color : border, width: selected ? 1.5 : 1),
                          ),
                          child: Text(
                            p.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? color : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text('Category', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: ['Study', 'Academic', 'Health', 'Personal', 'Project'].map((c) {
                    final selected = category == c;
                    return GestureDetector(
                      onTap: () => setS(() => category = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? accent.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? accent : border, width: selected ? 1.5 : 1),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? accent : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty) {
                        final task = TaskItemModel(
                          id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          category: category,
                          priority: priority,
                          dueDate: existing?.dueDate ?? DateTime.now().add(const Duration(hours: 4)),
                          isCompleted: existing?.isCompleted ?? false,
                        );
                        if (existing == null) {
                          ctrl.addTask(task);
                        } else {
                          ctrl.addTask(task);
                        }
                        Navigator.pop(ctx2);
                        SnackbarHelper.showSuccess(ctx, existing == null ? 'Task Added!' : 'Task Updated!');
                      }
                    },
                    child: Text(existing == null ? 'Add Task' : 'Save Changes', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── ADD / EDIT HABIT DIALOG ───────────────────────────────────────────────
  void _showAddEditHabitDialog(BuildContext ctx, ProductivityController ctrl, [HabitItemModel? existing]) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    int targetDays = existing?.targetDaysPerWeek ?? 5;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx2, setS) {
          final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
          final border = isDark ? const Color(0xFF1E2D42) : AppColors.lightSurfaceVariant;
          final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
          final textPrimary = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

          return Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(bCtx2).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 36, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(4))),
                ),
                const SizedBox(height: 18),
                Text(
                  existing == null ? 'Create New Habit' : 'Edit Habit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: _inputDeco('Habit Title (e.g. 📚 Read 30 Mins Daily)', isDark, border, accent),
                ),
                const SizedBox(height: 14),
                Text('Target Days per Week: $targetDays days', style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(7, (i) {
                    final days = i + 1;
                    final selected = targetDays == days;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setS(() => targetDays = days),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? accent.withOpacity(0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: selected ? accent : border, width: selected ? 1.5 : 1),
                          ),
                          child: Text('$days d', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? accent : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant))),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty) {
                        final habit = HabitItemModel(
                          id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          streakCount: existing?.streakCount ?? 0,
                          completedDates: existing?.completedDates ?? [],
                          targetDaysPerWeek: targetDays,
                        );
                        if (existing == null) {
                          ctrl.addHabit(habit);
                        } else {
                          ctrl.updateHabit(habit);
                        }
                        Navigator.pop(bCtx2);
                        SnackbarHelper.showSuccess(ctx, existing == null ? 'Habit Created!' : 'Habit Updated!');
                      }
                    },
                    child: Text(existing == null ? 'Save Habit' : 'Update Habit', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── ADD / EDIT GOAL DIALOG ────────────────────────────────────────────────
  void _showAddEditGoalDialog(BuildContext ctx, ProductivityController ctrl, [GoalItemModel? existing]) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final targetHoursCtrl = TextEditingController(text: existing?.targetHours.toString() ?? '30');
    final completedHoursCtrl = TextEditingController(text: existing?.completedHours.toString() ?? '0');
    String category = existing?.category ?? 'Academic';
    DateTime deadline = existing?.deadline ?? DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx2, setS) {
          final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
          final border = isDark ? const Color(0xFF1E2D42) : AppColors.lightSurfaceVariant;
          final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
          final textPrimary = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

          return Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(bCtx2).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 36, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(4))),
                ),
                const SizedBox(height: 18),
                Text(
                  existing == null ? 'Create New Goal' : 'Edit Goal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: _inputDeco('Goal Title (e.g. Master Data Structures)', isDark, border, accent),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: targetHoursCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textPrimary),
                        decoration: _inputDeco('Target Hours (e.g. 40)', isDark, border, accent),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: completedHoursCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textPrimary),
                        decoration: _inputDeco('Done Hours (e.g. 10)', isDark, border, accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: category,
                        decoration: _inputDeco('Category', isDark, border, accent),
                        dropdownColor: isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
                        style: TextStyle(fontSize: 12, color: textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'Academic', child: Text('Academic')),
                          DropdownMenuItem(value: 'Study', child: Text('Study')),
                          DropdownMenuItem(value: 'Health', child: Text('Health')),
                          DropdownMenuItem(value: 'Personal', child: Text('Personal')),
                          DropdownMenuItem(value: 'Project', child: Text('Project')),
                        ],
                        onChanged: (v) => setS(() => category = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: bCtx2,
                            initialDate: deadline,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setS(() => deadline = picked);
                        },
                        child: InputDecorator(
                          decoration: _inputDeco('Deadline', isDark, border, accent),
                          child: Text('${deadline.day}/${deadline.month}/${deadline.year}', style: TextStyle(fontSize: 12, color: textPrimary)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty) {
                        final goal = GoalItemModel(
                          id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          targetHours: double.tryParse(targetHoursCtrl.text) ?? 30.0,
                          completedHours: double.tryParse(completedHoursCtrl.text) ?? 0.0,
                          deadline: deadline,
                          category: category,
                        );
                        if (existing == null) {
                          ctrl.addGoal(goal);
                        } else {
                          ctrl.updateGoal(goal);
                        }
                        Navigator.pop(bCtx2);
                        SnackbarHelper.showSuccess(ctx, existing == null ? 'Goal Created!' : 'Goal Updated!');
                      }
                    },
                    child: Text(existing == null ? 'Save Goal' : 'Update Goal', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDeco(String label, bool isDark, Color border, Color accent) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 12, color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant),
      filled: true,
      fillColor: isDark ? AppColors.darkSurface2 : AppColors.lightSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accent, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBackground;
    final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final textSecondary = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final cardColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark ? const Color(0xFF1E2D42) : AppColors.lightSurfaceVariant;

    final ctrl = Provider.of<ProductivityController>(context);

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) {
          final idx = _tabController.index;
          if (idx == 1) {
            return _AddFAB(label: 'Add Task', icon: Icons.add_task_rounded, onTap: () => _showAddTaskDialog(context, ctrl), isDark: isDark);
          } else if (idx == 2) {
            return _AddFAB(label: 'Add Habit', icon: Icons.loop_rounded, onTap: () => _showAddEditHabitDialog(context, ctrl), isDark: isDark);
          } else if (idx == 3) {
            return _AddFAB(label: 'Add Goal', icon: Icons.flag_rounded, onTap: () => _showAddEditGoalDialog(context, ctrl), isDark: isDark);
          }
          return const SizedBox.shrink();
        },
      ),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: bg,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Productivity Hub',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            actions: [
              AnimatedBuilder(
                animation: _tabController,
                builder: (_, __) {
                  final idx = _tabController.index;
                  IconData icon = Icons.add_task_rounded;
                  VoidCallback onTap = () => _showAddTaskDialog(context, ctrl);
                  if (idx == 2) {
                    icon = Icons.loop_rounded;
                    onTap = () => _showAddEditHabitDialog(context, ctrl);
                  } else if (idx == 3) {
                    icon = Icons.flag_rounded;
                    onTap = () => _showAddEditGoalDialog(context, ctrl);
                  }
                  if (idx == 0) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Material(
                      color: isDark ? AppColors.darkSurface1.withOpacity(0.7) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onTap,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(icon, size: 20, color: accent),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                indicatorColor: accent,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: accent,
                unselectedLabelColor: textSecondary,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                dividerColor: border,
                tabs: List.generate(
                  _tabs.length,
                  (i) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_tabIcons[i], size: 14),
                        const SizedBox(width: 5),
                        Text(_tabs[i]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboard(context, ctrl, isDark, accent, textPrimary, textSecondary, cardColor, border),
            _buildTasksTab(context, ctrl, isDark, accent, textPrimary, textSecondary, cardColor, border),
            _buildHabitsTab(context, ctrl, isDark, accent, textPrimary, textSecondary, cardColor, border),
            _buildGoalsTab(context, ctrl, isDark, accent, textPrimary, textSecondary, cardColor, border),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DASHBOARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDashboard(
    BuildContext context,
    ProductivityController ctrl,
    bool isDark,
    Color accent,
    Color textPrimary,
    Color textSecondary,
    Color cardColor,
    Color border,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedListItem(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _PomodoroCard(ctrl: ctrl, isDark: isDark),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedListItem(
            delay: const Duration(milliseconds: 60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _StatMiniCard(
                    icon: Icons.task_alt_rounded,
                    label: 'Tasks Done',
                    value: '${ctrl.completedTasksToday}/${ctrl.totalTasksToday}',
                    color: accent,
                    isDark: isDark,
                    cardColor: cardColor,
                    border: border,
                  ),
                  const SizedBox(width: 10),
                  _StatMiniCard(
                    icon: Icons.schedule_rounded,
                    label: 'Study hrs',
                    value: '${ctrl.totalStudyHoursThisWeek.toStringAsFixed(1)}h',
                    color: isDark ? AppColors.darkTertiary : AppColors.lightTertiary,
                    isDark: isDark,
                    cardColor: cardColor,
                    border: border,
                  ),
                  const SizedBox(width: 10),
                  _StatMiniCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Best Streak',
                    value: ctrl.habits.isNotEmpty ? '${ctrl.habits.first.streakCount}🔥' : '0',
                    color: AppColors.warning,
                    isDark: isDark,
                    cardColor: cardColor,
                    border: border,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedListItem(
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SectionLabel(label: 'Study Statistics', isDark: isDark),
                      const Spacer(),
                      _SegmentToggle(
                        selected: _showWeeklyChart,
                        isDark: isDark,
                        accent: accent,
                        onChanged: (v) => setState(() => _showWeeklyChart = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _showWeeklyChart ? 'Hours studied per day this week' : 'Monthly study hours overview',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant),
                        ),
                        const SizedBox(height: 14),
                        StudyChartWidget(
                          weeklyData: ctrl.weeklyStudyHours,
                          monthlyData: ctrl.monthlyStudyHours,
                          showWeekly: _showWeeklyChart,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TASKS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTasksTab(
    BuildContext context,
    ProductivityController ctrl,
    bool isDark,
    Color accent,
    Color textPrimary,
    Color textSecondary,
    Color cardColor,
    Color border,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedListItem(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _TaskProgressBanner(
                ctrl: ctrl,
                isDark: isDark,
                accent: accent,
                textSecondary: textSecondary,
                cardColor: cardColor,
                border: border,
              ),
            ),
          ),
        ),
        if (ctrl.pendingTasks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: AnimatedListItem(
              delay: const Duration(milliseconds: 50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: _SectionLabel(label: 'Pending Tasks', isDark: isDark),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => AnimatedListItem(
                  delay: Duration(milliseconds: 50 * i),
                  child: _TaskCard(
                    task: ctrl.pendingTasks[i],
                    ctrl: ctrl,
                    isDark: isDark,
                    accent: accent,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    cardColor: cardColor,
                    border: border,
                    priorityColor: _priorityColor,
                    onEdit: () => _showAddTaskDialog(context, ctrl, existing: ctrl.pendingTasks[i]),
                  ),
                ),
                childCount: ctrl.pendingTasks.length,
              ),
            ),
          ),
        ],
        if (ctrl.completedTasks.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: _SectionLabel(label: 'Completed', isDark: isDark),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => AnimatedListItem(
                  delay: Duration(milliseconds: 30 * i),
                  child: _TaskCard(
                    task: ctrl.completedTasks[i],
                    ctrl: ctrl,
                    isDark: isDark,
                    accent: accent,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    cardColor: cardColor,
                    border: border,
                    priorityColor: _priorityColor,
                    onEdit: () => _showAddTaskDialog(context, ctrl, existing: ctrl.completedTasks[i]),
                  ),
                ),
                childCount: ctrl.completedTasks.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HABITS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHabitsTab(
    BuildContext context,
    ProductivityController ctrl,
    bool isDark,
    Color accent,
    Color textPrimary,
    Color textSecondary,
    Color cardColor,
    Color border,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedListItem(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'Daily Habit Tracker', isDark: isDark),
                      const SizedBox(height: 4),
                      Text('Tap a habit to mark it done for today', style: TextStyle(fontSize: 12, color: textSecondary)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAddEditHabitDialog(context, ctrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 14, color: accent),
                          const SizedBox(width: 4),
                          Text('Add Habit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (ctrl.habits.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyStateWidget(
                title: 'No Habits Yet',
                description: 'Tap below to create your first daily habit!',
                icon: Icons.loop_rounded,
                actionLabel: 'Add Habit',
                onAction: () => _showAddEditHabitDialog(context, ctrl),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final habit = ctrl.habits[i];
                  final done = habit.isCompletedToday;
                  return AnimatedListItem(
                    delay: Duration(milliseconds: 60 * i),
                    child: _HabitCard(
                      habit: habit,
                      done: done,
                      isDark: isDark,
                      accent: accent,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      cardColor: cardColor,
                      border: border,
                      onTap: () {
                        ctrl.toggleHabitToday(habit);
                        SnackbarHelper.showSuccess(
                          context,
                          done ? 'Habit marked incomplete.' : '🔥 ${habit.title} completed!',
                        );
                      },
                      onEdit: () => _showAddEditHabitDialog(context, ctrl, habit),
                      onDelete: () => ctrl.deleteHabit(habit.id),
                    ),
                  );
                },
                childCount: ctrl.habits.length,
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOALS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGoalsTab(
    BuildContext context,
    ProductivityController ctrl,
    bool isDark,
    Color accent,
    Color textPrimary,
    Color textSecondary,
    Color cardColor,
    Color border,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedListItem(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  _SectionLabel(label: 'Goal Tracking', isDark: isDark),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showAddEditGoalDialog(context, ctrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 14, color: accent),
                          const SizedBox(width: 4),
                          Text('Add Goal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (ctrl.goals.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyStateWidget(
                title: 'No Goals Set',
                description: 'Tap below to set your first target goal!',
                icon: Icons.flag_rounded,
                actionLabel: 'Add Goal',
                onAction: () => _showAddEditGoalDialog(context, ctrl),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final goal = ctrl.goals[i];
                  return AnimatedListItem(
                    delay: Duration(milliseconds: 60 * i),
                    child: _GoalCard(
                      goal: goal,
                      isDark: isDark,
                      accent: accent,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      cardColor: cardColor,
                      border: border,
                      onAddProgress: () {
                        ctrl.addGoalProgress(goal.id, 1.0);
                        SnackbarHelper.showSuccess(context, 'Progress updated (+1h)!');
                      },
                      onEdit: () => _showAddEditGoalDialog(context, ctrl, goal),
                      onDelete: () => ctrl.deleteGoal(goal.id),
                    ),
                  );
                },
                childCount: ctrl.goals.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Pomodoro Card ────────────────────────────────────────────────────────────

class _PomodoroCard extends StatelessWidget {
  final ProductivityController ctrl;
  final bool isDark;
  const _PomodoroCard({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B1FA2).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timer_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Pomodoro Focus Timer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              PulsingDot(
                color: ctrl.isPomodoroRunning ? const Color(0xFF69F0AE) : Colors.white54,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ctrl.pomodoroProgress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctrl.pomodoroDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      ctrl.isPomodoroRunning ? 'Focusing' : 'Ready',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!ctrl.isPomodoroRunning)
                _TimerBtn(
                  icon: Icons.play_arrow_rounded,
                  label: 'Start',
                  onTap: ctrl.startPomodoro,
                )
              else
                _TimerBtn(
                  icon: Icons.pause_rounded,
                  label: 'Pause',
                  onTap: ctrl.pausePomodoro,
                  ghost: true,
                ),
              const SizedBox(width: 10),
              _TimerBtn(
                icon: Icons.refresh_rounded,
                label: 'Reset',
                onTap: ctrl.resetPomodoro,
                ghost: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '🏆 ${ctrl.completedPomodoros} sessions completed today',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool ghost;

  const _TimerBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.ghost = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: ghost ? Colors.white.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: ghost ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ghost ? Colors.white : const Color(0xFF4527A0)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ghost ? Colors.white : const Color(0xFF4527A0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Mini Card ───────────────────────────────────────────────────────────

class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final Color cardColor;
  final Color border;

  const _StatMiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.cardColor,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Segment Toggle ───────────────────────────────────────────────────────────

class _SegmentToggle extends StatelessWidget {
  final bool selected;
  final bool isDark;
  final Color accent;
  final ValueChanged<bool> onChanged;

  const _SegmentToggle({
    required this.selected,
    required this.isDark,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurfaceVariant;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Seg(label: 'Weekly', active: selected, accent: accent, onTap: () => onChanged(true), isDark: isDark),
          _Seg(label: 'Monthly', active: !selected, accent: accent, onTap: () => onChanged(false), isDark: isDark),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label;
  final bool active;
  final Color accent;
  final VoidCallback onTap;
  final bool isDark;
  const _Seg({required this.label, required this.active, required this.accent, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

// ─── Task Progress Banner ─────────────────────────────────────────────────────

class _TaskProgressBanner extends StatelessWidget {
  final ProductivityController ctrl;
  final bool isDark;
  final Color accent;
  final Color textSecondary;
  final Color cardColor;
  final Color border;

  const _TaskProgressBanner({
    required this.ctrl,
    required this.isDark,
    required this.accent,
    required this.textSecondary,
    required this.cardColor,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final pct = ctrl.taskCompletionRate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Today's Progress",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                ),
              ),
              const Spacer(),
              AnimatedCounter(
                target: pct.toInt(),
                suffix: '%',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: accent.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${ctrl.completedTasksToday} of ${ctrl.totalTasksToday} tasks completed',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Task Card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskItemModel task;
  final ProductivityController ctrl;
  final bool isDark;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardColor;
  final Color border;
  final Color Function(String) priorityColor;
  final VoidCallback onEdit;

  const _TaskCard({
    required this.task,
    required this.ctrl,
    required this.isDark,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.border,
    required this.priorityColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? (isDark ? AppColors.darkSurface0 : const Color(0xFFF5F5F5))
            : cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ctrl.toggleTask(task),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? accent : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? accent : border,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: task.isCompleted ? textSecondary : textPrimary,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.category,
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.priority.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert_rounded, size: 18, color: textSecondary),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') ctrl.deleteTask(task.id);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Habit Card ───────────────────────────────────────────────────────────────

class _HabitCard extends StatelessWidget {
  final HabitItemModel habit;
  final bool done;
  final bool isDark;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardColor;
  final Color border;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit,
    required this.done,
    required this.isDark,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.border,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: done ? accent.withOpacity(0.1) : cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? accent.withOpacity(0.4) : border,
          width: done ? 1.5 : 1,
        ),
        boxShadow: done
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? accent : (isDark ? AppColors.darkSurface2 : AppColors.lightSurfaceVariant),
                ),
                child: Icon(
                  done ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: done ? Colors.white : textSecondary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${habit.targetDaysPerWeek}x per week target',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 2),
                    Text(
                      '${habit.streakCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: done ? accent : textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text('streak', style: TextStyle(fontSize: 10, color: textSecondary)),
              ],
            ),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.more_vert_rounded, size: 18, color: textSecondary),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Goal Card ────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final GoalItemModel goal;
  final bool isDark;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardColor;
  final Color border;
  final VoidCallback onAddProgress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.isDark,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.border,
    required this.onAddProgress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final pct = goal.progressPercentage;
    final progressColor = pct >= 75 ? AppColors.success : accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goal.category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert_rounded, size: 18, color: textSecondary),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${goal.completedHours.toStringAsFixed(1)} / ${goal.targetHours}h',
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                minHeight: 7,
                backgroundColor: progressColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 12, color: textSecondary),
              const SizedBox(width: 4),
              Text(
                'Due ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}',
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAddProgress,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 14, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        '+1 Hour',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── FAB ─────────────────────────────────────────────────────────────────────

class _AddFAB extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _AddFAB({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0066CC).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
