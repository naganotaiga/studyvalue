/// StudyValue - データベース管理サービス
/// Hiveを使用したローカルデータベースの初期化と管理

import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/study_session.dart';
import '../models/salary_data.dart';
import '../models/notification_settings.dart';

class DatabaseManager {
  static const String userProfileBoxName = 'user_profile';
  static const String studySessionBoxName = 'study_sessions';
  static const String salaryDataBoxName = 'salary_data';
  static const String notificationSettingsBoxName = 'notification_settings';

  static Box<UserProfile>? _userProfileBox;
  static Box<StudySession>? _studySessionBox;
  static Box<SalaryData>? _salaryDataBox;
  static Box<NotificationSettings>? _notificationSettingsBox;

  /// データベース初期化
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // アダプターを登録
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserProfileAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(StudySessionAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SalaryDataAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NotificationSettingsAdapter());

    // 型付きBoxを開く
    _userProfileBox = await Hive.openBox<UserProfile>(userProfileBoxName);
    _studySessionBox = await Hive.openBox<StudySession>(studySessionBoxName);
    _salaryDataBox = await Hive.openBox<SalaryData>(salaryDataBoxName);
    _notificationSettingsBox = await Hive.openBox<NotificationSettings>(notificationSettingsBoxName);

    // 初期データセットアップ
    await _setupInitialData();

    // データマイグレーション実行
    await migrateData();
  }

  /// 初期データのセットアップ
  static Future<void> _setupInitialData() async {
    // デフォルト年収データ
    if (_salaryDataBox!.isEmpty) {
      final defaultSalaryData = [
        SalaryData(
          universityName: '東京大学',
          averageAnnualSalary: 8000000,
          deviationValue: 80,
          category: '国立',
          lastUpdated: DateTime.now(),
        ),
        SalaryData(
          universityName: '京都大学',
          averageAnnualSalary: 7500000,
          deviationValue: 78,
          category: '国立',
          lastUpdated: DateTime.now(),
        ),
        SalaryData(
          universityName: '早稲田大学',
          averageAnnualSalary: 6000000,
          deviationValue: 70,
          category: '私立',
          lastUpdated: DateTime.now(),
        ),
        SalaryData(
          universityName: '慶應義塾大学',
          averageAnnualSalary: 6200000,
          deviationValue: 72,
          category: '私立',
          lastUpdated: DateTime.now(),
        ),
      ];

      for (var data in defaultSalaryData) {
        await _salaryDataBox!.add(data);
      }
    }

    // デフォルト通知設定
    if (_notificationSettingsBox!.isEmpty) {
      final defaultNotificationSettings = NotificationSettings(
        lastUpdated: DateTime.now(),
      );
      await _notificationSettingsBox!.add(defaultNotificationSettings);
    }
  }

  /// ユーザープロフィールBox取得
  static Box<UserProfile> get userProfileBox {
    if (_userProfileBox == null) {
      throw Exception('Database not initialized. Call DatabaseManager.initialize() first.');
    }
    return _userProfileBox!;
  }

  /// 勉強セッションBox取得
  static Box<StudySession> get studySessionBox {
    if (_studySessionBox == null) {
      throw Exception('Database not initialized. Call DatabaseManager.initialize() first.');
    }
    return _studySessionBox!;
  }

  /// 年収データBox取得
  static Box<SalaryData> get salaryDataBox {
    if (_salaryDataBox == null) {
      throw Exception('Database not initialized. Call DatabaseManager.initialize() first.');
    }
    return _salaryDataBox!;
  }

  /// 通知設定Box取得
  static Box<NotificationSettings> get notificationSettingsBox {
    if (_notificationSettingsBox == null) {
      throw Exception('Database not initialized. Call DatabaseManager.initialize() first.');
    }
    return _notificationSettingsBox!;
  }

  /// データベースを閉じる
  static Future<void> close() async {
    await _userProfileBox?.close();
    await _studySessionBox?.close();
    await _salaryDataBox?.close();
    await _notificationSettingsBox?.close();
  }

  /// 全データを削除（デバッグ用）
  static Future<void> clearAllData() async {
    await _userProfileBox?.clear();
    await _studySessionBox?.clear();
    await _salaryDataBox?.clear();
    await _notificationSettingsBox?.clear();
  }

  /// データベースマイグレーション - 新しいフィールドのデフォルト値設定
  static Future<void> migrateData() async {
    // 開発中は簡単のためにデータをクリア
    // 本番環境では適切なマイグレーション処理を実装
    print('Migration: Clearing data for schema update compatibility');
  }
}