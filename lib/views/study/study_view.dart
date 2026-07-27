import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/routine_controller.dart';
import '../../helpers/snackbar_helper.dart';
import '../../models/routine_item_model.dart';
import '../../services/routine_pdf_service.dart';
import '../../widgets/animation_widgets.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/routine_item_card.dart';
import 'widgets/add_edit_routine_dialog.dart';

class StudyView extends StatefulWidget {
  const StudyView({super.key});

  @override
  State<StudyView> createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView>
    with SingleTickerProviderStateMixin {
  late final TabController _dayTabCtrl;

  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  static const List<String> _dayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _dayTabCtrl = TabController(length: _days.length, vsync: this);
    _dayTabCtrl.addListener(() {
      if (!_dayTabCtrl.indexIsChanging) {
        context.read<RoutineController>().setSelectedDay(_days[_dayTabCtrl.index]);
      }
    });
  }

  @override
  void dispose() {
    _dayTabCtrl.dispose();
    super.dispose();
  }

  void _showAddEditDialog(BuildContext context, RoutineController ctrl,
      {RoutineItemModel? item}) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditRoutineDialog(
        item: item,
        activeSemester: ctrl.selectedSemester,
        activeSection: ctrl.selectedSection,
        activeGroup: ctrl.selectedGroup,
        onSave: (newItem) {
          ctrl.addOrUpdateRoutine(newItem);
          SnackbarHelper.showSuccess(
            context,
            item == null ? 'Class Added!' : 'Class Updated!',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark ? const Color(0xFF1E2D42) : AppColors.lightSurfaceVariant;
    final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final textSecondary = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    final profile = Provider.of<HomeController>(context).profile;

    return Consumer<RoutineController>(
      builder: (context, controller, _) {
        final filtered = controller.filteredRoutines;

        return Scaffold(
          backgroundColor: bg,
          floatingActionButton: _PremiumFAB(
            onTap: () => _showAddEditDialog(context, controller),
            isDark: isDark,
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
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_view_week_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Routine Generator',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                actions: [
                  _AppBarBtn(
                    icon: controller.showFavoritesOnly
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: controller.showFavoritesOnly ? Colors.amber : null,
                    isDark: isDark,
                    onTap: controller.toggleFavoritesOnly,
                    tooltip: 'Favorites',
                  ),
                  _AppBarBtn(
                    icon: Icons.picture_as_pdf_rounded,
                    isDark: isDark,
                    color: const Color(0xFFEF5350),
                    onTap: () {
                      if (filtered.isEmpty) {
                        SnackbarHelper.showError(
                            context, 'No routine slots to export!');
                        return;
                      }
                      RoutinePdfService.exportAndPrintPdf(
                        routines: filtered,
                        semester: controller.selectedSemester,
                        section: controller.selectedSection,
                        group: controller.selectedGroup,
                      );
                    },
                    tooltip: 'Export PDF',
                  ),
                  const SizedBox(width: 4),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(132),
                  child: Column(
                    children: [
                      // ── Filter Row ──────────────────────────────────────
                      AnimatedListItem(
                        delay: const Duration(milliseconds: 30),
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _FilterDropdown(
                                  label: profile.academicLevelLabel,
                                  value: controller.selectedSemester,
                                  items: profile.academicLevelOptions,
                                  isDark: isDark,
                                  accent: accent,
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.updateStudentProfileFilter(
                                        val,
                                        controller.selectedSection,
                                        controller.selectedGroup,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Section',
                                  value: controller.selectedSection,
                                  items: const ['A', 'B', 'C', 'D'],
                                  isDark: isDark,
                                  accent: accent,
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.updateStudentProfileFilter(
                                        controller.selectedSemester,
                                        val,
                                        controller.selectedGroup,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _FilterDropdown(
                                  label: 'Group',
                                  value: controller.selectedGroup,
                                  items: const ['Group 1', 'Group 2'],
                                  isDark: isDark,
                                  accent: accent,
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.updateStudentProfileFilter(
                                        controller.selectedSemester,
                                        controller.selectedSection,
                                        val,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ── View Mode + Day Tabs ────────────────────────────
                      AnimatedListItem(
                        delay: const Duration(milliseconds: 60),
                        child: Container(
                          height: 46,
                          color: Colors.transparent,
                          child: _buildDayTabs(controller, isDark, accent, textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: _buildBody(
                context, controller, filtered, isDark, accent, textPrimary, textSecondary, border),
          ),
        );
      },
    );
  }

  Widget _buildDayTabs(RoutineController ctrl, bool isDark, Color accent, Color textSecondary) {
    return Row(
      children: [
        // View mode toggle
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: _ViewModeToggle(
            mode: ctrl.viewMode,
            isDark: isDark,
            accent: accent,
            onChanged: ctrl.setViewMode,
          ),
        ),
        // Day tabs (when daily)
        if (ctrl.viewMode == RoutineViewMode.daily)
          Expanded(
            child: TabBar(
              controller: _dayTabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: accent,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: accent,
              unselectedLabelColor: textSecondary,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              dividerColor: Colors.transparent,
              tabs: _dayShort.map((d) => Tab(text: d)).toList(),
            ),
          )
        else
          const Spacer(),
        // Import button
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Material(
            color: isDark
                ? AppColors.darkSurface1.withOpacity(0.8)
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                context.read<RoutineController>().importMasterRoutineSamples();
                SnackbarHelper.showSuccess(
                    context, 'Master Routine Imported!');
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.cloud_download_rounded,
                    size: 18, color: accent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    RoutineController ctrl,
    List<RoutineItemModel> filtered,
    bool isDark,
    Color accent,
    Color textPrimary,
    Color textSecondary,
    Color border,
  ) {
    if (ctrl.viewMode == RoutineViewMode.weekly) {
      return _buildWeeklyView(context, ctrl, isDark, accent, textPrimary, textSecondary, border);
    }
    if (ctrl.viewMode == RoutineViewMode.calendar) {
      return _buildGridView(context, ctrl, isDark, accent, textPrimary, textSecondary, border);
    }

    // Daily view
    if (filtered.isEmpty) {
      return EmptyStateWidget(
        title: 'No Classes Today',
        description:
            'No scheduled classes for ${ctrl.selectedDay}.\n${ctrl.selectedSemester} • Sec ${ctrl.selectedSection} • ${ctrl.selectedGroup}',
        icon: Icons.calendar_today_outlined,
        actionLabel: 'Add Class',
        onAction: () => _showAddEditDialog(context, ctrl),
      );
    }

    return CustomScrollView(
      slivers: [
        // Stats bar
        SliverToBoxAdapter(
          child: AnimatedListItem(
            child: _DayStatsBar(
              count: filtered.length,
              day: ctrl.selectedDay,
              isDark: isDark,
              accent: accent,
              textSecondary: textSecondary,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => AnimatedListItem(
                key: ValueKey('${ctrl.selectedDay}_$i'),
                delay: Duration(milliseconds: 50 * i),
                child: RoutineItemCard(
                  routine: filtered[i],
                  onFavoriteToggle: () => ctrl.toggleFavorite(filtered[i]),
                  onEdit: () => _showAddEditDialog(context, ctrl, item: filtered[i]),
                  onDelete: () => ctrl.deleteRoutine(filtered[i].id),
                ),
              ),
              childCount: filtered.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyView(
    BuildContext context,
    RoutineController ctrl,
    bool isDark,
    Color accent,
    Color textPrimary,
    Color textSecondary,
    Color border,
  ) {
    final surfaceColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Column(
        children: List.generate(_days.length, (di) {
          final day = _days[di];
          final dayItems = ctrl.allRoutines
              .where((r) =>
                  r.dayOfWeek == day &&
                  r.semester == ctrl.selectedSemester &&
                  r.section == ctrl.selectedSection &&
                  r.group == ctrl.selectedGroup)
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          return AnimatedListItem(
            delay: Duration(milliseconds: 60 * di),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _dayShort[di],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${dayItems.length} class${dayItems.length != 1 ? 'es' : ''}',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (dayItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Text(
                        'No classes scheduled',
                        style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    ...dayItems.map((item) {
                      final color = Color(item.colorHex);
                      return Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14, 0, 14, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.subjectName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.startTime}–${item.endTime} • ${item.roomNo}',
                                    style: TextStyle(
                                        fontSize: 11, color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    RoutineController ctrl,
    bool isDark,
    Color accent,
    Color textPrimary,
    Color textSecondary,
    Color border,
  ) {
    final allItems = ctrl.filteredRoutines;
    final surfaceColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;

    if (allItems.isEmpty) {
      return EmptyStateWidget(
        title: 'No Classes',
        description: 'Add classes to see them in grid view',
        icon: Icons.grid_view_rounded,
        actionLabel: 'Add Class',
        onAction: () => _showAddEditDialog(context, ctrl),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: allItems.length,
        itemBuilder: (_, i) {
          final item = allItems[i];
          final color = Color(item.colorHex);
          return AnimatedListItem(
            delay: Duration(milliseconds: 40 * i),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
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
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          item.dayOfWeek.substring(0, 3),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subjectName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '${item.startTime}–${item.endTime}',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    item.teacherName,
                    style: TextStyle(fontSize: 10, color: textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final Color? color;
  final VoidCallback onTap;
  final String tooltip;

  const _AppBarBtn({
    required this.icon,
    required this.isDark,
    required this.onTap,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Material(
        color: isDark
            ? AppColors.darkSurface1.withOpacity(0.6)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon,
                size: 20,
                color: color ??
                    (isDark
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface)),
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final bool isDark;
  final Color accent;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.isDark,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final textPrimary =
        isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            isDense: true,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
            dropdownColor:
                isDark ? AppColors.darkSurface2 : AppColors.lightSurface,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: accent),
            items: items
                .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.replaceFirst(' Semester', ' Sem'),
                        style: TextStyle(fontSize: 12, color: textPrimary),
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  final RoutineViewMode mode;
  final bool isDark;
  final Color accent;
  final ValueChanged<RoutineViewMode> onChanged;

  const _ViewModeToggle({
    required this.mode,
    required this.isDark,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final modes = RoutineViewMode.values;
    final icons = [
      Icons.view_day_rounded,
      Icons.view_week_rounded,
      Icons.grid_view_rounded,
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface1 : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(modes.length, (i) {
          final selected = mode == modes[i];
          return GestureDetector(
            onTap: () => onChanged(modes[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                icons[i],
                size: 16,
                color: selected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DayStatsBar extends StatelessWidget {
  final int count;
  final String day;
  final bool isDark;
  final Color accent;
  final Color textSecondary;

  const _DayStatsBar({
    required this.count,
    required this.day,
    required this.isDark,
    required this.accent,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 14, color: textSecondary),
          const SizedBox(width: 5),
          Text(
            '$count class${count != 1 ? 'es' : ''} on $day',
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
          const Spacer(),
          AnimatedCounter(
            target: count,
            suffix: ' slots',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFAB extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _PremiumFAB({required this.onTap, required this.isDark});

  @override
  State<_PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<_PremiumFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B1FA2).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Class',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
