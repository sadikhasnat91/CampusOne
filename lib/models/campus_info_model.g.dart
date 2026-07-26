// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_info_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CampusInfoModelAdapter extends TypeAdapter<CampusInfoModel> {
  @override
  final int typeId = 14;

  @override
  CampusInfoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CampusInfoModel(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      type: fields[3] as String,
      date: fields[4] as DateTime,
      metadata: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CampusInfoModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampusInfoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
