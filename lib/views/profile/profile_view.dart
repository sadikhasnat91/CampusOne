import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../theme/theme_manager.dart';
import '../../controllers/app_state_controller.dart';
import '../../services/backup_service.dart';
import '../../helpers/snackbar_helper.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeManager = Provider.of<ThemeManager>(context);
    final appState = Provider.of<AppStateController>(context);

    final bg = isDark ? AppColors.darkBg : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final border = isDark ? const Color(0xFF1E2D42) : AppColors.lightSurfaceVariant;
    final textPrimary = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final textSecondary = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final accent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          'Settings & Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Profile Header ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.heroGradientDark : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066CC).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campus Student',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student ID: #2026-CAMPUS-01',
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

            const SizedBox(height: 28),

            // ── Preferences ──────────────────────────────────────────────
            _SectionLabel(label: 'Preferences', accent: accent),
            const SizedBox(height: 10),
            _SettingsGroup(
              cardColor: cardColor,
              border: border,
              children: [
                _SettingsSwitchTile(
                  icon: themeManager.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  iconColor: const Color(0xFF9575CD),
                  title: 'Dark Theme Mode',
                  subtitle: 'Toggle dark and light visual mode',
                  value: themeManager.isDarkMode,
                  onChanged: (val) => themeManager.toggleTheme(val),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                ),
                Divider(height: 1, color: border),
                _SettingsSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  iconColor: const Color(0xFF4FC3F7),
                  title: 'Push Notifications',
                  subtitle: 'Receive reminders and updates',
                  value: appState.notificationsEnabled,
                  onChanged: (val) => appState.toggleNotifications(val),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Security ─────────────────────────────────────────────────
            _SectionLabel(label: 'Security', accent: accent),
            const SizedBox(height: 10),
            _SettingsGroup(
              cardColor: cardColor,
              border: border,
              children: [
                _SettingsSwitchTile(
                  icon: Icons.fingerprint_rounded,
                  iconColor: const Color(0xFF26C6DA),
                  title: 'Biometric App Lock',
                  subtitle: 'Require authentication to open the app',
                  value: appState.isAppLockEnabled,
                  onChanged: (val) => appState.toggleAppLock(val),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Data Management ───────────────────────────────────────────
            _SectionLabel(label: 'Data Management', accent: accent),
            const SizedBox(height: 10),
            _SettingsGroup(
              cardColor: cardColor,
              border: border,
              children: [
                _SettingsNavTile(
                  icon: Icons.backup_outlined,
                  iconColor: const Color(0xFF66BB6A),
                  title: 'Backup Data',
                  subtitle: 'Export a .campusone backup file',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                  onTap: () async {
                    try {
                      await BackupService.createBackup();
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarHelper.showError(context, 'Backup Failed: $e');
                      }
                    }
                  },
                ),
                Divider(height: 1, color: border),
                _SettingsNavTile(
                  icon: Icons.restore_page_outlined,
                  iconColor: const Color(0xFFFFB74D),
                  title: 'Restore Data',
                  subtitle: 'Import a previous backup file',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                  onTap: () async {
                    try {
                      final success = await BackupService.restoreBackup();
                      if (success && context.mounted) {
                        SnackbarHelper.showSuccess(
                          context,
                          'Restore Successful! Restart the app to see changes.',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        SnackbarHelper.showError(context, 'Restore Failed: $e');
                      }
                    }
                  },
                ),
                Divider(height: 1, color: border),
                _SettingsNavTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF8A9BBE),
                  title: 'About CampusOne',
                  subtitle: 'Version 1.0.0+1 • Production Ready',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                  onTap: null,
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable setting components ──────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color accent;
  const _SectionLabel({required this.label, required this.accent});

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
            color: accent,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final Color cardColor;
  final Color border;
  const _SettingsGroup({required this.children, required this.cardColor, required this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const _SettingsSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
          ),
        ],
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const _SettingsNavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: textSecondary)),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
