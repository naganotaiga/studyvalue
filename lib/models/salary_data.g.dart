// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalaryDataAdapter extends TypeAdapter<SalaryData> {
  @override
  final int typeId = 2;

  @override
  SalaryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalaryData(
      universityName: fields[0] as String,
      averageAnnualSalary: fields[1] as double,
      deviationValue: fields[2] as int,
      category: fields[3] as String,
      lastUpdated: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SalaryData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.universityName)
      ..writeByte(1)
      ..write(obj.averageAnnualSalary)
      ..writeByte(2)
      ..write(obj.deviationValue)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
