import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/hive_box_keys.dart';
import '../database/hive_service.dart';
import '../models/dashboard_stats_model.dart';
import '../models/student_profile_model.dart';

class HomeController extends ChangeNotifier {
  late StudentProfileModel _profile;
  late DashboardStatsModel _stats;
  Timer? _pomodoroTimer;

  StudentProfileModel get profile => _profile;
  DashboardStatsModel get stats => _stats;

  HomeController() {
    _loadDataFromHive();
  }

  void _loadDataFromHive() {
    final profileBox = HiveService.instance.userProfileBox;
    final statsBox = HiveService.instance.dashboardStatsBox;

    final existingProfile = profileBox.get(HiveBoxKeys.studentProfileKey);
    if (existingProfile == null) {
      _profile = StudentProfileModel.defaultProfile();
      profileBox.put(HiveBoxKeys.studentProfileKey, _profile);
    } else {
      _profile = existingProfile;
    }

    final existingStats = statsBox.get(HiveBoxKeys.dashboardStatsKey);
    if (existingStats == null) {
      _stats = DashboardStatsModel.defaultStats();
      statsBox.put(HiveBoxKeys.dashboardStatsKey, _stats);
    } else {
      _stats = existingStats;
    }

    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String department,
    required String semester,
    required String section,
    required String group,
    required String university,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      department: department,
      semester: semester,
      section: section,
      group: group,
      university: university,
    );
    notifyListeners();

    await HiveService.instance.userProfileBox.put(
      HiveBoxKeys.studentProfileKey,
      _profile,
    );
  }

  Future<void> togglePomodoroTimer() async {
    if (_stats.isPomodoroRunning) {
      _pomodoroTimer?.cancel();
      _stats = _stats.copyWith(isPomodoroRunning: false);
    } else {
      _stats = _stats.copyWith(isPomodoroRunning: true);
      _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_stats.pomodoroMinutesLeft > 0) {
          _stats = _stats.copyWith(
            pomodoroMinutesLeft: _stats.pomodoroMinutesLeft,
          );
          notifyListeners();
        } else {
          timer.cancel();
          _stats = _stats.copyWith(
            isPomodoroRunning: false,
            pomodoroMinutesLeft: 25,
          );
          notifyListeners();
        }
      });
    }
    notifyListeners();
    await HiveService.instance.dashboardStatsBox.put(
      HiveBoxKeys.dashboardStatsKey,
      _stats,
    );
  }

  Future<void> incrementClasses() async {
    _stats = _stats.copyWith(todaysClasses: _stats.todaysClasses + 1);
    notifyListeners();
    await _saveStats();
  }

  Future<void> incrementTasks() async {
    _stats = _stats.copyWith(todaysTasks: _stats.todaysTasks + 1);
    notifyListeners();
    await _saveStats();
  }

  Future<void> _saveStats() async {
    await HiveService.instance.dashboardStatsBox.put(
      HiveBoxKeys.dashboardStatsKey,
      _stats,
    );
  }

  @override
  void dispose() {
    _pomodoroTimer?.cancel();
    super.dispose();
  }
}
