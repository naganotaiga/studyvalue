/// StudyValue - 勉強セッションデータモデル
/// 個別の勉強記録を管理

import 'package:hive/hive.dart';

part 'study_session.g.dart';

@HiveType(typeId: 1)
class StudySession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  int duration; // 秒

  @HiveField(4)
  bool isManuallyEdited;

  @HiveField(5)
  String? memo;

  @HiveField(6)
  double earnedAmount;

  StudySession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.isManuallyEdited = false,
    this.memo,
    required this.earnedAmount,
  });

  StudySession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    bool? isManuallyEdited,
    String? memo,
    double? earnedAmount,
  }) {
    return StudySession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      isManuallyEdited: isManuallyEdited ?? this.isManuallyEdited,
      memo: memo ?? this.memo,
      earnedAmount: earnedAmount ?? this.earnedAmount,
    );
  }

  /// セッションが完了しているかどうか
  bool get isCompleted => endTime != null;

  /// セッションが現在進行中かどうか
  bool get isInProgress => endTime == null && duration > 0;

  @override
  String toString() {
    return 'StudySession(id: $id, startTime: $startTime, duration: $duration, earnedAmount: $earnedAmount)';
  }
}