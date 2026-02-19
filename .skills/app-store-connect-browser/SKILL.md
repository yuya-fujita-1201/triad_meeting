---
name: app-store-connect-browser
description: >
  App Store Connectをブラウザ（Claude in Chrome）で自動操作するためのノウハウ集。
  アプリ登録、Bundle ID作成、サブスクリプション商品設定、P8キー生成、価格設定などを含む。
  このスキルは以下のようなリクエストで必ず使用すること:
  - App Store Connectでアプリを登録したい
  - iOSサブスクリプション（課金）を設定したい
  - P8キー（In-App Purchase Key）を生成したい
  - App Store Connectで価格を設定したい
  - Bundle IDを登録したい
  App Store Connect、Apple Developer Portal、iOS課金設定に言及があれば必ずこのスキルを読むこと。
---

# App Store Connect ブラウザ自動操作スキル

App Store ConnectはReactベースのSPAで、標準的なブラウザ操作ツールだけでは入力がうまくいかない場面が多い。このスキルは実際のセットアップ経験から抽出した「確実に動く手順」と「回避策」をまとめたもの。

## 最重要テクニック: nativeInputValueSetter

App Store ConnectのフォームはReactで制御されており、`form_input`ツールや通常の`type`アクションでは値が反映されないことが頻繁にある。以下のJavaScriptパターンを使うこと。

```javascript
// テキスト入力の場合
const nativeInputValueSetter = Object.getOwnPropertyDescriptor(
  window.HTMLInputElement.prototype, 'value'
).set;
const input = document.getElementById('targetId');
// または: document.querySelector('input[name="..."]')
nativeInputValueSetter.call(input, '入力したい値');
input.dispatchEvent(new Event('input', { bubbles: true }));
input.dispatchEvent(new Event('change', { bubbles: true }));

// SELECT要素の場合
const selectSetter = Object.getOwnPropertyDescriptor(
  window.HTMLSelectElement.prototype, 'value'
).set;
const select = document.querySelector('select');
selectSetter.call(select, 'ja');
select.dispatchEvent(new Event('change', { bubbles: true }));
```

このパターンが必要な理由: Reactは内部stateで値を管理しているため、DOMを直接書き換えてもReactが変更を検知しない。`nativeInputValueSetter`でブラウザネイティブのsetterを呼び、その後`input`/`change`イベントを発火することで、Reactの合成イベントシステムを正しくトリガーする。

### いつこのテクニックを使うか

- `form_input`ツールで値をセットしたのにフィールドが空のままの場合
- `type`アクションで文字を打ったのに「必須項目です」エラーが出る場合
- ダイアログ内の入力フィールド全般（特にモーダルダイアログ）

### 入力フィールドの特定方法

App Store Connectのダイアログでは以下のIDパターンがよく使われる:
- `referenceName` — 参照名
- `productId` — プロダクトID
- `displayName` — 表示名
- `description` — 説明

IDがない場合はgetBoundingClientRect()で位置ベースで特定する:
```javascript
const inputs = dialog.querySelectorAll('input');
const results = [];
for (const input of inputs) {
  const rect = input.getBoundingClientRect();
  if (rect.width > 200 && rect.height > 20) {
    results.push({ top: rect.top, name: input.name, id: input.id, placeholder: input.placeholder });
  }
}
JSON.stringify(results);
```

---

## ワークフロー1: Bundle ID登録

**場所:** Apple Developer Portal → Certificates, Identifiers & Profiles → Identifiers

1. https://developer.apple.com/account/resources/identifiers/list にアクセス
2. 「+」ボタンをクリック（新規Identifier作成）
3. 「App IDs」を選択 → Continue
4. 「App」を選択 → Continue
5. Description と Bundle ID を入力
   - ここで`form_input`が失敗しやすい → **nativeInputValueSetterを使う**
6. 必要なCapabilities（例: In-App Purchase）にチェック
7. Continue → Register

**注意点:**
- Bundle IDは一度登録すると変更不可
- Explicit App ID（com.example.appname形式）を使うこと
- Wildcard（com.example.*）ではIn-App Purchaseが使えない

---

## ワークフロー2: アプリ登録

**場所:** App Store Connect → My Apps → 「+」

1. https://appstoreconnect.apple.com/apps にアクセス
2. 「新規App」をクリック
3. ダイアログで以下を入力:
   - プラットフォーム: iOS
   - 名前: アプリ名（**App Store上で一意である必要がある**）
   - プライマリ言語: 日本語
   - Bundle ID: 先に登録したものをドロップダウンから選択
   - SKU: 任意の識別子
4. 「作成」をクリック

**躓きポイント:**
- アプリ名がApp Store全体で重複するとエラーになる。その場合は「AI」「Pro」などを付加して再試行
- Bundle IDドロップダウンは登録後すぐに反映されないことがある。ページをリロードして再試行
- SKUは後から変更不可。シンプルな英数字（例: `snap_english`）を推奨

---

## ワークフロー3: P8キー生成（In-App Purchase Key）

**場所:** App Store Connect → ユーザとアクセス → 統合 → アプリ内課金

1. https://appstoreconnect.apple.com/access/integrations にアクセス
2. 左サイドバーまたはタブから「アプリ内課金」（In-App Purchase）を選択
3. 「アプリ内課金キーを生成」をクリック
4. キー名を入力（例: "SnapEnglish"） → **nativeInputValueSetterを使う可能性あり**
5. 「生成」をクリック
6. **P8ファイルをダウンロード** → **一度きりのダウンロード。二度とダウンロードできない**
7. 画面に表示される **Key ID** と **Issuer ID** をメモする

**重要な注意:**
- P8ファイルは生成直後にダウンロードすること。ページを離れると二度とダウンロードできない
- Key IDは「P7PDD4P69G」のような英数字10文字
- Issuer IDは「e359cd97-a6d4-4ef9-bcb3-24336fda0e74」のようなUUID形式
- ダウンロードボタンが見つからない場合は`find`ツールで「ダウンロード」「Download」を検索

**P8ファイルのブラウザ自動アップロードは不可:**
ブラウザのセキュリティ制約により、`<input type="file">`への自動ファイルセットはできない。ユーザーに手動でファイルを選択してもらう必要がある。`upload_image`ツールはスクリーンショット用であり、一般ファイルには使えない。

---

## ワークフロー4: サブスクリプション設定

**場所:** App Store Connect → アプリ → 収益化 → サブスクリプション

### Step 1: サブスクリプショングループ作成
1. アプリの「サブスクリプション」ページに移動（左サイドバー → 収益化 → サブスクリプション）
2. 「作成」ボタンをクリック
3. 「サブスクリプショングループを作成」ダイアログで参照名を入力
   - `form_input`が効かない → **nativeInputValueSetterで入力**
4. 「作成」をクリック

### Step 2: サブスクリプション商品作成
1. グループ内で「作成」をクリック
2. ダイアログで参照名とプロダクトIDを入力
   - `getElementById('referenceName')` と `getElementById('productId')` でアクセス可能
3. 「作成」をクリック

### Step 3: 期間を設定
1. 「サブスクリプション期間」ドロップダウンを探す
2. `form_input`ツールで「1か月」等を選択（これはSELECT要素なので通常動作する）

### Step 4: 価格を設定

**Appleの価格帯に関する重大な注意点:**
Appleは独自の標準価格帯（Tier）を使っている。日本円で設定可能な主な価格:
- ¥100, ¥200, ¥300, **¥400**, ¥500, ¥600, ¥800, ¥1,000, ¥1,200...
- **¥150, ¥250, ¥350, ¥380, ¥450 などの半端な価格は存在しない**
- 企画段階で「¥380」のような中間価格を想定していた場合、最寄りの価格帯に変更が必要
- 詳細は `references/apple_price_tiers.md` を参照

設定手順:
1. 「サブスクリプション価格を追加」をクリック
2. **基準となる国を選択**（デフォルトはアメリカ。日本向けなら「日本（JPY）」に変更）
   - 国の変更はドロップダウンから検索。検索欄も**nativeInputValueSetter**が必要な場合あり
3. 価格帯から選択（検索ボックスで絞り込み可能）
4. 「次へ」 → 他国の自動計算された価格を確認 → 「次へ」 → 「確認」

### Step 5: ローカリゼーション追加
1. 「ローカリゼーションを追加」をクリック
2. 言語（例: 日本語）を選択
3. 表示名と説明を入力 → **nativeInputValueSetterを使う**
   - `getElementById('displayName')` と `getElementById('description')` でアクセス
4. 「追加」をクリック

### Step 6: 保存
1. ページ上部の「保存」ボタンをクリック
2. 「✓ 保存」のトースト通知を確認

---

## クリック操作のコツ

App Store Connectではボタンのクリックが反応しないことがある。以下の順で試す:

1. **まず`find`ツール**で要素を特定してrefを取得 → refでクリック
2. `find`で見つからなければ`read_page`でアクセシビリティツリーを確認
3. 座標クリックは最後の手段（要素の位置が動的に変わるため不安定）

特にモーダルダイアログ内のボタンは座標ベースだと失敗しやすい。必ず`find`または`read_page`のrefを使うこと。

---

## ダイアログ操作の待ち時間

App Store Connectのダイアログはアニメーション付きで開く。操作直後にフォーム入力すると失敗する。

- ダイアログを開く操作の後に**1〜2秒の`wait`**を入れる
- スクリーンショットで描画完了を確認してから入力操作に進む
- 入力後もすぐに「作成」ボタンを押さず、`screenshot`で値が入っていることを確認する

---

## トラブルシューティング

| 症状 | 原因と対処 |
|---|---|
| 「このフィールドは必須です」 | `nativeInputValueSetter`で値をセットし直す。`input`と`change`の両イベントを発火 |
| ドロップダウン検索で「結果なし」 | 検索フィールドもReact制御。`nativeInputValueSetter`でクリア＆再入力 |
| ボタンクリックが反応しない | `find`ツールでrefを取得してrefベースでクリック |
| ページ遷移後に要素が見つからない | SPAのためDOM更新が遅れる。`wait`2秒 → `screenshot`で確認 |
| ファイルアップロードが空になる | ブラウザ制約。ユーザーに手動でファイル選択を依頼する |
