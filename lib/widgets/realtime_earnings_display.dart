/// StudyValue - リアルタイム収入時計ウィジェット（最適化版）
/// 秒ごとに更新される獲得金額表示とアニメーション効果
///
/// 【機能】
/// - 勉強中は秒ごとにリアルタイム更新
/// - スムーズなアニメーション効果
/// - 勉強状態に応じたビジュアル変化
/// - 今日の累計収益表示
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/study_session_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/salary_calculator.dart';

class RealtimeEarningsDisplay extends ConsumerWidget {
  const RealtimeEarningsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(studySessionProvider);
    final todaySessions = ref.watch(todayStudySessionsProvider);
    final userProfile = ref.watch(userProfileProvider);

    // 今日の累計収益計算
    final todayTotalEarnings = todaySessions.fold<double>(
        0, (sum, session) => sum + session.earnedAmount);

    // 現在のセッション収益
    final currentSessionEarnings = currentSession?.earnedAmount ?? 0;

    // 勉強中かどうか
    final isStudying = currentSession != null && currentSession.endTime == null;

    // 時給情報
    final hourlyWage = userProfile != null
        ? SalaryCalculator.calculateHourlyWage(userProfile)
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // 勉強状態に応じたグラデーション
        gradient: LinearGradient(
          colors: isStudying
              ? [
                  const Color(0xFF10B981), // エメラルドグリーン
                  const Color(0xFF059669), // 深いグリーン
                ]
              : [
                  const Color(0xFF3B82F6), // ブルー
                  const Color(0xFF1D4ED8), // 深いブルー
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (isStudying ? const Color(0xFF10B981) : const Color(0xFF3B82F6))
                    .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ヘッダー部分
          _buildHeader(isStudying),

          const SizedBox(height: 16),

          // メイン収益表示
          _buildMainEarningsDisplay(todayTotalEarnings, isStudying),

          const SizedBox(height: 12),

          // サブ情報表示
          _buildSubInfo(currentSessionEarnings, hourlyWage, isStudying),

          // 勉強中のライブインジケーター
          if (isStudying) ...[
            const SizedBox(height: 16),
            _buildLiveIndicator(),
          ],
        ],
      ),
    );
  }

  /// ヘッダー部分の構築
  Widget _buildHeader(bool isStudying) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 状態アイコン
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isStudying
                ? CupertinoIcons.money_dollar_circle_fill
                : CupertinoIcons.money_dollar_circle,
            key: ValueKey(isStudying),
            color: CupertinoColors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),

        // タイトル
        Text(
          isStudying ? '勉強中の収益' : '今日の収益',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'NotoSansJP',
          ),
        ),
      ],
    );
  }

  /// メイン収益表示の構築
  Widget _buildMainEarningsDisplay(double totalEarnings, bool isStudying) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: Text(
        SalaryCalculator.formatCurrency(totalEarnings),
        key: ValueKey(totalEarnings.toStringAsFixed(0)),
        style: TextStyle(
          color: CupertinoColors.white,
          fontSize: isStudying ? 40 : 36,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansJP',
          shadows: [
            Shadow(
              color: CupertinoColors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  /// サブ情報表示の構築
  Widget _buildSubInfo(
      double currentSessionEarnings, double hourlyWage, bool isStudying) {
    return Column(
      children: [
        // 現在のセッション収益（勉強中のみ）
        if (isStudying && currentSessionEarnings > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'このセッション: ${SalaryCalculator.formatCurrency(currentSessionEarnings)}',
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'NotoSansJP',
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // 時給情報
        if (hourlyWage > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '時給 ${SalaryCalculator.formatCurrency(hourlyWage)}',
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansJP',
              ),
            ),
          ),
      ],
    );
  }

  /// ライブインジケーターの構築
  Widget _buildLiveIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 脈動する円
        _buildPulsingDot(),
        const SizedBox(width: 8),

        // ライブテキスト
        const Text(
          'リアルタイム更新中...',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: 'NotoSansJP',
          ),
        ),
      ],
    );
  }

  /// 脈動するドットの構築
  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          width: 8 * value,
          height: 8 * value,
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        // アニメーション無限ループ（Statefulウィジェットに変更する場合）
      },
    );
  }
}

/// 脈動アニメーション用のStatefulウィジェット版（必要に応じて使用）
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // 無限ループアニメーション
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8 * _animation.value,
          height: 8 * _animation.value,
          decoration: BoxDecoration(
            color: CupertinoColors.white.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
