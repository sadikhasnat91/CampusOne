// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_page_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoverPageModelAdapter extends TypeAdapter<CoverPageModel> {
  @override
  final int typeId = 16;

  @override
  CoverPageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoverPageModel(
      id: fields[0] as String,
      title: fields[1] as String,
      studentName: fields[2] as String,
      studentId: fields[3] as String,
      department: fields[4] as String,
      semester: fields[5] as String,
      section: fields[6] as String,
      courseName: fields[7] as String,
      courseCode: fields[8] as String,
      teacherName: fields[9] as String,
      submissionDate: fields[10] as DateTime,
      universityName: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CoverPageModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.studentName)
      ..writeByte(3)
      ..write(obj.studentId)
      ..writeByte(4)
      ..write(obj.department)
      ..writeByte(5)
      ..write(obj.semester)
      ..writeByte(6)
      ..write(obj.section)
      ..writeByte(7)
      ..write(obj.courseName)
      ..writeByte(8)
      ..write(obj.courseCode)
      ..writeByte(9)
      ..write(obj.teacherName)
      ..writeByte(10)
      ..write(obj.submissionDate)
      ..writeByte(11)
      ..write(obj.universityName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoverPageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
