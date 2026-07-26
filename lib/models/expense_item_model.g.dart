// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseItemModelAdapter extends TypeAdapter<ExpenseItemModel> {
  @override
  final int typeId = 15;

  @override
  ExpenseItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseItemModel(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as String,
      category: fields[4] as String,
      date: fields[5] as DateTime,
      note: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
