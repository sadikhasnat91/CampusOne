import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_strings.dart';
import '../controllers/main_navigation_controller.dart';
import 'home/home_view.dart';
import 'study/study_view.dart';
import 'planner/planner_view.dart';
import 'notes/notes_view.dart';
import 'campus/campus_view.dart';
import 'profile/profile_view.dart';
import 'search/global_search_delegate.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  final List<Widget> _pages = const [
    HomeView(),
    StudyView(),
    PlannerView(),
    NotesView(),
    CampusView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final navController = Provider.of<MainNavigationController>(context);

    return Scaffold(
      body: IndexedStack(
        index: navController.currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Search Everywhere',
        onPressed: () {
          showSearch(
            context: context,
            delegate: GlobalSearchDelegate(),
          );
        },
        child: const Icon(Icons.search_rounded),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navController.currentIndex,
        onDestinationSelected: (index) => navController.changeTab(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: AppStrings.navStudy,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: AppStrings.navPlanner,
          ),
          NavigationDestination(
            icon: Icon(Icons.sticky_note_2_outlined),
            selectedIcon: Icon(Icons.sticky_note_2_rounded),
            label: AppStrings.navNotes,
          ),
          NavigationDestination(
            icon: Icon(Icons.location_city_outlined),
            selectedIcon: Icon(Icons.location_city_rounded),
            label: 'Campus',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: AppStrings.navProfile,
          ),
        ],
      ),
    );
  }
}
