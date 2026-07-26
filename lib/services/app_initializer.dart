import 'package:flutter/material.dart';
import '../database/hive_service.dart';
import 'notification_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize Hive Offline Database
    await HiveService.instance.initHive();

    // 2. Initialize Notification Service
    await NotificationService.instance.initNotification();

    debugPrint('CampusOne App Services successfully booted.');
  }
}
