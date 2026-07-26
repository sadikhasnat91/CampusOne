// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_location_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CampusLocationModelAdapter extends TypeAdapter<CampusLocationModel> {
  @override
  final int typeId = 12;

  @override
  CampusLocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CampusLocationModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      description: fields[3] as String,
      floor: fields[4] as String,
      contactNumber: fields[5] as String,
      openHours: fields[6] as String,
      isFavorite: fields[7] as bool,
      colorHex: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CampusLocationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.floor)
      ..writeByte(5)
      ..write(obj.contactNumber)
      ..writeByte(6)
      ..write(obj.openHours)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.colorHex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampusLocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
