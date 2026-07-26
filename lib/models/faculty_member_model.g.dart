// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FacultyMemberModelAdapter extends TypeAdapter<FacultyMemberModel> {
  @override
  final int typeId = 13;

  @override
  FacultyMemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FacultyMemberModel(
      id: fields[0] as String,
      name: fields[1] as String,
      designation: fields[2] as String,
      department: fields[3] as String,
      email: fields[4] as String,
      phone: fields[5] as String,
      roomNo: fields[6] as String,
      officeHours: fields[7] as String,
      isFavorite: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FacultyMemberModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.designation)
      ..writeByte(3)
      ..write(obj.department)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.roomNo)
      ..writeByte(7)
      ..write(obj.officeHours)
      ..writeByte(8)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacultyMemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
