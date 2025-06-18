/// StudyValue - 段階的警告システムサービス
/// 勉強進捗に基づく3段階の警告・モチベーション管理

import '../models/user_profile.dart';
import '../models/study_session.dart';
import '../services/salary_calculator.dart';

enum WarningLevel {
  none,      // 警告なし（80%以上達成）
  level1,    // レベル1（60-79%達成）
  level2,    // レベル2（40-59%達成）
  level3,    // レベル3（40%未満達成）
}

class WarningData {
  final WarningLevel level;
  final String message;
  final String submessage;
  final double lossAmount;
  final String actionAdvice;

  WarningData({
    required this.level,
    required this.message,
    required this.submessage,
    required this.lossAmount,
    required this.actionAdvice,
  });
}

class WarningSystem {
  /// 現在の警告レベルを計算
  static WarningLevel calculateWarningLevel(UserProfile profile, List<StudySession> sessions) {
    final progress = SalaryCalculator.calculateDailyProgress(profile, sessions);
    
    if (progress >= 0.8) return WarningLevel.none;
    if (progress >= 0.6) return WarningLevel.level1;
    if (progress >= 0.4) return WarningLevel.level2;
    return WarningLevel.level3;
  }

  /// 警告データを生成
  static WarningData generateWarningData(UserProfile profile, List<StudySession> sessions) {
    final level = calculateWarningLevel(profile, sessions);
    final hourlyWage = SalaryCalculator.calculateHourlyWage(profile);
    final todayStudyTime = SalaryCalculator.calculateTodayStudyTime(sessions);
    
    switch (level) {
      case WarningLevel.none:
        return WarningData(
          level: WarningLevel.none,
          message: '今日も順調です！',
          submessage: '時給1.1倍達成可能',
          lossAmount: 0,
          actionAdvice: 'この調子で頑張りましょう',
        );
        
      case WarningLevel.level1:
        final targetTime = _getDailyTargetSeconds(profile);
        final missingTime = targetTime - todayStudyTime;
        final lossAmount = (missingTime / 3600) * hourlyWage;
        
        return WarningData(
          level: WarningLevel.level1,
          message: '挽回チャンス！',
          submessage: 'あと${SalaryCalculator.formatDuration(missingTime)}で目標達成',
          lossAmount: lossAmount,
          actionAdvice: '今から+1時間で挽回可能',
        );
        
      case WarningLevel.level2:
        final targetTime = _getDailyTargetSeconds(profile);
        final missingTime = targetTime - todayStudyTime;
        final lossAmount = (missingTime / 3600) * hourlyWage;
        
        return WarningData(
          level: WarningLevel.level2,
          message: '今日の損失',
          submessage: '${SalaryCalculator.formatCurrency(lossAmount)}',
          lossAmount: lossAmount,
          actionAdvice: '明日+2時間で挽回可能',
        );
        
      case WarningLevel.level3:
        final targetTime = _getDailyTargetSeconds(profile);
        final missingTime = targetTime - todayStudyTime;
        final lossAmount = (missingTime / 3600) * hourlyWage;
        final weeklyLoss = lossAmount * 7; // 週間損失予測
        
        return WarningData(
          level: WarningLevel.level3,
          message: '累積損失予測',
          submessage: '週間: ${SalaryCalculator.formatCurrency(weeklyLoss)}',
          lossAmount: weeklyLoss,
          actionAdvice: '週末集中で50%回復可能',
        );
    }
  }

  /// 警告レベルに応じた色を取得
  static String getWarningColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.none:
        return '#4CAF50'; // 緑
      case WarningLevel.level1:
        return '#2196F3'; // 青
      case WarningLevel.level2:
        return '#FF9800'; // オレンジ
      case WarningLevel.level3:
        return '#F44336'; // 赤
    }
  }

  /// 警告メッセージのアイコンを取得
  static String getWarningIcon(WarningLevel level) {
    switch (level) {
      case WarningLevel.none:
        return '✅';
      case WarningLevel.level1:
        return '💪';
      case WarningLevel.level2:
        return '⚠️';
      case WarningLevel.level3:
        return '🚨';
    }
  }

  /// 1日の目標勉強時間（秒）を取得
  static int _getDailyTargetSeconds(UserProfile profile) {
    final isWeekend = DateTime.now().weekday == DateTime.saturday || DateTime.now().weekday == DateTime.sunday;
    final targetHours = isWeekend ? profile.weekendStudyHours : profile.weekdayStudyHours;
    return targetHours * 3600;
  }

  /// モチベーションメッセージを生成
  static String generateMotivationMessage(UserProfile profile, List<StudySession> sessions) {
    final progress = SalaryCalculator.calculateDailyProgress(profile, sessions);
    final level = calculateWarningLevel(profile, sessions);
    
    if (level == WarningLevel.none) {
      if (progress >= 1.0) {
        return '🎉 本日の目標達成！素晴らしい努力です！';
      } else {
        return '🔥 順調なペースです！この調子で頑張りましょう！';
      }
    } else {
      final daysUntilExam = profile.examDate.difference(DateTime.now()).inDays;
      return '📚 受験まであと${daysUntilExam}日。今の努力が将来の収入に直結します！';
    }
  }
}