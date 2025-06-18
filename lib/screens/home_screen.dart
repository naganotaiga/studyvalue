/// StudyValue - ホーム画面（完全実装版）
/// リアルタイム勉強セッション管理と収益表示
///
/// 【主要機能】
/// - 勉強開始・停止ボタン（完全実装）
/// - リアルタイム収入時計（秒ごと更新）
/// - 今日の進捗率表示
/// - 段階的警告システム
/// - 統計カード表示
library;

import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/app_theme.dart';
import '../models/user_profile.dart';
import '../models/study_session.dart';
import '../providers/user_profile_provider.dart';
import '../providers/study_session_provider.dart';
import '../services/salary_calculator.dart';
import '../services/warning_system.dart';
import '../widgets/progress_bar_widget.dart';
import '../widgets/realtime_earnings_display.dart';
import '../widgets/warning_display_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final currentSession = ref.watch(studySessionProvider);
    final todaySessions = ref.watch(todayStudySessionsProvider);
    final dailyProgress = ref.watch(dailyProgressProvider);

    return CupertinoPageScaffold(
      // ナビゲーションバー（タブ使用時は簡潔に）
      navigationBar: const CupertinoNavigationBar(
        middle: Text('StudyValue'),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),

      child: SafeArea(
        child: userProfile == null
            ? _buildProfileSetupPrompt(context)
            : _buildMainContent(context, ref, userProfile, currentSession,
                todaySessions, dailyProgress),
      ),
    );
  }

  /// プロフィール未設定時の案内画面
  Widget _buildProfileSetupPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アイコン
            const Icon(
              CupertinoIcons.person_circle,
              size: 100,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(height: 24),

            // メッセージ
            const Text(
              'プロフィール設定が必要です',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansJP',
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              '志望校と勉強時間を設定して\n時給計算を開始しましょう',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
                fontFamily: 'NotoSansJP',
              ),
            ),
            const SizedBox(height: 32),

            // 設定ボタン
            const Text(
              '画面下部の「設定」タブから\n設定してください',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey2,
                fontStyle: FontStyle.italic,
                fontFamily: 'NotoSansJP',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// メインコンテンツ表示
  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile userProfile,
    StudySession? currentSession,
    List<StudySession> todaySessions,
    double dailyProgress,
  ) {
    final isStudying = currentSession != null && currentSession.endTime == null;
    final todayEarnings = todaySessions.fold<double>(
        0, (sum, session) => sum + session.earnedAmount);
    final todayMinutes =
        todaySessions.fold<int>(0, (sum, session) => sum + session.duration) ~/
            60;
    final streak = _calculateStreak(todaySessions);
    final hourlyWage = SalaryCalculator.calculateHourlyWage(userProfile);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // リアルタイム収入表示
            const RealtimeEarningsDisplay(),

            const SizedBox(height: 20),

            // 進捗バー
            ProgressBarWidget(progress: dailyProgress),

            const SizedBox(height: 20),

            // 警告・モチベーションメッセージ
            WarningDisplayWidget(
              profile: userProfile,
              sessions: todaySessions,
            ),

            const SizedBox(height: 20),

            // メイン勉強コントロールボタン
            _buildStudyControlButton(context, ref, isStudying, currentSession),

            const SizedBox(height: 20),

            // 統計カード群
            _buildStatsGrid(userProfile, todaySessions, hourlyWage, streak),

            const SizedBox(height: 20),

            // 今日のセッション概要
            _buildTodaySessionsSummary(todaySessions),
          ],
        ),
      ),
    );
  }

  /// 勉強開始・停止コントロールボタン（完全実装）
  Widget _buildStudyControlButton(
    BuildContext context,
    WidgetRef ref,
    bool isStudying,
    StudySession? currentSession,
  ) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: (isStudying
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGreen)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CupertinoButton(
        color: isStudying
            ? CupertinoColors.systemRed
            : CupertinoColors.systemGreen,
        borderRadius: BorderRadius.circular(40),
        padding: EdgeInsets.zero,

        // 勉強開始・停止の完全実装
        onPressed: () async {
          try {
            if (isStudying) {
              // 勉強停止処理
              await ref.read(studySessionProvider.notifier).endSession();

              // 完了ダイアログ表示
              if (currentSession != null && context.mounted) {
                _showSessionCompleteDialog(context, currentSession);
              }
            } else {
              // 勉強開始処理
              await ref.read(studySessionProvider.notifier).startSession();
            }
          } catch (e) {
            // エラーハンドリング
            if (context.mounted) {
              _showErrorDialog(context, '勉強セッションの操作に失敗しました: $e');
            }
          }
        },

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isStudying ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill,
              color: CupertinoColors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              isStudying ? '勉強を停止' : '勉強を開始',
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansJP',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 統計グリッド表示
  Widget _buildStatsGrid(UserProfile userProfile,
      List<StudySession> todaySessions, double hourlyWage, int streak) {
    final sessionCount = todaySessions.length;
    final totalTime =
        todaySessions.fold<int>(0, (sum, session) => sum + session.duration);
    final daysUntilExam =
        userProfile.examDate.difference(DateTime.now()).inDays;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '時給',
                SalaryCalculator.formatCurrency(hourlyWage),
                CupertinoIcons.money_dollar_circle_fill,
                CupertinoColors.systemGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'ストリーク',
                '${streak}日',
                CupertinoIcons.flame_fill,
                CupertinoColors.systemOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '受験まで',
                '${daysUntilExam}日',
                CupertinoIcons.calendar_today,
                CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'セッション',
                '${sessionCount}回',
                CupertinoIcons.timer_fill,
                CupertinoColors.systemBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 統計カード作成
  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'NotoSansJP',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
              fontFamily: 'NotoSansJP',
            ),
          ),
        ],
      ),
    );
  }

  /// 今日のセッション概要
  Widget _buildTodaySessionsSummary(List<StudySession> todaySessions) {
    if (todaySessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '今日はまだ勉強セッションがありません\n勉強を開始して記録を作成しましょう',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CupertinoColors.systemGrey,
            fontFamily: 'NotoSansJP',
          ),
        ),
      );
    }

    final totalTime =
        todaySessions.fold<int>(0, (sum, session) => sum + session.duration);
    final totalEarnings = todaySessions.fold<double>(
        0, (sum, session) => sum + session.earnedAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日の成果',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansJP',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '勉強時間: ${SalaryCalculator.formatDuration(totalTime)}',
                style: const TextStyle(fontFamily: 'NotoSansJP'),
              ),
              Text(
                SalaryCalculator.formatCurrency(totalEarnings),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGreen,
                  fontFamily: 'NotoSansJP',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ストリーク計算
  int _calculateStreak(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final checkDate = currentDate.subtract(Duration(days: i));
      final hasStudyOnDay = sessions.any((session) {
        final sessionDate = DateTime(session.startTime.year,
            session.startTime.month, session.startTime.day);
        final checkDateOnly =
            DateTime(checkDate.year, checkDate.month, checkDate.day);
        return sessionDate == checkDateOnly;
      });

      if (hasStudyOnDay) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// セッション完了ダイアログ
  void _showSessionCompleteDialog(BuildContext context, StudySession session) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.checkmark_alt_circle_fill,
              color: CupertinoColors.systemGreen,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'お疲れさまでした！',
              style: TextStyle(fontFamily: 'NotoSansJP'),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '勉強時間',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            fontFamily: 'NotoSansJP',
                          ),
                        ),
                        Text(
                          SalaryCalculator.formatDuration(session.duration),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NotoSansJP',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '獲得金額',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                            fontFamily: 'NotoSansJP',
                          ),
                        ),
                        Text(
                          SalaryCalculator.formatCurrency(session.earnedAmount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGreen,
                            fontFamily: 'NotoSansJP',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '素晴らしい努力です！\nこの調子で頑張りましょう。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                  fontFamily: 'NotoSansJP',
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              'OK',
              style: TextStyle(fontFamily: 'NotoSansJP'),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// エラーダイアログ
  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'エラー',
          style: TextStyle(fontFamily: 'NotoSansJP'),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'NotoSansJP'),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              'OK',
              style: TextStyle(fontFamily: 'NotoSansJP'),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
