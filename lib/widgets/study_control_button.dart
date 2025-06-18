/// StudyValue - 勉強開始・停止ボタンウィジェット
/// 大きな分かりやすいボタンで勉強セッションを制御

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';
import '../providers/study_session_provider.dart';
import '../services/salary_calculator.dart';

class StudyControlButton extends ConsumerWidget {
  const StudyControlButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSession = ref.watch(studySessionProvider);
    final isStudying = currentSession != null && currentSession.endTime == null;
    
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: (isStudying ? CupertinoColors.systemRed : CupertinoColors.systemGreen)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CupertinoButton(
        color: isStudying ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
        borderRadius: BorderRadius.circular(35),
        padding: EdgeInsets.zero,
        onPressed: () async {
          if (isStudying) {
            await ref.read(studySessionProvider.notifier).endSession();
            if (context.mounted) {
              _showSessionCompleteDialog(context, currentSession);
            }
          } else {
            await ref.read(studySessionProvider.notifier).startSession();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isStudying ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill,
              color: CupertinoColors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              isStudying ? '勉強終了' : '勉強開始',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSessionCompleteDialog(BuildContext context, StudySession session) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.checkmark_alt_circle_fill,
              color: CupertinoColors.systemGreen,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('勉強お疲れさまでした！'),
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
                          ),
                        ),
                        Text(
                          SalaryCalculator.formatDuration(session.duration),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                          ),
                        ),
                        Text(
                          SalaryCalculator.formatCurrency(session.earnedAmount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGreen,
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
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}