/// StudyValue - iOS専用勉強時間管理アプリ
/// 勉強時間を時給として可視化し、モチベーションを向上させる
///
/// 【主要機能】
/// - タブベースナビゲーション（ホーム・記録・設定）
/// - リアルタイム勉強時間計測と時給計算
/// - 偏差値帯別年収データに基づく収益予測
/// - 段階的警告システムによるモチベーション管理
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/database_manager.dart';
import 'screens/main_tab_screen.dart';

/// StudyValueアプリケーションクラス
/// CupertinoAppを使用してiOSネイティブな体験を提供
class StudyValueApp extends StatelessWidget {
  const StudyValueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'StudyValue',

      // iOSネイティブなテーマ設定
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        // NotoSansJPフォントを全体に適用
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            color: CupertinoColors.label,
          ),
        ),
      ),

      // タブベースナビゲーションをルートに設定
      home: const MainTabScreen(),

      // デバッグバナー非表示（リリース時の美観向上）
      debugShowCheckedModeBanner: false,

      // iOS固有の設定
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'), // 日本語優先
        Locale('en', 'US'), // 英語フォールバック
      ],
    );
  }
}

/// アプリケーションエントリーポイント
/// データベース初期化とプロバイダー設定を行う
Future<void> main() async {
  // Flutter初期化（プラットフォーム固有の設定前に必須）
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Hiveデータベース初期化
    // ユーザープロフィール、勉強セッション、年収データ、通知設定を管理
    await DatabaseManager.initialize();
    print('✅ データベース初期化完了');

    // 開発中の新機能対応のため一時的にデータクリア
    // 本番環境では適切なマイグレーション処理に変更する
    await DatabaseManager.clearAllData();
    print('🔄 開発用データベースクリア完了');
  } catch (e) {
    // データベース初期化エラーのハンドリング
    print('❌ データベース初期化エラー: $e');
    // エラーがあってもアプリは起動する（オフライン対応）
  }

  // Riverpodプロバイダースコープでアプリ全体を包む
  // 状態管理と依存性注入を提供
  runApp(
    const ProviderScope(
      child: StudyValueApp(),
    ),
  );
}
