/// StudyValue - 警告表示ウィジェット（最適化版）
/// 段階的警告システムによるモチベーション管理
///
/// 【機能】
/// - 3段階の警告レベル表示
/// - 進捗に応じたビジュアル変化
/// - アクションアドバイス表示
/// - モチベーションメッセージ
library;

import 'package:flutter/cupertino.dart';
import '../models/user_profile.dart';
import '../models/study_session.dart';
import '../services/warning_system.dart';

class WarningDisplayWidget extends StatelessWidget {
  final UserProfile profile;
  final List<StudySession> sessions;

  const WarningDisplayWidget({
    super.key,
    required this.profile,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final warningData = WarningSystem.generateWarningData(profile, sessions);
    final motivationMessage =
        WarningSystem.generateMotivationMessage(profile, sessions);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getBackgroundColor(warningData.level),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(warningData.level),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor(warningData.level).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // メインメッセージ部分
          _buildMainMessage(warningData),

          // アクションアドバイス
          if (warningData.actionAdvice.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildActionAdvice(warningData),
          ],

          // モチベーションメッセージ
          if (motivationMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMotivationMessage(motivationMessage, warningData.level),
          ],
        ],
      ),
    );
  }

  /// メインメッセージ部分の構築
  Widget _buildMainMessage(WarningData warningData) {
    return Row(
      children: [
        // 警告アイコン（アニメーション付き）
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(warningData.level),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    WarningSystem.getWarningIcon(warningData.level),
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 16),

        // メッセージテキスト
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // メインタイトル
              Text(
                warningData.message,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(warningData.level),
                  fontFamily: 'NotoSansJP',
                ),
              ),

              // サブメッセージ
              if (warningData.submessage.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  warningData.submessage,
                  style: TextStyle(
                    fontSize: 15,
                    color: _getTextColor(warningData.level).withOpacity(0.8),
                    fontFamily: 'NotoSansJP',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// アクションアドバイス部分の構築
  Widget _buildActionAdvice(WarningData warningData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(warningData.level).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // アドバイスアイコン
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getTextColor(warningData.level).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.lightbulb,
              color: _getTextColor(warningData.level),
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // アドバイステキスト
          Expanded(
            child: Text(
              warningData.actionAdvice,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getTextColor(warningData.level),
                fontFamily: 'NotoSansJP',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// モチベーションメッセージ部分の構築
  Widget _buildMotivationMessage(String message, WarningLevel level) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTextColor(level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: _getTextColor(level).withOpacity(0.9),
          fontFamily: 'NotoSansJP',
        ),
      ),
    );
  }

  /// 警告レベルに応じた背景色を取得
  Color _getBackgroundColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.none:
        return CupertinoColors.systemGreen.withOpacity(0.1);
      case WarningLevel.level1:
        return CupertinoColors.systemBlue.withOpacity(0.1);
      case WarningLevel.level2:
        return CupertinoColors.systemOrange.withOpacity(0.1);
      case WarningLevel.level3:
        return CupertinoColors.systemRed.withOpacity(0.1);
    }
  }

  /// 警告レベルに応じたボーダー色を取得
  Color _getBorderColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.none:
        return CupertinoColors.systemGreen.withOpacity(0.4);
      case WarningLevel.level1:
        return CupertinoColors.systemBlue.withOpacity(0.4);
      case WarningLevel.level2:
        return CupertinoColors.systemOrange.withOpacity(0.4);
      case WarningLevel.level3:
        return CupertinoColors.systemRed.withOpacity(0.4);
    }
  }

  /// 警告レベルに応じたテキスト色を取得
  Color _getTextColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.none:
        return CupertinoColors.systemGreen;
      case WarningLevel.level1:
        return CupertinoColors.systemBlue;
      case WarningLevel.level2:
        return CupertinoColors.systemOrange;
      case WarningLevel.level3:
        return CupertinoColors.systemRed;
    }
  }

  /// アイコン背景色を取得
  Color _getIconBackgroundColor(WarningLevel level) {
    return _getTextColor(level).withOpacity(0.15);
  }
}
