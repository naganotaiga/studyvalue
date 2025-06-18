/// StudyValue - 進捗バーウィジェット（最適化版）
/// 今日の目標達成率を視覚的に表示
///
/// 【機能】
/// - アニメーション付きの進捗表示
/// - 目標達成率に応じた色変化
/// - 詳細な統計情報表示
/// - 100%達成時の特別エフェクト
library;

import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../providers/study_session_provider.dart';
import '../services/salary_calculator.dart';

class ProgressBarWidget extends ConsumerWidget {
  final double progress;

  const ProgressBarWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final todayTotalTime = ref.watch(todayTotalStudyTimeProvider);

    if (userProfile == null) {
      return const SizedBox.shrink();
    }

    final targetHours = ref.read(userProfileProvider.notifier).todayTargetHours;
    final progressPercentage = (progress * 100).clamp(0.0, 999.0); // 上限を設定
    final targetSeconds = targetHours * 3600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー部分
          _buildHeader(progressPercentage, progress),

          const SizedBox(height: 16),

          // メイン進捗バー
          _buildProgressBar(context, progress),

          const SizedBox(height: 12),

          // 詳細統計
          _buildDetailedStats(targetHours, todayTotalTime, targetSeconds),

          // 達成状況メッセージ
          const SizedBox(height: 12),
          _buildStatusMessage(progress),
        ],
      ),
    );
  }

  /// ヘッダー部分の構築
  Widget _buildHeader(double progressPercentage, double progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '今日の目標達成率',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'NotoSansJP',
          ),
        ),
        Row(
          children: [
            // 達成率数値
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                key: ValueKey(progressPercentage.toStringAsFixed(1)),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progress),
                  fontFamily: 'NotoSansJP',
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 達成状況アイコン
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _getProgressIcon(progress),
                key: ValueKey(_getProgressIcon(progress)),
                color: _getProgressColor(progress),
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// メイン進捗バーの構築
  Widget _buildProgressBar(BuildContext context, double progress) {
    return Container(
      width: double.infinity,
      height: 16,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // 背景
            Container(
              width: double.infinity,
              height: double.infinity,
              color: CupertinoColors.systemGrey5,
            ),

            // 進捗バー（アニメーション付き）
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return FractionallySizedBox(
                  widthFactor: animatedProgress,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getProgressGradient(progress),
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                );
              },
            ),

            // 100%達成ライン
            if (progress > 1.0) ...[
              Positioned(
                left: (MediaQuery.of(context).size.width - 80) * 1.0 - 1,
                child: Container(
                  width: 2,
                  height: 16,
                  color: CupertinoColors.systemYellow,
                ),
              ),
            ],

            // 超過分の表示（100%を超えた場合）
            if (progress > 1.0)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: progress.clamp(1.0, 2.0)),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animatedProgress, child) {
                  return FractionallySizedBox(
                    widthFactor: animatedProgress,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CupertinoColors.systemGreen.withOpacity(0.3),
                            CupertinoColors.systemGreen.withOpacity(0.6),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 詳細統計の構築
  Widget _buildDetailedStats(
      int targetHours, int todayTotalTime, int targetSeconds) {
    final remainingTime = math.max(0, targetSeconds - todayTotalTime);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(
          label: '目標',
          value: '${targetHours}時間',
          color: CupertinoColors.systemGrey,
        ),
        _buildStatItem(
          label: '完了',
          value: SalaryCalculator.formatDuration(todayTotalTime),
          color: CupertinoColors.systemBlue,
        ),
        _buildStatItem(
          label: '残り',
          value: remainingTime > 0
              ? SalaryCalculator.formatDuration(remainingTime)
              : '達成済み',
          color: remainingTime > 0
              ? CupertinoColors.systemOrange
              : CupertinoColors.systemGreen,
        ),
      ],
    );
  }

  /// 統計アイテムの構築
  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'NotoSansJP',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
            fontFamily: 'NotoSansJP',
          ),
        ),
      ],
    );
  }

  /// 達成状況メッセージの構築
  Widget _buildStatusMessage(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getProgressColor(progress).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getProgressColor(progress).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getProgressIcon(progress),
            color: _getProgressColor(progress),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getProgressMessage(progress),
              style: TextStyle(
                fontSize: 14,
                color: _getProgressColor(progress),
                fontWeight: FontWeight.w500,
                fontFamily: 'NotoSansJP',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 進捗に応じた色を取得
  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return CupertinoColors.systemGreen;
    if (progress >= 0.8) return CupertinoColors.systemBlue;
    if (progress >= 0.6) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }

  /// 進捗に応じたアイコンを取得
  IconData _getProgressIcon(double progress) {
    if (progress >= 1.0) return CupertinoIcons.checkmark_circle_fill;
    if (progress >= 0.8) return CupertinoIcons.arrow_up_circle_fill;
    if (progress >= 0.6) return CupertinoIcons.exclamationmark_circle_fill;
    return CupertinoIcons.xmark_circle_fill;
  }

  /// 進捗に応じたグラデーションを取得
  List<Color> _getProgressGradient(double progress) {
    if (progress >= 1.0) {
      return [
        CupertinoColors.systemGreen,
        CupertinoColors.systemGreen.withOpacity(0.8),
      ];
    }
    if (progress >= 0.8) {
      return [
        CupertinoColors.systemBlue,
        CupertinoColors.systemBlue.withOpacity(0.8),
      ];
    }
    if (progress >= 0.6) {
      return [
        CupertinoColors.systemOrange,
        CupertinoColors.systemOrange.withOpacity(0.8),
      ];
    }
    return [
      CupertinoColors.systemRed,
      CupertinoColors.systemRed.withOpacity(0.8),
    ];
  }

  /// 進捗に応じたメッセージを取得
  String _getProgressMessage(double progress) {
    if (progress >= 1.2) return '素晴らしい！目標を大幅に達成しました！';
    if (progress >= 1.0) return '目標達成！おめでとうございます！';
    if (progress >= 0.8) return '順調なペースです。もう一息で達成！';
    if (progress >= 0.6) return '良いペースですが、もう少し頑張りましょう';
    if (progress >= 0.4) return '今日は少し遅れています。追い込みましょう！';
    return '今日はまだ勉強が始まっていません';
  }
}
