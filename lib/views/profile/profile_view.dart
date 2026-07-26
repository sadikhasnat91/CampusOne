import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_dimensions.dart';
import '../../theme/theme_manager.dart';
import '../../widgets/custom_card.dart';
import '../../controllers/app_state_controller.dart';
import '../../services/backup_service.dart';
import '../../helpers/snackbar_helper.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final appState = Provider.of<AppStateController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.person_rounded, size: 36, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Campus Student', style: theme.textTheme.titleMedium),
                        Text('Student ID: #2026-CAMPUS-01', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Preferences
            Text('Preferences', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.sm),
            CustomCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark Theme Mode'),
                    subtitle: const Text('Toggle dark and light visual mode'),
                    secondary: Icon(
                      themeManager.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    ),
                    value: themeManager.isDarkMode,
                    onChanged: (val) => themeManager.toggleTheme(val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive reminders and updates'),
                    secondary: const Icon(Icons.notifications_active_outlined),
                    value: appState.notificationsEnabled,
                    onChanged: (val) => appState.toggleNotifications(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Security
            Text('Security', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.sm),
            CustomCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Biometric App Lock'),
                subtitle: const Text('Require authentication to open the app'),
                secondary: const Icon(Icons.fingerprint_rounded),
                value: appState.isAppLockEnabled,
                onChanged: (val) => appState.toggleAppLock(val),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Data Management
            Text('Data Management', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimensions.sm),
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.backup_outlined),
                    title: const Text('Backup Data'),
                    subtitle: const Text('Export a .campusone backup file'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      try {
                        await BackupService.createBackup();
                      } catch (e) {
                        if (context.mounted) SnackbarHelper.showError(context, 'Backup Failed: $e');
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restore_page_outlined),
                    title: const Text('Restore Data'),
                    subtitle: const Text('Import a previous backup file'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      try {
                        final success = await BackupService.restoreBackup();
                        if (success && context.mounted) {
                          SnackbarHelper.showSuccess(context, 'Restore Successful! Restart the app to see changes.');
                        }
                      } catch (e) {
                        if (context.mounted) SnackbarHelper.showError(context, 'Restore Failed: $e');
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About CampusOne'),
                    subtitle: const Text('Version 1.0.0+1 • Production Ready'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}
