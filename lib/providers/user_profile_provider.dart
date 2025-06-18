/// StudyValue - ユーザープロフィール状態管理
/// ユーザーの基本情報と設定を管理

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/database_manager.dart';

/// ユーザープロフィールプロバイダー
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _loadProfile();
  }

  /// プロフィールをロード
  Future<void> _loadProfile() async {
    try {
      final box = DatabaseManager.userProfileBox;
      if (box.isNotEmpty) {
        state = box.values.first;
      } else {
        // デフォルトプロフィールを作成
        await createDefaultProfile();
      }
    } catch (e) {
      // エラーハンドリング：デフォルトプロフィール作成
      await createDefaultProfile();
    }
  }

  /// デフォルトプロフィールを作成
  Future<void> createDefaultProfile() async {
    final defaultProfile = UserProfile(
      targetUniversity: '東京大学',
      examDate: DateTime.now().add(const Duration(days: 365)),
      gender: '男性',
      age: 18,
      weekdayStudyHours: 8,
      weekendStudyHours: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveProfile(defaultProfile);
  }

  /// プロフィールを保存
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final box = DatabaseManager.userProfileBox;
      await box.clear(); // 既存データをクリア
      await box.add(profile);
      state = profile;
    } catch (e) {
      // エラーハンドリング
      throw Exception('プロフィールの保存に失敗しました: $e');
    }
  }

  /// プロフィールを更新
  Future<void> updateProfile({
    String? targetUniversity,
    DateTime? examDate,
    String? gender,
    int? age,
    int? weekdayStudyHours,
    int? weekendStudyHours,
    double? customSalaryData,
  }) async {
    if (state == null) return;

    final updatedProfile = state!.copyWith(
      targetUniversity: targetUniversity,
      examDate: examDate,
      gender: gender,
      age: age,
      weekdayStudyHours: weekdayStudyHours,
      weekendStudyHours: weekendStudyHours,
      customSalaryData: customSalaryData,
      updatedAt: DateTime.now(),
    );

    await saveProfile(updatedProfile);
  }

  /// プロフィールを削除
  Future<void> deleteProfile() async {
    try {
      final box = DatabaseManager.userProfileBox;
      await box.clear();
      state = null;
    } catch (e) {
      throw Exception('プロフィールの削除に失敗しました: $e');
    }
  }

  /// プロフィールが存在するかチェック
  bool get hasProfile => state != null;

  /// 受験日までの日数を取得
  int get daysUntilExam {
    if (state == null) return 0;
    return state!.examDate.difference(DateTime.now()).inDays;
  }

  /// 週末かどうか判定
  bool get isWeekend {
    final now = DateTime.now();
    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  /// 今日の目標勉強時間（時間）
  int get todayTargetHours {
    if (state == null) return 8;
    return isWeekend ? state!.weekendStudyHours : state!.weekdayStudyHours;
  }
}