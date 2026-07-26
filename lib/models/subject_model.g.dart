// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectModelAdapter extends TypeAdapter<SubjectModel> {
  @override
  final int typeId = 4;

  @override
  SubjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectModel(
      id: fields[0] as String,
      name: fields[1] as String,
      code: fields[2] as String,
      credits: fields[3] as double,
      semester: fields[4] as String,
      attendedClasses: fields[5] as int,
      totalClasses: fields[6] as int,
      gradePoint: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SubjectModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.credits)
      ..writeByte(4)
      ..write(obj.semester)
      ..writeByte(5)
      ..write(obj.attendedClasses)
      ..writeByte(6)
      ..write(obj.totalClasses)
      ..writeByte(7)
      ..write(obj.gradePoint);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
