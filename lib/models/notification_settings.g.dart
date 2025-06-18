// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 3;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      isEnabled: fields[0] as bool,
      studyReminderEnabled: fields[1] as bool,
      reminderTimes: (fields[2] as List).cast<int>(),
      achievementNotificationEnabled: fields[3] as bool,
      warningNotificationEnabled: fields[4] as bool,
      reminderIntervalMinutes: fields[5] as int,
      lastUpdated: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.studyReminderEnabled)
      ..writeByte(2)
      ..write(obj.reminderTimes)
      ..writeByte(3)
      ..write(obj.achievementNotificationEnabled)
      ..writeByte(4)
      ..write(obj.warningNotificationEnabled)
      ..writeByte(5)
      ..write(obj.reminderIntervalMinutes)
      ..writeByte(6)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
