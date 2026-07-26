import 'package:hive/hive.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 0)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  final String themeMode; // 'system', 'light', 'dark'

  @HiveField(1)
  final bool isFirstRun;

  @HiveField(2)
  final DateTime lastOpened;

  @HiveField(3)
  final bool isAppLockEnabled;

  @HiveField(4)
  final bool notificationsEnabled;

  AppSettingsModel({
    required this.themeMode,
    required this.isFirstRun,
    required this.lastOpened,
    this.isAppLockEnabled = false,
    this.notificationsEnabled = true,
  });

  AppSettingsModel copyWith({
    String? themeMode,
    bool? isFirstRun,
    DateTime? lastOpened,
    bool? isAppLockEnabled,
    bool? notificationsEnabled,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      isFirstRun: isFirstRun ?? this.isFirstRun,
      lastOpened: lastOpened ?? this.lastOpened,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
