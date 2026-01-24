# 開発TIPS（ナレッジ蓄積用）

このファイルは「次回以降の開発で詰まらないための知見」を追記していく場所です。  
事実ベースで簡潔に書き、**再現条件・原因・対策**の3点セットで残します。

---

## ストア申請・配信

### Bundle ID / Application ID は最初に決める
- **再現条件:** 公開前にIDを変更したくなる  
- **原因:** Flutter初期値 `com.example...` を使ったまま進めた  
- **対策:** `flutter create --org <org>` で最初から本番ID

### iPad対応は明示的に決める
- **再現条件:** iPhone専用のつもりがiPadスクショが必要になる  
- **原因:** デフォルトでiPad対応がON  
- **対策:** Phase 1でiPad対応有無を明記し、Xcodeで制御

---

## 課金・広告

### RevenueCatはアプリID未取得だと詰まる
- **再現条件:** ストア登録前に課金実装を進める  
- **原因:** App Store / Play のアプリIDがない  
- **対策:** **Phase 2に回す** / App登録後に着手

### 広告はPhase 1では最小にする
- **再現条件:** UXを崩す / 実装が肥大化  
- **原因:** バナーやリワードまで最初から入れる  
- **対策:** **Phase 1はインタースティシャルのみ**

---

## AI API / コスト

### 無料ユーザーの回数制限はサーバー側必須
- **再現条件:** クライアントのみ制限で抜け道がある  
- **原因:** ローカル判定のみ  
- **対策:** **サーバーで日次カウント + 429**

---

## Firebase / 実機テスト

### Firebase設定が未投入だと実機で警告だらけになる
- **再現条件:** `firebase_options.dart` がプレースホルダのまま  
- **原因:** `google-services.json` / `GoogleService-Info.plist` 未配置  
- **対策:** Firebase Console から取得して配置（Android: `app/android/app/`、iOS: `app/ios/Runner/`）

### Firebase未設定でも起動はできるがAnalytics等は無効
- **再現条件:** Firebase App ID未設定  
- **原因:** `YOUR_ANDROID_APP_ID` などのプレースホルダ  
- **対策:** 本番前に必ずFirebase設定を入れる（実機テスト時も推奨）

---

## Flutter / テスト

### FlutterテストはSDKキャッシュへのアクセスが必要
- **再現条件:** sandboxで `flutter test` が失敗  
- **原因:** Flutter SDKキャッシュに書き込み不可  
- **対策:** 権限を上げて実行する or ローカルで実行

### Themeの型エラーが出たらCardThemeDataを使う
- **再現条件:** `CardTheme` と `CardThemeData` の型不一致  
- **原因:** Flutterバージョン差分  
- **対策:** `ThemeData.cardTheme` は `CardThemeData` を使う

---

## Firebase設定

### Cloud Firestore APIは手動で有効化が必要
- **再現条件:** サーバーから初回アクセス時に「SERVICE_DISABLED」エラー
- **原因:** Firebase プロジェクト作成だけでは Firestore API が有効化されない
- **対策:** Firebase Console から「データベースを作成」を実行（テストモード、asia-northeast1推奨）

### Firebase設定は Firebase Console から行う
- **再現条件:** Google Cloud Console でAPIを有効化しようとすると権限エラー
- **原因:** プロジェクト権限の違い
- **対策:** **Firebase Console（console.firebase.google.com）から操作する**と権限エラーが出にくい

### google-services.json / GoogleService-Info.plist の配置場所
- **再現条件:** Firebase設定ファイルを配置したがビルドエラーまたは警告
- **原因:** 配置場所が間違っている
- **対策:**
  - Android: `android/app/google-services.json`
  - iOS: `ios/Runner/GoogleService-Info.plist`
  - さらに `settings.gradle.kts` と `app/build.gradle.kts` に Google Services プラグイン追加が必要

### Google Services プラグインの追加を忘れずに
- **再現条件:** google-services.json を配置してもFirebaseが動作しない
- **原因:** Gradleプラグインが未追加
- **対策:**
  - `android/settings.gradle.kts` に `id("com.google.gms.google-services") version "4.4.2" apply false`
  - `android/app/build.gradle.kts` の plugins に `id("com.google.gms.google-services")`

---

## サーバー開発

### .env ファイルは必ず .gitignore に追加
- **再現条件:** APIキーや秘密鍵がGitにコミットされる
- **原因:** .env ファイルが追跡されている
- **対策:** `.gitignore` に `.env` を追加、`.env.example` をテンプレートとして残す

### Firebase Admin SDK の秘密鍵は改行を含む
- **再現条件:** 秘密鍵の設定が失敗する
- **原因:** 改行文字 `\n` を正しく扱っていない
- **対策:** .env ファイルでは `"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"` のようにダブルクォートで囲む

### ローカル開発時はMacのIPアドレスを使う
- **再現条件:** 実機からlocalhost:3000に接続できない
- **原因:** localhost は実機からはアクセスできない
- **対策:**
  - `ifconfig` でMacのローカルIPを確認（例: 192.168.68.115）
  - Flutter実行時に `--dart-define=API_BASE_URL=http://192.168.68.115:3000` を指定

### 開発時は認証を緩和すると便利
- **再現条件:** Firebase認証トークンの検証でエラーが多発
- **原因:** 開発中はトークン未設定や期限切れが頻発
- **対策:** 開発環境では認証エラー時にデフォルトユーザーIDを返す（**本番では必ず元に戻す**）
