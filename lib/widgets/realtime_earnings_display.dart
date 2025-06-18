/// StudyValue - リアルタイム収入時計ウィジェット
/// 秒ごとに更新される獲得金額表示

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/study_session_provider.dart';
import '../services/salary_calculator.dart';

class RealtimeEarningsDisplay extends ConsumerWidget {
  const RealtimeEarningsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(studySessionProvider);
    final earnedAmount = currentSession?.earnedAmount ?? 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CupertinoColors.systemBlue,
            CupertinoColors.systemPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                currentSession != null && currentSession.endTime == null
                    ? CupertinoIcons.money_dollar_circle_fill
                    : CupertinoIcons.money_dollar_circle,
                color: CupertinoColors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '今日の獲得金額',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              SalaryCalculator.formatCurrency(earnedAmount),
              key: ValueKey(earnedAmount.toStringAsFixed(0)),
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (currentSession != null && currentSession.endTime == null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'リアルタイム更新中...',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}