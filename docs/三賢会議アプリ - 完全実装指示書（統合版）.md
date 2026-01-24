# 三賢会議アプリ - 完全実装指示書（統合版）

**作成日:** 2026年1月24日  
**バージョン:** 2.1  
**対象:** iOS / Android（Flutter）  
**目的:** Codex / Claude Code に渡しても追加質問が出ないレベルの実装指示

---

## 0. 実装時の基本ルール（質問抑止ポリシー）

- 本書に明記されていない軽微な判断は**質問せずに実装で決める**  
  - 例: 余白、アニメーションの速度、エラーメッセージの文言など
- 仕様に矛盾がある場合は**本書の内容を優先**する  
- MVPでは**「実装コストが低い方」**を選ぶ（複雑な選択肢は後回し）  
- 外部IDや鍵が必要な箇所は**環境変数・設定ファイルで差し替え可能**にし、  
  未提供の値は**プレースホルダ**で進行してよい  
- ストア申請や法務文言などは**実装と分離**して進行可能とする  

---

## 0.5 フェーズ方針（詰まり防止）

- **Phase 1:** 無料版のみ（課金/RevenueCatは実装しない）  
- **Phase 2:** 課金（RevenueCat）、有料機能、バナー広告の検討  
- フェーズを跨ぐ機能は、**Phase 1でダミーUIのみ**にする  

---

## 0.6 フェーズ別実装範囲（必ず守る）

### Phase 1（公開対象 / 無料版のみ）
- 画面: Home / Deliberation / Resolution / History / Settings（アカウント・プライバシーのみ）  
- 認証: Anonymous必須。Apple/Googleは設定が揃えば実装、未準備ならUI非表示でスキップ  
- API: `/v1/deliberate`, `/v1/history`, `/v1/consultations/{id}/save`, `/v1/consultations/{id}`  
- 1日10回制限を**サーバー側で必ず適用（JST日付境界）**  
- 広告: インタースティシャルのみ  
- 分析: `app_open`, `consultation_start`, `consultation_complete`, `ad_impression`  
- 課金UI/RevenueCatは一切入れない  

### Phase 2（後続実装）
- RevenueCat導入・購読UI  
- 無制限相談 / 広告非表示 / プレミアム機能の解放  
- バナー/リワード広告の検討  
- iPadマルチカラムレイアウト  
- 英語対応・海外配信  
- 分析: `upgrade_clicked`, `upgrade_success`  

---

## 1. プロダクト概要

### 1.1 コンセプト
**三賢会議**は、3つの人格AI（ロジック・ハート・フラッシュ）が合議して意思決定を支援するアプリ。

### 1.2 コア体験（MVP）
1. 質問入力  
2. 3ラウンドの審議  
3. 決議書カード表示  
4. 履歴閲覧

### 1.3 主要ペルソナ
- 20〜40代の意思決定に迷いやすい層  
- 日常（恋愛/転職/生活）と仕事（判断/優先順位）に使うライトユーザー  

---

## 2. 決定済みプロダクト/ストア要件

### 2.1 アプリ名/字幕
- **日本語名:** 三賢会議（さんけんかいぎ）  
- **英語名:** Triad Council  
- **サブタイトル（JP）:** 3つの視点で、迷いを終わらせる  
- **サブタイトル（EN）:** Three perspectives. One decision.

### 2.2 Bundle ID / Application ID / SKU
- **Bundle ID / Application ID:** `com.sankenkaigi.app`  
- **SKU:** `SANKEN-KAIGI-001`

### 2.3 カテゴリ / 年齢制限
- **App Store:** ライフスタイル（Primary） / 仕事効率化（Secondary）  
- **Google Play:** ライフスタイル  
- **年齢制限:** 4+（全年齢）

### 2.4 配信地域 / 価格
- **ローンチ時:** 日本のみ  
- **価格:** 基本無料（フリーミアム）

### 2.5 対応OS / 端末 / 言語
- **iOS:** 13.0+（iPhone + iPad 対応）  
- **Android:** 7.0+（API 24）  
- **言語:** 日本語のみ（後で英語対応）  

### 2.6 ストア掲載名義
- **開発者名/著作権表記:** marumi.works  

---

## 3. 技術スタック（確定）

### 3.1 フロントエンド
- Flutter 3.16+  
- Riverpod 2.4+  
- Dio 5.4+  
- Hive 2.2+（ゲスト履歴）  
- Firebase Auth（認証）  
- Firebase Analytics / Crashlytics  

### 3.2 バックエンド
- Node.js 20 LTS  
- Express 4.18+  
- TypeScript 5.3+  
- Zod（バリデーション）  
- Winston（ログ）  

### 3.3 AI
- OpenAI API（サーバー経由）  
- **モデル:** `gpt-4o-mini`（コスト優先。変更は環境変数で可）

### 3.4 DB / インフラ
- Firestore  
- Firebase Storage（将来の画像保存用）  
- Vercel（バックエンドAPI）

---

## 4. アーキテクチャ

```
Flutter App
  └─ API (HTTPS)
        └─ Node.js/Express
             ├─ OpenAI API
             └─ Firestore
```

### データフロー
1. ユーザー入力 → アプリ  
2. `/v1/deliberate` へ送信  
3. サーバーで3人格を生成  
4. 決議書生成  
5. 返却してUIで段階表示  

---

## 5. UI/UX仕様

### 5.1 デザインシステム
- **フォント:** Noto Sans JP  
- **カラー:**  
  - Primary: `#8B7FFF`  
  - Secondary: `#5B9FFF`  
  - Logic: `#4A5FD9`  
  - Heart: `#FF6B9D`  
  - Flash: `#FFB800`  

### 5.2 画面一覧（MVP）
- Home  
- Deliberation  
- Resolution  
- History  
- Settings（最低限: アカウント/プライバシー）  

### 5.3 画面要件（抜粋）
**iPad対応（MVP）**  
- iPhoneレイアウトを流用し、横幅は最大幅制限で中央寄せ  
- iPad専用のマルチカラムはフェーズ2で対応  

**Home**  
- AI人格カード3枚  
- 相談入力（1〜2文推奨）  
- 「会議を始める」ボタン  

**Deliberation**  
- 3人格の発言を順番に表示  
- ラウンド進行表示（1/3,2/3,3/3）  
- スクロールは最新追従  

**Resolution**  
- 決議 / 投票 / 理由 / 次の一手 / 再審期限  
- 保存・シェアボタン  

**History**  
- 過去相談の一覧  
- タップで詳細（決議書表示）  

---

## 6. API設計（確定版）

### ベースURL
```
https://api.sankenkaigi.com
```

### 認証
- Firebase ID Token を `Authorization: Bearer <token>` で送信  
- ゲストは匿名認証トークン

### 6.1 POST /v1/deliberate
相談→審議→決議まで一括生成（ストリーミング無し）

**Request**
```json
{
  "consultation": "転職するか迷っています",
  "userId": "user_12345",
  "plan": "free"
}
```

**Response**
```json
{
  "consultationId": "consult_abc123",
  "rounds": [
    {
      "roundNumber": 1,
      "messages": [
        { "ai": "logic", "message": "…", "timestamp": "2026-01-20T10:30:00Z" },
        { "ai": "heart", "message": "…", "timestamp": "2026-01-20T10:30:02Z" },
        { "ai": "flash", "message": "…", "timestamp": "2026-01-20T10:30:04Z" }
      ]
    }
  ],
  "resolution": {
    "decision": "推奨",
    "votes": { "logic": "approve", "heart": "approve", "flash": "pending" },
    "reasoning": ["…"],
    "nextSteps": ["…"],
    "reviewDate": "2026-01-27",
    "risks": ["…"]
  }
}
```

**Rate Limit Error（無料ユーザー上限超過時）**
```
HTTP 429 Too Many Requests
```
```json
{
  "error": {
    "code": "DAILY_LIMIT_EXCEEDED",
    "message": "本日の無料相談回数（10回）を超えました。",
    "resetAt": "2026-01-24T24:00:00+09:00"
  }
}
```

### 6.2 GET /v1/history
```http
GET /v1/history?userId=user_12345&limit=10&offset=0
```

### 6.3 POST /v1/consultations/{id}/save
保存（ゲスト→ログイン時の移行にも使用）

### 6.4 DELETE /v1/consultations/{id}
履歴削除（ユーザー削除時にまとめて実行）

---

## 7. AIロジック

### 7.1 人格プロンプト
**Logic**
```
あなたは「ロジック」という論理的なAIです。
- 事実とデータを客観的に分析
- メリット/デメリットを整理
- 長期的な結果を考慮
日本語で2〜3文に要約。
```

**Heart**
```
あなたは「ハート」という共感的なAIです。
- 感情や人間関係を重視
- 精神的健康を優先
日本語で2〜3文に要約。
```

**Flash**
```
あなたは「フラッシュ」という直感的なAIです。
- 即断即決、行動志向
- 大胆な提案も可
日本語で2〜3文に要約。
```

### 7.2 議論ルール
- 3ラウンド方式  
- Round1: 初期意見  
- Round2: 反論/同意  
- Round3: 最終意見 & 投票  

### 7.3 決議ロジック
- 全員賛成 → **強く推奨**  
- 2/3賛成 → **推奨**  
- 1/3賛成 → **条件付き推奨**  
- 0/3賛成 → **推奨しない**  

---

## 8. Firestore設計

### collections
```
users/{userId}
  - profile
  - subscription
  - createdAt

users/{userId}/consultations/{consultationId}
  - question
  - rounds[]
  - resolution
  - createdAt
```

---

## 9. 認証フロー

- 初回起動 → Anonymous Auth  
- 3回目相談後に登録促し  
- Apple Sign-In / Google Sign-In 実装（LINEは後回し）

---

## 10. 課金仕様（Phase 2）

### サブスク価格
- 月額: ¥480  
- 年額: ¥4,800  

### RevenueCat（Phase 2で実装）
**Entitlement:** `premium`  
**Products:**  
- `tc_premium_monthly`  
- `tc_premium_yearly`

### フリーミアム制限（Phase 1で有効化）
- 無料は1日10回  
- 履歴10件  
- 広告あり  
- **制限判定はサーバー側で必須**（Firestoreで日次カウント）  
- 日付境界は **JST（日本時間）** で切り替える  

---

## 11. 広告仕様（Phase 1）

- AdMob  
- 1相談につき1回インタースティシャル（MVPはこれのみ）  
- リワード広告・バナー広告はPhase 2以降に検討  
- 本番/テストIDを環境で切替

---

## 12. 分析イベント（最低限）

**Phase 1**  
- app_open  
- consultation_start  
- consultation_complete  
- ad_impression  

**Phase 2**  
- upgrade_clicked  
- upgrade_success  

---

## 13. セキュリティ / プライバシー

- APIキーはサーバー側のみ  
- 相談内容はFirestore保存  
- 設定画面から**アカウント削除**可能  
- プライバシーポリシーにOpenAI送信を明記  
- 自動削除は行わない（ユーザー削除まで保持）

---

## 14. 環境変数

**Backend**
```
OPENAI_API_KEY=...
FIREBASE_PROJECT_ID=...
FIREBASE_PRIVATE_KEY=...
FIREBASE_CLIENT_EMAIL=...
```

**App**
```
API_BASE_URL=https://api.sankenkaigi.com
ADMOB_APP_ID=...
```

---

## 15. ビルド・リリース（要約）

- `flutter build ios --release`  
- `flutter build appbundle --release`  
- 署名/ビルド番号更新  
- ストア素材（アイコン、スクショ、説明文）  

詳細は `docs/APP_DEVELOPMENT_CHECKLIST.md` を参照。

---

## 16. 受け入れ基準（MVP）

- 相談を入力 → 3ラウンド表示 → 決議書が生成される  
- 履歴が保存・閲覧できる  
- 無料ユーザーが1日10回を超えると429が返る  
- 広告が審議フローを阻害しない  
- クラッシュなし（iOS/Android 実機テスト）

---

**このドキュメントの内容が最優先です。**
