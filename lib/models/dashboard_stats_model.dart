import 'package:hive/hive.dart';

part 'dashboard_stats_model.g.dart';

@HiveType(typeId: 2)
class DashboardStatsModel extends HiveObject {
  @HiveField(0)
  final int todaysClasses;

  @HiveField(1)
  final int todaysTasks;

  @HiveField(2)
  final String upcomingAssignment;

  @HiveField(3)
  final double attendancePercentage;

  @HiveField(4)
  final double cgpa;

  @HiveField(5)
  final String upcomingExam;

  @HiveField(6)
  final int pomodoroMinutesLeft;

  @HiveField(7)
  final bool isPomodoroRunning;

  DashboardStatsModel({
    required this.todaysClasses,
    required this.todaysTasks,
    required this.upcomingAssignment,
    required this.attendancePercentage,
    required this.cgpa,
    required this.upcomingExam,
    required this.pomodoroMinutesLeft,
    required this.isPomodoroRunning,
  });

  DashboardStatsModel copyWith({
    int? todaysClasses,
    int? todaysTasks,
    String? upcomingAssignment,
    double? attendancePercentage,
    double? cgpa,
    String? upcomingExam,
    int? pomodoroMinutesLeft,
    bool? isPomodoroRunning,
  }) {
    return DashboardStatsModel(
      todaysClasses: todaysClasses ?? this.todaysClasses,
      todaysTasks: todaysTasks ?? this.todaysTasks,
      upcomingAssignment: upcomingAssignment ?? this.upcomingAssignment,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      cgpa: cgpa ?? this.cgpa,
      upcomingExam: upcomingExam ?? this.upcomingExam,
      pomodoroMinutesLeft: pomodoroMinutesLeft ?? this.pomodoroMinutesLeft,
      isPomodoroRunning: isPomodoroRunning ?? this.isPomodoroRunning,
    );
  }

  factory DashboardStatsModel.defaultStats() {
    return DashboardStatsModel(
      todaysClasses: 0,
      todaysTasks: 0,
      upcomingAssignment: '',
      attendancePercentage: 0.0,
      cgpa: 0.0,
      upcomingExam: '',
      pomodoroMinutesLeft: 25,
      isPomodoroRunning: false,
    );
  }
}
