// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudentProfileModelAdapter extends TypeAdapter<StudentProfileModel> {
  @override
  final int typeId = 1;

  @override
  StudentProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentProfileModel(
      name: fields[0] as String,
      department: fields[1] as String,
      semester: fields[2] as String,
      section: fields[3] as String,
      group: fields[4] as String,
      university: fields[5] as String,
      profilePictureUrl: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, StudentProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.department)
      ..writeByte(2)
      ..write(obj.semester)
      ..writeByte(3)
      ..write(obj.section)
      ..writeByte(4)
      ..write(obj.group)
      ..writeByte(5)
      ..write(obj.university)
      ..writeByte(6)
      ..write(obj.profilePictureUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
