/// StudyValue - 勉強時間表示ウィジェット
/// 現在のセッション時間と今日の合計時間を表示

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/study_session_provider.dart';
import '../services/salary_calculator.dart';

class StudyTimeDisplay extends ConsumerWidget {
  const StudyTimeDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(studySessionProvider);
    final todayTotalTime = ref.watch(todayTotalStudyTimeProvider);
    
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
        children: [
          // 現在のセッション時間
          _buildTimeSection(
            icon: CupertinoIcons.timer,
            title: '現在のセッション',
            time: SalaryCalculator.formatDuration(currentSession?.duration ?? 0),
            color: currentSession != null && currentSession.endTime == null
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemGrey,
            isActive: currentSession != null && currentSession.endTime == null,
          ),
          
          const SizedBox(height: 16),
          
          // 区切り線
          Container(
            height: 1,
            color: CupertinoColors.systemGrey5,
          ),
          
          const SizedBox(height: 16),
          
          // 今日の合計時間
          _buildTimeSection(
            icon: CupertinoIcons.calendar_today,
            title: '今日の合計時間',
            time: SalaryCalculator.formatDuration(todayTotalTime),
            color: CupertinoColors.systemBlue,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection({
    required IconData icon,
    required String title,
    required String time,
    required Color color,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  time,
                  key: ValueKey(time),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}