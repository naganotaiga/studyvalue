/// StudyValue - メインタブスクリーン
/// iOSネイティブなタブバーナビゲーションを提供
///
/// 【タブ構成】
/// 1. ホーム: 勉強セッション管理とリアルタイム収益表示
/// 2. 記録: 過去の勉強履歴と統計表示
/// 3. 設定: ユーザープロフィールと各種設定
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'study_records_screen.dart';
import 'profile_setting_screen.dart';
import '../providers/user_profile_provider.dart';

/// メインタブスクリーンクラス
/// CupertinoTabScaffoldを使用してiOSネイティブなタブ体験を提供
class MainTabScreen extends ConsumerStatefulWidget {
  const MainTabScreen({super.key});

  @override
  ConsumerState<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends ConsumerState<MainTabScreen> {
  /// 現在選択中のタブインデックス
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return CupertinoTabScaffold(
      // タブバーの設定
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        // iOSらしいタブバーデザイン
        backgroundColor: CupertinoColors.systemBackground,
        activeColor: CupertinoColors.systemBlue,
        inactiveColor: CupertinoColors.systemGrey,
        iconSize: 28,

        // タブアイテム定義
        items: [
          // ホームタブ
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.home),
            activeIcon: const Icon(CupertinoIcons.home_fill),
            label: 'ホーム',
          ),

          // 記録タブ
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chart_bar),
            activeIcon: const Icon(CupertinoIcons.chart_bar_fill),
            label: '記録',
          ),

          // 設定タブ
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(CupertinoIcons.settings),
                // プロフィール未設定時の通知バッジ
                if (userProfile == null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              children: [
                const Icon(CupertinoIcons.settings_solid),
                if (userProfile == null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.systemRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: '設定',
          ),
        ],
      ),

      // タブビルダー（遅延読み込み対応）
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => const HomeScreen(),
              defaultTitle: 'StudyValue',
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const StudyRecordsScreen(),
              defaultTitle: '勉強記録',
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => const ProfileSettingScreen(),
              defaultTitle: '設定',
            );
          default:
            return CupertinoTabView(
              builder: (context) => const HomeScreen(),
              defaultTitle: 'StudyValue',
            );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // 初回起動時にプロフィール未設定の場合は設定タブに誘導
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = ref.read(userProfileProvider);
      if (userProfile == null) {
        _showFirstTimeWelcome();
      }
    });
  }

  /// 初回起動時のウェルカムダイアログ表示
  void _showFirstTimeWelcome() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.sparkles,
              color: CupertinoColors.systemBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('StudyValueへようこそ！'),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            '勉強時間を時給として可視化し、\nモチベーションを向上させましょう。\n\nまずはプロフィール設定から始めます。',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('設定を始める'),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentIndex = 2; // 設定タブに移動
              });
            },
          ),
        ],
      ),
    );
  }
}
