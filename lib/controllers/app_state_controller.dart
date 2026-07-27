import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../database/hive_service.dart';
import '../constants/hive_box_keys.dart';
import '../models/app_settings_model.dart';
import '../services/notification_service.dart';

class AppStateController extends ChangeNotifier {
  late AppSettingsModel _settings;
  bool _isAuthenticated = false;

  AppStateController() {
    _loadSettings();
  }

  void _loadSettings() {
    final box = HiveService.instance.appSettingsBox;
    _settings =
        box.get(HiveBoxKeys.themeModeKey) ??
        AppSettingsModel(
          themeMode: 'system',
          isFirstRun: true,
          lastOpened: DateTime.now(),
          isAppLockEnabled: false,
          notificationsEnabled: true,
        );
  }

  bool get isFirstRun => _settings.isFirstRun;
  bool get isAppLockEnabled => _settings.isAppLockEnabled;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> setFirstRunComplete() async {
    _settings = _settings.copyWith(isFirstRun: false);
    await _saveSettings();
  }

  Future<void> toggleAppLock(bool value) async {
    _settings = _settings.copyWith(isAppLockEnabled: value);
    await _saveSettings();
  }

  Future<void> toggleNotifications(bool value) async {
    _settings = _settings.copyWith(notificationsEnabled: value);
    await _saveSettings();

    if (value) {
      await NotificationService.instance.initNotification();
      await NotificationService.instance.requestPermissions();
    } else {
      await NotificationService.instance.cancelAllNotifications();
    }
  }

  Future<void> _saveSettings() async {
    final box = HiveService.instance.appSettingsBox;
    await box.put(HiveBoxKeys.themeModeKey, _settings);
    notifyListeners();
  }

  Future<bool> authenticate() async {
    if (!_settings.isAppLockEnabled) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _isAuthenticated = true; // Fallback if no hardware is present
        notifyListeners();
        return true;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access CampusOne',
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );

      _isAuthenticated = didAuthenticate;
      notifyListeners();
      return didAuthenticate;
    } catch (e) {
      _isAuthenticated = true; // Fail open if error
      notifyListeners();
      return true;
    }
  }
}
