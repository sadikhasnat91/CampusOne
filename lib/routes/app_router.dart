import 'package:flutter/material.dart';
import '../views/auth/auth_wrapper.dart';
import '../views/auth/splash_view.dart';
import '../views/auth/onboarding_view.dart';
import '../views/main_navigation_shell.dart';
import '../views/expense/expense_view.dart';
import '../views/cover_page/cover_page_list_view.dart';
import '../views/cover_page/cover_page_editor_view.dart';
import '../models/cover_page_model.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingView());
      case AppRoutes.initial:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case AppRoutes.expenseTracker:
        return MaterialPageRoute(builder: (_) => const ExpenseTrackerView());
      case AppRoutes.coverPages:
        return MaterialPageRoute(builder: (_) => const CoverPageListView());
      case AppRoutes.coverPageEditor:
        final template = settings.arguments as CoverPageModel;
        return MaterialPageRoute(builder: (_) => CoverPageEditorView(initialTemplate: template));
      case AppRoutes.mainShell:
      default:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationShell(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
    }
  }
}
