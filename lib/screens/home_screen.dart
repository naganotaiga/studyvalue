/// StudyValue - ホーム画面
/// 世界最高水準のUX/UIで勉強を習慣化

import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/app_theme.dart';
import '../models/user_profile.dart';
import '../models/study_session.dart';
import '../providers/user_profile_provider.dart';
import '../providers/study_session_provider.dart';
import '../services/salary_calculator.dart';
import 'profile_setting_screen.dart';
import 'study_records_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final currentSession = ref.watch(studySessionProvider);
    final todaySessions = ref.watch(todayStudySessionsProvider);
    final dailyProgress = ref.watch(dailyProgressProvider);
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('StudyValue'),
        backgroundColor: CupertinoColors.systemBackground,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (context) => const ProfileSettingScreen(),
              ),
            );
          },
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: SafeArea(
        child: userProfile == null
            ? _buildWelcomeScreen(context)
            : _buildMainScreen(context, ref, userProfile, currentSession, todaySessions, dailyProgress),
      ),
    );
  }

  /// 初回セットアップ画面
  Widget _buildWelcomeScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.book_circle,
              size: 100,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(height: 24),
            const Text(
              'StudyValueへようこそ！',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '勉強時間を時給として可視化し、\nモチベーションを向上させましょう',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (context) => const ProfileSettingScreen(),
                    ),
                  );
                },
                child: const Text('プロフィール設定を開始'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// メイン画面 - 世界最高水準のUI/UX
  Widget _buildMainScreen(
    BuildContext context,
    WidgetRef ref,
    UserProfile userProfile,
    StudySession? currentSession,
    List<StudySession> todaySessions,
    double dailyProgress,
  ) {
    final isStudying = currentSession != null && currentSession.endTime == null;
    final todayEarnings = todaySessions.fold<double>(0, (sum, session) => sum + session.earnedAmount);
    final todayMinutes = todaySessions.fold<int>(0, (sum, session) => sum + session.duration) ~/ 60;
    final streak = _calculateStreak(todaySessions);
    final hourlyWage = SalaryCalculator.calculateHourlyWage(userProfile);
    
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ヒーロー収入セクション
            _buildHeroEarningsSection(todayEarnings, hourlyWage, isStudying),
            
            // プログレスリング
            _buildProgressRings(dailyProgress, todayMinutes, streak),
            
            // メインコントロール
            _buildMainControls(context, isStudying),
            
            // 統計カード
            _buildStatsCards(context, userProfile, todaySessions),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
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
        final sessionDate = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
        final checkDateOnly = DateTime(checkDate.year, checkDate.month, checkDate.day);
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
  
  /// ヒーロー収入セクション
  Widget _buildHeroEarningsSection(double todayEarnings, double hourlyWage, bool isStudying) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isStudying ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isStudying ? '勉強中' : '休憩中',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '今日の収入',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            SalaryCalculator.formatCurrency(todayEarnings),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '時給 ${SalaryCalculator.formatCurrency(hourlyWage)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// プログレスリング
  Widget _buildProgressRings(double dailyProgress, int todayMinutes, int streak) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProgressItem(
            '目標達成',
            '${(dailyProgress * 100).toInt()}%',
            dailyProgress,
            const Color(0xFF3B82F6),
            CupertinoIcons.scope,
          ),
          _buildProgressItem(
            '勉強時間',
            '${todayMinutes}分',
            math.min(todayMinutes / 480, 1.0), // 8時間を最大として
            const Color(0xFF10B981),
            CupertinoIcons.time,
          ),
          _buildProgressItem(
            'ストリーク',
            '${streak}日',
            math.min(streak / 30, 1.0), // 30日を最大として
            const Color(0xFFF59E0B),
            CupertinoIcons.flame,
          ),
        ],
      ),
    );
  }
  
  /// プログレスアイテム
  Widget _buildProgressItem(String label, String value, double progress, Color color, IconData icon) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CupertinoActivityIndicator.partiallyRevealed(
                progress: progress,
                color: color,
                radius: 30,
              ),
            ),
            Icon(
              icon,
              color: color,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  /// メインコントロール
  Widget _buildMainControls(BuildContext context, bool isStudying) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 勉強開始/停止ボタン
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isStudying 
                  ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                  : [const Color(0xFF10B981), const Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: (isStudying ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // StudyControlButton の機能を統合
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // クイックアクション
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  context,
                  '記録を見る',
                  CupertinoIcons.chart_bar_alt_fill,
                  const Color(0xFF6366F1),
                  () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (context) => const StudyRecordsScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickAction(
                  context,
                  '設定',
                  CupertinoIcons.settings_solid,
                  const Color(0xFF8B5CF6),
                  () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (context) => const ProfileSettingScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// クイックアクション
  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(20),
        onPressed: onPressed,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 統計カード
  Widget _buildStatsCards(BuildContext context, UserProfile userProfile, List<StudySession> todaySessions) {
    final daysUntilExam = userProfile.examDate.difference(DateTime.now()).inDays;
    final sessionCount = todaySessions.length;
    final totalTime = todaySessions.fold<int>(0, (sum, session) => sum + session.duration);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '志望校',
                  userProfile.targetUniversity,
                  CupertinoIcons.building_2_fill,
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '受験まで',
                  '${daysUntilExam}日',
                  CupertinoIcons.calendar,
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'セッション',
                  '${sessionCount}回',
                  CupertinoIcons.play_circle_fill,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '合計時間',
                  SalaryCalculator.formatDuration(totalTime),
                  CupertinoIcons.time_solid,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 統計カード
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
