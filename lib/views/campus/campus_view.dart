import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/campus_controller.dart';
import '../../models/campus_info_model.dart';
import '../../models/campus_location_model.dart';
import '../../models/faculty_member_model.dart';
import '../../widgets/animation_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class CampusView extends StatefulWidget {
  const CampusView({super.key});

  @override
  State<CampusView> createState() => _CampusViewState();
}

class _CampusViewState extends State<CampusView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  int _selectedTypeIndex = -1; // -1 = all

  static const List<String> _tabs = ['Events', 'Bus', 'Emergency'];

  static const List<IconData> _tabIcons = [
    Icons.event_rounded,
    Icons.directions_bus_rounded,
    Icons.emergency_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<CampusController>().setSection(
          _tabs[_tabController.index],
        );
        _searchCtrl.clear();
        context.read<CampusController>().setSearchQuery('');
        setState(() => _selectedTypeIndex = -1);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface0
        : AppColors.lightSurface;
    final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Consumer<CampusController>(
      builder: (context, ctrl, _) => Scaffold(
        backgroundColor: bg,
        body: NestedScrollView(
          headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Campus',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkOnSurface
                          : AppColors.lightOnSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PulsingDot(color: AppColors.success, size: 7),
                ],
              ),
              actions: [
                _AppBarIconBtn(
                  icon: Icons.notifications_none_rounded,
                  isDark: isDark,
                ),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(104),
                child: Column(
                  children: [
                    // ── Animated Search Bar ──────────────────────────────
                    AnimatedListItem(
                      delay: const Duration(milliseconds: 50),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: _AnimatedSearchBar(
                          ctrl: _searchCtrl,
                          hintText: 'Search ${_tabs[_tabController.index]}…',
                          onChanged: ctrl.setSearchQuery,
                          isDark: isDark,
                          accent: accent,
                        ),
                      ),
                    ),
                    // ── Premium Tab Bar ──────────────────────────────────
                    Container(
                      height: 48,
                      color: surfaceColor.withOpacity(0.0),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        indicatorColor: accent,
                        indicatorWeight: 2.5,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: accent,
                        unselectedLabelColor: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.lightOnSurfaceVariant,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        dividerColor: isDark
                            ? const Color(0xFF1E2D42)
                            : AppColors.lightSurfaceVariant,
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
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoList(
                context,
                theme,
                ctrl.events,
                'event',
                const Color(0xFF7E57C2),
                isDark,
              ),
              _buildBusTab(context, theme, ctrl, isDark),
              _buildEmergencyTab(context, theme, ctrl, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EXPLORE TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildExploreTab(
    BuildContext context,
    ThemeData theme,
    CampusController ctrl,
    bool isDark,
  ) {
    final types = ['department', 'lab', 'library', 'cafeteria', 'building'];
    final typeData = {
      'department': _TypeData(
        'Depts',
        Icons.school_rounded,
        const Color(0xFF4FC3F7),
      ),
      'lab': _TypeData('Labs', Icons.computer_rounded, const Color(0xFFFFB74D)),
      'library': _TypeData(
        'Library',
        Icons.local_library_rounded,
        const Color(0xFFEF5350),
      ),
      'cafeteria': _TypeData(
        'Cafeteria',
        Icons.restaurant_rounded,
        const Color(0xFF66BB6A),
      ),
      'building': _TypeData(
        'Buildings',
        Icons.apartment_rounded,
        const Color(0xFF9575CD),
      ),
    };

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Live Campus Banner ────────────────────────────────
                AnimatedListItem(
                  child: _LiveCampusBanner(isDark: isDark, theme: theme),
                ),
                const SizedBox(height: 20),

                // ── Category Filter Pills ─────────────────────────────
                AnimatedListItem(
                  delay: const Duration(milliseconds: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        label: 'Explore by Category',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 88,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: types.length + 1, // +1 for "All"
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              final selected = _selectedTypeIndex == -1;
                              return _CategoryPill(
                                label: 'All',
                                icon: Icons.grid_view_rounded,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                                selected: selected,
                                onTap: () =>
                                    setState(() => _selectedTypeIndex = -1),
                                isDark: isDark,
                              );
                            }
                            final type = types[i - 1];
                            final data = typeData[type]!;
                            final selected = _selectedTypeIndex == i - 1;
                            return _CategoryPill(
                              label: data.label,
                              icon: data.icon,
                              color: data.color,
                              selected: selected,
                              onTap: () => setState(
                                () =>
                                    _selectedTypeIndex = selected ? -1 : i - 1,
                              ),
                              isDark: isDark,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Favorites ─────────────────────────────────────────
                if (ctrl.favoriteLocations.isNotEmpty) ...[
                  AnimatedListItem(
                    delay: const Duration(milliseconds: 120),
                    child: _SectionLabel(
                      label: '⭐ My Favorites',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),

        // Favorites list
        if (ctrl.favoriteLocations.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => AnimatedListItem(
                  delay: Duration(milliseconds: 120 + i * 50),
                  child: _LocationCard(
                    loc: ctrl.favoriteLocations[i],
                    ctrl: ctrl,
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
                childCount: ctrl.favoriteLocations.length,
              ),
            ),
          ),

        // Section title
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          sliver: SliverToBoxAdapter(
            child: AnimatedListItem(
              delay: const Duration(milliseconds: 160),
              child: _SectionLabel(label: 'All Campus Spaces', isDark: isDark),
            ),
          ),
        ),

        // Filtered locations
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: Builder(
            builder: (_) {
              final filtered = _selectedTypeIndex == -1
                  ? ctrl.filteredLocations
                  : ctrl.filteredLocations
                        .where((l) => l.type == types[_selectedTypeIndex])
                        .toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => AnimatedListItem(
                    delay: Duration(milliseconds: 60 * i),
                    child: _LocationCard(
                      loc: filtered[i],
                      ctrl: ctrl,
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                  childCount: filtered.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FACULTY TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFacultyTab(
    BuildContext context,
    ThemeData theme,
    CampusController ctrl,
    bool isDark,
  ) {
    final faculty = ctrl.filteredFaculty;
    final favorites = ctrl.favoriteFaculty;

    return CustomScrollView(
      slivers: [
        if (favorites.isNotEmpty) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: AnimatedListItem(
                child: _SectionLabel(
                  label: '⭐ Favorite Faculty',
                  isDark: isDark,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => AnimatedListItem(
                  delay: Duration(milliseconds: 40 * i),
                  child: _FacultyChip(
                    f: favorites[i],
                    ctrl: ctrl,
                    isDark: isDark,
                    theme: theme,
                    onTap: () =>
                        _showFacultyDetail(context, theme, favorites[i], ctrl),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: AnimatedListItem(
              delay: const Duration(milliseconds: 80),
              child: _SectionLabel(label: 'All Faculty', isDark: isDark),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => AnimatedListItem(
                delay: Duration(milliseconds: 60 + i * 50),
                child: _FacultyCard(
                  f: faculty[i],
                  ctrl: ctrl,
                  isDark: isDark,
                  theme: theme,
                  onTap: () =>
                      _showFacultyDetail(context, theme, faculty[i], ctrl),
                ),
              ),
              childCount: faculty.length,
            ),
          ),
        ),
      ],
    );
  }

  void _showFacultyDetail(
    BuildContext context,
    ThemeData theme,
    FacultyMemberModel f,
    CampusController ctrl,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _FacultyDetailSheet(f: f, ctrl: ctrl, isDark: isDark, theme: theme),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NOTICES / EVENTS LIST
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildInfoList(
    BuildContext context,
    ThemeData theme,
    List<CampusInfoModel> items,
    String type,
    Color accent,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'notice'
                  ? Icons.notifications_none_rounded
                  : Icons.event_rounded,
              size: 64,
              color:
                  (isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.lightOnSurfaceVariant)
                      .withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No ${type}s found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return AnimatedListItem(
          delay: Duration(milliseconds: 50 * i),
          child: _InfoCard(
            item: item,
            accent: accent,
            isDark: isDark,
            theme: theme,
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUS TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBusTab(
    BuildContext context,
    ThemeData theme,
    CampusController ctrl,
    bool isDark,
  ) {
    final routes = ctrl.busRoutes;
    final reminders = ctrl.busReminders;
    const busColor = Color(0xFF00C897);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedListItem(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: busColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campus Bus Schedules',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          PulsingDot(color: Colors.white, size: 6),
                          const SizedBox(width: 6),
                          Text(
                            '${routes.length} routes available',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () =>
                                _showAddBusReminderDialog(context, ctrl),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.32),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_alert_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Set Reminder',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
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
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddBusReminderDialog(context, ctrl),
                    icon: const Icon(Icons.add_alert_rounded, size: 18),
                    label: const Text(
                      'Set Bus Time Reminder',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: busColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (reminders.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: _SectionLabel(label: 'My Bus Reminders', isDark: isDark),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((_, i) {
                final reminder = reminders[i];
                return AnimatedListItem(
                  delay: Duration(milliseconds: 40 + i * 40),
                  child: _BusRouteCard(
                    route: reminder,
                    isDark: isDark,
                    theme: theme,
                    isReminder: true,
                    onEdit: () => _showAddBusReminderDialog(
                      context,
                      ctrl,
                      existing: reminder,
                    ),
                    onDelete: () {
                      ctrl.deleteBusReminder(reminder.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bus reminder removed')),
                      );
                    },
                  ),
                );
              }, childCount: reminders.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: _SectionLabel(label: 'Campus Bus Routes', isDark: isDark),
            ),
          ),
        ],
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final route = routes[i];
              return AnimatedListItem(
                delay: Duration(milliseconds: 60 + i * 60),
                child: _BusRouteCard(
                  route: route,
                  isDark: isDark,
                  theme: theme,
                ),
              );
            }, childCount: routes.length),
          ),
        ),
        if (routes.isEmpty && reminders.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface1
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E2D42)
                        : AppColors.lightSurfaceVariant,
                  ),
                ),
                child: const Text(
                  'No bus data yet. Tap "Set Bus Time Reminder" to add your own place, stop, and time.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAddBusReminderDialog(
    BuildContext context,
    CampusController ctrl, {
    CampusInfoModel? existing,
  }) {
    final parsed = _parseReminderMeta(existing?.metadata ?? '');
    final placeCtrl = TextEditingController(text: parsed.$1);
    final stopCtrl = TextEditingController(text: parsed.$2);
    TimeOfDay selectedTime = existing != null
        ? TimeOfDay(hour: existing.date.hour, minute: existing.date.minute)
        : TimeOfDay.now();
    int notifyBeforeMinutes = parsed.$3;

    const notifyOptions = [5, 10, 15, 30];
    if (!notifyOptions.contains(notifyBeforeMinutes)) {
      notifyBeforeMinutes = 10;
    }

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

        return StatefulBuilder(
          builder: (ctx, setS) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
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
                    existing == null ? 'Set Bus Reminder' : 'Edit Bus Reminder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: placeCtrl,
                    style: TextStyle(color: textPrimary),
                    decoration: inputDeco('Pickup Place (e.g. City Center)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: stopCtrl,
                    style: TextStyle(color: textPrimary),
                    decoration: inputDeco('Drop Stop (e.g. Gate A)'),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: sheetCtx,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setS(() => selectedTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: inputDeco('Bus Departure Time'),
                      child: Text(
                        selectedTime.format(sheetCtx),
                        style: TextStyle(fontSize: 14, color: textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: notifyBeforeMinutes,
                    decoration: inputDeco('Notify Before'),
                    dropdownColor: isDark
                        ? AppColors.darkSurface2
                        : AppColors.lightSurface,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    items: const [
                      DropdownMenuItem(
                        value: 5,
                        child: Text('5 minutes before'),
                      ),
                      DropdownMenuItem(
                        value: 10,
                        child: Text('10 minutes before'),
                      ),
                      DropdownMenuItem(
                        value: 15,
                        child: Text('15 minutes before'),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text('30 minutes before'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setS(() => notifyBeforeMinutes = val);
                      }
                    },
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
                        final place = placeCtrl.text.trim();
                        final stop = stopCtrl.text.trim();

                        if (place.isEmpty || stop.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter both place and stop'),
                            ),
                          );
                          return;
                        }

                        if (existing == null) {
                          await ctrl.addBusReminder(
                            place: place,
                            stop: stop,
                            departureTime: selectedTime,
                            notifyBeforeMinutes: notifyBeforeMinutes,
                          );
                        } else {
                          await ctrl.updateBusReminder(
                            reminderId: existing.id,
                            place: place,
                            stop: stop,
                            departureTime: selectedTime,
                            notifyBeforeMinutes: notifyBeforeMinutes,
                          );
                        }

                        if (context.mounted) {
                          Navigator.pop(sheetCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                existing == null
                                    ? 'Bus reminder scheduled successfully'
                                    : 'Bus reminder updated successfully',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Save Bus Reminder',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  (String, String, int) _parseReminderMeta(String metadata) {
    final basePart = metadata.split('|').first.trim();
    final segments = basePart.split('->');
    final place = segments.isNotEmpty ? segments.first.trim() : '';
    final stop = segments.length > 1 ? segments[1].trim() : '';

    final notifyMatch = RegExp(r'notify\s*:\s*(\d+)').firstMatch(metadata);
    final notifyBefore = int.tryParse(notifyMatch?.group(1) ?? '') ?? 10;

    return (place, stop, notifyBefore);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EMERGENCY TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmergencyTab(
    BuildContext context,
    ThemeData theme,
    CampusController ctrl,
    bool isDark,
  ) {
    final contacts = ctrl.emergencyContacts;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AnimatedListItem(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF5350).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Tap any contact to call directly',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddEmergencyContactDialog(context, ctrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_ic_call_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add Contact',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (contacts.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface1
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E2D42)
                        : AppColors.lightSurfaceVariant,
                  ),
                ),
                child: const Text(
                  'No emergency contacts yet. Tap "Add Contact" to save a number for one-tap calling.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final contact = contacts[i];
              final colors = [
                const Color(0xFFEF5350),
                const Color(0xFFFFB74D),
                const Color(0xFF4FC3F7),
                const Color(0xFF9575CD),
              ];
              final color = colors[i % colors.length];

              return AnimatedListItem(
                delay: Duration(milliseconds: 60 + i * 60),
                child: _EmergencyCard(
                  contact: contact,
                  color: color,
                  isDark: isDark,
                  theme: theme,
                  onDelete: () {
                    ctrl.deleteEmergencyContact(contact.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emergency contact removed'),
                      ),
                    );
                  },
                ),
              );
            }, childCount: contacts.length),
          ),
        ),
      ],
    );
  }

  void _showAddEmergencyContactDialog(
    BuildContext context,
    CampusController ctrl,
  ) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

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
                'Add Emergency Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: textPrimary),
                decoration: inputDeco(
                  'Contact Name (e.g. Mom, Campus Security)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: textPrimary),
                decoration: inputDeco('Phone Number (e.g. +880123456789)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                style: TextStyle(color: textPrimary),
                decoration: inputDeco('Note (optional)'),
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
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();

                    if (name.isEmpty || phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter both contact name and phone number',
                          ),
                        ),
                      );
                      return;
                    }

                    await ctrl.addEmergencyContact(
                      name: name,
                      phone: phone,
                      note: noteCtrl.text.trim(),
                    );

                    if (context.mounted) {
                      Navigator.pop(sheetCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emergency contact added'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save Contact',
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
}

// ─── Private helper classes ──────────────────────────────────────────────────

class _TypeData {
  final String label;
  final IconData icon;
  final Color color;
  const _TypeData(this.label, this.icon, this.color);
}

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  const _AppBarIconBtn({required this.icon, required this.isDark});

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
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.lightOnSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSearchBar extends StatefulWidget {
  final TextEditingController ctrl;
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final Color accent;

  const _AnimatedSearchBar({
    required this.ctrl,
    required this.hintText,
    required this.onChanged,
    required this.isDark,
    required this.accent,
  });

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: widget.accent.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: widget.ctrl,
          onChanged: (val) {
            widget.onChanged(val);
            setState(() {});
          },
          style: TextStyle(
            color: widget.isDark
                ? AppColors.darkOnSurface
                : AppColors.lightOnSurface,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: widget.isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _focused
                  ? widget.accent
                  : (widget.isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant),
              size: 20,
            ),
            suffixIcon: widget.ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      widget.ctrl.clear();
                      widget.onChanged('');
                      setState(() {});
                    },
                  )
                : null,
            isDense: true,
            filled: true,
            fillColor: widget.isDark
                ? AppColors.darkSurface1
                : AppColors.lightSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: widget.isDark
                    ? const Color(0xFF1E2D42)
                    : AppColors.lightSurfaceVariant,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: widget.isDark
                    ? const Color(0xFF1E2D42)
                    : AppColors.lightSurfaceVariant,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.accent, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

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

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 70,
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.18)
              : (isDark ? AppColors.darkSurface1 : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color
                : (isDark
                      ? const Color(0xFF1E2D42)
                      : AppColors.lightSurfaceVariant),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(selected ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? color
                    : (isDark
                          ? AppColors.darkOnSurfaceVariant
                          : AppColors.lightOnSurfaceVariant),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveCampusBanner extends StatefulWidget {
  final bool isDark;
  final ThemeData theme;
  const _LiveCampusBanner({required this.isDark, required this.theme});

  @override
  State<_LiveCampusBanner> createState() => _LiveCampusBannerState();
}

class _LiveCampusBannerState extends State<_LiveCampusBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _shimmer = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: widget.isDark
            ? AppColors.heroGradientDark
            : AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066CC).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated shimmer overlay
          AnimatedBuilder(
            animation: _shimmer,
            builder: (_, __) => Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(_shimmer.value - 1, -0.5),
                    end: Alignment(_shimmer.value + 1, 0.5),
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Grid pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(color: Colors.white.withOpacity(0.07)),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PulsingDot(color: const Color(0xFF69F0AE), size: 6),
                          const SizedBox(width: 6),
                          const Text(
                            'Campus Live',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Interactive Campus Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Select a category below to explore',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Building icons decoration
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.location_city_rounded,
                size: 120,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 20.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _LocationCard extends StatefulWidget {
  final CampusLocationModel loc;
  final CampusController ctrl;
  final bool isDark;
  final ThemeData theme;

  const _LocationCard({
    required this.loc,
    required this.ctrl,
    required this.isDark,
    required this.theme,
  });

  @override
  State<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<_LocationCard> {
  bool _hovered = false;

  IconData _iconFor(String type) {
    switch (type) {
      case 'lab':
        return Icons.computer_rounded;
      case 'library':
        return Icons.local_library_rounded;
      case 'cafeteria':
        return Icons.restaurant_rounded;
      case 'building':
        return Icons.apartment_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.loc.colorHex);
    final border = widget.isDark
        ? const Color(0xFF1E2D42)
        : AppColors.lightSurfaceVariant;
    final cardColor = widget.isDark
        ? AppColors.darkSurface1
        : AppColors.lightSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _hovered
              ? (widget.isDark
                    ? AppColors.darkSurface2
                    : AppColors.lightSurfaceVariant)
              : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hovered ? color.withOpacity(0.4) : border),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? color.withOpacity(0.15)
                  : Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {},
            splashColor: color.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(_hovered ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconFor(widget.loc.type),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.loc.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: widget.isDark
                                ? AppColors.darkOnSurface
                                : AppColors.lightOnSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.loc.floor,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark
                                ? AppColors.darkOnSurfaceVariant
                                : AppColors.lightOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: widget.isDark
                                  ? AppColors.darkOnSurfaceVariant
                                  : AppColors.lightOnSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                widget.loc.openHours,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.isDark
                                      ? AppColors.darkOnSurfaceVariant
                                      : AppColors.lightOnSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.ctrl.toggleLocationFavorite(widget.loc),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        widget.loc.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        key: ValueKey(widget.loc.isFavorite),
                        color: widget.loc.isFavorite
                            ? Colors.amber
                            : (widget.isDark
                                  ? AppColors.darkOnSurfaceVariant
                                  : AppColors.lightOnSurfaceVariant),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FacultyChip extends StatelessWidget {
  final FacultyMemberModel f;
  final CampusController ctrl;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _FacultyChip({
    required this.f,
    required this.ctrl,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  static const _colors = [
    Color(0xFF4FC3F7),
    Color(0xFF9575CD),
    Color(0xFF66BB6A),
    Color(0xFFFFB74D),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[f.name.codeUnitAt(0) % _colors.length];
    final cardColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark
        ? const Color(0xFF1E2D42)
        : AppColors.lightSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  f.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              f.name.split(' ').last,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              f.department.split(' ').first,
              style: TextStyle(
                fontSize: 9,
                color: isDark
                    ? AppColors.darkOnSurfaceVariant
                    : AppColors.lightOnSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FacultyCard extends StatefulWidget {
  final FacultyMemberModel f;
  final CampusController ctrl;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _FacultyCard({
    required this.f,
    required this.ctrl,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  State<_FacultyCard> createState() => _FacultyCardState();
}

class _FacultyCardState extends State<_FacultyCard> {
  static const _colors = [
    Color(0xFF4FC3F7),
    Color(0xFF9575CD),
    Color(0xFF66BB6A),
    Color(0xFFFFB74D),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[widget.f.name.codeUnitAt(0) % _colors.length];
    final border = widget.isDark
        ? const Color(0xFF1E2D42)
        : AppColors.lightSurfaceVariant;
    final cardColor = widget.isDark
        ? AppColors.darkSurface1
        : AppColors.lightSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.08),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.f.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.f.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: widget.isDark
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.f.designation} • ${widget.f.department}',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.lightOnSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.room_outlined, size: 11, color: color),
                        const SizedBox(width: 3),
                        Text(
                          widget.f.roomNo,
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: widget.isDark
                              ? AppColors.darkOnSurfaceVariant
                              : AppColors.lightOnSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            widget.f.officeHours,
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.isDark
                                  ? AppColors.darkOnSurfaceVariant
                                  : AppColors.lightOnSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () => widget.ctrl.toggleFacultyFavorite(widget.f),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        widget.f.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        key: ValueKey(widget.f.isFavorite),
                        color: widget.f.isFavorite
                            ? Colors.amber
                            : (widget.isDark
                                  ? AppColors.darkOnSurfaceVariant
                                  : AppColors.lightOnSurfaceVariant),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: widget.isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacultyDetailSheet extends StatelessWidget {
  final FacultyMemberModel f;
  final CampusController ctrl;
  final bool isDark;
  final ThemeData theme;

  const _FacultyDetailSheet({
    required this.f,
    required this.ctrl,
    required this.isDark,
    required this.theme,
  });

  static const _colors = [
    Color(0xFF4FC3F7),
    Color(0xFF9575CD),
    Color(0xFF66BB6A),
    Color(0xFFFFB74D),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[f.name.codeUnitAt(0) % _colors.length];
    final bg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark
        ? const Color(0xFF1E2D42)
        : AppColors.lightSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: border)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                f.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            f.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              f.designation,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            f.department,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkOnSurfaceVariant
                  : AppColors.lightOnSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface2
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _InfoRow(
                  Icons.location_on_outlined,
                  'Room',
                  f.roomNo,
                  color,
                  isDark,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  Icons.access_time_rounded,
                  'Office Hours',
                  f.officeHours,
                  color,
                  isDark,
                ),
                const SizedBox(height: 10),
                _InfoRow(Icons.email_outlined, 'Email', f.email, color, isDark),
                const SizedBox(height: 10),
                _InfoRow(Icons.phone_outlined, 'Phone', f.phone, color, isDark),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Email'),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    f.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 18,
                  ),
                  label: Text(f.isFavorite ? 'Unfavorite' : 'Favorite'),
                  onPressed: () {
                    ctrl.toggleFacultyFavorite(f);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _InfoRow(this.icon, this.label, this.value, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: isDark
                ? AppColors.darkOnSurfaceVariant
                : AppColors.lightOnSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.lightOnSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final CampusInfoModel item;
  final Color accent;
  final bool isDark;
  final ThemeData theme;

  const _InfoCard({
    required this.item,
    required this.accent,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark
        ? const Color(0xFF1E2D42)
        : AppColors.lightSurfaceVariant;
    final cardColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withOpacity(0.75)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.date.day}/${item.date.month}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.body,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                if (item.metadata.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        item.metadata,
                        style: TextStyle(
                          fontSize: 12,
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusRouteCard extends StatelessWidget {
  final CampusInfoModel route;
  final bool isDark;
  final ThemeData theme;
  final bool isReminder;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _BusRouteCard({
    required this.route,
    required this.isDark,
    required this.theme,
    this.isReminder = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF00C897);
    final border = isDark
        ? const Color(0xFF1E2D42)
        : AppColors.lightSurfaceVariant;
    final cardColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReminder ? 'Reminder: ${route.title}' : route.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    route.metadata.split('|').first.trim(),
                    style: const TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  route.body,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                if (isReminder && (onEdit != null || onDelete != null)) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (onEdit != null)
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: Color(0xFF4FC3F7),
                          ),
                          label: const Text(
                            'Edit Reminder',
                            style: TextStyle(
                              color: Color(0xFF4FC3F7),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 24),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (onDelete != null)
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                          label: const Text(
                            'Remove Reminder',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 24),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final CampusInfoModel contact;
  final Color color;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback? onDelete;

  const _EmergencyCard({
    required this.contact,
    required this.color,
    required this.isDark,
    required this.theme,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark
        ? const Color(0xFF1E2D42)
        : AppColors.lightSurfaceVariant;
    final cardColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final raw = contact.metadata.trim();
          final phone = raw.replaceAll(RegExp(r'[^0-9+]'), '');
          if (phone.isEmpty) return;

          final uri = Uri.parse('tel:$phone');
          final launched = await launchUrl(uri);
          if (!launched && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to open dialer on this device'),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.1),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkOnSurface
                            : AppColors.lightOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.body,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkOnSurfaceVariant
                            : AppColors.lightOnSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  contact.metadata,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
