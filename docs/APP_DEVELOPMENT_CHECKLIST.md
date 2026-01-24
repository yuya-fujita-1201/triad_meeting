# アプリ開発・ストア公開チェックリスト

このドキュメントは、「はじめてメモ」の開発・公開経験から得た教訓をまとめたものです。
次のアプリ開発をスムーズに進めるための実践的なチェックリストです。

## 📋 目次

1. [プロジェクト開始前の準備](#プロジェクト開始前の準備)
2. [プロジェクト設定（初期）](#プロジェクト設定初期)
3. [開発中の注意点](#開発中の注意点)
4. [ストア公開準備](#ストア公開準備)
5. [iOS固有の注意点](#ios固有の注意点)
6. [Android固有の注意点](#android固有の注意点)
7. [今回遭遇した問題と解決策](#今回遭遇した問題と解決策)
8. [便利なスクリプト・ツール](#便利なスクリプトツール)

---

## プロジェクト開始前の準備

### アカウント・登録

- [ ] **Apple Developer Program** 登録（iOS配信する場合）- 年間$99
- [ ] **Google Play Console** 登録（Android配信する場合）- 一度だけ$25
- [ ] **Firebase プロジェクト** 作成（バックエンド使う場合）
- [ ] **RevenueCat アカウント**（課金機能使う場合）
- [ ] **AdMob アカウント**（広告表示する場合）

### アプリ名・ドメイン

- [ ] **アプリ名を決定** - App Store/Google Playで重複チェック
  - 既存アプリと被らないか確認
  - 商標問題がないか確認
  - ドメイン名も一緒に確保できるか確認

- [ ] **Bundle ID / Application ID を決定**
  - 形式: `com.company.appname` または `works.company.appname`
  - **重要**: 一度公開したら変更不可
  - 例: iOS `works.yourcompany.appname` / Android `works.yourcompany.appname`
  - iOS と Android で同じIDにすると管理が楽

### 企画・設計

- [ ] **プライバシーポリシーURL** を準備
  - GitHub Pages、個人サイト、またはGitHub READMEへの直リンク
  - 最低限の内容: データ収集、利用目的、第三者サービス、連絡先
  - **作成タイミング**: プロジェクト初期（README.mdに含めるのが簡単）

- [ ] **サポートURL** を準備
  - GitHub Issues、問い合わせフォーム、メールアドレスなど

- [ ] **スクリーンショット撮影計画**
  - 主要機能5つをピックアップ
  - 各画面に短いキャッチコピーを追加する計画

---

## プロジェクト設定（初期）

### Flutter プロジェクト作成

```bash
flutter create --org works.yourcompany app_name
cd app_name
```

**重要**: `--org` オプションで Bundle ID のプレフィックスを指定
- これで `works.yourcompany.appName` が自動生成される
- 後から変更するより最初から正しく設定する

### iOS 設定（最初から正しく）

#### 1. Bundle ID の確認

- [ ] `ios/Runner.xcodeproj/project.pbxproj` を開く
- [ ] `PRODUCT_BUNDLE_IDENTIFIER` が正しいか確認
- [ ] 開発用とリリース用で同じBundle IDを使う

#### 2. Deployment Target

- [ ] Xcode > Runner > General > Deployment Info
- [ ] iOS最小バージョンを設定（推奨: iOS 12.0以上）

#### 3. 対応デバイス

- [ ] **iPhone専用** または **iPhone + iPad** を最初に決定
- [ ] iPad対応する場合: スクリーンショットが2倍必要
- [ ] 判断基準:
  - アプリがiPadで意味があるか？
  - iPad用UIを作る工数があるか？
  - **迷ったらiPhone専用にする**（後から追加可能）

#### 4. 対応言語

- [ ] Info.plist で `CFBundleLocalizations` 設定
- [ ] 日本語のみ or 英語も対応するか決定

### Android 設定（最初から正しく）

#### 1. Application ID の確認

- [ ] `android/app/build.gradle.kts` を開く
- [ ] `applicationId` が正しいか確認
- [ ] `namespace` も同じにする

```kotlin
android {
    namespace = "works.yourcompany.appname"
    defaultConfig {
        applicationId = "works.yourcompany.appname"
        minSdk = 21
        targetSdk = flutter.targetSdk
        versionCode = 1
        versionName = "1.0.0"
    }
}
```

#### 2. パッケージ構造

- [ ] MainActivity.kt のパッケージ名を確認
- [ ] ファイルパスも `app/src/main/kotlin/works/yourcompany/appname/` に移動

#### 3. 署名設定（早めに準備）

**開発開始時にキーストアを作成**:

```bash
keytool -genkey -v -keystore ~/release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias release
```

- [ ] パスワードを安全に保管（1Passwordなど）
- [ ] `android/key.properties` を作成（`.gitignore`に追加）

```properties
storePassword=your_password
keyPassword=your_password
keyAlias=release
storeFile=/path/to/release.keystore
```

- [ ] `android/app/build.gradle.kts` に署名設定を追加

### Firebase 設定（使う場合）

#### iOS

- [ ] Firebase Console で iOS アプリ追加
- [ ] **正しいBundle ID**を入力
- [ ] `GoogleService-Info.plist` をダウンロード
- [ ] `ios/Runner/GoogleService-Info.plist` に配置
- [ ] Xcodeプロジェクトに追加（Runnerフォルダにドラッグ）

#### Android

- [ ] Firebase Console で Android アプリ追加
- [ ] **正しいApplication ID**を入力
- [ ] SHA-1証明書フィンガープリントを追加（デバッグ・リリース両方）
- [ ] `google-services.json` をダウンロード
- [ ] `android/app/google-services.json` に配置

**SHA-1の取得方法**:

```bash
# デバッグ用
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore

# リリース用
keytool -list -v -alias release \
  -keystore ~/release.keystore
```

### AdMob 設定（使う場合）

- [ ] AdMob アカウント作成
- [ ] アプリを登録（iOS・Android別々）
- [ ] **広告ユニットID**を作成して記録
  - バナー広告
  - インタースティシャル広告
  - リワード広告（必要に応じて）
- [ ] **テスト用広告ID**を開発中は使用
- [ ] リリース前に**本番広告ID**に差し替え

#### iOS での設定

`ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

#### Android での設定

`android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
```

### RevenueCat 設定（課金機能使う場合）

- [ ] RevenueCat プロジェクト作成
- [ ] iOS: App Store Connect API キー連携
- [ ] Android: Google Play Console サービスアカウント連携
- [ ] 商品（Entitlements & Offerings）設定
- [ ] Public API Key を記録

---

## 開発中の注意点

### バージョン管理

- [ ] **セマンティックバージョニング**を使う: `MAJOR.MINOR.PATCH`
  - 例: `1.0.0`, `1.1.0`, `1.1.1`
- [ ] **ビルド番号**は毎回インクリメント
  - iOS: `CFBundleVersion`
  - Android: `versionCode`

`pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ^^^^^ ^^
#        |     ビルド番号（毎回+1）
#        バージョン名
```

### コミット・ブランチ戦略

- [ ] **main ブランチ = リリース可能な状態**を維持
- [ ] 機能開発は feature ブランチで
- [ ] リリース前に必ず `git tag` でタグ付け

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### セキュリティ

- [ ] **APIキー・シークレットをコードに直接書かない**
- [ ] `.env` ファイルを使用（`.gitignore` に追加）
- [ ] 環境変数は `flutter_dotenv` などで管理

**絶対にコミットしてはいけないファイル**:
```
# .gitignore に追加
*.keystore
key.properties
.env
google-services.json  # 場合による
GoogleService-Info.plist  # 場合による
```

### テスト

- [ ] 最低限のウィジェットテストを書く
- [ ] リリース前に必ず実機テスト（iOS・Android両方）
- [ ] メモリリーク・パフォーマンス確認

---

## ストア公開準備

### 共通準備（iOS・Android両方）

#### 1. スクリーンショット

**撮影タイミング**: 開発完了後、UI確定後

**必要なサイズ**:
- **iOS iPhone**: 6.7" (1290 x 2796px) または 6.5" (1242 x 2688px)
- **iOS iPad** (対応する場合): 13" (2064 x 2752px)
- **Android**:
  - Phone: 1080 x 1920px 以上
  - Tablet (対応する場合): 1920 x 1080px 以上

**枚数**: 最低3枚、推奨5枚

**Tips**:
- [ ] 1枚目が最も重要（ユーザーが最初に見る）
- [ ] 各スクリーンショットにキャッチコピーを追加
- [ ] 実際の画面を使う（モックアップNG）
- [ ] 明るく、見やすく、テキストは大きく

**スクリーンショット作成のコツ**:
1. エミュレータ/シミュレータで起動
2. 主要画面を表示
3. スクリーンショット撮影
4. Canva/Figmaで装飾（任意）
   - デバイスフレームを追加
   - キャッチコピーを追加
   - 背景をグラデーションに

**リサイズスクリプト**:
```bash
# macOS の sips コマンドを使用
sips -z 2796 1290 input.png --out output.png
```

#### 2. アプリアイコン

**サイズ**: 1024x1024px (iOS・Android共通)

**注意点**:
- [ ] 背景透過NG（塗りつぶす）
- [ ] 角丸は自動で付く（四角いまま作る）
- [ ] シンプルで認識しやすいデザイン
- [ ] 小さくても見える

**作成ツール**:
- Canva（無料）
- Figma（無料）
- Adobe Illustrator
- App Icon Generator（自動生成）

#### 3. 説明文

**構成**:
1. **短い説明**（30文字程度）
   - アプリの本質を一言で
   - 例: 「赤ちゃんの成長の瞬間を記録」

2. **プロモーション文**（170文字程度）
   - 最初の1-2文で魅力を伝える
   - 箇条書きNG、読みやすく

3. **詳細説明**（4000文字程度）
   - **「こんな方におすすめ」** セクション
   - **「主な機能」** セクション（箇条書き）
   - **「アプリの特徴」** セクション
   - 無料版・有料版の違い（課金ある場合）
   - シンプルで読みやすく

**Tips**:
- [ ] ユーザーのペインポイント（困りごと）から書く
- [ ] 機能ではなく、ベネフィット（利益）を伝える
- [ ] 専門用語は避ける
- [ ] 読みやすい改行・見出しを使う

#### 4. キーワード（検索最適化）

**iOS**: 100文字、カンマ区切り
**Android**: 自由記述（説明文に自然に含める）

**選び方**:
- [ ] アプリの**カテゴリ**を表すワード（例: 育児、日記、記録）
- [ ] **ターゲットユーザー**を表すワード（例: 赤ちゃん、新生児、ママ）
- [ ] **用途・シーン**を表すワード（例: 成長記録、マイルストーン、アルバム）
- [ ] **競合アプリ名は避ける**
- [ ] スペースは入れない（カンマで区切る）

例:
```
育児,赤ちゃん,成長記録,マイルストーン,初めて,子育て,日記,アルバム,写真,メモ,タイムライン,共有,家族,子供,乳児,新生児,発達,記録
```

#### 5. カテゴリ

**1つのメインカテゴリ + 1つのサブカテゴリ**

よく使うカテゴリ:
- ライフスタイル
- ヘルスケア/フィットネス
- 教育
- エンターテインメント
- 仕事効率化
- ユーティリティ

**選び方**:
- [ ] ユーザーが検索しそうなカテゴリを選ぶ
- [ ] 競合が少ないカテゴリも検討
- [ ] 一度決めたら変更は慎重に（ランキングがリセットされる）

#### 6. 年齢制限

**レーティング質問に正直に答える**

よくある設定:
- **4+**: 特に問題のないアプリ
- **9+**: 軽度の暴力表現など
- **12+**: 性的表現、暴力表現など
- **17+**: 成人向けコンテンツ

**注意**:
- [ ] 広告を表示する場合、広告の内容も考慮
- [ ] ユーザー生成コンテンツがある場合は高めに設定

---

## iOS固有の注意点

### App Store Connect 準備

#### アカウント・契約

- [ ] Apple Developer Program 登録済み
- [ ] 契約・税金・口座情報を設定（課金アプリの場合）

#### App情報の事前準備

以下を**コード・ドキュメントに記録しておく**:

```markdown
## iOS App Store 情報

- **アプリ名**: Your App Name
- **サブタイトル**: Your app subtitle（30文字以内）
- **Bundle ID**: works.yourcompany.appname
- **SKU**: appname（任意の一意な識別子）
- **プライマリ言語**: 日本語
- **カテゴリ**: ライフスタイル, ヘルスケア/フィットネス（例）
- **年齢制限**: 4+
- **プライバシーポリシーURL**: https://...
- **サポートURL**: https://...
- **マーケティングURL**: https://...（任意）
- **著作権**: © 2026 Your Company Name
```

### ビルド・アーカイブ前のチェック

- [ ] **Bundle ID** が本番用になっているか
- [ ] **バージョン番号**と**ビルド番号**が正しいか
- [ ] **署名設定**（Signing & Capabilities）が正しいか
- [ ] **Deployment Target**（最小iOSバージョン）が適切か
- [ ] **デバイス対応**（iPhone / iPad）が意図通りか
- [ ] **本番用広告ID**に差し替えたか（AdMob使用時）
- [ ] **本番用APIキー**に差し替えたか

### アーカイブ作成

```bash
cd ios
open Runner.xcworkspace  # .xcodeproj ではなく .xcworkspace を開く
```

1. **Product > Clean Build Folder** (⇧⌘K)
2. スキームで **Any iOS Device (arm64)** を選択
3. **Product > Archive**
4. ビルド完了を待つ（数分）
5. **Organizer** が開く

### アップロード前の確認

- [ ] **暗号化使用に関する申告**
  - HTTPS通信のみ: 「上記のアルゴリズムのどれでもない」を選択
  - 独自暗号化なし: 同上

### App Store Connect での設定チェックリスト

#### 一般 > アプリ情報

- [ ] 名前
- [ ] サブタイトル
- [ ] カテゴリ
- [ ] 年齢制限

#### App Store > 価格および配信可能状況

- [ ] 価格: 無料 or 有料
- [ ] 配信地域: すべて or 日本のみ

#### App Store > アプリのプライバシー

- [ ] プライバシーポリシーURL
- [ ] データ収集の詳細を**正確に**申告:
  - **写真/動画**: アプリの機能で使用（Pro版のバックアップなど）
  - **デバイスID**: 広告配信で使用（AdMob）
  - **購入履歴**: アプリ内課金の管理

**重要**: 虚偽の申告は審査却下の原因

#### バージョン情報

- [ ] スクリーンショット（iPhone・iPadそれぞれ）
- [ ] プロモーション用テキスト（任意）
- [ ] 説明
- [ ] キーワード
- [ ] サポートURL
- [ ] マーケティングURL（任意）
- [ ] ビルドを選択
- [ ] 著作権

#### App Reviewに関する情報

- [ ] サインイン情報（アカウント不要な場合はチェックを外す）
- [ ] 連絡先情報（名前、電話、メール）
- [ ] 注意事項（任意、審査員へのメモ）

#### App Store/バージョンのリリース

- [ ] 「このバージョンを手動でリリース」（推奨）
- [ ] または「このバージョンを審査後に自動的にリリース」

### よくあるリジェクト理由と対策

#### 1. Guideline 2.1 - Performance - App Completeness

**原因**: アプリがクラッシュする、機能が動作しない

**対策**:
- [ ] 実機で徹底的にテスト
- [ ] 全機能を審査員がテストできる状態にする
- [ ] エラーハンドリングを適切に実装

#### 2. Guideline 4.3 - Design - Spam

**原因**: 似たようなアプリを大量に出している

**対策**:
- [ ] 各アプリに独自性を持たせる
- [ ] テンプレートアプリは避ける

#### 3. Guideline 5.1.1 - Legal - Privacy - Data Collection and Storage

**原因**: プライバシーポリシーが不十分、データ収集の申告が不正確

**対策**:
- [ ] プライバシーポリシーを詳細に記載
- [ ] データ収集を正確に申告
- [ ] 第三者サービス（Firebase、AdMobなど）も明記

#### 4. Guideline 2.3 - Performance - Accurate Metadata

**原因**: 説明文とアプリの機能が一致しない、スクリーンショットが誤解を招く

**対策**:
- [ ] 実際の機能のみを説明
- [ ] スクリーンショットは実際の画面を使用
- [ ] 過度な演出は避ける

---

## Android固有の注意点

### Google Play Console 準備

#### アカウント

- [ ] Google Play Console アカウント登録（$25、一度のみ）
- [ ] 本人確認完了

#### アプリの作成

**最初にやること**:

1. **アプリを作成**
   - アプリ名
   - デフォルト言語
   - アプリ or ゲーム
   - 無料 or 有料

2. **Application ID を正しく設定**
   - `build.gradle.kts` の `applicationId` と一致させる

### APK/AAB ビルド前のチェック

- [ ] **Application ID** が本番用になっているか
- [ ] **バージョン番号**と**ビルド番号**が正しいか
- [ ] **署名設定**（Release署名）が正しいか
- [ ] **minSdk** / **targetSdk** が適切か
- [ ] **本番用広告ID**に差し替えたか
- [ ] **本番用APIキー**に差し替えたか
- [ ] **難読化**（ProGuard/R8）が有効か

### AAB ビルド（推奨）

```bash
cd android
./gradlew clean
./gradlew bundleRelease
```

成果物: `android/app/build/outputs/bundle/release/app-release.aab`

**AAB vs APK**:
- **AAB（推奨）**: Google Playが端末ごとに最適化したAPKを生成
- **APK**: 全端末用の汎用ファイル、サイズが大きい

### Google Play Console での設定チェックリスト

#### アプリのコンテンツ

**必須項目**:

- [ ] **アプリのアクセス権**
  - すべての機能にアクセス可能 or テストアカウントが必要

- [ ] **広告**
  - 広告が含まれていますか？ Yes/No

- [ ] **コンテンツのレーティング**
  - 質問票に回答（5-10分）
  - 正直に答える

- [ ] **ターゲット層とコンテンツ**
  - 13歳未満も対象にしていますか？
  - 興味/関心に基づく広告を表示しますか？

- [ ] **プライバシーポリシー**
  - URL入力（HTTPS必須）

- [ ] **アプリカテゴリ**
  - アプリ or ゲーム
  - カテゴリ選択

- [ ] **ストアの設定**
  - メールアドレス、外部マーケティング（任意）

- [ ] **データセーフティ**
  - 収集するデータを申告
  - **最も重要** - 正確に記入

#### メインのストア掲載情報

- [ ] **アプリ名**（30文字以内）
- [ ] **簡単な説明**（80文字以内）
- [ ] **詳細な説明**（4000文字以内）
- [ ] **アプリアイコン**（512x512px）
- [ ] **機能グラフィック**（1024x500px）
- [ ] **スクリーンショット**（最低2枚、推奨8枚）
  - Phone: 最低2枚
  - Tablet（対応する場合）: 最低2枚

#### リリースの作成

1. **テストトラック**（内部テスト or クローズドテスト）でまず公開
2. 問題なければ**本番トラック**に昇格

**リリース作成時**:
- [ ] リリース名（例: v1.0.0）
- [ ] リリースノート（各言語）
- [ ] AABファイルをアップロード

### よくあるリジェクト理由と対策

#### 1. ポリシー違反 - プライバシーポリシー

**原因**: プライバシーポリシーがない、不十分

**対策**:
- [ ] HTTPS URLで公開
- [ ] データ収集・利用目的を明記
- [ ] 第三者サービスを明記

#### 2. データセーフティの不一致

**原因**: 実際のデータ収集と申告が異なる

**対策**:
- [ ] AdMob使用時は「広告用識別子」を申告
- [ ] Firebase使用時は収集データを確認
- [ ] 権限（カメラ、位置情報など）と対応するデータタイプを申告

#### 3. ターゲット API レベル

**原因**: 古いAPI levelをターゲットにしている

**対策**:
- [ ] `targetSdk` を最新 or 最新-1 に設定
- [ ] Google Play の要件を確認（毎年更新される）

#### 4. アプリアイコンの問題

**原因**: 透過背景、低解像度、著作権違反

**対策**:
- [ ] 512x512px、32bit PNG
- [ ] 透過NG（塗りつぶす）
- [ ] オリジナルデザインを使用

---

## 今回遭遇した問題と解決策

### 問題1: Bundle ID / Application ID の変更が必要だった

**状況**:
- 開発時は `com.example.appname` を使用（Flutterのデフォルト）
- 公開時に本番用のBundle ID（例: `works.yourcompany.appname`）に変更が必要

**教訓**:
- ✅ **最初から本番用のBundle ID/Application IDを設定する**
- ✅ `flutter create --org works.yourcompany` を使う
- ✅ Firebase設定も最初から本番IDで作成

**解決策**:
- iOS: `project.pbxproj` を全置換
- Android: `build.gradle.kts` と MainActivity のパッケージを変更
- Firebase: 新しいアプリを追加して `google-services.json` / `GoogleService-Info.plist` を置き換え

### 問題2: CocoaPods の依存関係エラー

**状況**:
- Archive時に「sandbox is not in sync with the Podfile.lock」エラー

**解決策**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

- ✅ **定期的に `pod install` を実行**
- ✅ ビルドエラー時は `Clean Build Folder` → `pod install` → 再ビルド

### 問題3: App Store Connect で「App Name already used」エラー

**状況**:
- Xcodeから自動でアプリを作成しようとしたが、名前が既に使われている

**解決策**:
- 先に**App Store Connectで手動でアプリを作成**してから、Xcodeでアップロード
- ✅ **アプリ名が一般的な場合は、事前に手動作成**

### 問題4: iPad用スクリーンショットが必要だった

**状況**:
- iPhone専用のつもりだったが、Flutterのデフォルト設定でiPad対応になっていた

**解決策**:
- iPad用スクリーンショットを追加（iPhone用をリサイズ）
- または、Xcodeで iPad を Supported Destinations から外す

**教訓**:
- ✅ **iPad対応の有無を最初に決定**
- ✅ 対応しない場合は Xcode設定で明示的に外す

### 問題5: プライバシーポリシーの申告が複雑

**状況**:
- 「データ収集しない」を選んだが、実際はAdMob・Firebaseでデータ収集している

**解決策**:
- 正確に申告:
  - AdMob: デバイスID、トラッキングあり
  - Firebase（Pro版）: ユーザーコンテンツ、購入履歴
  - すべて「アプリの機能」目的で使用

**教訓**:
- ✅ **使っている第三者サービスのデータ収集を事前調査**
- ✅ Firebase、AdMob、RevenueCat などの公式ドキュメントを確認

### 問題6: 「サインインが必要」のチェックでエラー

**状況**:
- App Reviewで「サインインが必要」にチェックが入っていたため、ユーザー名・パスワードが必須になった

**解決策**:
- アカウント不要なアプリは**チェックを外す**

**教訓**:
- ✅ **デフォルトのチェックボックスを確認**
- ✅ 不要な項目はオフにする

---

## 便利なスクリプト・ツール

### スクリーンショットリサイズスクリプト

#### iOS用（macOS）

```bash
#!/bin/bash
# resize_ios_screenshots.sh

INPUT_DIR="./screenshots"
OUTPUT_DIR="./screenshots_ios"
mkdir -p "$OUTPUT_DIR"

# iPhone 6.7" (1290 x 2796)
for file in "$INPUT_DIR"/*.png; do
    filename=$(basename "$file")
    sips -z 2796 1290 "$file" --out "$OUTPUT_DIR/iphone_$filename"
done

# iPad 13" (2064 x 2752)
for file in "$INPUT_DIR"/*.png; do
    filename=$(basename "$file")
    sips -z 2752 2064 "$file" --out "$OUTPUT_DIR/ipad_$filename"
done

echo "完了"
```

#### Android用（macOS）

```bash
#!/bin/bash
# resize_android_screenshots.sh

INPUT_DIR="./screenshots"
OUTPUT_DIR="./screenshots_android"
mkdir -p "$OUTPUT_DIR"

# Phone (1080 x 1920)
for file in "$INPUT_DIR"/*.png; do
    filename=$(basename "$file")
    sips -z 1920 1080 "$file" --out "$OUTPUT_DIR/phone_$filename"
done

echo "完了"
```

### バージョン番号自動インクリメント

`pubspec.yaml` のバージョン番号を自動で上げるスクリプト:

```bash
#!/bin/bash
# bump_version.sh

PUBSPEC="pubspec.yaml"

# 現在のバージョンを取得
current=$(grep "^version:" "$PUBSPEC" | sed 's/version: //')
version=$(echo "$current" | cut -d'+' -f1)
build=$(echo "$current" | cut -d'+' -f2)

# ビルド番号をインクリメント
new_build=$((build + 1))
new_version="${version}+${new_build}"

# 更新
sed -i '' "s/^version: .*/version: $new_version/" "$PUBSPEC"

echo "バージョン更新: $current → $new_version"
```

使い方:
```bash
chmod +x bump_version.sh
./bump_version.sh
```

### Git タグ自動作成

```bash
#!/bin/bash
# tag_release.sh

VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d'+' -f1)

git tag -a "v$VERSION" -m "Release version $VERSION"
git push origin "v$VERSION"

echo "タグ作成完了: v$VERSION"
```

### Flutter ビルドコマンド集

```bash
# iOS
flutter build ios --release
flutter build ipa --release

# Android
flutter build apk --release
flutter build appbundle --release

# すべてのプラットフォーム
flutter build apk --release && flutter build appbundle --release

# デバッグビルド（動作確認）
flutter build ios --debug
flutter build apk --debug
```

---

## チェックリスト: リリース前の最終確認

### コード

- [ ] デバッグ用 `print()` を削除
- [ ] TODO コメントを確認・対応
- [ ] 不要なコメントアウトコードを削除
- [ ] リリースビルドでエラー・警告がないか確認
- [ ] `flutter analyze` でエラーがないか
- [ ] バージョン番号が正しいか（`pubspec.yaml`）

### 設定ファイル

- [ ] Bundle ID / Application ID が本番用
- [ ] 広告IDが本番用（テスト用IDを削除）
- [ ] APIキーが本番用
- [ ] Firebase設定ファイルが本番用
- [ ] 署名設定が正しい（iOS: Provisioning Profile、Android: keystore）

### テスト

- [ ] 実機で全機能をテスト（iOS・Android）
- [ ] 課金機能のテスト（Sandbox環境）
- [ ] 広告表示のテスト
- [ ] ネットワークエラー時の挙動確認
- [ ] 初回起動時の挙動確認
- [ ] パーミッション要求の確認

### ストア準備

- [ ] スクリーンショット準備完了
- [ ] アプリアイコン準備完了
- [ ] 説明文・キーワード準備完了
- [ ] プライバシーポリシーURL準備完了
- [ ] サポートURL準備完了

### Git

- [ ] すべての変更をコミット
- [ ] リモートにプッシュ
- [ ] リリースタグを作成

---

## 参考リンク

### Apple

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Connect ヘルプ](https://help.apple.com/app-store-connect/)

### Google

- [Google Play Console ヘルプ](https://support.google.com/googleplay/android-developer/)
- [デベロッパー ポリシー センター](https://play.google.com/about/developer-content-policy/)
- [アプリの品質に関するガイドライン](https://developer.android.com/quality)

### Flutter

- [Flutter Deployment](https://docs.flutter.dev/deployment)
- [Build and release an iOS app](https://docs.flutter.dev/deployment/ios)
- [Build and release an Android app](https://docs.flutter.dev/deployment/android)

---

## まとめ: 次回スムーズに進めるための3つのポイント

### 1. 最初から本番設定で開始

- ❌ 開発用Bundle ID → 後で変更
- ✅ 最初から本番Bundle ID

- ❌ テスト用広告ID → 後で変更
- ✅ 最初から切り替え可能な設計（環境変数）

### 2. ドキュメント・チェックリストを作る

- このチェックリストを**プロジェクトごとにコピー**
- 進捗に合わせて☑チェック
- 問題が起きたら**教訓を追記**

### 3. 早めにストア準備を始める

- スクリーンショット: UI確定後すぐ
- 説明文: 開発中に下書き
- プライバシーポリシー: プロジェクト初期にREADMEに追加

---

次のアプリ開発、頑張ってください！🚀
