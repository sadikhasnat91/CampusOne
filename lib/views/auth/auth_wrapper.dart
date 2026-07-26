import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_state_controller.dart';
import '../main_navigation_shell.dart';
import '../../constants/app_dimensions.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final ctrl = context.read<AppStateController>();
    if (ctrl.isAppLockEnabled && !ctrl.isAuthenticated) {
      await ctrl.authenticate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateController>(
      builder: (context, ctrl, child) {
        if (ctrl.isAppLockEnabled && !ctrl.isAuthenticated) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 80, color: Colors.grey),
                  const SizedBox(height: AppDimensions.lg),
                  const Text('App Locked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppDimensions.sm),
                  const Text('Authenticate to access CampusOne', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: AppDimensions.xl),
                  ElevatedButton.icon(
                    onPressed: _checkAuth,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('Unlock'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const MainNavigationShell();
      },
    );
  }
}
