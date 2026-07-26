// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitItemModelAdapter extends TypeAdapter<HabitItemModel> {
  @override
  final int typeId = 8;

  @override
  HabitItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitItemModel(
      id: fields[0] as String,
      title: fields[1] as String,
      streakCount: fields[2] as int,
      completedDates: (fields[3] as List).cast<String>(),
      targetDaysPerWeek: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HabitItemModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.streakCount)
      ..writeByte(3)
      ..write(obj.completedDates)
      ..writeByte(4)
      ..write(obj.targetDaysPerWeek);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
