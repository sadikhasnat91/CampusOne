import 'package:flutter/material.dart';
import '../database/hive_service.dart';
import '../models/app_settings_model.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeManager() {
    _loadThemeFromHive();
  }

  void _loadThemeFromHive() {
    final box = HiveService.instance.appSettingsBox;
    final settings = box.get('settings');

    if (settings != null) {
      switch (settings.themeMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final box = HiveService.instance.appSettingsBox;
    final settings = box.get('settings') ??
        AppSettingsModel(
          themeMode: 'system',
          isFirstRun: false,
          lastOpened: DateTime.now(),
        );

    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';

    await box.put(
      'settings',
      settings.copyWith(themeMode: modeString, lastOpened: DateTime.now()),
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
