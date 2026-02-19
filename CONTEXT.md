# 三賢会議 (Triad Council) ― コンテキスト引き継ぎドキュメント
# 最終更新: 2026-02-19 04:30 Cowork — App Store審査提出完了

---

## 📌 プロジェクト概要

### アプリ名
**三賢会議（Triad Council）**

### コンセプト
3人のAI賢者（哲学者・戦略家・実践家）が相談内容を3ラウンド審議し、決議書を生成するiOS / Androidアプリ。

### 技術スタック
| 層 | 技術 |
|---|---|
| フロントエンド | Flutter/Dart |
| バックエンド | Node.js + TypeScript + Express |
| DB / Auth | Firebase（Firestore + Anonymous Auth） |
| AI | OpenAI API (gpt-4o-mini) |
| 広告 | Google Mobile Ads (AdMob) |
| 課金 | RevenueCat (purchases_flutter) |
| ストレージ | Hive（ローカル履歴保存） |
| インフラ | Cloudflare Pages（プライバシーポリシー等） |

### Bundle ID
- iOS: `com.sankenkaigi.app`
- Team ID: `5CMYP437MX`

### AdMob ID（本番）
- アプリID: `ca-app-pub-2551004292724620~2672533121`
- インタースティシャル広告ユニットID: `ca-app-pub-2551004292724620/2398469875`

### RevenueCat
- Product IDs: `triad_meeting_weekly`（週額）, `triad_meeting_monthly`（月額）
- Entitlement: `premium`
- API Key: 環境変数 `REVENUECAT_API_KEY` で設定

---

## 📅 開発フェーズ

### Phase 1 + 2（統合）: 無料版 + プレミアム版 ✅ コード実装完了
- 相談入力 → 3ラウンド審議 → 決議書表示
- Firebase Anonymous Auth
- 1日10回制限（サーバー側、JST日付境界）→ プレミアムは無制限
- インタースティシャル広告（決議書後）→ プレミアムは非表示
- RevenueCat課金（週額+月額サブスクリプション）
- ペイウォール画面・設定画面からアップグレード導線
- iOS / Android 対応

---

## ✅ 完了タスク

### コード実装（2026-01-24頃 Genspark AI Developer）
- [x] Flutter プロジェクト初期化
- [x] ホーム画面（相談入力）
- [x] 審議画面（3ラウンド表示・アニメーション）
- [x] 決議書画面（決議/投票/理由/次の一手/再審期限）
- [x] 履歴画面（一覧・詳細・削除）
- [x] Firebase Anonymous Auth 実装
- [x] Hive ローカル保存
- [x] AdMob インタースティシャル広告
- [x] 羊皮紙・万年筆インク風デザイン
- [x] アプリアイコン（三賢会議デザイン）
- [x] デバイス別ユーザー分離（UUID管理）
- [x] 本番環境への準備（最終コミット: `54465ab`）

### RevenueCat課金実装（2026-02-19 Cowork）
- [x] purchases_flutter SDK追加
- [x] PurchaseService（初期化・購入・復元ロジック）
- [x] PaywallScreen（プラン選択UI・特典表示・おすすめバッジ）
- [x] プレミアムユーザーは広告非表示
- [x] プレミアムユーザーは利用回数制限解除
- [x] 設定画面にプレミアムステータス・アップグレードボタン追加
- [x] 日次制限エラー時にペイウォール案内
- [x] APIリクエストにplan(free/premium)パラメータ追加
- [x] コミット: `dcc031a feat: RevenueCat課金機能・ビルドパイプライン追加`

### AdMob本番ID設定（2026-02-19 Cowork）
- [x] AdMobコンソールで三賢会議（iOS）アプリ登録
- [x] インタースティシャル広告ユニット作成
- [x] app_config.dart に本番ID反映
- [x] Info.plist に本番GADApplicationIdentifier反映
- ⚠️ コミット未完了（gitロックファイル問題）→ ファイル変更は保存済み

### ビルドパイプライン（2026-02-19 Cowork）
- [x] scripts/build-pipeline.sh 作成
- [x] triad_meeting / snap_english 切り替え対応（--project=オプション）

### ドキュメント整備
- [x] APP_STORE_SUBMISSION_GUIDE.md 作成
- [x] APP_STORE_CHECKLIST.md 作成
- [x] SUPPORT.md / PRIVACY_POLICY.md 作成
- [x] docs/index.html / docs/privacy.html 作成
- [x] .claude/CLAUDE.md / CONTEXT.md 作成

---

### 中継サーバー設定完了（2026-02-19 Cowork）
- [x] cowork-codex-relay のWORKDIRをtriad_meetingに変更
- [x] Flutter PATH問題の解決（server.js: shell: true）
- [x] flutter analyze 成功（エラー0、warning/info のみ）
- [x] flutter build ios --release 成功（53.9MB）
- [x] overrideWithValue → overrideWith 修正（main.dart）
- [x] CLAUDE.md に中継サーバーノウハウを記録

### iOSビルド修正・再ビルド・アップロード（2026-02-19 Cowork）
- [x] NSUserTrackingUsageDescription を Info.plist から削除（審査リジェクト対応）
- [x] iPad向け UISupportedInterfaceOrientations~ipad を削除（iPhone専用に変更）
- [x] TARGETED_DEVICE_FAMILY を "1"（iPhoneのみ）に変更
- [x] flutter build ios --release 再ビルド成功
- [x] Xcode Archive → IPA Export → xcrun altool でアップロード（Build 6）

### App Store Connect 設定完了（2026-02-19 Cowork）
- [x] 価格設定: 無料（$0.00）全175カ国/地域
- [x] アプリの利用可能地域: 全カ国/地域
- [x] コンテンツ配信権: いいえ（サードパーティコンテンツなし）
- [x] アプリのプライバシー: 公開済み（7データタイプ）
- [x] ビルド選択: Build 3 → Build 6 に変更
- [x] 暗号化コンプライアンス: カスタム暗号化なし（Apple標準HTTPSのみ）
- [x] **App Store 審査提出完了**（2026-02-19 04:28 JST）
  - ステータス: 「審査待ち」（最大48時間）

---

## ⏳ 未完了タスク（審査通過後・今後）

### git コミット
- [ ] 全変更をまとめてコミット（RevenueCat・AdMob・中継サーバー修正・Info.plist修正等）

### RevenueCat ダッシュボード設定（Phase 2 課金有効化時）
- [ ] App Store Connect でサブスクリプション商品作成（週額・月額）
- [ ] RevenueCat ダッシュボードでOfferings設定
- [ ] RevenueCat API Key を取得してビルド時に設定

### 審査結果対応
- [ ] 審査通過 → リリース / 審査リジェクト → 修正対応

---

## 🔜 次のアクション（優先順）

1. **審査結果を待つ**（最大48時間）
2. **git コミット** → 全変更をまとめてコミット
3. **審査結果に応じた対応**

---

## 🧰 中継サーバー（cowork-codex-relay）

```bash
# Mac側: ステータス確認
bash ~/Projects/ai-director-project/scripts/relay-service.sh status

# Mac側: ngrok URL 確認
bash ~/Projects/ai-director-project/scripts/relay-service.sh url

# Cowork側: ビルド全自動（triad_meeting）
bash scripts/build-pipeline.sh <ngrok-url>

# Cowork側: SnapEnglish切り替え
bash scripts/build-pipeline.sh <ngrok-url> --project=snap_english
```

---

## 📂 プロジェクトフォルダ構成

```
triad_meeting/
├── app/                          # Flutter アプリ本体
│   ├── lib/
│   │   ├── config/               # 環境設定（AdMob ID・RevenueCat設定）
│   │   ├── models/               # データモデル
│   │   ├── providers/            # Riverpod プロバイダー
│   │   ├── screens/              # 各画面（+ PaywallScreen追加）
│   │   ├── services/             # API・DB・広告・課金サービス
│   │   ├── theme/                # テーマ・スタイル
│   │   └── widgets/              # 再利用コンポーネント
│   └── screenshots/              # App Store用スクショ（未撮影）
├── server/                       # Node.js バックエンド
├── scripts/                      # ビルドパイプライン（NEW）
│   └── build-pipeline.sh         # triad_meeting/snap_english切り替え対応
├── cloudflare-pages/             # Cloudflare Pages 用 HTML
├── docs/                         # 仕様書・チェックリスト
├── .claude/CLAUDE.md             # プロジェクト設定
├── .skills/                      # カスタムスキル
├── CONTEXT.md                    # このファイル
└── README.md
```

---

## ⚠️ 新しいチャットを始めるときの指示テンプレート

```
以下のコンテキストドキュメントを読み込んでください。
これは「三賢会議」アプリ開発の進行状況です。

[CONTEXT.md の内容を貼り付け]

前回までの到達点：[最新の状況]
今回やりたいこと：[今回の目的]
```
