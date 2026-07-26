import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/productivity_controller.dart';
import '../../helpers/snackbar_helper.dart';
import '../../models/task_item_model.dart';
import '../../widgets/custom_card.dart';
import 'widgets/study_chart_widget.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showWeeklyChart = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showAddTaskDialog(BuildContext context, ProductivityController ctrl) {
    final titleCtrl = TextEditingController();
    String priority = 'medium';
    String category = 'Study';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
          title: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Task Title', hintText: 'e.g. Study Chapter 5'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['high', 'medium', 'low'].map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase()))).toList(),
                onChanged: (val) => setS(() => priority = val!),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Study', 'Academic', 'Health', 'Personal'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setS(() => category = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  ctrl.addTask(TaskItemModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleCtrl.text.trim(),
                    category: category,
                    priority: priority,
                    dueDate: DateTime.now().add(const Duration(hours: 4)),
                  ));
                  Navigator.pop(ctx);
                  SnackbarHelper.showSuccess(context, 'Task Added!');
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = Provider.of<ProductivityController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Tasks'),
            Tab(text: 'Habits'),
            Tab(text: 'Goals'),
          ],
          isScrollable: false,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () => _showAddTaskDialog(context, ctrl),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(context, theme, ctrl),
          _buildTasksTab(context, theme, ctrl),
          _buildHabitsTab(context, theme, ctrl),
          _buildGoalsTab(context, theme, ctrl),
        ],
      ),
    );
  }

  // ─── DASHBOARD TAB ───────────────────────────────────────────────────────
  Widget _buildDashboard(BuildContext context, ThemeData theme, ProductivityController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pomodoro Focus Timer Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
            ),
            child: Column(
              children: [
                const Text('Pomodoro Focus Timer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: AppDimensions.md),
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: ctrl.pomodoroProgress,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        color: Colors.white,
                      ),
                      Text(
                        ctrl.pomodoroDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!ctrl.isPomodoroRunning)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: theme.colorScheme.primary),
                        onPressed: ctrl.startPomodoro,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Focus'),
                      )
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.25), foregroundColor: Colors.white),
                        onPressed: ctrl.pausePomodoro,
                        icon: const Icon(Icons.pause_rounded),
                        label: const Text('Pause'),
                      ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: ctrl.resetPomodoro,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  '🏆 ${ctrl.completedPomodoros} sessions completed today',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Quick Stats Row
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.task_alt_rounded, color: theme.colorScheme.primary, size: 24),
                      const SizedBox(height: AppDimensions.xs),
                      Text('${ctrl.completedTasksToday}/${ctrl.totalTasksToday}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      const Text('Tasks Done', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule_rounded, color: theme.colorScheme.tertiary, size: 24),
                      const SizedBox(height: AppDimensions.xs),
                      Text('${ctrl.totalStudyHoursThisWeek.toStringAsFixed(1)}h', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary)),
                      const Text('Study This Week', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 24),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        ctrl.habits.isNotEmpty ? '${ctrl.habits.first.streakCount}🔥' : '0',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const Text('Best Streak', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.lg),

          // Study Statistics Charts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Study Statistics', style: theme.textTheme.titleMedium),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Weekly')),
                  ButtonSegment(value: false, label: Text('Monthly')),
                ],
                selected: {_showWeeklyChart},
                onSelectionChanged: (s) => setState(() => _showWeeklyChart = s.first),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showWeeklyChart ? 'Hours Studied Per Day This Week' : 'Monthly Study Hours Overview',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppDimensions.md),
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
    );
  }

  // ─── TASKS TAB ──────────────────────────────────────────────────────────
  Widget _buildTasksTab(BuildContext context, ThemeData theme, ProductivityController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          CustomCard(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today\'s Progress', style: theme.textTheme.titleMedium),
                    Text('${ctrl.taskCompletionRate.toStringAsFixed(0)}%', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: ctrl.taskCompletionRate / 100),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text('${ctrl.completedTasksToday} of ${ctrl.totalTasksToday} tasks completed', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          if (ctrl.pendingTasks.isNotEmpty) ...[
            Text('Pending Tasks', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.sm),
            ...ctrl.pendingTasks.map((task) => _taskTile(context, theme, task, ctrl)),
          ],

          if (ctrl.completedTasks.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.md),
            Text('Completed', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppDimensions.sm),
            ...ctrl.completedTasks.map((task) => _taskTile(context, theme, task, ctrl)),
          ],
        ],
      ),
    );
  }

  Widget _taskTile(BuildContext context, ThemeData theme, TaskItemModel task, ProductivityController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: CustomCard(
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
                  color: task.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? theme.colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  Text(task.category, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _priorityColor(task.priority).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.priority.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _priorityColor(task.priority)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              onPressed: () => ctrl.deleteTask(task.id),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HABITS TAB ─────────────────────────────────────────────────────────
  Widget _buildHabitsTab(BuildContext context, ThemeData theme, ProductivityController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Habit Tracker', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Text('Tap to mark as done for today', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppDimensions.md),
          ...ctrl.habits.map((habit) {
            final done = habit.isCompletedToday;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: GestureDetector(
                onTap: () {
                  ctrl.toggleHabitToday(habit);
                  SnackbarHelper.showSuccess(context, done ? 'Habit marked incomplete.' : '🔥 ${habit.title} completed!');
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: done ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6) : theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(
                      color: done ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: done ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: Icon(
                          done ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: done ? Colors.white : theme.colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(habit.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text('${habit.targetDaysPerWeek}x per week target', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 2),
                              Text('${habit.streakCount}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 16)),
                            ],
                          ),
                          Text('day streak', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── GOALS TAB ──────────────────────────────────────────────────────────
  Widget _buildGoalsTab(BuildContext context, ThemeData theme, ProductivityController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Goal Tracking', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          ...ctrl.goals.map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.md),
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(goal.category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${goal.completedHours.toStringAsFixed(1)} / ${goal.targetHours}h', style: theme.textTheme.bodyMedium),
                        Text('${goal.progressPercentage.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: goal.progressPercentage / 100),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        color: goal.progressPercentage >= 75 ? Colors.green : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Due: ${goal.deadline.day}/${goal.deadline.month}/${goal.deadline.year}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('+1 Hour'),
                          onPressed: () {
                            ctrl.addGoalProgress(goal.id, 1.0);
                            SnackbarHelper.showSuccess(context, 'Progress updated!');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
