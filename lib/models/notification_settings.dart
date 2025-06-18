/// StudyValue - 通知設定データモデル
/// 各種通知の設定を管理

import 'package:hive/hive.dart';

part 'notification_settings.g.dart';

@HiveType(typeId: 3)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  bool isEnabled;

  @HiveField(1)
  bool studyReminderEnabled;

  @HiveField(2)
  List<int> reminderTimes; // 時刻（時間）のリスト

  @HiveField(3)
  bool achievementNotificationEnabled;

  @HiveField(4)
  bool warningNotificationEnabled;

  @HiveField(5)
  int reminderIntervalMinutes;

  @HiveField(6)
  DateTime lastUpdated;

  NotificationSettings({
    this.isEnabled = true,
    this.studyReminderEnabled = true,
    this.reminderTimes = const [9, 14, 19], // デフォルト：9時、14時、19時
    this.achievementNotificationEnabled = true,
    this.warningNotificationEnabled = true,
    this.reminderIntervalMinutes = 60,
    required this.lastUpdated,
  });

  NotificationSettings copyWith({
    bool? isEnabled,
    bool? studyReminderEnabled,
    List<int>? reminderTimes,
    bool? achievementNotificationEnabled,
    bool? warningNotificationEnabled,
    int? reminderIntervalMinutes,
    DateTime? lastUpdated,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      studyReminderEnabled: studyReminderEnabled ?? this.studyReminderEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      achievementNotificationEnabled: achievementNotificationEnabled ?? this.achievementNotificationEnabled,
      warningNotificationEnabled: warningNotificationEnabled ?? this.warningNotificationEnabled,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(enabled: $isEnabled, reminders: $reminderTimes)';
  }
}