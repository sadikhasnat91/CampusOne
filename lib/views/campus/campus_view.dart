import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../controllers/campus_controller.dart';
import '../../models/campus_info_model.dart';
import '../../models/campus_location_model.dart';
import '../../models/faculty_member_model.dart';

class CampusView extends StatefulWidget {
  const CampusView({super.key});

  @override
  State<CampusView> createState() => _CampusViewState();
}

class _CampusViewState extends State<CampusView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  final List<String> _tabs = [
    'Faculty', 'Notices', 'Events', 'Bus', 'Emergency', 'Explore',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<CampusController>().setSection(_tabs[_tabController.index]);
        _searchCtrl.clear();
        context.read<CampusController>().setSearchQuery('');
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
    return Consumer<CampusController>(
      builder: (context, ctrl, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Campus', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(96),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: ctrl.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search ${_tabs[_tabController.index]}…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                ctrl.setSearchQuery('');
                              },
                            )
                          : null,
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFacultyTab(context, theme, ctrl),
            _buildNoticesTab(context, theme, ctrl),
            _buildEventsTab(context, theme, ctrl),
            _buildBusTab(context, theme, ctrl),
            _buildEmergencyTab(context, theme, ctrl),
            _buildExploreTab(context, theme, ctrl),
          ],
        ),
      ),
    );
  }

  // ─── FACULTY TAB ────────────────────────────────────────────────────────
  Widget _buildFacultyTab(BuildContext context, ThemeData theme, CampusController ctrl) {
    final faculty = ctrl.filteredFaculty;
    final favorites = ctrl.favoriteFaculty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (favorites.isNotEmpty) ...[
            _sectionHeader(theme, '⭐ Favorite Faculty', Icons.star_rounded, Colors.amber),
            const SizedBox(height: AppDimensions.sm),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppDimensions.sm),
                itemBuilder: (context, i) => _facultyChip(context, theme, favorites[i], ctrl),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
          _sectionHeader(theme, 'All Faculty', Icons.people_rounded, theme.colorScheme.primary),
          const SizedBox(height: AppDimensions.sm),
          ...faculty.map((f) => _facultyCard(context, theme, f, ctrl)),
        ],
      ),
    );
  }

  Widget _facultyChip(BuildContext context, ThemeData theme, FacultyMemberModel f, CampusController ctrl) {
    return GestureDetector(
      onTap: () => _showFacultyDetail(context, theme, f, ctrl),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              child: Text(f.name[0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 6),
            Text(f.name.split(' ').last, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(f.department, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant), maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _facultyCard(BuildContext context, ThemeData theme, FacultyMemberModel f, CampusController ctrl) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(f.name[0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${f.designation} • ${f.department}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => ctrl.toggleFacultyFavorite(f),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    f.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    key: ValueKey(f.isFavorite),
                    color: f.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
          onTap: () => _showFacultyDetail(context, theme, f, ctrl),
        ),
      ),
    );
  }

  void _showFacultyDetail(BuildContext context, ThemeData theme, FacultyMemberModel f, CampusController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: AppDimensions.lg),
            CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(f.name[0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 32)),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(f.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(f.designation, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            Text(f.department, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppDimensions.lg),
            _infoRow(theme, Icons.location_on_outlined, 'Room', f.roomNo),
            _infoRow(theme, Icons.access_time_rounded, 'Office Hours', f.officeHours),
            _infoRow(theme, Icons.email_outlined, 'Email', f.email),
            _infoRow(theme, Icons.phone_outlined, 'Phone', f.phone),
            const SizedBox(height: AppDimensions.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email'),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(f.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded),
                    label: Text(f.isFavorite ? 'Unfavorite' : 'Favorite'),
                    onPressed: () {
                      ctrl.toggleFacultyFavorite(f);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppDimensions.sm),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // ─── NOTICES TAB ────────────────────────────────────────────────────────
  Widget _buildNoticesTab(BuildContext context, ThemeData theme, CampusController ctrl) {
    return _buildInfoList(context, theme, ctrl.notices, 'notice', const Color(0xFF0061A4));
  }

  // ─── EVENTS TAB ─────────────────────────────────────────────────────────
  Widget _buildEventsTab(BuildContext context, ThemeData theme, CampusController ctrl) {
    return _buildInfoList(context, theme, ctrl.events, 'event', const Color(0xFF5856D6));
  }

  Widget _buildInfoList(BuildContext context, ThemeData theme, List<CampusInfoModel> items, String type, Color accent) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type == 'notice' ? Icons.notifications_none_rounded : Icons.event_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppDimensions.md),
            Text('No ${type}s found', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + i * 50),
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.7)]),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMd)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Text(
                        '${item.date.day}/${item.date.month}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.body, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 13, height: 1.5)),
                      if (item.metadata.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.sm),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(item.metadata, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── BUS TAB ────────────────────────────────────────────────────────────
  Widget _buildBusTab(BuildContext context, ThemeData theme, CampusController ctrl) {
    final routes = ctrl.busRoutes;
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: routes.length,
      itemBuilder: (_, i) {
        final route = routes[i];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + i * 60),
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: const Icon(Icons.directions_bus_rounded, color: Color(0xFF2E7D32), size: 28),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(route.metadata, style: TextStyle(color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(route.body, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── EMERGENCY TAB ──────────────────────────────────────────────────────
  Widget _buildEmergencyTab(BuildContext context, ThemeData theme, CampusController ctrl) {
    final contacts = ctrl.emergencyContacts;
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: contacts.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.md),
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFBA1A1A), Color(0xFFE32929)]),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Emergency Contacts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Tap any contact to call directly', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final contact = contacts[i - 1];
        final colors = [const Color(0xFFBA1A1A), const Color(0xFFED6C02), const Color(0xFF0061A4), const Color(0xFF5856D6)];
        final color = colors[(i - 1) % colors.length];

        return AnimatedContainer(
          duration: Duration(milliseconds: 150 + i * 60),
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.phone_rounded, color: color, size: 22),
              ),
              title: Text(contact.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(contact.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(contact.metadata, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── EXPLORE/MAP TAB ────────────────────────────────────────────────────
  Widget _buildExploreTab(BuildContext context, ThemeData theme, CampusController ctrl) {
    final types = ['department', 'lab', 'library', 'cafeteria', 'building'];
    final typeIcons = {
      'department': (Icons.school_rounded, const Color(0xFF0061A4)),
      'lab': (Icons.computer_rounded, const Color(0xFFED6C02)),
      'library': (Icons.local_library_rounded, const Color(0xFFBA1A1A)),
      'cafeteria': (Icons.restaurant_rounded, const Color(0xFF2E7D32)),
      'building': (Icons.apartment_rounded, const Color(0xFF5856D6)),
    };
    final typeLabels = {
      'department': 'Departments',
      'lab': 'Labs',
      'library': 'Library',
      'cafeteria': 'Cafeteria',
      'building': 'Buildings',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campus Map Placeholder Banner
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                _buildMapGrid(theme),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_rounded, size: 40, color: theme.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('Interactive Campus Map', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      Text('Tap a building to get directions', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Quick Category Chips
          Text('Explore by Category', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: types.map((type) {
              final (icon, color) = typeIcons[type]!;
              return GestureDetector(
                onTap: () => _showLocationsByType(context, theme, ctrl, type, typeLabels[type]!, color),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(typeLabels[type]!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Favorites
          if (ctrl.favoriteLocations.isNotEmpty) ...[
            _sectionHeader(theme, '⭐ My Favorites', Icons.star_rounded, Colors.amber),
            const SizedBox(height: AppDimensions.sm),
            ...ctrl.favoriteLocations.map((loc) => _locationCard(context, theme, loc, ctrl)),
          ],

          const SizedBox(height: AppDimensions.sm),
          _sectionHeader(theme, 'All Campus Spaces', Icons.business_rounded, theme.colorScheme.primary),
          const SizedBox(height: AppDimensions.sm),
          ...ctrl.filteredLocations.map((loc) => _locationCard(context, theme, loc, ctrl)),
        ],
      ),
    );
  }

  void _showLocationsByType(BuildContext context, ThemeData theme, CampusController ctrl, String type, String label, Color color) {
    final locations = ctrl.locationsByType(type);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(AppDimensions.md),
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: AppDimensions.md), decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(4)))),
            Row(children: [
              Icon(Icons.business_rounded, color: color),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: AppDimensions.md),
            ...locations.map((loc) => _locationCard(context, theme, loc, ctrl)),
          ],
        ),
      ),
    );
  }

  Widget _locationCard(BuildContext context, ThemeData theme, CampusLocationModel loc, CampusController ctrl) {
    final color = Color(loc.colorHex);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(_iconFor(loc.type), color: color, size: 24),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(loc.floor, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time_outlined, size: 11, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(loc.openHours, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ctrl.toggleLocationFavorite(loc),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    loc.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    key: ValueKey(loc.isFavorite),
                    color: loc.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'lab': return Icons.computer_rounded;
      case 'library': return Icons.local_library_rounded;
      case 'cafeteria': return Icons.restaurant_rounded;
      case 'building': return Icons.apartment_rounded;
      default: return Icons.school_rounded;
    }
  }

  Widget _buildMapGrid(ThemeData theme) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: CustomPaint(
          painter: _MapGridPainter(
            lineColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            blockColors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.08),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final Color lineColor;
  final List<Color> blockColors;

  _MapGridPainter({required this.lineColor, required this.blockColors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const cols = 8;
    const rows = 5;
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final radius = const Radius.circular(3);

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        paint.color = blockColors[(c + r) % blockColors.length];
        canvas.drawRRect(
          RRect.fromLTRBR(
            c * cellW + 3, r * cellH + 3,
            (c + 1) * cellW - 3, (r + 1) * cellH - 3,
            radius,
          ),
          paint,
        );
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;
    for (var c = 1; c < cols; c++) {
      canvas.drawLine(Offset(c * cellW, 0), Offset(c * cellW, size.height), linePaint);
    }
    for (var r = 1; r < rows; r++) {
      canvas.drawLine(Offset(0, r * cellH), Offset(size.width, r * cellH), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
