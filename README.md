# 三賢会議 (Triad Council) – Phase 1

Phase 1 実装（無料版のみ）の Flutter + Node.js/Express 構成です。

## 構成
- `app/` Flutter アプリ
- `server/` Node.js + Express API

## アプリ起動（Flutter）
```bash
cd app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.sankenkaigi.com \
  --dart-define=ADMOB_APP_ID=ca-app-pub-xxxxxxxx~yyyyyyyy \
  --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-xxxxxxxx/zzzzzzzz
```

> Firebase の各設定値は `app/lib/firebase_options.dart` を差し替えてください。

## バックエンド起動（Node.js）
```bash
cd server
npm install
cp .env.example .env
npm run dev
```

## 環境変数（backend）
- `OPENAI_API_KEY`
- `OPENAI_MODEL` (default: gpt-4o-mini)
- `FIREBASE_PROJECT_ID`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_PRIVATE_KEY`
- `PORT`

## API
- POST `/v1/deliberate`
- GET `/v1/history`
- POST `/v1/consultations/{id}/save`
- GET `/v1/consultations/{id}`
- DELETE `/v1/consultations/{id}`

---

## App Store 審査対応

App Store審査に提出する前に、以下のドキュメントを確認してください:

### 📄 必須ドキュメント

1. **[App Store提出ガイド](./APP_STORE_SUBMISSION_GUIDE.md)**
   - スクリーンショット要件
   - メタデータのチェックリスト
   - 審査で避けるべき問題

2. **[サポートページ](./SUPPORT.md)**
   - Cloudflare Pages用: [cloudflare-pages/triad-council/support/index.html](./cloudflare-pages/triad-council/support/index.html)
   - よくある質問、お問い合わせ情報

3. **[プライバシーポリシー](./PRIVACY_POLICY.md)**
   - Cloudflare Pages用: [cloudflare-pages/triad-council/privacy/index.html](./cloudflare-pages/triad-council/privacy/index.html)
   - データ収集・使用に関する詳細

### 🌐 サポートページの公開

Cloudflare Pagesを使用してサポートページを公開:

```bash
# 1. 既存のCloudflare Pagesプロジェクトに追加
cd /path/to/your-cloudflare-pages-project
cp -r /Users/yuyafujita/Desktop/workspaces/triad_meeting/cloudflare-pages/triad-council ./

# 2. Gitにコミット＆プッシュ
git add triad-council/
git commit -m "feat: 三賢会議のサポートページとプライバシーポリシーを追加"
git push origin main

# 3. 公開URL（数分後に利用可能）
# https://marumi-works.com/triad-council/support/
# https://marumi-works.com/triad-council/privacy/
```

詳細は [cloudflare-pages/README.md](./cloudflare-pages/README.md) を参照。

### ✅ 審査前チェックリスト

#### スクリーンショット
- [ ] iPhone 6.9" のスクリーンショット (最低3枚)
- [ ] iPhone 6.7" のスクリーンショット (最低3枚)
- [ ] iPad用スクリーンショット (推奨)
- [ ] スプラッシュ画面のみのスクリーンショットがない
- [ ] 実際の機能を示している

#### メタデータ
- [ ] アプリ説明に実装されていない機能が記載されていない
- [ ] "Pro版" など存在しない機能への言及がない
- [ ] カテゴリが適切

#### URL設定（App Store Connect）
- [ ] サポートURL: `https://marumi-works.com/triad-council/support/`
- [ ] プライバシーポリシーURL: `https://marumi-works.com/triad-council/privacy/`
- [ ] メールアドレス: `support@sankenkaigi.com` が機能している

#### アプリ内
- [ ] プライバシーポリシー画面が更新されている
- [ ] 設定画面にバージョン情報が表示されている
- [ ] 全機能が正常動作している

### 📱 スクリーンショット作成

```bash
# シミュレータでアプリを起動
cd app
flutter run

# 必要な画面でスクリーンショット撮影（Cmd + S）
# 保存先: ~/Desktop/

# 推奨するスクリーンショット:
# 1. ホーム画面（テーマ入力）
# 2. 審議画面（議論中）
# 3. 決議書画面
# 4. 履歴画面
# 5. 詳細画面
```

### 🔄 審査で問題が発生した場合

App Store Connectの「Resolution Center」で返信してください。
主な対応方法は [APP_STORE_SUBMISSION_GUIDE.md](./APP_STORE_SUBMISSION_GUIDE.md) に記載。
