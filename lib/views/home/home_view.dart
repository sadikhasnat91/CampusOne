import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../controllers/academic_controller.dart';
import '../../controllers/app_state_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/productivity_controller.dart';
import '../../controllers/routine_controller.dart';
import '../../models/student_profile_model.dart';
import '../../models/dashboard_stats_model.dart';
import '../../helpers/snackbar_helper.dart';
import '../../theme/theme_manager.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_stat_card.dart';
import '../../routes/app_routes.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/notification_panel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _showEditProfile(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (ctx) => EditProfileDialog(
        profile: controller.profile,
        onSave:
            (
              name,
              dept,
              semester,
              section,
              group,
              uni,
              instType,
              profilePicUrl,
              logoUrl,
            ) {
              controller
                  .updateProfile(
                    name: name,
                    department: dept,
                    semester: semester,
                    section: section,
                    group: group,
                    university: uni,
                    institutionType: instType,
                    profilePictureUrl: profilePicUrl,
                    institutionLogoUrl: logoUrl,
                  )
                  .then((_) {
                    if (context.mounted) {
                      context.read<AcademicController>().syncWithProfile();
                      context.read<RoutineController>().syncWithProfile();
                    }
                  });
              SnackbarHelper.showSuccess(context, 'Student Profile Updated!');
            },
      ),
    );
  }

  void _showAcademicStatsDialog(
    BuildContext context,
    HomeController controller,
  ) {
    final profile = controller.profile;
    final maxGrade =
        profile.institutionType == 'school' ||
            profile.institutionType == 'college'
        ? 5.0
        : 4.0;

    final gradeCtrl = TextEditingController(
      text: controller.stats.cgpa > 0
          ? controller.stats.cgpa.toStringAsFixed(2)
          : '',
    );
    final attendanceCtrl = TextEditingController(
      text: controller.stats.attendancePercentage > 0
          ? controller.stats.attendancePercentage.toStringAsFixed(1)
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;
        final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
        final border = isDark
            ? const Color(0xFF1E2D42)
            : AppColors.lightSurfaceVariant;
        final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        final textPrimary = isDark
            ? AppColors.darkOnSurface
            : AppColors.lightOnSurface;

        InputDecoration inputDeco(String label) {
          return InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.darkSurface2
                : AppColors.lightSurfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          );
        }

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
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
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Update Academic Snapshot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Set your ${profile.gradeLabel} and attendance to show on dashboard.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant
                      : AppColors.lightOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: gradeCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(color: textPrimary),
                decoration: inputDeco('${profile.gradeLabel} (0 - $maxGrade)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: attendanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(color: textPrimary),
                decoration: inputDeco('Attendance % (0 - 100)'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final grade = double.tryParse(gradeCtrl.text.trim());
                    final attendance = double.tryParse(
                      attendanceCtrl.text.trim(),
                    );

                    if (grade == null || grade < 0 || grade > maxGrade) {
                      SnackbarHelper.showError(
                        context,
                        'Enter valid ${profile.gradeLabel} between 0 and $maxGrade',
                      );
                      return;
                    }
                    if (attendance == null ||
                        attendance < 0 ||
                        attendance > 100) {
                      SnackbarHelper.showError(
                        context,
                        'Enter valid attendance between 0 and 100',
                      );
                      return;
                    }

                    await controller.updateAcademicSnapshot(
                      gradePoint: grade,
                      attendancePercentage: attendance,
                    );

                    if (context.mounted) {
                      Navigator.pop(sheetCtx);
                      SnackbarHelper.showSuccess(
                        context,
                        'Academic stats updated successfully!',
                      );
                    }
                  },
                  child: const Text(
                    'Save Academic Stats',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeManager = Provider.of<ThemeManager>(context);
    final controller = Provider.of<HomeController>(context);
    final notifCtrl = Provider.of<NotificationController>(context);
    final appState = context.read<AppStateController>();
    final academicCtrl = Provider.of<AcademicController>(context);
    final productivityCtrl = context.read<ProductivityController>();
    final profile = controller.profile;
    final stats = controller.stats;
    final screenW = MediaQuery.of(context).size.width;

    // Sync notifications from live data on every build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifCtrl.syncFromData(
        events: academicCtrl.events,
        tasks: productivityCtrl.tasks,
        habits: productivityCtrl.habits,
        pushEnabled: appState.notificationsEnabled,
      );
    });
    final hPad = Responsive.isTablet(context) ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ── Premium SliverAppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: isDark
                ? AppColors.darkBg
                : AppColors.lightBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDark
                    ? AppColors.darkPrimaryContainer
                    : AppColors.lightPrimaryContainer,
                backgroundImage: _buildImageProvider(profile.profilePictureUrl),
                child: _buildImageProvider(profile.profilePictureUrl) == null
                    ? Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : 'S',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      )
                    : null,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isNotEmpty ? profile.name : 'Student',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface,
                  ),
                ),
                Text(
                  profile.institutionType == 'school'
                      ? '${profile.semester} • ${profile.department}'
                      : profile.institutionType == 'college'
                      ? '${profile.department} Group • ${profile.semester}'
                      : '${profile.department} • ${profile.semester}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              _NavIconButton(
                icon: themeManager.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: () => themeManager.toggleTheme(!themeManager.isDarkMode),
                isDark: isDark,
              ),
              _NavIconButton(
                icon: Icons.edit_note_rounded,
                onTap: () => _showEditProfile(context, controller),
                isDark: isDark,
              ),
              _NavIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => NotificationPanel(isDark: isDark),
                ),
                isDark: isDark,
                badge: notifCtrl.unreadCount,
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Body content ─────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // ── Hero Profile Banner ───────────────────────────────────
                _HeroBanner(
                  profile: profile,
                  academicCtrl: academicCtrl,
                  stats: stats,
                  isDark: isDark,
                  theme: theme,
                ),
                const SizedBox(height: 24),

                // ── Quick Actions ─────────────────────────────────────────
                _SectionTitle(
                  label: 'Quick Actions',
                  theme: theme,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _QuickActionsRow(
                  controller: controller,
                  context: context,
                  isDark: isDark,
                  theme: theme,
                  stats: stats,
                  onUpdateAcademicStats: () =>
                      _showAcademicStatsDialog(context, controller),
                ),
                const SizedBox(height: 24),

                // ── Stats Grid ────────────────────────────────────────────
                _SectionTitle(label: 'Dashboard', theme: theme, isDark: isDark),
                const SizedBox(height: 12),
                _StatsGrid(stats: stats, theme: theme, screenW: screenW),
                const SizedBox(height: 24),

                // ── Pomodoro Card ─────────────────────────────────────────
                _PomodoroCard(
                  controller: controller,
                  stats: stats,
                  isDark: isDark,
                  theme: theme,
                ),
                const SizedBox(height: 16),

                // ── Info cards ────────────────────────────────────────────
                _InfoCard(
                  icon: Icons.assignment_outlined,
                  title: 'Upcoming Assignment',
                  body: stats.upcomingAssignment,
                  iconGradient: AppColors.tealGradient,
                  isDark: isDark,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.event_outlined,
                  title: 'Upcoming Exam Alert',
                  body: stats.upcomingExam,
                  iconGradient: AppColors.purpleGradient,
                  isDark: isDark,
                  theme: theme,
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final int badge;
  const _NavIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Material(
        color: isDark
            ? AppColors.darkSurface1.withOpacity(0.7)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDark
                      ? AppColors.darkOnSurface
                      : AppColors.lightOnSurface,
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkSurface1 : Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final bool isDark;
  const _SectionTitle({
    required this.label,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Image helper functions ────────────────────────────────────────────────────

ImageProvider? _buildImageProvider(String url) {
  final normalized = url.trim();
  if (normalized.isEmpty) return null;

  if (normalized.startsWith('data:image')) {
    try {
      final base64Data = normalized.split(',').last;
      return MemoryImage(_decodeBase64String(base64Data));
    } catch (_) {
      return null;
    }
  }

  if (normalized.startsWith('assets/')) {
    return AssetImage(normalized);
  }

  final uri = Uri.tryParse(normalized);
  final scheme = uri?.scheme.toLowerCase();
  if (uri != null && (scheme == 'http' || scheme == 'https')) {
    return NetworkImage(normalized);
  }

  return null;
}

DecorationImage? _buildImageDecoration(String url) {
  final provider = _buildImageProvider(url);
  if (provider == null) return null;
  return DecorationImage(image: provider, fit: BoxFit.cover);
}

Widget _buildImageWidgetFromUrl(String url) {
  final provider = _buildImageProvider(url);
  if (provider == null) return const SizedBox();
  return Image(image: provider, fit: BoxFit.cover);
}

Uint8List _decodeBase64String(String base64Str) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  final lookup = <int, int>{};
  for (int i = 0; i < chars.length; i++) {
    lookup[chars.codeUnitAt(i)] = i;
  }
  final padded = base64Str.padRight((base64Str.length + 3) ~/ 4 * 4, '=');
  final output = <int>[];
  for (int i = 0; i < padded.length; i += 4) {
    final a = lookup[padded.codeUnitAt(i)] ?? 0;
    final b = lookup[padded.codeUnitAt(i + 1)] ?? 0;
    final c = lookup[padded.codeUnitAt(i + 2)] ?? 0;
    final d = lookup[padded.codeUnitAt(i + 3)] ?? 0;
    output.add((a << 2) | (b >> 4));
    if (padded[i + 2] != '=') output.add(((b & 0xf) << 4) | (c >> 2));
    if (padded[i + 3] != '=') output.add(((c & 0x3) << 6) | d);
  }
  return Uint8List.fromList(output);
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final StudentProfileModel profile;
  final AcademicController academicCtrl;
  final DashboardStatsModel stats;
  final bool isDark;
  final ThemeData theme;
  const _HeroBanner({
    required this.profile,
    required this.academicCtrl,
    required this.stats,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final calculated = academicCtrl.calculateOverallCgpa();
    final gradeValue = stats.cgpa > 0 ? stats.cgpa : calculated;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDark
            ? AppColors.heroGradientDark
            : AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066CC).withOpacity(isDark ? 0.4 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (profile.institutionLogoUrl.isNotEmpty) ...[
                        ClipOval(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: _buildImageWidgetFromUrl(
                              profile.institutionLogoUrl,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          profile.university.isNotEmpty
                              ? profile.university
                              : profile.institutionLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.offline_bolt_rounded,
                      size: 11,
                      color: Color(0xFF69F0AE),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Offline Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Profile avatar
              Container(
                width: 52,
                height: 52,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  image: _buildImageDecoration(profile.profilePictureUrl),
                ),
                child: _buildImageDecoration(profile.profilePictureUrl) == null
                    ? Center(
                        child: Text(
                          profile.name.isNotEmpty
                              ? profile.name[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isNotEmpty ? profile.name : 'Student Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.institutionType == 'school'
                          ? '${profile.semester} • ${profile.department}'
                          : profile.institutionType == 'college'
                          ? '${profile.department} Group • ${profile.semester}'
                          : '${profile.department} | ${profile.semester}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _HeroChip(
                label: 'Sec ${profile.section}',
                icon: Icons.class_rounded,
              ),
              _HeroChip(label: profile.group, icon: Icons.group_rounded),
              _HeroChip(
                label: '${profile.gradeLabel} ${gradeValue.toStringAsFixed(2)}',
                icon: Icons.grade_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _HeroChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final HomeController controller;
  final BuildContext context;
  final bool isDark;
  final ThemeData theme;
  final dynamic stats;
  final VoidCallback onUpdateAcademicStats;
  const _QuickActionsRow({
    required this.controller,
    required this.context,
    required this.isDark,
    required this.theme,
    required this.stats,
    required this.onUpdateAcademicStats,
  });

  @override
  Widget build(BuildContext ctx) {
    final actions = [
      _QA(
        icon: Icons.add_task_rounded,
        label: 'Add Task',
        color: const Color(0xFF4FC3F7),
        onTap: () {
          controller.incrementTasks();
          SnackbarHelper.showSuccess(context, 'Task count incremented!');
        },
      ),
      _QA(
        icon: Icons.class_rounded,
        label: 'Check-in',
        color: const Color(0xFF26C6DA),
        onTap: () {
          controller.incrementClasses();
          SnackbarHelper.showSuccess(context, 'Classes updated!');
        },
      ),
      _QA(
        icon: stats.isPomodoroRunning
            ? Icons.pause_circle_rounded
            : Icons.timer_rounded,
        label: stats.isPomodoroRunning ? 'Pause' : 'Pomodoro',
        color: const Color(0xFF9575CD),
        onTap: () => controller.togglePomodoroTimer(),
      ),
      _QA(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Expenses',
        color: const Color(0xFF66BB6A),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.expenseTracker);
        },
      ),
      _QA(
        icon: Icons.file_copy_rounded,
        label: 'Cover Page',
        color: const Color(0xFFFFB74D),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.coverPages);
        },
      ),
      _QA(
        icon: Icons.edit_rounded,
        label: 'Update Stats',
        color: const Color(0xFFEF5350),
        onTap: onUpdateAcademicStats,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions
            .map(
              (a) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _QuickActionItem(qa: a, isDark: isDark, theme: theme),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QA {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QA({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionItem extends StatelessWidget {
  final _QA qa;
  final bool isDark;
  final ThemeData theme;
  const _QuickActionItem({
    required this.qa,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: qa.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E2D42)
                  : AppColors.lightSurfaceVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: qa.color.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: qa.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(qa.icon, size: 16, color: qa.color),
              ),
              const SizedBox(width: 8),
              Text(
                qa.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkOnSurface
                      : AppColors.lightOnSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final dynamic stats;
  final ThemeData theme;
  final double screenW;
  const _StatsGrid({
    required this.stats,
    required this.theme,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    final academicCtrl = Provider.of<AcademicController>(
      context,
      listen: false,
    );
    final homeCtrl = Provider.of<HomeController>(context, listen: false);
    final profile = homeCtrl.profile;
    final gradeLabel = profile.gradeLabel;
    final calculatedCgpa = academicCtrl.calculateOverallCgpa();
    final gradeValue = stats.cgpa > 0 ? stats.cgpa : calculatedCgpa;

    final items = [
      _StatItem(
        "Today's Classes",
        '${stats.todaysClasses}',
        Icons.menu_book_rounded,
        const Color(0xFF4FC3F7),
        profile.institutionType == 'school'
            ? 'Active classes'
            : 'Active lectures',
      ),
      _StatItem(
        "Today's Tasks",
        '${stats.todaysTasks}',
        Icons.check_box_outlined,
        const Color(0xFF26C6DA),
        'Pending todos',
      ),
      _StatItem(
        'Attendance',
        '${stats.attendancePercentage.toStringAsFixed(1)}%',
        Icons.pie_chart_rounded,
        const Color(0xFF66BB6A),
        'Good Standing',
      ),
      _StatItem(
        gradeLabel,
        gradeValue.toStringAsFixed(2),
        Icons.grade_rounded,
        const Color(0xFFFFB74D),
        profile.institutionType == 'school' ||
                profile.institutionType == 'college'
            ? 'Academic Grade'
            : 'Current rank',
      ),
    ];

    final crossCount = screenW > 600 ? 4 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: screenW > 600 ? 1.4 : 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => AnimatedStatCard(
        title: items[i].title,
        value: items[i].value,
        icon: items[i].icon,
        color: items[i].color,
        subtitle: items[i].subtitle,
      ),
    );
  }
}

class _StatItem {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  const _StatItem(this.title, this.value, this.icon, this.color, this.subtitle);
}

class _PomodoroCard extends StatelessWidget {
  final HomeController controller;
  final dynamic stats;
  final bool isDark;
  final ThemeData theme;
  const _PomodoroCard({
    required this.controller,
    required this.stats,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E2D42)
              : AppColors.lightSurfaceVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9575CD).withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stats.isPomodoroRunning
                  ? Icons.timer_rounded
                  : Icons.timer_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pomodoro Focus Session',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stats.isPomodoroRunning
                      ? 'Session in progress... stay focused!'
                      : '${stats.pomodoroMinutesLeft} Min Session Ready',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.togglePomodoroTimer(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9575CD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(stats.isPomodoroRunning ? 'Pause' : 'Start'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Gradient iconGradient;
  final bool isDark;
  final ThemeData theme;
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.iconGradient,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E2D42)
              : AppColors.lightSurfaceVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: iconGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
