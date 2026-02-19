# GitHub Pages セットアップガイド

このディレクトリには、App Store審査で必要なサポートページとプライバシーポリシーのHTMLファイルが含まれています。

## 📁 ファイル構成

```
docs/
├── index.html       # サポートページ
├── privacy.html     # プライバシーポリシー
└── README.md        # このファイル
```

## 🚀 GitHub Pagesの有効化

### 1. GitHubリポジトリの設定

1. GitHubリポジトリ (https://github.com/yuya-fujita-1201/triad_meeting) にアクセス
2. 「Settings」タブをクリック
3. 左メニューから「Pages」を選択
4. 「Source」セクションで以下を設定:
   - **Source**: Deploy from a branch
   - **Branch**: `main`
   - **Folder**: `/docs`
5. 「Save」ボタンをクリック

### 2. 公開URLの確認

設定後、数分で以下のURLでページが公開されます:

```
https://yuya-fujita-1201.github.io/triad_meeting/
```

**サポートページ:**
```
https://yuya-fujita-1201.github.io/triad_meeting/
```

**プライバシーポリシー:**
```
https://yuya-fujita-1201.github.io/triad_meeting/privacy.html
```

### 3. 動作確認

公開後、以下を確認してください:
- [ ] サポートページが正しく表示される
- [ ] プライバシーポリシーが正しく表示される
- [ ] ナビゲーションリンクが機能する
- [ ] レスポンシブデザインが動作する（スマホ・タブレット）

## 📝 App Store Connectでの設定

### サポートURLの設定

1. **App Store Connect** (https://appstoreconnect.apple.com/) にログイン
2. 「マイApp」から「三賢会議」を選択
3. 「App情報」セクションをクリック
4. 「サポートURL」フィールドに以下を入力:
   ```
   https://yuya-fujita-1201.github.io/triad_meeting/
   ```
5. 「保存」をクリック

### プライバシーポリシーURLの設定

1. 同じく「App情報」セクションで
2. 「プライバシーポリシーURL」フィールドに以下を入力:
   ```
   https://yuya-fujita-1201.github.io/triad_meeting/privacy.html
   ```
3. 「保存」をクリック

## 🔄 ページの更新方法

HTMLファイルを編集した後:

```bash
# 変更をコミット
git add docs/
git commit -m "docs: サポートページを更新"

# リモートにプッシュ
git push origin main
```

GitHub Pagesは自動的に更新されます（反映まで数分かかる場合があります）。

## ✅ 審査前チェックリスト

- [ ] GitHub Pagesが有効化されている
- [ ] サポートページがブラウザで正しく表示される
- [ ] プライバシーポリシーがブラウザで正しく表示される
- [ ] App Store ConnectのサポートURLが正しく設定されている
- [ ] App Store ConnectのプライバシーポリシーURLが正しく設定されている
- [ ] メールアドレス (support@sankenkaigi.com) が機能している
- [ ] 両ページがモバイルデバイスで正しく表示される

## 📧 メールアドレスの設定

サポートメールアドレス `support@sankenkaigi.com` を設定してください。

### オプション1: 独自ドメインのメール
- ドメインプロバイダーでメールアカウントを作成

### オプション2: Gmail転送
1. Gmailアカウントを作成
2. ドメインのDNS設定でMXレコードを設定
3. Gmail で受信できるように設定

### オプション3: 一時的な対応
HTMLファイル内のメールアドレスを一時的に個人のメールアドレスに変更:
```bash
# index.html と privacy.html 内の
# support@sankenkaigi.com
# を実際に使用するメールアドレスに置換
```

## 🌐 独自ドメインの使用（オプション）

GitHub Pagesで独自ドメイン (例: support.sankenkaigi.com) を使用する場合:

### 1. DNSレコードの設定

ドメインプロバイダーで以下のCNAMEレコードを追加:

```
support.sankenkaigi.com  CNAME  yuya-fujita-1201.github.io
```

### 2. GitHub Pagesの設定

1. リポジトリの Settings > Pages
2. 「Custom domain」に `support.sankenkaigi.com` を入力
3. 「Save」をクリック
4. 「Enforce HTTPS」にチェック

### 3. ファイルの作成

`docs/CNAME` ファイルを作成:
```bash
echo "support.sankenkaigi.com" > docs/CNAME
git add docs/CNAME
git commit -m "docs: カスタムドメインを設定"
git push
```

### 4. App Store Connectの更新

URLを以下に変更:
- サポートURL: `https://support.sankenkaigi.com`
- プライバシーポリシー: `https://support.sankenkaigi.com/privacy.html`

## 🐛 トラブルシューティング

### ページが表示されない
1. GitHub Pagesの設定を確認
2. ブランチとフォルダが正しいか確認（main, /docs）
3. 5-10分待ってから再度アクセス
4. ブラウザのキャッシュをクリア

### 404エラー
1. ファイル名が正しいか確認（index.html, privacy.html）
2. URLが正しいか確認
3. GitHubリポジトリが公開されているか確認

### スタイルが崩れる
1. HTMLファイルの文字コードがUTF-8か確認
2. CSSの記述にエラーがないか確認
3. ブラウザの開発者ツールでエラーを確認

## 📚 参考リンク

- [GitHub Pages ドキュメント](https://docs.github.com/en/pages)
- [App Store Connect ヘルプ](https://help.apple.com/app-store-connect/)
- [カスタムドメインの設定](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)

---

**最終更新日**: 2026-01-31
