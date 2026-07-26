// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_material_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseMaterialModelAdapter extends TypeAdapter<CourseMaterialModel> {
  @override
  final int typeId = 5;

  @override
  CourseMaterialModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseMaterialModel(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as String,
      contentUrl: fields[4] as String,
      dateAdded: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CourseMaterialModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.contentUrl)
      ..writeByte(5)
      ..write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseMaterialModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
