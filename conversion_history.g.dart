// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversionHistoryAdapter extends TypeAdapter<ConversionHistory> {
  @override
  final int typeId = 0;

  @override
  ConversionHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionHistory(
      inputUnit: fields[0] as String,
      inputValue: fields[1] as double,
      outputUnit: fields[2] as String,
      outputValue: fields[3] as double,
      dateTime: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ConversionHistory obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.inputUnit)
      ..writeByte(1)
      ..write(obj.inputValue)
      ..writeByte(2)
      ..write(obj.outputUnit)
      ..writeByte(3)
      ..write(obj.outputValue)
      ..writeByte(4)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
