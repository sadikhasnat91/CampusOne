import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_strings.dart';
import 'controllers/academic_controller.dart';
import 'controllers/app_state_controller.dart';
import 'controllers/campus_controller.dart';
import 'controllers/cover_page_controller.dart';
import 'controllers/expense_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/main_navigation_controller.dart';
import 'controllers/notes_controller.dart';
import 'controllers/productivity_controller.dart';
import 'controllers/routine_controller.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'services/app_initializer.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(const CampusOneApp());
}

class CampusOneApp extends StatelessWidget {
  const CampusOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => MainNavigationController()),
        ChangeNotifierProvider(create: (_) => AppStateController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => RoutineController()),
        ChangeNotifierProvider(create: (_) => AcademicController()),
        ChangeNotifierProvider(create: (_) => ProductivityController()),
        ChangeNotifierProvider(create: (_) => NotesController()),
        ChangeNotifierProvider(create: (_) => CampusController()),
        ChangeNotifierProvider(create: (_) => ExpenseController()),
        ChangeNotifierProvider(create: (_) => CoverPageController()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeManager.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
