import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../controllers/notification_controller.dart';

class NotificationPanel extends StatelessWidget {
  final bool isDark;
  const NotificationPanel({super.key, required this.isDark});

  Color _typeColor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.deadline:
        return const Color(0xFFEF5350);
      case AppNotificationType.task:
        return const Color(0xFF4FC3F7);
      case AppNotificationType.habit:
        return const Color(0xFF66BB6A);
      case AppNotificationType.reminder:
        return const Color(0xFFFFB74D);
      case AppNotificationType.system:
        return const Color(0xFF9575CD);
    }
  }

  IconData _typeIcon(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.deadline:
        return Icons.warning_amber_rounded;
      case AppNotificationType.task:
        return Icons.task_alt_rounded;
      case AppNotificationType.habit:
        return Icons.loop_rounded;
      case AppNotificationType.reminder:
        return Icons.emoji_events_rounded;
      case AppNotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark ? const Color(0xFF1E2D42) : AppColors.lightSurfaceVariant;
    final textPrimary = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final textSecondary = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final cardBg = isDark ? AppColors.darkSurface2 : const Color(0xFFF8FAFC);

    return Consumer<NotificationController>(
      builder: (ctx, ctrl, _) {
        final notifications = ctrl.notifications;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
                          ),
                          if (ctrl.unreadCount > 0)
                            Text(
                              '${ctrl.unreadCount} unread',
                              style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    if (notifications.isNotEmpty) ...[
                      TextButton(
                        onPressed: ctrl.markAllRead,
                        child: Text('Mark all read', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary)),
                      ),
                      IconButton(
                        onPressed: () {
                          ctrl.clearAll();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.delete_sweep_rounded, size: 20, color: textSecondary),
                        tooltip: 'Clear all',
                      ),
                    ],
                  ],
                ),
              ),
              Divider(height: 1, color: border),
              // Notification list
              Flexible(
                child: notifications.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 48, color: textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text('All caught up!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textPrimary)),
                            const SizedBox(height: 4),
                            Text('No notifications right now.', style: TextStyle(fontSize: 13, color: textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: border, indent: 72),
                        itemBuilder: (_, i) {
                          final n = notifications[i];
                          final color = _typeColor(n.type);
                          return Dismissible(
                            key: Key(n.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: AppColors.error.withOpacity(0.12),
                              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            ),
                            onDismissed: (_) => ctrl.dismiss(n.id),
                            child: InkWell(
                              onTap: () => ctrl.markRead(n.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                color: n.isRead ? Colors.transparent : color.withOpacity(isDark ? 0.06 : 0.04),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_typeIcon(n.type), color: color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.title,
                                            style: TextStyle(
                                              fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                                              fontSize: 13,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            n.body,
                                            style: TextStyle(fontSize: 12, color: textSecondary),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _timeAgo(n.createdAt),
                                            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!n.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
