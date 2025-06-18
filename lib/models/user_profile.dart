/// StudyValue - ユーザープロフィールデータモデル
/// 志望校、受験日、基本情報、勉強時間設定を管理

import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String targetUniversity;
  
  @HiveField(1)
  DateTime examDate;
  
  @HiveField(2)
  String gender;
  
  @HiveField(3)
  int age;
  
  @HiveField(4)
  int weekdayStudyHours;
  
  @HiveField(5)
  int weekendStudyHours;
  
  @HiveField(6)
  double? customSalaryData;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  int currentStreak;

  @HiveField(10)
  int longestStreak;

  @HiveField(11)
  int totalStudyDays;

  @HiveField(12)
  double totalEarnings;

  UserProfile({
    required this.targetUniversity,
    required this.examDate,
    required this.gender,
    required this.age,
    required this.weekdayStudyHours,
    required this.weekendStudyHours,
    this.customSalaryData,
    required this.createdAt,
    required this.updatedAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalStudyDays = 0,
    this.totalEarnings = 0.0,
  });

  UserProfile copyWith({
    String? targetUniversity,
    DateTime? examDate,
    String? gender,
    int? age,
    int? weekdayStudyHours,
    int? weekendStudyHours,
    double? customSalaryData,
    DateTime? updatedAt,
    int? currentStreak,
    int? longestStreak,
    int? totalStudyDays,
    double? totalEarnings,
  }) {
    return UserProfile(
      targetUniversity: targetUniversity ?? this.targetUniversity,
      examDate: examDate ?? this.examDate,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weekdayStudyHours: weekdayStudyHours ?? this.weekdayStudyHours,
      weekendStudyHours: weekendStudyHours ?? this.weekendStudyHours,
      customSalaryData: customSalaryData ?? this.customSalaryData,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalStudyDays: totalStudyDays ?? this.totalStudyDays,
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }

  @override
  String toString() {
    return 'UserProfile(targetUniversity: $targetUniversity, examDate: $examDate, gender: $gender, age: $age)';
  }
}