# 三賢会議アプリ - MVP開発タスク一覧（Phase1準拠）

**作成日:** 2026年1月24日  
**対象:** Phase 1（無料版のみ）  
**技術スタック:** Flutter + Node.js + Firebase + Vercel  
**目的:** 実装タスクの抜け漏れ防止（統合版指示書に準拠）

---

## 🎯 Phase 1 スコープ（必須）

**MVP成功基準**
- 相談入力 → 3ラウンド審議 → 決議書表示が完了する  
- 履歴が保存・閲覧できる（Firestore + ローカル）  
- 無料ユーザーは**1日10回**でサーバー側制限（JST日付境界）  
- 上限超過時に **HTTP 429 / DAILY_LIMIT_EXCEEDED** が返る  
- インタースティシャル広告が決議書後に1回表示される  
- iOS/Android実機でクラッシュなし  

**Phase 1に含めない**
- 課金（RevenueCat）、プレミアム機能  
- バナー広告 / リワード広告  
- AI人格カスタマイズ  
- PDF/画像エクスポート  
- SNSシェア  
- プッシュ通知  
- 英語対応 / 海外配信  
- iPadマルチカラムレイアウト  

---

## 🧩 機能一覧（Phase 1）

| ID | 機能 | 内容 | 優先度 |
|:---|:---|:---|:---|
| F-001 | ホーム画面 | 相談入力、AI人格表示、開始ボタン | 🔴 |
| F-002 | 審議画面 | 3ラウンド表示、進捗、アニメーション | 🔴 |
| F-003 | 決議書画面 | 決議/投票/理由/次の一手/再審期限 | 🔴 |
| F-004 | 履歴画面 | 一覧・詳細、削除 | 🔴 |
| F-005 | ローカル保存 | Hiveで履歴保持 | 🔴 |
| F-006 | エラーハンドリング | 429/通信/サーバーエラー表示 | 🔴 |
| F-007 | 広告 | インタースティシャル（決議書後） | 🔴 |
| F-008 | 認証 | Firebase Anonymous Auth | 🔴 |
| F-009 | 日次回数制限 | サーバー側で10回/日 | 🔴 |
| F-010 | 設定画面 | プライバシーポリシー/アカウント削除 | 🟡 |
| F-011 | ローディング | 審議中のローディング表示 | 🟡 |
| F-012 | 入力バリデーション | 空欄/文字数制限 | 🟡 |
| F-013 | Analytics | Firebase Analytics/Crashlytics | 🟡 |

---

## 🖥️ バックエンド開発タスク

### セットアップ
- [ ] Node.js + TypeScript + Express 初期化  
- [ ] OpenAI SDK 設定（gpt-4o-mini）  
- [ ] Firebase Admin SDK 設定  
- [ ] Firebase ID Token 検証ミドルウェア  
- [ ] ログ（Winston）  

### API実装（/v1）
- [ ] POST `/v1/deliberate`  
  - [ ] 3ラウンド審議ロジック  
  - [ ] 決議書生成  
  - [ ] Firestore保存  
  - [ ] 日次回数制限チェック（JST）  
  - [ ] 429エラー返却  
- [ ] GET `/v1/history`  
- [ ] POST `/v1/consultations/{id}/save`  
- [ ] DELETE `/v1/consultations/{id}`  

### エラーハンドリング
- [ ] OpenAI API 失敗時のエラー統一  
- [ ] タイムアウト・リトライ（必要最小限）  

---

## 📱 フロントエンド開発タスク

### セットアップ
- [ ] Flutterプロジェクト作成（Bundle ID: `com.sankenkaigi.app`）  
- [ ] パッケージ導入（Riverpod, Dio, Hive, Firebase, AdMob）  
- [ ] Firebase初期化 + Anonymous Auth  
- [ ] DioインターセプタでID Token付与  

### 画面実装
- [ ] Home  
- [ ] Deliberation  
- [ ] Resolution  
- [ ] History  
- [ ] Settings（プライバシーポリシー / アカウント削除）  

### 広告
- [ ] AdMobインタースティシャル表示（決議書後1回）  
- [ ] テストID/本番IDの切り替え  

### その他
- [ ] 429エラー時のUIメッセージ  
- [ ] iPadは最大幅制限で中央寄せ  
- [ ] ローディング/エラー/空状態  

---

## 🧪 統合・テスト

- [ ] 相談→審議→決議→履歴のE2E動作  
- [ ] 1日10回制限の動作確認  
- [ ] ネットワーク断時の表示  
- [ ] iOS/Android実機テスト  

---

## 🚀 デプロイ・リリース（Phase 1）

- [ ] Vercel環境変数設定  
- [ ] Firebaseプロジェクト作成  
- [ ] Firestoreルール設定  
- [ ] iOS/Androidリリースビルド確認  

---

## 📝 実装時の注意事項

- OpenAIモデルは **gpt-4o-mini** 固定（変更は環境変数）  
- 1日10回制限は**サーバー側で必須**  
- APIパスは `/v1` で統一  
- 課金/RevenueCatはPhase 2で実装  

