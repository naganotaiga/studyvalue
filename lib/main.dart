/// StudyValue - iOS専用勉強時間管理アプリ
/// 勉強時間を時給として可視化し、モチベーションを向上させる
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/database_manager.dart';
import 'screens/home_screen.dart';

class StudyValueApp extends StatelessWidget {
  const StudyValueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'StudyValue',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// アプリケーションエントリーポイント
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // データベース初期化
  await DatabaseManager.initialize();
  
  // 開発中のため、新しいフィールドとの互換性のためにデータベースをクリア
  // 本番環境では適切なマイグレーション処理を行う
  try {
    await DatabaseManager.clearAllData();
    print('Database cleared for new schema compatibility');
  } catch (e) {
    print('Error clearing database: $e');
  }
  
  runApp(
    const ProviderScope(
      child: StudyValueApp(),
    ),
  );
}