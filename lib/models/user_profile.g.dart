// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      targetUniversity: fields[0] as String,
      examDate: fields[1] as DateTime,
      gender: fields[2] as String,
      age: fields[3] as int,
      weekdayStudyHours: fields[4] as int,
      weekendStudyHours: fields[5] as int,
      customSalaryData: fields[6] as double?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      currentStreak: fields[9] as int,
      longestStreak: fields[10] as int,
      totalStudyDays: fields[11] as int,
      totalEarnings: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.targetUniversity)
      ..writeByte(1)
      ..write(obj.examDate)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.weekdayStudyHours)
      ..writeByte(5)
      ..write(obj.weekendStudyHours)
      ..writeByte(6)
      ..write(obj.customSalaryData)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.currentStreak)
      ..writeByte(10)
      ..write(obj.longestStreak)
      ..writeByte(11)
      ..write(obj.totalStudyDays)
      ..writeByte(12)
      ..write(obj.totalEarnings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
