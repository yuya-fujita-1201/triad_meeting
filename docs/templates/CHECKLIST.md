# 開発チェックリスト（ナレッジ蓄積用）

このチェックリストは「毎回必ず確認すべき事項」を追加していく場所です。  
プロジェクトごとにコピーして使う運用を推奨します。

---

## プロジェクト開始前

- [ ] アプリ名 / 英語名 / サブタイトルを決定  
- [ ] Bundle ID / Application ID / SKU を決定  
- [ ] 配信地域 / 価格モデル / 年齢制限を決定  
- [ ] プライバシーポリシーURL / サポートURL を用意  
- [ ] Phase 1 / Phase 2 の境界を明記  

---

## 開発初期

- [ ] Flutter `--org` で本番IDを設定
- [ ] iPad対応方針を明記（ON/OFF）
- [ ] Firebaseプロジェクト作成（必要なら）
- [ ] **Firebase Console で Cloud Firestore を有効化**（データベース作成）
- [ ] **google-services.json を `android/app/` に配置**
- [ ] **GoogleService-Info.plist を `ios/Runner/` に配置**
- [ ] **Google Services プラグインを Gradle に追加**
- [ ] **Firebase App ID がプレースホルダでないことを確認**
- [ ] APIベースURLを固定
- [ ] 環境変数の一覧を明記
- [ ] **サーバーの .env ファイルを作成**（OpenAI API Key, Firebase Admin SDK）
- [ ] **server/.env を .gitignore に追加**

---

## 実装中

- [ ] APIキーをコードに直書きしていない
- [ ] **.env ファイルがGitに含まれていない**（.gitignore確認）
- [ ] 日次回数制限はサーバー側で実装
- [ ] 429（上限超過）時のUI文言を確認
- [ ] 主要フローにローディング/エラー表示がある
- [ ] **ローカル開発時は --dart-define で MacのIPアドレスを指定**
- [ ] iOS/Android実機で最低1回テスト

---

## 実機テスト前

- [ ] Firebase App ID が設定済み（`YOUR_ANDROID_APP_ID` 等が残っていない）
- [ ] AdMob（テストIDでも可）が設定済み

---

## リリース前

- [ ] ビルド番号/バージョン番号を更新
- [ ] **本番APIベースURLに切り替え**（--dart-defineを外す）
- [ ] 本番APIキーに切り替え
- [ ] **サーバー認証を有効化**（開発用の緩和設定を削除）
- [ ] 本番広告IDに切り替え（広告ありの場合）
- [ ] **Firestore セキュリティルールをテストモードから本番用に変更**
- [ ] スクリーンショット/アイコンが揃っている
- [ ] プライバシーポリシーが公開されている
