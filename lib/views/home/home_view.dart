import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/home_controller.dart';
import '../../helpers/snackbar_helper.dart';
import '../../theme/theme_manager.dart';
import '../../widgets/animated_stat_card.dart';
import '../../widgets/custom_card.dart';
import '../../routes/app_routes.dart';
import 'widgets/edit_profile_dialog.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _showEditProfile(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (ctx) => EditProfileDialog(
        profile: controller.profile,
        onSave: (name, dept, semester, section, group, uni) {
          controller.updateProfile(
            name: name,
            department: dept,
            semester: semester,
            section: section,
            group: group,
            university: uni,
          );
          SnackbarHelper.showSuccess(context, 'Student Profile Updated!');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final controller = Provider.of<HomeController>(context);
    final profile = controller.profile;
    final stats = controller.stats;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                profile.name.isNotEmpty ? profile.name[0] : 'S',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${profile.department} • ${profile.semester}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeManager.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            ),
            onPressed: () => themeManager.toggleTheme(!themeManager.isDarkMode),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () => _showEditProfile(context, controller),
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comprehensive Student Profile Apple/Material Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          profile.university,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.offline_bolt_rounded, size: 12, color: Colors.greenAccent),
                            SizedBox(width: 4),
                            Text('Hive Offline Active', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.department} | ${profile.semester}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.class_rounded, size: 14, color: Colors.white),
                        label: Text('Sec ${profile.section}', style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                      ),
                      Chip(
                        avatar: const Icon(Icons.group_rounded, size: 14, color: Colors.white),
                        label: Text(profile.group, style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Quick Actions Bar
            Text('Quick Actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.add_task, size: 16),
                    label: const Text('Add Task'),
                    onPressed: () {
                      controller.incrementTasks();
                      SnackbarHelper.showSuccess(context, 'Task count incremented!');
                    },
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  ActionChip(
                    avatar: const Icon(Icons.class_outlined, size: 16),
                    label: const Text('Check-in Class'),
                    onPressed: () {
                      controller.incrementClasses();
                      SnackbarHelper.showSuccess(context, 'Classes updated!');
                    },
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  ActionChip(
                    avatar: const Icon(Icons.timer_outlined, size: 16),
                    label: Text(stats.isPomodoroRunning ? 'Pause Pomodoro' : 'Start Pomodoro'),
                    onPressed: () {
                      controller.togglePomodoroTimer();
                    },
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  ActionChip(
                    avatar: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit Profile'),
                    onPressed: () => _showEditProfile(context, controller),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  ActionChip(
                    avatar: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                    label: const Text('Expense Tracker'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.expenseTracker),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  ActionChip(
                    avatar: const Icon(Icons.file_copy_outlined, size: 16),
                    label: const Text('Cover Page'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.coverPages),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Animated Statistics Section
            Text('Dashboard Statistics', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.md),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              childAspectRatio: 1.3,
              children: [
                AnimatedStatCard(
                  title: "Today's Classes",
                  value: "${stats.todaysClasses}",
                  icon: Icons.menu_book_rounded,
                  color: theme.colorScheme.primary,
                  subtitle: "Active lectures scheduled",
                ),
                AnimatedStatCard(
                  title: "Today's Tasks",
                  value: "${stats.todaysTasks}",
                  icon: Icons.check_box_outlined,
                  color: theme.colorScheme.secondary,
                  subtitle: "Pending tasks & todos",
                ),
                AnimatedStatCard(
                  title: "Attendance",
                  value: "${stats.attendancePercentage}%",
                  icon: Icons.pie_chart_outline_rounded,
                  color: Colors.green,
                  subtitle: "Good Standing (>85%)",
                ),
                AnimatedStatCard(
                  title: "Cumulative CGPA",
                  value: "${stats.cgpa}",
                  icon: Icons.grade_outlined,
                  color: Colors.amber.shade800,
                  subtitle: "Current semester rank",
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.md),

            // Focus Pomodoro & Academic Highlights Cards
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      stats.isPomodoroRunning ? Icons.timer_rounded : Icons.timer_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pomodoro Focus Session', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          stats.isPomodoroRunning
                              ? 'Session in progress... stay focused!'
                              : '${stats.pomodoroMinutesLeft} Min Session Ready',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.togglePomodoroTimer(),
                    child: Text(stats.isPomodoroRunning ? 'Pause' : 'Start'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.md),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('Upcoming Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(stats.upcomingAssignment, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.md),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_outlined, color: theme.colorScheme.tertiary, size: 20),
                      const SizedBox(width: 8),
                      const Text('Upcoming Exam Alert', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(stats.upcomingExam, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
