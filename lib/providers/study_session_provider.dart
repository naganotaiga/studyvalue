/// StudyValue - 勉強セッション状態管理
/// 現在の勉強セッションと過去の記録を管理

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_session.dart';
import '../services/database_manager.dart';
import '../services/salary_calculator.dart';
import 'user_profile_provider.dart';

/// 現在の勉強セッションプロバイダー
final studySessionProvider = StateNotifierProvider<StudySessionNotifier, StudySession?>((ref) {
  return StudySessionNotifier(ref);
});

/// 勉強セッション履歴プロバイダー
final studySessionListProvider = Provider<List<StudySession>>((ref) {
  try {
    final box = DatabaseManager.studySessionBox;
    return box.values.toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  } catch (e) {
    return [];
  }
});

/// 今日の勉強セッションプロバイダー
final todayStudySessionsProvider = Provider<List<StudySession>>((ref) {
  final allSessions = ref.watch(studySessionListProvider);
  final today = DateTime.now();
  
  return allSessions.where((session) =>
      session.startTime.year == today.year &&
      session.startTime.month == today.month &&
      session.startTime.day == today.day
  ).toList();
});

/// 今日の合計勉強時間プロバイダー（秒）
final todayTotalStudyTimeProvider = Provider<int>((ref) {
  final todaySessions = ref.watch(todayStudySessionsProvider);
  return todaySessions.fold<int>(0, (total, session) => total + session.duration);
});

/// 今日の進捗率プロバイダー（0.0〜1.0）
final dailyProgressProvider = Provider<double>((ref) {
  final profile = ref.watch(userProfileProvider);
  final todaySessions = ref.watch(todayStudySessionsProvider);
  
  if (profile == null) return 0.0;
  return SalaryCalculator.calculateDailyProgress(profile, todaySessions);
});

class StudySessionNotifier extends StateNotifier<StudySession?> {
  StudySessionNotifier(this._ref) : super(null);
  
  final Ref _ref;
  Timer? _timer;
  
  /// 勉強開始
  Future<void> startSession() async {
    if (state != null) return; // 既に開始済み
    
    final now = DateTime.now();
    final newSession = StudySession(
      id: now.millisecondsSinceEpoch.toString(),
      startTime: now,
      duration: 0,
      earnedAmount: 0,
    );
    
    state = newSession;
    
    // 1秒ごとに更新
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateSession();
    });
  }
  
  /// セッションを更新（1秒ごと）
  void _updateSession() {
    if (state == null) return;
    
    final profile = _ref.read(userProfileProvider);
    if (profile == null) return;
    
    final newDuration = state!.duration + 1;
    final perSecondEarning = SalaryCalculator.calculatePerSecondEarning(profile);
    
    state = state!.copyWith(
      duration: newDuration,
      earnedAmount: newDuration * perSecondEarning,
    );
  }
  
  /// 勉強終了
  Future<void> endSession() async {
    if (state == null) return;
    
    _timer?.cancel();
    
    final completedSession = state!.copyWith(
      endTime: DateTime.now(),
    );
    
    // データベースに保存
    await _saveSession(completedSession);
    
    // 現在のセッションをクリア
    state = null;
  }
  
  /// セッションをデータベースに保存
  Future<void> _saveSession(StudySession session) async {
    try {
      final box = DatabaseManager.studySessionBox;
      await box.add(session);
    } catch (e) {
      // エラーハンドリング
      throw Exception('勉強セッションの保存に失敗しました: $e');
    }
  }
  
  /// セッションを強制停止（リセット）
  void resetSession() {
    _timer?.cancel();
    state = null;
  }
  
  /// セッションが進行中かどうか
  bool get isSessionActive => state != null && state!.endTime == null;
  
  /// 現在のセッション時間（秒）
  int get currentSessionDuration => state?.duration ?? 0;
  
  /// 現在のセッション獲得金額
  double get currentEarnedAmount => state?.earnedAmount ?? 0;
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// 勉強セッション管理プロバイダー（CRUD操作用）
final studySessionManagerProvider = Provider<StudySessionManager>((ref) {
  return StudySessionManager(ref);
});

class StudySessionManager {
  StudySessionManager(this._ref);
  
  final Ref _ref;
  
  /// セッションを手動追加
  Future<void> addManualSession({
    required DateTime startTime,
    required DateTime endTime,
    String? memo,
  }) async {
    final duration = endTime.difference(startTime).inSeconds;
    if (duration <= 0) {
      throw Exception('終了時刻は開始時刻より後である必要があります');
    }
    
    final profile = _ref.read(userProfileProvider);
    if (profile == null) {
      throw Exception('ユーザープロフィールが設定されていません');
    }
    
    final perSecondEarning = SalaryCalculator.calculatePerSecondEarning(profile);
    
    final session = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      isManuallyEdited: true,
      memo: memo,
      earnedAmount: duration * perSecondEarning,
    );
    
    try {
      final box = DatabaseManager.studySessionBox;
      await box.add(session);
    } catch (e) {
      throw Exception('セッションの追加に失敗しました: $e');
    }
  }
  
  /// セッションを編集
  Future<void> editSession(
    String sessionId, {
    DateTime? startTime,
    DateTime? endTime,
    String? memo,
  }) async {
    try {
      final box = DatabaseManager.studySessionBox;
      final sessions = box.values.where((s) => s.id == sessionId).toList();
      
      if (sessions.isEmpty) {
        throw Exception('セッションが見つかりません');
      }
      
      final session = sessions.first;
      final sessionIndex = box.values.toList().indexOf(session);
      
      final updatedSession = session.copyWith(
        startTime: startTime,
        endTime: endTime,
        memo: memo,
        isManuallyEdited: true,
      );
      
      // 時間が変更された場合、獲得金額を再計算
      if (startTime != null || endTime != null) {
        final newDuration = (updatedSession.endTime ?? DateTime.now())
            .difference(updatedSession.startTime).inSeconds;
        
        final profile = _ref.read(userProfileProvider);
        if (profile != null) {
          final perSecondEarning = SalaryCalculator.calculatePerSecondEarning(profile);
          final newEarnedAmount = newDuration * perSecondEarning;
          
          final finalSession = updatedSession.copyWith(
            duration: newDuration,
            earnedAmount: newEarnedAmount,
          );
          
          await box.putAt(sessionIndex, finalSession);
        }
      } else {
        await box.putAt(sessionIndex, updatedSession);
      }
    } catch (e) {
      throw Exception('セッションの編集に失敗しました: $e');
    }
  }
  
  /// セッションを削除
  Future<void> deleteSession(String sessionId) async {
    try {
      final box = DatabaseManager.studySessionBox;
      final sessions = box.values.where((s) => s.id == sessionId).toList();
      
      if (sessions.isEmpty) {
        throw Exception('セッションが見つかりません');
      }
      
      final session = sessions.first;
      final sessionIndex = box.values.toList().indexOf(session);
      
      await box.deleteAt(sessionIndex);
    } catch (e) {
      throw Exception('セッションの削除に失敗しました: $e');
    }
  }
  
  /// 全セッションを削除
  Future<void> deleteAllSessions() async {
    try {
      final box = DatabaseManager.studySessionBox;
      await box.clear();
    } catch (e) {
      throw Exception('全セッションの削除に失敗しました: $e');
    }
  }
}