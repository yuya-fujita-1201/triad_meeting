# 三賢会議 (Triad Council) ― Claude 設定

## プロジェクト概要
Flutter + Node.js/Express + Firebase 構成の iOS / Android アプリ。
3人のAI賢者が相談内容を議論し、決議書を生成する「三賢会議」アプリ。

### 技術スタック
- Flutter/Dart（フロントエンド）
- Node.js + TypeScript + Express（バックエンド）
- Firebase（Anonymous Auth + Firestore）
- OpenAI API（gpt-4o-mini）
- AdMob（インタースティシャル広告）
- Cloudflare Pages（プライバシーポリシー・サポートページ公開）

### フォルダ構成
```
triad_meeting/
├── app/                  # Flutter アプリ本体
│   └── lib/
│       ├── config/
│       ├── models/
│       ├── providers/
│       ├── screens/
│       ├── services/
│       ├── theme/
│       └── widgets/
├── server/               # Node.js + Express バックエンド
├── cloudflare-pages/     # Cloudflare Pages 用 HTML
├── docs/                 # 仕様書・チェックリスト
├── .claude/              # Claude 設定（このファイル等）
├── .skills/              # プロジェクト用カスタムスキル
├── CONTEXT.md            # 詳細なプロジェクトコンテキスト（必ず読む）
└── CLAUDE.md             # このファイル
```

---

## 開発フェーズ

### Phase 1（現行）: 無料版
- 相談入力 → 3ラウンド審議 → 決議書表示
- Firebase Anonymous Auth
- 1日10回制限（サーバー側）
- インタースティシャル広告（決議書後）
- iOS / Android 対応

### Phase 2（予定）: プレミアム版
- RevenueCat 課金
- 無制限利用
- AI人格カスタマイズ
- PDF/画像エクスポート

---

## 開発ルール
1. コードは全てClaude Codeが書く（人間はコードを書かない）
2. 日本語でのチャット指示に従って実装する
3. 変更はこまめにgit commitする（日本語コミットメッセージ）
4. エラーが出たら自分で診断・修正を試みる
5. 作業内容は必ずCONTEXT.mdに記録する

---

## ログ記録ポリシー
別セッションや別チャットからでもプロジェクト状況を正確に把握できるよう、以下を徹底する。

### いつ記録するか
- タスク完了時（コード実装、App Store操作、ビルド成功など）
- セッション終了前（途中であっても現在地を記録）

### 何を記録するか
1. **`CONTEXT.md`の「現在のステータス」**: 最新の進捗に更新する
2. **`CLAUDE.md`の「現在のステータス」**: CONTEXT.mdと同期させる

### 記録の原則
- **別セッションが読んでも状況がわかる**ことを最優先にする
- ファイルに書かれていないことは「やっていない」と見なされる前提で記録する
- チャットでのやり取りだけで完結させず、必ずファイルに残す

---

## iOSビルド: 中継サーバー（cowork-codex-relay）
CoworkのVM上からMacのXcodeビルドを実行するために中継サーバーを使用する。
SnapEnglish（ai-director-project）での実績あり。

### サーバー管理（Mac側）
```bash
# ステータス確認
bash ~/Projects/ai-director-project/scripts/relay-service.sh status

# ngrok URL 確認
bash ~/Projects/ai-director-project/scripts/relay-service.sh url

# 再起動
bash ~/Projects/ai-director-project/scripts/relay-service.sh restart
```

### ビルド手順（Cowork側）
```bash
# ビルド全自動（ngrok URLを取得してから）
bash ~/Projects/ai-director-project/scripts/build-pipeline.sh <ngrok-url>
```

### 接続情報
- 場所: `/Users/yuyafujita/Projects/cowork-codex-relay/`
- macOS LaunchAgent で自動起動済み（`com.marumiworks.cowork-relay.plist`）
- ヘッダー: `Authorization: Bearer snap2026` + `ngrok-skip-browser-warning: true`
- 利用可能コマンド: flutter_analyze, flutter_test, flutter_build_ios_release, xcode_archive, xcode_archive_to_ipa, xcode_release_pipeline, xcrun_upload_app, xcode_prepare_signing, ipad_screenshot_capture

### API呼び出し方法（Cowork VM側）
```bash
# コマンド一覧取得
curl -s -H "Authorization: Bearer snap2026" -H "ngrok-skip-browser-warning: true" "<ngrok-url>/api/commands"

# コマンド実行（同期）
curl -s -X POST -H "Authorization: Bearer snap2026" -H "ngrok-skip-browser-warning: true" \
  -H "Content-Type: application/json" \
  -d '{"id": "flutter_analyze"}' "<ngrok-url>/api/execute"

# パラメータ付き実行（例: xcode_archive）
curl -s -X POST -H "Authorization: Bearer snap2026" -H "ngrok-skip-browser-warning: true" \
  -H "Content-Type: application/json" \
  -d '{"id": "xcode_archive", "params": {"workspace": "Runner.xcworkspace", "scheme": "Runner"}}' \
  "<ngrok-url>/api/execute"

# 非同期実行（長時間コマンド向け）
curl -s -X POST ... -d '{"id": "flutter_build_ios_release", "async": true}' "<ngrok-url>/api/execute"
# → {"jobId": "xxx"} を返す
curl -s -H "Authorization: Bearer snap2026" "<ngrok-url>/api/jobs/<jobId>"  # 結果確認
```

### マルチプロジェクト対応（2026-02-19追加）
- `projects.json` でプロジェクト一覧を管理（再起動不要で切替可能）
- **プロジェクト切替**: API or CLI or Web UIから
  ```bash
  # API経由
  curl -s -X POST -H "Authorization: Bearer snap2026" -H "ngrok-skip-browser-warning: true" \
    -H "Content-Type: application/json" \
    -d '{"project": "triad_meeting"}' "<ngrok-url>/api/switch-project"

  # CLIスクリプト経由
  bash ~/Projects/cowork-codex-relay/bin/switch-project.sh triad_meeting [ngrok-url]
  ```
- **リクエスト単位の指定**: `workingDir` にプロジェクトID指定可
  ```bash
  curl -s -X POST ... -d '{"id": "flutter_analyze", "workingDir": "triad_meeting"}' "<ngrok-url>/api/execute"
  ```
- 登録済みプロジェクト:
  - `snap_english`: `/Users/yuyafujita/Projects/ai-director-project/app/snap_english`
  - `triad_meeting`: `/Users/yuyafujita/Projects/triad_meeting/app`
- **注意**: triad_meetingのパスが `~/Desktop/workspaces/` → `~/Projects/` に移動済み（2026-02-19）

### 重要なトラブルシューティング（2026-02-19 解決済み）
1. **ngrok URL検出の問題**: `relay-service.sh url` でURL未検出と表示されることがあるが、`relay-service.sh logs` で実際のURLを確認できる
2. **Flutter PATH問題（LaunchAgent）**: LaunchAgentはユーザーのシェルPATHを継承しない。解決策:
   - `server.js` の `spawn()` で `shell: true` を設定（`shell: false` → `shell: true`）
   - これにより `/opt/homebrew/bin/flutter` が見つかるようになる
   - 補助: `sudo ln -sf /opt/homebrew/bin/flutter /usr/local/bin/flutter`

### 初回セットアップ手順（新しいMacや再インストール時）
```bash
# 1. install → 2. restart → 3. logs でURL確認
bash ~/Projects/ai-director-project/scripts/relay-service.sh install
bash ~/Projects/ai-director-project/scripts/relay-service.sh restart
sleep 5 && bash ~/Projects/ai-director-project/scripts/relay-service.sh logs
```

---

## App Store Connect 設定値
- App Store Connect App ID: `6758553766`
- Bundle ID: `com.sankenkaigi.app`
- Team ID: `5CMYP437MX`
- 価格: 無料
- 現在のビルド: Build 7 (1.0.0+7)
- ステータス: **審査待ち**（2026-02-20 再提出）
- App Store Connect API Key ID: `P26V6QTLTW`
- API Issuer ID: `e359cd97-a6d4-4ef9-bcb3-24336fda0e74`
- .p8キー保存先: `.appstoreconnect/private_keys/AuthKey_P26V6QTLTW.p8`

---

## カスタムスキル（.skills/）
| スキル名 | 用途 |
|---|---|
| app-store-connect-browser | App Store Connect ブラウザ自動操作（サブスクリプション設定、アプリ登録等） |
| app-store-connect-api | App Store Connect API自動化（スクショアップロード、審査提出、暗号化コンプライアンス等） |
| revenuecat-browser | RevenueCat ブラウザ操作（Phase 2用） |

スキルはai-director-projectから継承・拡張。使用時は `.skills/{スキル名}/SKILL.md` を読むこと。
**ファイルアップロードが必要な操作は必ずAPI版を使うこと**（ブラウザのファイルピッカーはVM操作不可）。

## 自動化スクリプト（scripts/）
| スクリプト | 用途 |
|---|---|
| scripts/upload_screenshots.py | App Store Connectにスクリーンショットをアップロード（`--device ipad-13` / `--device iphone-6.7` 等） |

---

## 現在のステータス
- Phase 1 コード実装完了（2026-01-24頃 Genspark AI Developer）
- RevenueCat課金機能実装済み（2026-02-19 Cowork）
- AdMob本番ID設定済み
- Build 6 審査リジェクト（Guideline 2.1 — iPadクラッシュ）→ Firebase初期化ガード修正・iPad対応
- **App Store 審査再提出完了**（2026-02-20 17:00 JST — Build 7）
- ステータス: 「審査待ち」
- .p8キーをプロジェクトフォルダに保存済み（`.appstoreconnect/private_keys/`）
- iPadスクリーンショットはApp Store Connect API経由でアップロード
- **未完了**: RevenueCatダッシュボード設定（Phase 2）

---

## コミットメッセージ規則
- 例: `feat: ホーム画面UI改善`、`fix: ビルドエラー修正`
- 日本語で簡潔に
