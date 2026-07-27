import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../controllers/main_navigation_controller.dart';
import 'home/home_view.dart';
import 'study/study_view.dart';
import 'campus/campus_view.dart';
import 'planner/planner_view.dart';
import 'notes/notes_view.dart';
import 'profile/profile_view.dart';
import 'search/global_search_delegate.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  static const List<Widget> _pages = [
    HomeView(),
    StudyView(),
    CampusView(),
    PlannerView(),
    NotesView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final navController = Provider.of<MainNavigationController>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBackground,
      body: IndexedStack(index: navController.currentIndex, children: _pages),
      floatingActionButton: _PremiumFAB(
        onTap: () =>
            showSearch(context: context, delegate: GlobalSearchDelegate()),
        isDark: isDark,
      ),
      bottomNavigationBar: _PremiumNavBar(
        currentIndex: navController.currentIndex,
        onTap: navController.changeTab,
        isDark: isDark,
      ),
    );
  }
}

class _PremiumFAB extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  const _PremiumFAB({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066CC).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withOpacity(0.2),
          child: const Center(
            child: Icon(Icons.search_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;
  const _PremiumNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, AppStrings.navHome),
    _NavItem(Icons.school_outlined, Icons.school_rounded, AppStrings.navStudy),
    _NavItem(
      Icons.location_city_outlined,
      Icons.location_city_rounded,
      AppStrings.navCampus,
    ),
    _NavItem(
      Icons.calendar_month_outlined,
      Icons.calendar_month_rounded,
      AppStrings.navPlanner,
    ),
    _NavItem(
      Icons.sticky_note_2_outlined,
      Icons.sticky_note_2_rounded,
      AppStrings.navNotes,
    ),
    _NavItem(
      Icons.person_outline_rounded,
      Icons.person_rounded,
      AppStrings.navProfile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkSurface0 : AppColors.lightSurface;
    final selectedColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final unselectedColor = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;
    final borderColor = isDark
        ? const Color(0xFF1A2535)
        : const Color(0xFFE0E8F0);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == currentIndex;
              final item = _items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? selectedColor.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          size: 22,
                          color: selected ? selectedColor : unselectedColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: selected ? selectedColor : unselectedColor,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
