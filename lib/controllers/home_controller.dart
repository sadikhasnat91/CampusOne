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
      _stats = _migrateSeededStats(existingStats);
      if (_stats != existingStats) {
        statsBox.put(HiveBoxKeys.dashboardStatsKey, _stats);
      }
    }

    notifyListeners();
  }

  DashboardStatsModel _migrateSeededStats(DashboardStatsModel stats) {
    // Legacy builds shipped fixed sample values for grade and attendance.
    // Reset only that exact seed so users start with real, editable values.
    final isLegacySeed =
        stats.attendancePercentage == 92.5 &&
        stats.cgpa == 3.84 &&
        stats.todaysClasses == 4 &&
        stats.todaysTasks == 6;

    if (!isLegacySeed) return stats;

    return stats.copyWith(attendancePercentage: 0.0, cgpa: 0.0);
  }

  Future<void> updateProfile({
    required String name,
    required String department,
    required String semester,
    required String section,
    required String group,
    required String university,
    required String institutionType,
    String? profilePictureUrl,
    String? institutionLogoUrl,
  }) async {
    final oldType = _profile.institutionType;
    _profile = _profile.copyWith(
      name: name,
      department: department,
      semester: semester,
      section: section,
      group: group,
      university: university,
      institutionType: institutionType,
      profilePictureUrl: profilePictureUrl,
      institutionLogoUrl: institutionLogoUrl,
    );
    notifyListeners();

    await HiveService.instance.userProfileBox.put(
      HiveBoxKeys.studentProfileKey,
      _profile,
    );

    if (oldType != institutionType) {
      final subBox = HiveService.instance.subjectsBox;
      await subBox.clear();
    }
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

  Future<void> updateAcademicSnapshot({
    required double gradePoint,
    required double attendancePercentage,
  }) async {
    _stats = _stats.copyWith(
      cgpa: double.parse(gradePoint.toStringAsFixed(2)),
      attendancePercentage: double.parse(
        attendancePercentage.toStringAsFixed(1),
      ),
    );
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
