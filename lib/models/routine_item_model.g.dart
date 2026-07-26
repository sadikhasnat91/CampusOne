// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineItemModelAdapter extends TypeAdapter<RoutineItemModel> {
  @override
  final int typeId = 3;

  @override
  RoutineItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineItemModel(
      id: fields[0] as String,
      subjectName: fields[1] as String,
      courseCode: fields[2] as String,
      teacherName: fields[3] as String,
      roomNo: fields[4] as String,
      startTime: fields[5] as String,
      endTime: fields[6] as String,
      dayOfWeek: fields[7] as String,
      semester: fields[8] as String,
      section: fields[9] as String,
      group: fields[10] as String,
      colorHex: fields[11] as int,
      isFavorite: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineItemModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectName)
      ..writeByte(2)
      ..write(obj.courseCode)
      ..writeByte(3)
      ..write(obj.teacherName)
      ..writeByte(4)
      ..write(obj.roomNo)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.dayOfWeek)
      ..writeByte(8)
      ..write(obj.semester)
      ..writeByte(9)
      ..write(obj.section)
      ..writeByte(10)
      ..write(obj.group)
      ..writeByte(11)
      ..write(obj.colorHex)
      ..writeByte(12)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
