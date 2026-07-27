import 'dart:async';
import 'package:flutter/foundation.dart';
import '../database/hive_service.dart';
import '../models/goal_item_model.dart';
import '../models/habit_item_model.dart';
import '../models/task_item_model.dart';

class ProductivityController extends ChangeNotifier {
  List<TaskItemModel> _tasks = [];
  List<HabitItemModel> _habits = [];
  List<GoalItemModel> _goals = [];

  // Pomodoro Timer State
  int _pomodoroSeconds = 25 * 60; // 25 minutes
  bool _isPomodoroRunning = false;
  int _completedPomodoros = 0;
  Timer? _pomodoroTimer;

  // Weekly study hours (mock tracked data for charts)
  final List<double> _weeklyStudyHours = [2.5, 4.0, 3.0, 5.5, 4.5, 2.0, 6.0];
  final List<double> _monthlyStudyHours = [
    52,
    68,
    75,
    61,
    80,
    72,
    55,
    90,
    65,
    78,
    88,
    70,
  ];

  ProductivityController() {
    _loadData();
  }

  // Getters
  List<TaskItemModel> get tasks => _tasks;
  List<TaskItemModel> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();
  List<TaskItemModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();
  List<HabitItemModel> get habits => _habits;
  List<GoalItemModel> get goals => _goals;
  int get pomodoroSeconds => _pomodoroSeconds;
  bool get isPomodoroRunning => _isPomodoroRunning;
  int get completedPomodoros => _completedPomodoros;
  List<double> get weeklyStudyHours => _weeklyStudyHours;
  List<double> get monthlyStudyHours => _monthlyStudyHours;

  String get pomodoroDisplay {
    final minutes = (_pomodoroSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_pomodoroSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get pomodoroProgress => 1.0 - (_pomodoroSeconds / (25 * 60));

  int get totalTasksToday => _tasks.length;
  int get completedTasksToday => _tasks.where((t) => t.isCompleted).length;
  double get taskCompletionRate {
    if (_tasks.isEmpty) return 0;
    return (completedTasksToday / totalTasksToday) * 100;
  }

  double get totalStudyHoursThisWeek =>
      _weeklyStudyHours.fold(0, (a, b) => a + b);

  void _loadData() {
    final taskBox = HiveService.instance.tasksBox;
    final habitBox = HiveService.instance.habitsBox;
    final goalBox = HiveService.instance.goalsBox;

    _tasks = taskBox.values.toList();
    _habits = habitBox.values.toList();
    _goals = goalBox.values.toList();

    notifyListeners();
  }

  Future<void> toggleTask(TaskItemModel task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await HiveService.instance.tasksBox.put(updated.id, updated);
    _loadData();
  }

  Future<void> addTask(TaskItemModel task) async {
    await HiveService.instance.tasksBox.put(task.id, task);
    _loadData();
  }

  Future<void> deleteTask(String id) async {
    await HiveService.instance.tasksBox.delete(id);
    _loadData();
  }

  Future<void> toggleHabitToday(HabitItemModel habit) async {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final newDates = List<String>.from(habit.completedDates);
    int newStreak = habit.streakCount;

    if (newDates.contains(todayKey)) {
      newDates.remove(todayKey);
      newStreak = newStreak > 0 ? newStreak - 1 : 0;
    } else {
      newDates.add(todayKey);
      newStreak++;
    }

    final updated = habit.copyWith(
      completedDates: newDates,
      streakCount: newStreak,
    );
    await HiveService.instance.habitsBox.put(updated.id, updated);
    _loadData();
  }

  Future<void> addHabit(HabitItemModel habit) async {
    await HiveService.instance.habitsBox.put(habit.id, habit);
    _loadData();
  }

  Future<void> updateHabit(HabitItemModel habit) async {
    await HiveService.instance.habitsBox.put(habit.id, habit);
    _loadData();
  }

  Future<void> deleteHabit(String id) async {
    await HiveService.instance.habitsBox.delete(id);
    _loadData();
  }

  Future<void> addGoal(GoalItemModel goal) async {
    await HiveService.instance.goalsBox.put(goal.id, goal);
    _loadData();
  }

  Future<void> updateGoal(GoalItemModel goal) async {
    await HiveService.instance.goalsBox.put(goal.id, goal);
    _loadData();
  }

  Future<void> deleteGoal(String id) async {
    await HiveService.instance.goalsBox.delete(id);
    _loadData();
  }

  Future<void> addGoalProgress(String goalId, double hoursToAdd) async {
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx != -1) {
      final updated = _goals[idx].copyWith(
        completedHours: (_goals[idx].completedHours + hoursToAdd).clamp(
          0.0,
          _goals[idx].targetHours,
        ),
      );
      await HiveService.instance.goalsBox.put(updated.id, updated);
      _loadData();
    }
  }

  void startPomodoro() {
    _isPomodoroRunning = true;
    notifyListeners();
    _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_pomodoroSeconds > 0) {
        _pomodoroSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _isPomodoroRunning = false;
        _completedPomodoros++;
        _pomodoroSeconds = 25 * 60;
        notifyListeners();
      }
    });
  }

  void pausePomodoro() {
    _pomodoroTimer?.cancel();
    _isPomodoroRunning = false;
    notifyListeners();
  }

  void resetPomodoro() {
    _pomodoroTimer?.cancel();
    _isPomodoroRunning = false;
    _pomodoroSeconds = 25 * 60;
    notifyListeners();
  }

  @override
  void dispose() {
    _pomodoroTimer?.cancel();
    super.dispose();
  }
}
