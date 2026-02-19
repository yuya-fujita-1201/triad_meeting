# Cloudflare Pages デプロイガイド

このディレクトリには、Cloudflare Pagesで公開する三賢会議のサポートページとプライバシーポリシーが含まれています。

## 📁 ディレクトリ構成

```
cloudflare-pages/
└── triad-council/
    ├── privacy/
    │   └── index.html      # プライバシーポリシー
    └── support/
        └── index.html      # サポートページ
```

## 🌐 公開URL

デプロイ後、以下のURLでアクセス可能になります:

- **サポートページ:** `https://marumi-works.com/triad-council/support/`
- **プライバシーポリシー:** `https://marumi-works.com/triad-council/privacy/`

## 🚀 Cloudflare Pagesへのデプロイ手順

### 前提条件
- Cloudflareアカウント（既存のものを使用）
- `marumi-works.com` ドメインが既にCloudflare Pagesで設定済み

### オプション1: 既存プロジェクトへの追加（推奨）

既に `first-steps` でCloudflare Pagesプロジェクトを使用している場合、同じプロジェクトに追加できます。

#### 1. ファイル構造の準備

既存のCloudflare Pagesプロジェクトのディレクトリ構造に合わせて、以下のようにファイルを配置:

```
your-cloudflare-pages-project/
├── first-steps/
│   ├── privacy/
│   │   └── index.html
│   └── support/
│       └── index.html
└── triad-council/          # 新しく追加
    ├── privacy/
    │   └── index.html
    └── support/
        └── index.html
```

#### 2. ファイルのコピー

```bash
# 既存のCloudflare Pagesプロジェクトディレクトリに移動
cd /path/to/your-cloudflare-pages-project

# triad-councilディレクトリをコピー
cp -r /Users/yuyafujita/Desktop/workspaces/triad_meeting/cloudflare-pages/triad-council ./
```

#### 3. Git にコミット＆プッシュ

```bash
# 変更を確認
git status

# ファイルを追加
git add triad-council/

# コミット
git commit -m "feat: 三賢会議のサポートページとプライバシーポリシーを追加"

# プッシュ（ブランチ名は環境に合わせて変更）
git push origin main
```

#### 4. Cloudflare Pagesの自動デプロイ

Cloudflare Pagesは自動的に変更を検出してデプロイします。
数分後、以下のURLでアクセス可能になります:
- `https://marumi-works.com/triad-council/support/`
- `https://marumi-works.com/triad-council/privacy/`

### オプション2: 新規プロジェクトとして作成

別のプロジェクトとして管理したい場合:

#### 1. Cloudflareダッシュボードにログイン

https://dash.cloudflare.com/ にアクセス

#### 2. Pagesプロジェクトを作成

1. 左メニューから「Workers & Pages」を選択
2. 「Create application」をクリック
3. 「Pages」タブを選択
4. 「Connect to Git」または「Upload assets」を選択

#### 3A. GitHubリポジトリを使用する場合

1. GitHubアカウントを接続
2. このリポジトリ（triad_meeting）を選択
3. ビルド設定:
   - **Build command:** (空欄)
   - **Build output directory:** `cloudflare-pages`
   - **Root directory:** `cloudflare-pages`
4. 「Save and Deploy」をクリック

#### 3B. 直接アップロードする場合

1. 「Upload assets」を選択
2. `cloudflare-pages/triad-council/` フォルダをドラッグ&ドロップ
3. プロジェクト名を入力（例: `triad-council`）
4. 「Deploy」をクリック

#### 4. カスタムドメインの設定

1. デプロイ完了後、プロジェクト設定を開く
2. 「Custom domains」タブを選択
3. 「Set up a custom domain」をクリック
4. ドメインを入力: `marumi-works.com`
5. サブパスの設定が必要な場合は、Cloudflare Workersでルーティングを設定

## 🔧 ローカルでのプレビュー

デプロイ前にローカルでページを確認できます:

### 方法1: シンプルなHTTPサーバー（Python）

```bash
# cloudflare-pages ディレクトリに移動
cd /Users/yuyafujita/Desktop/workspaces/triad_meeting/cloudflare-pages

# Pythonのシンプルサーバーを起動
python3 -m http.server 8000

# ブラウザで確認
# http://localhost:8000/triad-council/support/
# http://localhost:8000/triad-council/privacy/
```

### 方法2: Cloudflare Wrangler（推奨）

```bash
# Wranglerをインストール（未インストールの場合）
npm install -g wrangler

# cloudflare-pages ディレクトリに移動
cd /Users/yuyafujita/Desktop/workspaces/triad_meeting/cloudflare-pages

# ローカルプレビュー
wrangler pages dev .

# ブラウザで確認
# http://localhost:8788/triad-council/support/
# http://localhost:8788/triad-council/privacy/
```

## 📝 App Store Connectでの設定

Cloudflare Pagesにデプロイ後、App Store Connectで以下のURLを設定してください:

### サポートURL
```
https://marumi-works.com/triad-council/support/
```

### プライバシーポリシーURL
```
https://marumi-works.com/triad-council/privacy/
```

### 設定手順
1. App Store Connect にログイン
2. 「マイApp」> 「三賢会議」を選択
3. 「App情報」タブをクリック
4. 「サポートURL」と「プライバシーポリシーURL」を入力
5. 「保存」をクリック

## ✅ デプロイ後の確認事項

- [ ] サポートページが正しく表示される
- [ ] プライバシーポリシーが正しく表示される
- [ ] 日本語が正しく表示される（文字化けなし）
- [ ] レスポンシブデザインが機能する（スマホ・タブレット）
- [ ] リンクが正しく機能する
- [ ] HTTPSでアクセスできる
- [ ] メールアドレス（support@sankenkaigi.com）のリンクが機能する

## 🔄 ページの更新方法

HTMLファイルを編集した後:

### GitHubリポジトリを使用している場合
```bash
# 変更をコミット
git add cloudflare-pages/
git commit -m "docs: サポートページを更新"

# プッシュ
git push origin main
```

Cloudflare Pagesが自動的に再デプロイします（数分で反映）。

### 直接アップロードの場合
1. Cloudflareダッシュボード > Pages > プロジェクトを選択
2. 「Create deployment」をクリック
3. 更新したファイルをアップロード

## 🎨 デザインについて

両ページは `first-steps` と同じデザインスタイルを使用しています:

- **配色:** 暖色系（クリーム、オレンジ）
- **フォント:** Zen Kaku Gothic New、Noto Sans JP
- **レイアウト:** カード型、最大幅980px
- **レスポンシブ:** モバイル・タブレット対応

デザインを統一することで、ブランドの一貫性を保ちます。

## 📧 メールアドレスの設定

ページ内で使用しているメールアドレス `support@sankenkaigi.com` を実際に使用可能にしてください。

### オプション1: 独自ドメインのメール
1. ドメインプロバイダーでメール機能を有効化
2. `support@sankenkaigi.com` アカウントを作成

### オプション2: メール転送
1. Cloudflareの Email Routing を使用
2. `support@sankenkaigi.com` を既存のメールアドレスに転送

### オプション3: 一時的な対応
HTMLファイル内のメールアドレスを実際に使用するアドレスに変更:

```bash
# support/index.html と privacy/index.html 内の
# support@sankenkaigi.com を置換
```

## 🐛 トラブルシューティング

### ページが表示されない
1. Cloudflare Pagesのデプロイステータスを確認
2. ファイルパスが正しいか確認（`triad-council/support/index.html`）
3. DNS設定を確認
4. ブラウザのキャッシュをクリア

### スタイルが崩れる
1. HTMLファイルの文字コードがUTF-8か確認
2. Google Fontsが正しく読み込まれているか確認
3. ブラウザの開発者ツールでエラーを確認

### 404エラー
1. ファイル名が正しいか確認（`index.html`）
2. ディレクトリ構造を確認
3. Cloudflare Pagesのビルドログを確認

## 📚 参考リンク

- [Cloudflare Pages ドキュメント](https://developers.cloudflare.com/pages/)
- [カスタムドメインの設定](https://developers.cloudflare.com/pages/platform/custom-domains/)
- [Email Routing](https://developers.cloudflare.com/email-routing/)
- [App Store Connect ヘルプ](https://help.apple.com/app-store-connect/)

---

**作成日:** 2026-01-31
**最終更新:** 2026-01-31

質問や問題があれば、このガイドを参照してください。
