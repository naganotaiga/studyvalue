/// StudyValue - 勉強記録画面
/// 過去の勉強セッション履歴と統計を表示

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';
import '../providers/study_session_provider.dart';
import '../services/salary_calculator.dart';

class StudyRecordsScreen extends ConsumerWidget {
  const StudyRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSessions = ref.watch(studySessionListProvider);
    final todaySessions = ref.watch(todayStudySessionsProvider);
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('勉強記録'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: allSessions.isEmpty
            ? _buildEmptyState()
            : _buildRecordsList(context, allSessions, todaySessions),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar_circle,
              size: 80,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 16),
            Text(
              'まだ勉強記録がありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '勉強を開始して記録を作成しましょう',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context, List<StudySession> allSessions, List<StudySession> todaySessions) {
    return CustomScrollView(
      slivers: [
        // 今日の統計
        SliverToBoxAdapter(
          child: _buildTodayStats(todaySessions),
        ),
        
        // セッション履歴
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '勉強履歴',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final session = allSessions[index];
              return _buildSessionCard(session);
            },
            childCount: allSessions.length,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStats(List<StudySession> todaySessions) {
    final totalTime = todaySessions.fold<int>(0, (sum, session) => sum + session.duration);
    final totalEarnings = todaySessions.fold<double>(0, (sum, session) => sum + session.earnedAmount);
    final sessionCount = todaySessions.length;
    
    return Container(
      margin: const EdgeInsets.all(16.0),
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
          const Text(
            '今日の統計',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.timer,
                  label: '勉強時間',
                  value: SalaryCalculator.formatDuration(totalTime),
                  color: CupertinoColors.systemBlue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.money_dollar_circle,
                  label: '獲得金額',
                  value: SalaryCalculator.formatCurrency(totalEarnings),
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.chart_bar,
                  label: 'セッション数',
                  value: '$sessionCount回',
                  color: CupertinoColors.systemOrange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.speedometer,
                  label: '平均セッション',
                  value: sessionCount > 0 
                      ? SalaryCalculator.formatDuration(totalTime ~/ sessionCount)
                      : '0秒',
                  color: CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(StudySession session) {
    final isToday = _isToday(session.startTime);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(
          color: CupertinoColors.systemBlue.withOpacity(0.3),
          width: 1,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SalaryCalculator.formatDateJP(session.startTime),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '今日',
                    style: TextStyle(
                      fontSize: 10,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.time,
                size: 16,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '${SalaryCalculator.formatTimeJP(session.startTime)} - ${session.endTime != null ? SalaryCalculator.formatTimeJP(session.endTime!) : "進行中"}',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SalaryCalculator.formatDuration(session.duration),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemBlue,
                ),
              ),
              Text(
                SalaryCalculator.formatCurrency(session.earnedAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
          if (session.memo != null && session.memo!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                session.memo!,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
          if (session.isManuallyEdited) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.pencil,
                  size: 12,
                  color: CupertinoColors.systemOrange,
                ),
                const SizedBox(width: 4),
                const Text(
                  '手動編集済み',
                  style: TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}