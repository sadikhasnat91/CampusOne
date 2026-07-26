// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalItemModelAdapter extends TypeAdapter<GoalItemModel> {
  @override
  final int typeId = 9;

  @override
  GoalItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalItemModel(
      id: fields[0] as String,
      title: fields[1] as String,
      targetHours: fields[2] as double,
      completedHours: fields[3] as double,
      deadline: fields[4] as DateTime,
      category: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GoalItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetHours)
      ..writeByte(3)
      ..write(obj.completedHours)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
