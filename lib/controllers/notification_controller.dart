import 'package:flutter/foundation.dart';
import '../models/academic_event_model.dart';
import '../models/habit_item_model.dart';
import '../models/task_item_model.dart';
import '../services/notification_service.dart';

enum AppNotificationType { deadline, task, habit, reminder, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationController extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications.reversed.toList());

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Called at startup / when data refreshes to build smart notifications
  void syncFromData({
    List<AcademicEventModel>? events,
    List<TaskItemModel>? tasks,
    List<HabitItemModel>? habits,
    bool pushEnabled = true,
  }) {
    final previousIds = _notifications.map((n) => n.id).toSet();
    final next = <AppNotification>[];

    final now = DateTime.now();

    // ── Deadline Alerts ────────────────────────────────────────────────────
    if (events != null) {
      for (final evt in events) {
        if (evt.isCompleted) continue;
        final daysLeft = evt.daysRemaining;
        if (daysLeft <= 7) {
          String urgency = daysLeft == 0
              ? '⚠️ Due TODAY!'
              : daysLeft == 1
              ? '🔔 Due TOMORROW'
              : '📅 Due in $daysLeft days';
          next.add(
            AppNotification(
              id: 'evt_${evt.id}',
              title: '$urgency — ${evt.eventType.toUpperCase()}',
              body: '${evt.title} (${evt.subjectName})',
              type: AppNotificationType.deadline,
              createdAt: now,
              isRead: daysLeft > 3,
            ),
          );
        }
      }
    }

    // ── Pending Tasks ──────────────────────────────────────────────────────
    if (tasks != null) {
      final pending = tasks.where((t) => !t.isCompleted).toList();
      final highPriority = pending.where((t) => t.priority == 'high').toList();

      if (highPriority.isNotEmpty) {
        next.add(
          AppNotification(
            id: 'tasks_high',
            title:
                '🔴 ${highPriority.length} High-Priority Task${highPriority.length > 1 ? 's' : ''} Pending',
            body: highPriority.map((t) => t.title).take(3).join(', '),
            type: AppNotificationType.task,
            createdAt: now,
            isRead: false,
          ),
        );
      }

      if (pending.length > highPriority.length) {
        final others = pending.length - highPriority.length;
        next.add(
          AppNotification(
            id: 'tasks_other',
            title: '📝 $others Task${others > 1 ? 's' : ''} Remaining Today',
            body: pending
                .where((t) => t.priority != 'high')
                .map((t) => t.title)
                .take(3)
                .join(', '),
            type: AppNotificationType.task,
            createdAt: now.subtract(const Duration(minutes: 5)),
            isRead: true,
          ),
        );
      }
    }

    // ── Habit Reminders ────────────────────────────────────────────────────
    if (habits != null) {
      final undoneToday = habits.where((h) => !h.isCompletedToday).toList();
      if (undoneToday.isNotEmpty) {
        next.add(
          AppNotification(
            id: 'habits_today',
            title:
                '🔥 ${undoneToday.length} Habit${undoneToday.length > 1 ? 's' : ''} Not Done Today',
            body: undoneToday.map((h) => h.title).take(3).join(', '),
            type: AppNotificationType.habit,
            createdAt: now.subtract(const Duration(minutes: 2)),
            isRead: false,
          ),
        );
      }

      // Streak milestones
      for (final h in habits) {
        if (h.streakCount > 0 && h.streakCount % 7 == 0) {
          next.add(
            AppNotification(
              id: 'streak_${h.id}',
              title: '🏆 ${h.streakCount}-Day Streak Milestone!',
              body: '${h.title} — Keep it going!',
              type: AppNotificationType.reminder,
              createdAt: now.subtract(const Duration(minutes: 10)),
              isRead: true,
            ),
          );
        }
      }
    }

    // ── Welcome / System ───────────────────────────────────────────────────
    if (next.isEmpty) {
      next.add(
        AppNotification(
          id: 'welcome',
          title: '👋 Welcome to CampusOne!',
          body:
              'Your smart academic companion is ready. Start by adding subjects, tasks, and habits.',
          type: AppNotificationType.system,
          createdAt: now.subtract(const Duration(hours: 1)),
          isRead: false,
        ),
      );
    }

    final changed = !_isSameState(_notifications, next);
    _notifications
      ..clear()
      ..addAll(next);

    if (pushEnabled) {
      _dispatchNewLocalNotifications(previousIds, next);
    }

    if (changed) {
      notifyListeners();
    }
  }

  bool _isSameState(List<AppNotification> a, List<AppNotification> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.id != y.id ||
          x.title != y.title ||
          x.body != y.body ||
          x.type != y.type ||
          x.isRead != y.isRead) {
        return false;
      }
    }
    return true;
  }

  void _dispatchNewLocalNotifications(
    Set<String> previousIds,
    List<AppNotification> next,
  ) {
    for (final n in next) {
      if (previousIds.contains(n.id)) continue;
      if (n.isRead) continue;
      if (n.type == AppNotificationType.system) continue;

      NotificationService.instance.showNotification(
        id: n.id.hashCode & 0x7fffffff,
        title: n.title,
        body: n.body,
        payload: n.id,
      );
    }
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
