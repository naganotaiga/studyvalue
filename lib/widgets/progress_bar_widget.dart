/// StudyValue - 進捗バーウィジェット
/// 今日の目標達成率を視覚化

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
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
    
    if (userProfile == null) {
      return const SizedBox.shrink();
    }
    
    final targetHours = ref.read(userProfileProvider.notifier).todayTargetHours;
    final progressPercentage = (progress * 100).clamp(0, 100);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '今日の目標達成率',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progress),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 進捗バー
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  // 背景
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: CupertinoColors.systemGrey5,
                  ),
                  // 進捗
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getProgressGradient(progress),
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  // 目標線（100%の位置）
                  if (progress > 1.0)
                    Positioned(
                      left: (1.0 * (MediaQuery.of(context).size.width - 72)) - 1,
                      child: Container(
                        width: 2,
                        height: 12,
                        color: CupertinoColors.systemYellow,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 目標時間情報
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '目標: ${targetHours}時間',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Text(
                _getProgressMessage(progress),
                style: TextStyle(
                  fontSize: 12,
                  color: _getProgressColor(progress),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return CupertinoColors.systemGreen;
    if (progress >= 0.8) return CupertinoColors.systemBlue;
    if (progress >= 0.6) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }

  List<Color> _getProgressGradient(double progress) {
    if (progress >= 1.0) {
      return [
        CupertinoColors.systemGreen,
        CupertinoColors.systemGreen.withOpacity(0.7),
      ];
    }
    if (progress >= 0.8) {
      return [
        CupertinoColors.systemBlue,
        CupertinoColors.systemBlue.withOpacity(0.7),
      ];
    }
    if (progress >= 0.6) {
      return [
        CupertinoColors.systemOrange,
        CupertinoColors.systemOrange.withOpacity(0.7),
      ];
    }
    return [
      CupertinoColors.systemRed,
      CupertinoColors.systemRed.withOpacity(0.7),
    ];
  }

  String _getProgressMessage(double progress) {
    if (progress >= 1.0) return '目標達成！';
    if (progress >= 0.8) return '順調なペース';
    if (progress >= 0.6) return '頑張ろう';
    return '要努力';
  }
}