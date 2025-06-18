# StudyValue

**勉強時間を時給として可視化し、モチベーションを向上させるiOS専用アプリ**

![iOS](https://img.shields.io/badge/iOS-12.0%E2%80%9318.5-blue?logo=apple)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 アプリ概要

StudyValueは、学生の勉強時間を「時給」として可視化することで、勉強に対するモチベーションを向上させるiOS専用アプリです。志望校の偏差値に基づく予想年収から時給を算出し、リアルタイムで勉強による「収入」を表示します。

### 🎯 主要機能

- **リアルタイム収入時計**: 勉強中に秒ごとに収入が増加
- **段階的警告システム**: 3段階の警告でモチベーション維持
- **勉強記録管理**: 詳細な勉強履歴の記録・編集
- **目標設定**: 受験日・勉強時間の個別設定
- **通知機能**: リマインダーと達成通知
- **プロフィール管理**: 志望校・年収データのカスタマイズ

## 🏗 アプリ構成

### 技術スタック

- **フレームワーク**: Flutter 3.0+
- **プログラミング言語**: Dart
- **状態管理**: Riverpod
- **ローカルDB**: Hive
- **UI**: iOS Cupertino Design
- **フォント**: Noto Sans JP
- **対象プラットフォーム**: iOS 12.0〜18.5

### アーキテクチャ

```
StudyValue/
├── lib/
│   ├── main.dart                 # エントリーポイント・全機能統合
│   └── models/
│       └── adapters.dart         # Hiveアダプター
├── assets/
│   └── fonts/                    # NotoSansJPフォント
├── ios/                          # iOS固有設定
└── pubspec.yaml                  # 依存関係設定
```

## 🚀 セットアップ

### 前提条件

- macOS (iOS開発のため)
- Xcode 16.4以降（iOS 18.5対応）
- Flutter SDK 3.0以降
- iOS Simulator または実機
- 対応iOS版: 12.0〜18.5

### インストール手順

1. **リポジトリクローン**
```bash
git clone <repository-url>
cd studyvalue
```

2. **依存関係インストール**
```bash
flutter pub get
```

3. **フォントファイル配置**
```bash
# assets/fonts/ フォルダに以下を配置
- NotoSansJP-Regular.ttf
- NotoSansJP-Medium.ttf  
- NotoSansJP-Bold.ttf
```

4. **Hiveアダプター生成**（自動生成を使用する場合）
```bash
flutter packages pub run build_runner build
```

5. **iOSセットアップ**
```bash
cd ios
pod install
cd ..
```

6. **アプリ実行**
```bash
flutter run
```

## 📋 使用方法

### 初回セットアップ

1. **プロフィール設定**
   - 志望校入力
   - 受験日設定
   - 性別・年齢入力
   - 平日・休日の勉強時間設定

2. **年収データ調整**（オプション）
   - 偏差値帯別年収データから選択
   - カスタム年収の手動設定

### 日常の使用

1. **勉強開始**
   - ホーム画面の大きな「スタート」ボタンをタップ
   - リアルタイム収入時計が開始

2. **勉強終了**
   - 「ストップ」ボタンをタップ
   - 自動で記録が保存

3. **進捗確認**
   - 今日の勉強時間と達成率を確認
   - 段階的警告メッセージでモチベーション管理

4. **記録管理**
   - 「記録」タブで過去の勉強セッションを確認
   - 必要に応じて記録の編集・削除

## 🔧 開発情報

### 主要クラス構成

#### データモデル
- `UserProfile`: ユーザープロフィール情報
- `StudySession`: 勉強セッション記録
- `SalaryData`: 偏差値帯別年収データ
- `NotificationSettings`: 通知設定

#### コアシステム
- `SalaryCalculator`: 時給計算エンジン
- `WarningSystem`: 段階的警告システム
- `NotificationManager`: 通知管理
- `DatabaseManager`: Hiveデータベース管理

#### UI コンポーネント
- `RealtimeEarningsDisplay`: リアルタイム収入時計
- `StudyControlButton`: 勉強開始・停止ボタン
- `WarningDisplayWidget`: 段階的警告表示
- `ProgressBarWidget`: 進捗バー

### 状態管理

Riverpodを使用した状態管理：

- `userProfileProvider`: ユーザープロフィール状態
- `studySessionProvider`: 勉強セッション状態
- `calculationProvider`: 時給計算データ
- `notificationSettingsProvider`: 通知設定状態

### 計算式

```dart
// 総収入予測 = 年収 × 勤務年数（22歳〜65歳）
総収入予測 = 偏差値帯別年収 × 43年

// 勉強1時間の時給 = 総収入予測 ÷ 総勉強可能時間
時給 = 総収入予測 ÷ ((平日勉強時間 × 平日数) + (休日勉強時間 × 休日数))

// 勉強1秒の収入 = 時給 ÷ 3600秒
秒収入 = 時給 ÷ 3600
```

## 🎨 UI/UX設計

### デザインシステム

- **テーマ**: iOS Cupertino Design Language
- **カラー**: システムカラー使用（ダークモード対応）
- **フォント**: Noto Sans JP（日本語最適化）
- **レイアウト**: iOS Human Interface Guidelines準拠

### 警告システム

3段階の段階的警告システム：

| レベル | 条件 | メッセージ例 | 色 |
|--------|------|-------------|-----|
| レベル1 | 80%以上達成 | "挽回チャンス！時給1.1倍達成可能" | 青 |
| レベル2 | 60-79%達成 | "今日の損失: ○○円 / 明日+1時間で挽回可能" | オレンジ |
| レベル3 | 60%未満 | "累積損失: ○○円 / 週末集中で50%回復可能" | 赤 |

## 🔔 通知機能

### 通知タイプ

1. **勉強リマインダー**: 設定時刻に勉強開始を促す
2. **達成通知**: 目標達成時の祝福メッセージ
3. **警告通知**: 勉強不足時の注意喚起

### 設定項目

- 通知有効/無効の切り替え
- 各通知タイプの個別設定
- リマインダー時刻のカスタマイズ

## 📊 データ管理

### ローカルストレージ

Hiveを使用したローカルデータベース：

- **プロフィールデータ**: ユーザー設定情報
- **勉強記録**: セッション履歴
- **年収データ**: 偏差値帯別年収情報
- **通知設定**: 通知の詳細設定

### データ形式

```dart
// 勉強セッション例
StudySession {
  startTime: 2025-06-03 19:00:00,
  endTime: 2025-06-03 21:30:00,
  duration: 9000, // 秒
  isManuallyEdited: false,
  memo: "数学の微積分を学習",
  earnedAmount: 2500.0 // 円
}
```

## 🔒 プライバシー・セキュリティ

- **ローカル専用**: すべてのデータはデバイス内のみ保存
- **外部通信なし**: インターネット接続不要
- **個人情報保護**: 機密情報の外部送信一切なし

## 🧪 テスト

### テスト戦略

- **単体テスト**: 計算エンジンとビジネスロジック
- **ウィジェットテスト**: UI コンポーネント
- **統合テスト**: アプリ全体のワークフロー

### テスト実行

```bash
# 全テスト実行
flutter test

# カバレッジ付きテスト
flutter test --coverage
```

## 📦 ビルド・リリース

### 開発ビルド

```bash
flutter build ios --debug
```

### リリースビルド

```bash
flutter build ios --release
```

### App Store対応

1. **証明書設定**: Apple Developer アカウント必要
2. **プロビジョニングプロファイル**: 配布用設定
3. **アプリアイコン**: 各サイズ対応
4. **メタデータ**: App Store Connect設定

## 🛠 トラブルシューティング

### よくある問題

**Q: ビルドエラーが発生する**
```bash
# キャッシュクリア
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

**Q: フォントが表示されない**
- `assets/fonts/` にフォントファイルが正しく配置されているか確認
- `pubspec.yaml` のフォント設定を確認

**Q: Hiveエラーが発生する**
```bash
# アダプター再生成
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 🤝 コントリビューション

### 開発ガイドライン

1. **コードスタイル**: `analysis_options.yaml` に準拠
2. **コミットメッセージ**: Conventional Commits 形式
3. **プルリクエスト**: 機能ごとに作成
4. **テスト**: 新機能には必ずテストを追加

### セットアップ（開発者向け）

```bash
# 開発環境セットアップ
git clone <repository-url>
cd studyvalue
flutter pub get
flutter pub run build_runner build
```

## 📄 ライセンス

このプロジェクトは [MIT License](LICENSE) の下で公開されています。

## 🙏 謝辞

- **Flutter**: Google が開発するUIフレームワーク
- **Riverpod**: Remi Rousselet が開発する状態管理ライブラリ
- **Hive**: Tobias Wehrle が開発するローカルデータベース
- **Noto Sans JP**: Google Fonts の日本語フォント

## 📞 サポート

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)
- **Wiki**: [プロジェクトWiki](../../wiki)

---

**StudyValue** - 勉強時間を価値に変えるアプリ 📚💰