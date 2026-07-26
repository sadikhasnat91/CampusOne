// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DashboardStatsModelAdapter extends TypeAdapter<DashboardStatsModel> {
  @override
  final int typeId = 2;

  @override
  DashboardStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardStatsModel(
      todaysClasses: fields[0] as int,
      todaysTasks: fields[1] as int,
      upcomingAssignment: fields[2] as String,
      attendancePercentage: fields[3] as double,
      cgpa: fields[4] as double,
      upcomingExam: fields[5] as String,
      pomodoroMinutesLeft: fields[6] as int,
      isPomodoroRunning: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DashboardStatsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.todaysClasses)
      ..writeByte(1)
      ..write(obj.todaysTasks)
      ..writeByte(2)
      ..write(obj.upcomingAssignment)
      ..writeByte(3)
      ..write(obj.attendancePercentage)
      ..writeByte(4)
      ..write(obj.cgpa)
      ..writeByte(5)
      ..write(obj.upcomingExam)
      ..writeByte(6)
      ..write(obj.pomodoroMinutesLeft)
      ..writeByte(7)
      ..write(obj.isPomodoroRunning);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
