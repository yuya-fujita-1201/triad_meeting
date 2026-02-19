# App Store 審査対応チェックリスト

このチェックリストは、App Store審査で指摘を受けないために必要な対応をまとめたものです。

## 📋 対応状況の概要

| カテゴリ | 対応状態 | 備考 |
|---------|---------|------|
| ドキュメント作成 | ✅ 完了 | サポートページ、プライバシーポリシー |
| HTMLページ作成 | ✅ 完了 | GitHub Pages用ファイル |
| アプリ内ポリシー更新 | ✅ 完了 | privacy_policy_screen.dart |
| スクリーンショット準備 | ⏳ 要対応 | ディレクトリ作成済み、撮影が必要 |
| GitHub Pages公開 | ⏳ 要対応 | 設定が必要 |
| App Store Connect設定 | ⏳ 要対応 | URL設定が必要 |
| メールアドレス設定 | ⏳ 要対応 | support@sankenkaigi.com |

---

## ✅ 完了済みの対応

### 1. ドキュメントの作成
以下のドキュメントを作成しました:

- ✅ `APP_STORE_SUBMISSION_GUIDE.md` - 審査提出の詳細ガイド
- ✅ `SUPPORT.md` - サポートページのMarkdown版
- ✅ `PRIVACY_POLICY.md` - プライバシーポリシーのMarkdown版
- ✅ `APP_STORE_CHECKLIST.md` - このファイル

### 2. GitHub Pages用HTMLファイル
以下のHTMLページを作成しました:

- ✅ `docs/index.html` - サポートページ
- ✅ `docs/privacy.html` - プライバシーポリシー
- ✅ `docs/README.md` - GitHub Pages設定ガイド

### 3. アプリ内の更新
- ✅ `app/lib/screens/privacy_policy_screen.dart` を詳細版に更新
  - AdMob、Firebase、OpenAIの使用について明記
  - ユーザーの権利について説明
  - データ保持期間を明記

### 4. スクリーンショット準備
- ✅ `app/screenshots/` ディレクトリ構造を作成
  - `iphone-6.9/`
  - `iphone-6.7/`
  - `ipad-13/`
- ✅ `app/screenshots/README.md` 撮影ガイドを作成

### 5. プロジェクトREADME更新
- ✅ `README.md` にApp Store審査対応セクションを追加

---

## ⏳ 実施が必要な対応

以下の作業は、あなた自身で実施する必要があります:

### 1. スクリーンショットの撮影 🎯 優先度: 高

#### 必要なデバイス
- iPhone 16 Pro Max または iPhone 15 Pro Max (6.9インチ)
- iPhone 16 Plus または iPhone 15 Plus (6.7インチ)
- iPad Pro 13-inch (M4) または iPad Pro 12.9-inch

#### 撮影手順
```bash
# 1. シミュレータを起動
open -a Simulator

# 2. 適切なデバイスを選択（例: iPhone 16 Pro Max）

# 3. アプリを実行
cd app
flutter run

# 4. 以下の画面でスクリーンショットを撮影（Cmd + S）
```

#### 必須スクリーンショット（各デバイス最低3枚）
1. **ホーム画面** - テーマ入力エリアが表示されている状態
2. **審議画面** - 3人の賢者が議論している様子
3. **決議書画面** - 審議結果が表示されている状態
4. **履歴画面** - 過去の審議一覧（推奨）
5. **詳細画面** - 審議内容の詳細（推奨）

#### 注意事項
- ⚠️ スプラッシュ画面のみのスクリーンショットは不可
- ⚠️ 空の画面やログイン画面のみも不可
- ✅ 実際の機能を示す画面であること

詳細: `app/screenshots/README.md` を参照

---

### 2. Cloudflare Pagesへのデプロイ 🎯 優先度: 高

#### 手順

**ステップ1: 既存のCloudflare Pagesプロジェクトに追加**

既に `first-steps` で使用しているCloudflare Pagesプロジェクトに、`triad-council` を追加します。

```bash
# 既存のCloudflare Pagesプロジェクトディレクトリに移動
cd /path/to/your-cloudflare-pages-project

# triad-councilディレクトリをコピー
cp -r /Users/yuyafujita/Desktop/workspaces/triad_meeting/cloudflare-pages/triad-council ./

# 変更をコミット
git add triad-council/
git commit -m "feat: 三賢会議のサポートページとプライバシーポリシーを追加"

# プッシュ
git push origin main
```

**ステップ2: 自動デプロイの確認**

Cloudflare Pagesが自動的にデプロイします（数分かかります）。

**ステップ3: 公開URLの確認**

デプロイ完了後、以下のURLでアクセス可能になります:
- サポートページ: `https://marumi-works.com/triad-council/support/`
- プライバシーポリシー: `https://marumi-works.com/triad-council/privacy/`

**ステップ4: 動作確認**
- [ ] サポートページが正しく表示される
- [ ] プライバシーポリシーが正しく表示される
- [ ] リンクが機能する
- [ ] スマホ・タブレットでも正しく表示される

詳細: `cloudflare-pages/README.md` を参照

---

### 3. サポートメールアドレスの設定 🎯 優先度: 高

現在、ドキュメントには `support@sankenkaigi.com` を記載していますが、このメールアドレスを実際に使用可能にする必要があります。

#### オプション1: 独自ドメインのメール（推奨）
1. ドメイン `sankenkaigi.com` のメール機能を有効化
2. `support@sankenkaigi.com` アカウントを作成
3. メール受信を確認

#### オプション2: Gmail転送
1. Gmailアカウントを作成
2. ドメインのDNS設定でGmail用MXレコードを設定
3. 受信テスト

#### オプション3: 一時的な対応
HTMLファイルとアプリ内のメールアドレスを実際に使用するアドレスに変更:

```bash
# 以下のファイル内の support@sankenkaigi.com を置換
# - docs/index.html
# - docs/privacy.html
# - app/lib/screens/privacy_policy_screen.dart
```

---

### 4. App Store Connectの設定 🎯 優先度: 高

GitHub Pagesの公開とメールアドレスの設定が完了したら、App Store Connectで設定を行います。

#### 手順

1. **App Store Connect にログイン**
   - https://appstoreconnect.apple.com/

2. **アプリを選択**
   - 「マイApp」 > 「三賢会議」を選択

3. **App情報を編集**
   - 「App情報」タブをクリック

4. **サポートURLを設定**
   ```
   https://yuya-fujita-1201.github.io/triad_meeting/
   ```

5. **プライバシーポリシーURLを設定**
   ```
   https://yuya-fujita-1201.github.io/triad_meeting/privacy.html
   ```

6. **マーケティングURLを設定（オプション）**
   ```
   https://yuya-fujita-1201.github.io/triad_meeting/
   ```

7. **保存**

#### 確認事項
- [ ] 両URLがブラウザで正しく開ける
- [ ] 日本語が正しく表示される
- [ ] お問い合わせメールアドレスが機能している

---

### 5. App Store メタデータの設定 🎯 優先度: 中

以下の内容を App Store Connect で設定してください:

#### アプリ名
```
三賢会議
```

#### サブタイトル（30文字以内）
```
3人のAI賢者があなたの悩みを審議
```

#### プロモーションテキスト（170文字以内）
```
あなたの悩みを3人のAI賢者が審議。異なる視点からの意見を基に、最適な答えを導き出します。美しい羊皮紙デザインで、重厚な審議体験をお楽しみください。
```

#### 説明文
`APP_STORE_SUBMISSION_GUIDE.md` の「メタデータの正確性」セクションを参照してください。

#### キーワード（最大100文字）
```
AI,相談,アドバイス,決断,悩み,議論,審議,賢者,ChatGPT,人工知能
```

#### カテゴリ
- プライマリカテゴリ: **ライフスタイル** または **仕事効率化**
- セカンダリカテゴリ: **ユーティリティ** または **教育**

#### 年齢制限
- **4+** (全年齢対象)

---

## 🚨 審査で指摘されないための重要ポイント

### Guideline 2.3.3 - スクリーンショット
❌ **避けるべき**
- スプラッシュ画面のみのスクリーンショット
- ログイン画面のみ
- 空の画面

✅ **推奨**
- 実際の機能を示す画面
- ホーム、審議、決議書、履歴などの画面
- 各デバイスで最低3枚以上

### Guideline 2.3 - メタデータの正確性
❌ **避けるべき**
- 実装されていない機能の記載（"Pro版"など）
- 将来実装予定の機能の言及
- メタデータと実装の不一致

✅ **推奨**
- 現在実装されている機能のみ記載
- 実際の動作を正確に説明
- スクリーンショットと説明の一致

### Guideline 1.5 - サポートURL
❌ **避けるべき**
- GitHubリポジトリURL
- 404エラーになるページ
- サポート情報がないページ

✅ **推奨**
- 機能的なサポートページ
- FAQ、お問い合わせ情報を含む
- プライバシーポリシーへのリンク

---

## 📝 最終確認チェックリスト

### 提出前の必須確認
- [ ] スクリーンショットを全デバイス分撮影済み
- [ ] Cloudflare Pages が正しく公開されている
- [ ] サポートメールアドレスが機能している
- [ ] App Store Connect のサポートURLとプライバシーポリシーURLが設定済み
- [ ] アプリ内のプライバシーポリシーが更新されている
- [ ] メタデータに実装されていない機能が記載されていない
- [ ] TestFlightでアプリが正常動作することを確認済み

### アプリの動作確認
- [ ] ホーム画面でテーマを入力できる
- [ ] 審議が正常に実行される
- [ ] 決議書が正しく表示される
- [ ] 履歴が保存・表示される
- [ ] 決議書の共有機能が動作する
- [ ] 設定画面が正しく表示される
- [ ] プライバシーポリシー画面が更新されている

### ドキュメントの確認
- [ ] サポートページにFAQが記載されている
- [ ] お問い合わせ方法が明記されている
- [ ] プライバシーポリシーにデータ収集の詳細が記載されている
- [ ] OpenAI、Firebase、AdMobの使用について説明している
- [ ] ユーザーの権利（削除権など）が明記されている

---

## 📞 審査で問題が発生した場合の対応

### App Reviewから連絡が来たら

1. **Resolution Center で返信**
   - App Store Connect > Resolution Center

2. **具体的に説明**
   - 機能の場所を明記
   - スクリーンショットを添付
   - 必要に応じて動画を提供

3. **よくある質問への回答例**

**Q: "Pro機能が見つかりません"**
```
本アプリ Phase 1 では Pro版機能は実装していません。
説明文とスクリーンショットから Pro版への言及を削除しました。
現在のバージョンでは、全機能を無料でご利用いただけます。
```

**Q: "サポートURLにアクセスできません"**
```
サポートページは以下URLで公開しています:
https://marumi-works.com/triad-council/support/

お問い合わせは support@sankenkaigi.com までお願いします。
```

**Q: "スクリーンショットがスプラッシュ画面のみです"**
```
新しいスクリーンショットをアップロードしました。
ホーム画面、審議画面、決議書画面、履歴画面など、
実際のアプリ機能を示しています。
```

---

## 📚 参考ドキュメント

プロジェクト内のドキュメント:
- [APP_STORE_SUBMISSION_GUIDE.md](./APP_STORE_SUBMISSION_GUIDE.md) - 詳細な審査ガイド
- [SUPPORT.md](./SUPPORT.md) - サポートページのMarkdown版
- [PRIVACY_POLICY.md](./PRIVACY_POLICY.md) - プライバシーポリシーのMarkdown版
- [cloudflare-pages/README.md](./cloudflare-pages/README.md) - Cloudflare Pages デプロイガイド
- [app/screenshots/README.md](./app/screenshots/README.md) - スクリーンショット撮影ガイド

Appleの公式ドキュメント:
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect ヘルプ](https://help.apple.com/app-store-connect/)
- [スクリーンショット仕様](https://help.apple.com/app-store-connect/#/devd274dd925)

---

## ✨ 対応完了後

全ての対応が完了したら、以下の手順でApp Storeに提出してください:

1. **最終ビルドの作成**
   ```bash
   cd app
   flutter build ios --release
   ```

2. **Xcodeでアーカイブ**
   - Xcode > Product > Archive
   - Organizer > Distribute App

3. **TestFlightで確認**
   - TestFlightでアプリをテスト
   - 全機能が正常動作することを確認

4. **App Store Connect で審査に提出**
   - バージョン情報を入力
   - ビルドを選択
   - メタデータを確認
   - 「審査に提出」をクリック

5. **審査結果を待つ**
   - 通常24-48時間で初回レビュー
   - 問題があれば Resolution Center で連絡が来る

---

**作成日**: 2026-01-31
**最終更新**: 2026-01-31

質問や問題があれば、このチェックリストと各ドキュメントを参照してください。
