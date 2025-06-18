/// StudyValue - 時給計算エンジンサービス
/// 偏差値帯別年収データから時給を計算し、各種フォーマット機能を提供

import '../models/user_profile.dart';
import '../models/salary_data.dart';
import '../models/study_session.dart';

class SalaryCalculator {
  static const Map<String, double> _defaultSalaryData = {
    '東京大学': 8000000,
    '京都大学': 7500000,
    '大阪大学': 7000000,
    '名古屋大学': 6800000,
    '東北大学': 6500000,
    '九州大学': 6300000,
    '北海道大学': 6200000,
    '早稲田大学': 6000000,
    '慶應義塾大学': 6200000,
    'その他私立大学': 5500000,
    'その他国公立大学': 5800000,
  };

  /// 偏差値帯別年収データを取得
  static double getAnnualSalary(String university, {double? customSalary}) {
    if (customSalary != null) return customSalary;
    return _defaultSalaryData[university] ?? 5500000;
  }

  /// 時給を計算
  static double calculateHourlyWage(UserProfile profile) {
    final annualSalary = getAnnualSalary(
      profile.targetUniversity,
      customSalary: profile.customSalaryData,
    );
    
    // 43年間の総収入予測（22歳〜65歳）
    final totalLifetimeEarnings = annualSalary * 43;
    
    // 受験日までの総勉強可能時間を計算
    final daysUntilExam = profile.examDate.difference(DateTime.now()).inDays;
    if (daysUntilExam <= 0) return 0;
    
    // 週7日のうち平日5日、休日2日として計算
    final weekdays = (daysUntilExam * 5 / 7).floor();
    final weekends = (daysUntilExam * 2 / 7).floor();
    
    final totalStudyHours = 
        (weekdays * profile.weekdayStudyHours) + 
        (weekends * profile.weekendStudyHours);
    
    if (totalStudyHours <= 0) return 0;
    
    return totalLifetimeEarnings / totalStudyHours;
  }

  /// 秒ごとの収入を計算
  static double calculatePerSecondEarning(UserProfile profile) {
    final hourlyWage = calculateHourlyWage(profile);
    return hourlyWage / 3600; // 1時間 = 3600秒
  }

  /// 今日の勉強時間を計算（秒）
  static int calculateTodayStudyTime(List<StudySession> sessions) {
    final today = DateTime.now();
    final todaySessions = sessions.where((session) =>
        session.startTime.year == today.year &&
        session.startTime.month == today.month &&
        session.startTime.day == today.day
    );
    
    return todaySessions.fold<int>(0, (total, session) => total + session.duration);
  }

  /// 今日の目標達成率を計算（0.0〜1.0）
  static double calculateDailyProgress(UserProfile profile, List<StudySession> sessions) {
    final todayStudySeconds = calculateTodayStudyTime(sessions);
    final isWeekend = DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday;
    final targetHours = isWeekend ? profile.weekendStudyHours : profile.weekdayStudyHours;
    final targetSeconds = targetHours * 3600;
    
    if (targetSeconds <= 0) return 0.0;
    return (todayStudySeconds / targetSeconds).clamp(0.0, 1.0);
  }

  /// 時間をフォーマット（例：2時間30分45秒）
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}時間${minutes}分${secs}秒';
    } else if (minutes > 0) {
      return '${minutes}分${secs}秒';
    } else {
      return '${secs}秒';
    }
  }

  /// 通貨をフォーマット（例：¥1,234,567）
  static String formatCurrency(double amount) {
    return '¥${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  /// 日付を日本語フォーマット（例：2025年6月17日）
  static String formatDateJP(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 時刻を日本語フォーマット（例：14時30分）
  static String formatTimeJP(DateTime time) {
    return '${time.hour}時${time.minute.toString().padLeft(2, '0')}分';
  }

  /// パーセンテージをフォーマット（例：75.5%）
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  /// 勉強効率レベルを計算（1-5レベル）
  static int calculateEfficiencyLevel(UserProfile profile, List<StudySession> sessions) {
    final progress = calculateDailyProgress(profile, sessions);
    
    if (progress >= 1.0) return 5; // 完璧
    if (progress >= 0.8) return 4; // 優秀
    if (progress >= 0.6) return 3; // 普通
    if (progress >= 0.4) return 2; // 努力が必要
    return 1; // 要改善
  }
}