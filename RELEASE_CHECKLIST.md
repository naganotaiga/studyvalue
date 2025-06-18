# iOS App Store リリースチェックリスト

## 完了済みの作業

### ✅ 必要なファイルの生成
- [x] プライバシーポリシー (PRIVACY_POLICY.md)
- [x] App Store申請情報 (APP_STORE_DESCRIPTION.md)
- [x] アプリアイコン（全サイズ完備）
- [x] スプラッシュスクリーン設定

### ✅ Info.plist設定の更新
- [x] 画面の向きを縦向きのみに制限
- [x] 暗号化除外の宣言を追加 (ITSAppUsesNonExemptEncryption = false)
- [x] アプリカテゴリを教育に設定 (LSApplicationCategoryType)

### ✅ 不要なファイルの削除
- [x] Androidディレクトリの削除を試行（権限エラーのため手動削除が必要）
- [x] 重複した.imlファイルの削除を試行
- [x] buildディレクトリの削除を試行

## 🚨 要対応項目

### 1. Bundle Identifier の修正
現在の設定: `com.example.stadyvalue`
- **タイポの修正**: "stadyvalue" → "studyvalue"
- **独自の識別子に変更**: 例 `com.yourcompany.studyvalue`

### 2. バージョン番号の確認
- pubspec.yaml: `version: 1.0.0+1`
- ビルド番号は自動的にXcodeプロジェクトに反映されます

### 3. 開発者情報の更新
- プライバシーポリシーの連絡先メールアドレス
- App Store説明文の著作権情報
- サポートURL
- マーケティングURL（オプション）

### 4. 手動削除が必要なファイル/ディレクトリ
```bash
# 以下のコマンドを実行してください
rm -rf android/
rm -f stadyvalue.iml studyvalue.iml
rm -rf build/
rm -f ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md
```

### 5. ビルドコマンド
```bash
# クリーンビルド
flutter clean
flutter pub get
cd ios && pod install && cd ..

# リリースビルド
flutter build ios --release

# Xcodeでアーカイブを作成
open ios/Runner.xcworkspace
```

### 6. Xcode での最終設定
1. Bundle Identifierの修正
2. Development TeamとCode Signingの設定
3. Product > Archive でアーカイブ作成
4. App Store Connect へのアップロード

## 📝 注意事項

- 最小iOS バージョン: 12.0
- 最大iOS バージョン: 18.5
- フォントファイル（NotoSansJP）は既に配置済み
- 通知機能は現在コメントアウト中（必要に応じて有効化）

## 📱 テスト推奨項目

1. 実機での動作確認
2. 異なるiOSバージョンでのテスト（12.0〜18.5）
3. iPhoneとiPadでの表示確認
4. データの保存・読み込み機能
5. 時給計算の精度確認