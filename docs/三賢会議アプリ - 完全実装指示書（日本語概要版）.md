# 三賢会議アプリ - 完全実装指示書（日本語概要版）

**バージョン:** 2.0  
**作成日:** 2026年1月20日  
**対象プラットフォーム:** iOS & Android（モバイルアプリ）  
**技術スタック:** Flutter + Node.js/Python バックエンド + OpenAI API  

---

## 目次

1. [プロジェクト概要](#1-プロジェクト概要)
2. [アーキテクチャ設計](#2-アーキテクチャ設計)
3. [技術スタック](#3-技術スタック)
4. [フロントエンド仕様（Flutter）](#4-フロントエンド仕様flutter)
5. [バックエンド仕様（API・AI処理）](#5-バックエンド仕様apiai処理)
6. [データベース設計](#6-データベース設計)
7. [AI処理ロジック](#7-ai処理ロジック)
8. [インフラ・デプロイ](#8-インフラデプロイ)
9. [開発ワークフロー](#9-開発ワークフロー)
10. [アプリストア申請](#10-アプリストア申請)

---

## 1. プロジェクト概要

### 1.1 アプリコンセプト

**三賢会議**は、3つのAIが合議によってユーザーの意思決定を支援するアプリです。各AIは異なる視点を持ちます：

- **ロジック**: 論理的・データ駆動型の分析
- **ハート**: 感情的・人間関係重視の視点
- **フラッシュ**: 直感的・行動志向のアプローチ

### 1.2 コア機能（MVP）

1. **ホーム画面**: 相談内容を入力、AI人格を選択
2. **審議画面**: AIの議論をリアルタイム表示（3ラウンド）
3. **決議書カード**: 最終決定、投票結果、理由、次のステップを表示
4. **履歴画面**: 過去の相談を保存・閲覧

### 1.3 ユーザーフロー

```
[ホーム画面]
    ↓ ユーザーが質問を入力
[審議画面]
    ↓ AIの議論（3ラウンド）
    ↓ - ラウンド1: 初期意見
    ↓ - ラウンド2: 反論・議論
    ↓ - ラウンド3: 最終合意
[決議書カード]
    ↓ 決定、投票、リスク、次のステップを表示
[履歴画面]
    ↓ 過去の決定を保存・閲覧
```

---

## 2. アーキテクチャ設計

### 2.1 システムアーキテクチャ

```
┌─────────────────────────────────────────────────────────┐
│                モバイルアプリ（Flutter）                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ ホーム   │  │ 審議     │  │ 決議書   │  │ 履歴    │ │
│  │ 画面     │  │ 画面     │  │ カード   │  │ 画面    │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                          │
                          │ HTTPS/REST API
                          ↓
┌─────────────────────────────────────────────────────────┐
│           バックエンドAPI（Node.js/Python）              │
│  ┌──────────────────────────────────────────────────┐   │
│  │  APIエンドポイント                                │   │
│  │  - POST /api/v1/deliberate                      │   │
│  │  - GET  /api/v1/history                         │   │
│  │  - POST /api/v1/save-decision                   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ↓               ↓               ↓
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  OpenAI API  │  │   Firebase   │  │  PostgreSQL  │
│   (GPT-4)    │  │     Auth     │  │  (オプション) │
└──────────────┘  └──────────────┘  └──────────────┘
```

### 2.2 データフロー

1. **ユーザー入力** → Flutterアプリ
2. **APIリクエスト** → バックエンドサーバー
3. **AI処理** → OpenAI API（3つの人格に並列リクエスト）
4. **議論ロジック** → バックエンドが複数ラウンドの議論を調整
5. **決議書生成** → バックエンドが最終決定カードをフォーマット
6. **レスポンス** → Flutterアプリが結果を表示
7. **保存** → データベースに相談履歴を保存

---

## 3. 技術スタック

### 3.1 フロントエンド

| コンポーネント | 技術 | 理由 |
|:---|:---|:---|
| **フレームワーク** | Flutter 3.16+ | クロスプラットフォーム（iOS/Android）、ネイティブパフォーマンス、美しいUI |
| **状態管理** | Riverpod 2.4+ | 型安全、スケーラブル、Flutter公式推奨 |
| **HTTPクライアント** | Dio 5.4+ | 強力なHTTPクライアント、インターセプター、エラーハンドリング |
| **ローカルストレージ** | Hive 2.2+ | 高速NoSQLデータベース、オフライン対応 |
| **UIコンポーネント** | カスタムウィジェット | デザイン仕様に正確に一致 |

### 3.2 バックエンド

| コンポーネント | 技術 | 理由 |
|:---|:---|:---|
| **ランタイム** | Node.js 20+（またはPython 3.11+） | 高速、スケーラブル、豊富なエコシステム |
| **フレームワーク** | Express 4.18+（またはFastAPI 0.109+） | 軽量、デプロイが容易 |
| **AI統合** | OpenAI API（GPT-4） | 最高クラスのLLM、自然な会話 |
| **データベース** | Firebase Firestore（またはPostgreSQL） | リアルタイム、スケーラブル、Firebase統合が容易 |
| **認証** | Firebase Auth | OAuth、メール/パスワード、将来の課金対応 |
| **ホスティング** | Vercel / Railway / AWS Lambda | サーバーレス、自動スケーリング、コスト効率 |

### 3.3 開発ツール

| ツール | 用途 |
|:---|:---|
| **Git** | バージョン管理 |
| **GitHub Actions** | CI/CDパイプライン |
| **Postman** | APIテスト |
| **Flutter DevTools** | デバッグ・プロファイリング |

---

## 4. フロントエンド仕様（Flutter）

### 4.1 プロジェクト構造

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── text_styles.dart
│   │   └── dimensions.dart
│   ├── utils/
│   │   └── validators.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   ├── ai_personality.dart
│   │   ├── consultation.dart
│   │   └── resolution_card.dart
│   ├── repositories/
│   │   └── consultation_repository.dart
│   └── services/
│       ├── api_service.dart
│       └── local_storage_service.dart
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── ai_card.dart
│   │   │       ├── input_field.dart
│   │   │       └── start_button.dart
│   │   ├── deliberation/
│   │   │   ├── deliberation_screen.dart
│   │   │   └── widgets/
│   │   │       ├── ai_avatar.dart
│   │   │       ├── message_bubble.dart
│   │   │       └── progress_indicator.dart
│   │   ├── resolution/
│   │   │   ├── resolution_screen.dart
│   │   │   └── widgets/
│   │   │       └── resolution_card.dart
│   │   └── history/
│   │       ├── history_screen.dart
│   │       └── widgets/
│   │           └── history_item.dart
│   └── providers/
│       ├── consultation_provider.dart
│       └── history_provider.dart
└── routes/
    └── app_router.dart
```

### 4.2 デザインシステム

#### 4.2.1 カラーパレット

```dart
// lib/core/constants/colors.dart

class AppColors {
  // 背景グラデーション
  static const Color bgStart = Color(0xFFF5F3FF);
  static const Color bgEnd = Color(0xFFE8F4FF);
  
  // カード・サーフェス
  static const Color cardBg = Color(0xFFFFFFFF);
  
  // テキスト
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  
  // AI人格カラー
  static const Color logic = Color(0xFF4A5FD9);      // 青
  static const Color heart = Color(0xFFFF6B9D);      // ピンク
  static const Color flash = Color(0xFFFFB800);      // 黄色
  
  // ボタングラデーション
  static const Color buttonStart = Color(0xFF8B7FFF);
  static const Color buttonEnd = Color(0xFF5B9FFF);
  
  // ボーダー・シャドウ
  static const Color inputBorder = Color(0xFFCBD5E0);
}
```

#### 4.2.2 タイポグラフィ

```dart
// lib/core/constants/text_styles.dart

class AppTextStyles {
  static const String fontFamily = 'NotoSansJP';
  
  // アプリタイトル
  static const TextStyle appTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: AppColors.textPrimary,
  );
  
  // キャッチコピー
  static const TextStyle tagline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  // AI名（カードタイトル）
  static const TextStyle aiName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // AIサブタイトル
  static const TextStyle aiSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
```

### 4.3 画面仕様

#### 4.3.1 ホーム画面

**レイアウト:**
```
┌─────────────────────────────────────┐
│          三賢会議                    │
│   3つの視点で、迷いを終わらせる      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [ロジックアイコン]           │   │
│  │   ロジック                   │   │
│  │   論理的思考                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │ [ハートアイコン]│[フラッシュアイコン]│
│  │   ハート    │  │  フラッシュ │  │
│  │  感情・共感 │  │  直感・行動 │  │
│  └─────────────┘  └─────────────┘  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 相談内容（1〜2文でOK）       │   │
│  │ 例：転職するか迷っています   │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      会議を始める            │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

#### 4.3.2 審議画面

**目的:** AIの議論をリアルタイムで表示（アニメーション付き）

**レイアウト:**
```
┌─────────────────────────────────────┐
│  [← 戻る]       審議中...           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [ロジックアバター]           │   │
│  │ まず、転職の理由を整理しま   │   │
│  │ しょう...                   │   │
│  └─────────────────────────────┘   │
│                                     │
│          ┌─────────────────────┐   │
│          │ [ハートアバター]     │   │
│          │ あなたの気持ちは？   │   │
│          └─────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [フラッシュアバター]         │   │
│  │ 今すぐ行動すべきか？         │   │
│  └─────────────────────────────┘   │
│                                     │
│  [進捗: ラウンド 2/3]               │
└─────────────────────────────────────┘
```

**主要機能:**
- メッセージの出現アニメーション（フェードイン + スライドアップ）
- 各AIのアバターアイコン
- 進捗インジケーター（ラウンド 1/3, 2/3, 3/3）
- 最新メッセージへの自動スクロール

#### 4.3.3 決議書カード画面

**目的:** 最終決定を構造化されたカード形式で表示

**カード構造:**
```
┌─────────────────────────────────────┐
│         決議書                       │
│                                     │
│  決議: 転職を推奨                    │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━       │
│                                     │
│  投票結果:                           │
│  ✓ ロジック: 賛成                   │
│  ✓ ハート: 賛成                     │
│  ✗ フラッシュ: 保留                 │
│                                     │
│  理由:                               │
│  - 現職での成長が限界               │
│  - 新しい環境での挑戦が必要         │
│  - ただし準備期間が必要             │
│                                     │
│  次の一手:                           │
│  1. 職務経歴書を更新する            │
│  2. 転職エージェントに登録          │
│  3. 1週間後に再評価                 │
│                                     │
│  再審期限: 2026年1月27日            │
│                                     │
│  [保存]  [シェア]                   │
└─────────────────────────────────────┘
```

---

## 5. バックエンド仕様（API・AI処理）

### 5.1 APIエンドポイント

**ベースURL:** `https://api.sankenkaigi.com/v1`

#### 5.1.1 POST /api/v1/deliberate

**目的:** AI審議プロセスを開始

**リクエスト:**
```json
{
  "consultation": "転職するか迷っています",
  "userId": "user_12345" // オプション、認証済みユーザー用
}
```

**レスポンス:**
```json
{
  "consultationId": "consult_abc123",
  "rounds": [
    {
      "roundNumber": 1,
      "messages": [
        {
          "ai": "logic",
          "message": "まず、転職の理由を明確にしましょう...",
          "timestamp": "2026-01-20T10:30:00Z"
        },
        ...
      ]
    },
    ...
  ],
  "resolution": {
    "decision": "転職を推奨",
    "votes": {
      "logic": "approve",
      "heart": "approve",
      "flash": "pending"
    },
    "reasoning": [...],
    "nextSteps": [...],
    "reviewDate": "2026-01-27",
    "risks": [...]
  }
}
```

#### 5.1.2 GET /api/v1/history

**目的:** 相談履歴を取得

**リクエスト:**
```
GET /api/v1/history?userId=user_12345&limit=10&offset=0
```

**レスポンス:**
```json
{
  "consultations": [
    {
      "consultationId": "consult_abc123",
      "question": "転職するか迷っています",
      "decision": "転職を推奨",
      "createdAt": "2026-01-20T10:30:00Z"
    },
    ...
  ],
  "total": 25,
  "hasMore": true
}
```

### 5.2 AI人格プロンプト定義

#### ロジック（Logic）

```
あなたは「ロジック」という名前の論理的なAIです。
あなたの役割は：
- 事実とデータを客観的に分析する
- メリット・デメリットを体系的に整理する
- 長期的な結果を考慮する
- 論理的な推論を提供する

日本語で回答し、簡潔に（2〜3文）まとめてください。
```

#### ハート（Heart）

```
あなたは「ハート」という名前の共感的なAIです。
あなたの役割は：
- 感情的な影響を考慮する
- 関係性や人間関係を重視する
- 精神的な健康を優先する
- 思いやりのあるアドバイスを提供する

日本語で回答し、簡潔に（2〜3文）まとめてください。
```

#### フラッシュ（Flash）

```
あなたは「フラッシュ」という名前の直感的なAIです。
あなたの役割は：
- 直感と第六感を信頼する
- 大胆な行動を促す
- 即座の次のステップに焦点を当てる
- 決断力のある推奨を提供する

日本語で回答し、簡潔に（2〜3文）まとめてください。
```

---

## 6. データベース設計

### 6.1 Firestoreコレクション

#### コレクション: `consultations`

```javascript
{
  "consultationId": "consult_abc123",
  "userId": "user_12345",
  "question": "転職するか迷っています",
  "rounds": [
    {
      "roundNumber": 1,
      "messages": [
        {
          "ai": "logic",
          "message": "...",
          "timestamp": "2026-01-20T10:30:00Z"
        },
        ...
      ]
    },
    ...
  ],
  "resolution": {
    "decision": "転職を推奨",
    "votes": {...},
    "reasoning": [...],
    "nextSteps": [...],
    "risks": [...],
    "reviewDate": "2026-01-27"
  },
  "createdAt": "2026-01-20T10:30:00Z",
  "updatedAt": "2026-01-20T10:35:00Z"
}
```

#### コレクション: `users`

```javascript
{
  "userId": "user_12345",
  "email": "user@example.com",
  "displayName": "田中太郎",
  "createdAt": "2026-01-15T08:00:00Z",
  "subscription": {
    "plan": "free", // "free", "premium"
    "startDate": "2026-01-15T08:00:00Z",
    "endDate": null
  },
  "usage": {
    "consultationsThisMonth": 5,
    "totalConsultations": 12
  }
}
```

---

## 7. AI処理ロジック

### 7.1 3ラウンド審議システム

**ラウンド1: 初期意見**
- 各AIが独立して分析を提供
- 他のAIの意見を知らない状態
- 各自のコア視点（論理/感情/直感）に焦点

**ラウンド2: 議論・反論**
- 各AIが他のAIのラウンド1の意見を受け取る
- 反論または同意を表明
- 対立点と共通点を特定

**ラウンド3: 最終合意**
- 各AIが全ての過去のメッセージを受け取る
- 最終推奨を提供
- 投票を表明（賛成/反対/保留）

### 7.2 決議書生成ロジック

**決定式:**
- **全員賛成** → "強く推奨"
- **2/3賛成** → "推奨"
- **1/3賛成** → "条件付き推奨"
- **0/3賛成** → "推奨しない"

**少数意見の扱い:**
- 反対意見を必ず「リスク」セクションに含める
- 少数派が賛成する条件を明示

---

## 8. インフラ・デプロイ

### 8.1 バックエンドホスティング

**推奨:** Vercel（Node.js）またはRailway（Python）

**環境変数:**
```
OPENAI_API_KEY=sk-...
DATABASE_URL=postgresql://...
FIREBASE_PROJECT_ID=sanken-kaigi
FIREBASE_PRIVATE_KEY=...
```

**デプロイ手順:**
1. コードをGitHubにプッシュ
2. GitHubリポジトリをVercel/Railwayに接続
3. 環境変数を設定
4. `main`ブランチへのプッシュで自動デプロイ

### 8.2 Flutterアプリビルド

**iOSビルド:**
```bash
flutter build ios --release
```

**Androidビルド:**
```bash
flutter build apk --release
flutter build appbundle --release
```

---

## 9. 開発ワークフロー

### 9.1 セットアップ手順

**バックエンド:**
```bash
# リポジトリをクローン
git clone https://github.com/your-repo/sanken-kaigi-backend.git
cd sanken-kaigi-backend

# 依存関係をインストール
npm install

# 環境変数を設定
cp .env.example .env
# .envファイルにAPIキーを記入

# 開発サーバーを起動
npm run dev
```

**フロントエンド:**
```bash
# リポジトリをクローン
git clone https://github.com/your-repo/sanken-kaigi-app.git
cd sanken-kaigi-app

# 依存関係をインストール
flutter pub get

# シミュレーターで実行
flutter run
```

### 9.2 テスト

**バックエンドAPIテスト:**
```bash
# curlを使用
curl -X POST http://localhost:3000/api/v1/deliberate \
  -H "Content-Type: application/json" \
  -d '{"consultation": "転職するか迷っています"}'
```

**Flutterウィジェットテスト:**
```bash
flutter test
```

---

## 10. アプリストア申請

### 10.1 iOS App Store

**必要なもの:**
- Apple Developer Account（年間$99）
- アプリアイコン（1024x1024px）
- スクリーンショット（各種iPhoneサイズ）
- プライバシーポリシーURL
- アプリ説明文（日本語・英語）

**手順:**
1. App Store Connectでアプリを作成
2. XcodeまたはTransporter経由でビルドをアップロード
3. アプリメタデータを入力
4. 審査に提出（7〜14日）

### 10.2 Google Play Store

**必要なもの:**
- Google Play Developer Account（一度限り$25）
- アプリアイコン（512x512px）
- フィーチャーグラフィック（1024x500px）
- スクリーンショット（各種Androidサイズ）
- プライバシーポリシーURL
- アプリ説明文（日本語・英語）

**手順:**
1. Google Play Consoleでアプリを作成
2. APK/AABをアップロード
3. ストアリストを入力
4. 審査に提出（1〜3日）

---

## 11. 実装チェックリスト

### フェーズ1: MVP（1〜2週間）
- [ ] バックエンドAPIセットアップ（Node.js/Python）
- [ ] OpenAI統合（3つのAI人格）
- [ ] Flutterプロジェクトセットアップ
- [ ] ホーム画面UI
- [ ] 審議画面UI
- [ ] 決議書カードUI
- [ ] FlutterでのAPI統合

### フェーズ2: コア機能（3〜4週間）
- [ ] 履歴画面
- [ ] ローカルストレージ（Hive）
- [ ] エラーハンドリング
- [ ] ローディング状態
- [ ] アニメーション

### フェーズ3: 仕上げ・テスト（5週目）
- [ ] UI改善
- [ ] パフォーマンス最適化
- [ ] バグ修正
- [ ] ユーザーテスト

### フェーズ4: デプロイ（6週目）
- [ ] バックエンドデプロイ（Vercel/Railway）
- [ ] iOSビルド・申請
- [ ] Androidビルド・申請
- [ ] マーケティング素材

---

## 12. 成功指標

**MVP成功基準:**
- アプリがクラッシュせずに起動する
- ユーザーが相談を入力してAIの回答を受け取れる
- 決議書カードが正しく表示される
- 履歴がローカルに保存される

**ローンチ後の指標:**
- デイリーアクティブユーザー（DAU）
- ユーザーあたりの平均相談数
- 完了率（審議を最後まで完了したユーザー）
- App Storeレーティング（目標: 4.5+）

---

## 仕様書終わり

**次のステップ:**
1. この仕様書をレビュー
2. 開発環境をセットアップ
3. フェーズ1の実装を開始
4. ユーザーフィードバックに基づいて反復

質問や不明点があれば、プロジェクトリーダーに連絡してください。
