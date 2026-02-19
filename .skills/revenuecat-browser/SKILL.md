---
name: revenuecat-browser
description: >
  RevenueCatダッシュボードをブラウザ（Claude in Chrome）で自動操作するためのノウハウ集。
  プロジェクト作成、Entitlement/Offering設定、Product Catalog管理、P8キーアップロードなどを含む。
  このスキルは以下のようなリクエストで必ず使用すること:
  - RevenueCatでプロジェクトを設定したい
  - RevenueCatにアプリ（iOS/Android）を追加したい
  - Entitlement、Offering、Packageを設定したい
  - RevenueCatのProduct Catalogに商品を追加したい
  - P8キーをRevenueCatにアップロードしたい
  - RevenueCatのAPIキーを取得したい
  RevenueCat、課金サービス設定、サブスクリプション管理ダッシュボードに言及があれば必ずこのスキルを読むこと。
---

# RevenueCat ブラウザ自動操作スキル

RevenueCatダッシュボード（app.revenuecat.com）はReactベースのSPAで、App Store Connectと同様にフォーム操作で特有の問題がある。このスキルは実際のセットアップ経験から「確実に動く手順」をまとめたもの。

## 前提: App Store Connectスキルとの併用

RevenueCatの設定にはApp Store Connect側の設定が先に必要なことが多い。以下の順番で作業すること:

1. **まずApp Store Connect側**でアプリ登録・サブスクリプション商品作成・P8キー生成を完了
2. **その後RevenueCat側**でプロジェクト作成・商品登録・Offering設定を行う

App Store Connect操作については `app-store-connect-browser` スキルを参照のこと。

---

## フォーム入力テクニック

RevenueCatダッシュボードもReactで構築されているため、App Store Connectと同様に`form_input`ツールが効かない場面がある。

### 標準的な入力フィールド
RevenueCatの通常のテキスト入力（プロジェクト名、商品IDなど）は**`form_input`ツールが動作する場合が多い**。まず`form_input`を試し、ダメなら以下のnativeInputValueSetterパターンを使う:

```javascript
const nativeInputValueSetter = Object.getOwnPropertyDescriptor(
  window.HTMLInputElement.prototype, 'value'
).set;
const input = document.querySelector('input[name="identifier"]');
nativeInputValueSetter.call(input, '入力値');
input.dispatchEvent(new Event('input', { bubbles: true }));
input.dispatchEvent(new Event('change', { bubbles: true }));
```

### DIVベースのドロップダウン（要注意）
RevenueCatでは一部のドロップダウンが`<select>`ではなく`<div>`で実装されている。このため:

- `form_input`を使うと「Element type DIV is not a supported form input」エラーになる
- **対処法**: ドロップダウンをクリックして開き、表示された選択肢を`find`ツールで検索してクリックする

```
例: Entitlementドロップダウン
1. ドロップダウン要素をクリック（開く）
2. find("premium") で選択肢のrefを取得
3. そのrefをクリック
```

---

## 全体セットアップの推奨順序

RevenueCatの初期設定は以下の順序で行うとスムーズ:

1. **プロジェクト作成**
2. **アプリ追加**（iOS App Store）
3. **APIキー取得**（テスト用）
4. **P8キー情報入力**（Key ID + Issuer ID + ファイルアップロード）
5. **Entitlement作成**（例: "premium"）
6. **Offering作成**（例: "default" + Monthly Package）
7. **Product作成**（App Store商品IDを紐付け）
8. **Product → Entitlement紐付け**
9. **Offering → Package → Product紐付け**

この順序を守る理由: 後のステップで前のステップで作成した要素を参照するため。例えばProductをOfferingに紐付けるには、先にProductとOfferingの両方が存在する必要がある。

---

## ワークフロー1: プロジェクト作成

**場所:** https://app.revenuecat.com → New Project

1. RevenueCatダッシュボードにログイン
2. 「+ New Project」をクリック
3. プロジェクト名を入力（例: "SnapEnglish"）
4. 「Create Project」をクリック

---

## ワークフロー2: アプリ追加（iOS）

**場所:** プロジェクト → Apps & providers → + New

1. サイドバーの「Apps & providers」をクリック
2. 「+ New」をクリック
3. 「Apple App Store」を選択
4. アプリ名とBundle IDを入力
5. 「Save Changes」をクリック

---

## ワークフロー3: APIキー取得

**場所:** プロジェクト → API keys

1. サイドバーの「API keys」をクリック
2. **テスト用APIキー**（`test_`で始まる）と**本番用APIキー**（`appl_`で始まる）が表示される
3. テスト段階では`test_`キーを使用する
4. コピーボタンでキーをコピー

**注意:** テストキーはSandbox環境でのみ動作する。App Store審査提出時は本番キーに切り替えること。

---

## ワークフロー4: P8キー情報の入力

**場所:** プロジェクト → Apps & providers → アプリ設定

P8キーの情報は3つの要素で構成される:
- **Key ID**: 英数字10文字（例: P7PDD4P69G）
- **Issuer ID**: UUID形式（例: e359cd97-a6d4-4ef9-bcb3-24336fda0e74）
- **P8ファイル**: .p8拡張子のファイル

設定手順:
1. Apps & providersからiOSアプリの設定を開く
2. 「App Store Connect API」セクションを探す
3. 「Issuer ID」と「Key ID」を入力
4. P8ファイルをアップロード

**P8ファイルアップロードの躓きポイント:**
- ブラウザ自動操作ではファイルの`<input type="file">`に直接ファイルをセットできない
- RevenueCatのUIでファイル名が表示されても、実際にはファイル内容がアップロードされていない場合がある
- **必ずユーザーに手動でP8ファイルを選択してもらうこと**
- アップロード後に`Save Changes`を押して、エラーが出ないことを確認する

確認方法（ファイルが実際にアップロードされたか）:
```javascript
const fileInputs = document.querySelectorAll('input[type="file"]');
const results = [];
fileInputs.forEach((input, i) => {
  results.push({
    index: i,
    files: input.files ? input.files.length : 0,
    fileName: input.files && input.files[0] ? input.files[0].name : 'none',
    fileSize: input.files && input.files[0] ? input.files[0].size : 0
  });
});
JSON.stringify(results);
// files: 0 なら未アップロード → ユーザーに手動選択を依頼
```

---

## ワークフロー5: Entitlement作成

**場所:** Product catalog → Entitlements タブ

1. Product catalogページの「Entitlements」タブをクリック
2. 「+ New」をクリック
3. Identifier（例: "premium"）を入力
4. 「Create」をクリック

Entitlementはアプリコード内の`CustomerInfo`で参照する識別子。一般的にはアプリ内で解除される機能単位で作成する（例: "premium", "pro", "ad_free"）。

---

## ワークフロー6: Offering + Package作成

**場所:** Product catalog → Offerings タブ

### Offering作成
1. 「+ New offering」をクリック
2. Identifier（例: "default"）と Display name を入力
3. 「Add」をクリック

### Package追加
1. 作成したOfferingを開く
2. 「Edit」をクリックして編集モードに入る
3. 「+ New Package」をクリック
4. パッケージタイプを選択（例: Monthly → `$rc_monthly`）
5. Description を入力（例: "Monthly"）

**"default" Offeringについて:** RevenueCatでは`default`というIDのOfferingが特別な意味を持つ。SDKの`getOfferings()`で最初に返されるOfferingになる。最低1つは`default` Offeringを作成すること。

---

## ワークフロー7: Product作成と紐付け

**場所:** Product catalog → Products タブ

### Product作成
1. 「Products」タブをクリック
2. アプリ横の「+ New」をクリック
3. **Identifier**: App Store Connectで作成した商品ID（例: `snap_english_monthly_380`）を正確に入力
4. **Display name**: 任意の表示名（例: "Monthly Premium ¥400"）
5. Product Type は「Subscription」が自動選択される
6. 「Create Product」をクリック

**重要: IdentifierはApp Store Connectの商品IDと完全一致させること。** 1文字でも違うとRevenueCatが商品を認識できない。

### Entitlement紐付け
1. 作成した商品のページを開く
2. 「Associated Entitlements」セクションの「Attach」をクリック
3. ドロップダウンからEntitlement（例: "premium"）を選択
   - このドロップダウンはDIV実装のため`form_input`は使えない
   - クリックして開き、`find`ツールで選択肢を探してクリックする
4. 「Attach」ボタンをクリック

### Offering → Package紐付け
1. Product catalogのOfferingsタブに戻る
2. 対象のOffering（例: "default"）を開く
3. 「Edit」をクリック
4. Packageセクションで、対象アプリのドロップダウンから商品を選択
   - ドロップダウンに登録済みの商品が表示される
   - `form_input`ツールまたはクリックで選択
5. 「Save」をクリック

---

## クリック操作のコツ

RevenueCatダッシュボードでもApp Store Connect同様、座標ベースのクリックが不安定なことがある。

1. **`find`ツールを優先的に使う**: ボタンやリンクは自然言語で検索してrefを取得
2. **`read_page`のinteractiveフィルター**: フォーム要素やボタンの一覧を取得するのに便利
3. **ドロップダウンの選択肢**: クリックで開いた後、`find`で選択肢テキストを検索

---

## トラブルシューティング

| 症状 | 原因と対処 |
|---|---|
| 「Element type DIV is not a supported form input」 | DIVベースのドロップダウン。クリックで開き`find`で選択肢をクリック |
| ProductがOfferingに表示されない | Productが先に作成されている必要がある。Products タブで存在を確認 |
| 「Both Apple's Subscription Key ID and Private Key must be provided」 | P8ファイルが実際にアップロードされていない。ユーザーに手動選択を依頼 |
| Entitlement紐付けボタンが反応しない | `find("Attach")`でrefを取得してrefベースでクリック |
| Save後に変更が反映されない | ページをリロードして確認。SPAのためUIが古い状態のことがある |
| ドロップダウンの選択肢が見えない | スクロール位置の問題。`scroll_to`で要素をビューポートに入れてから操作 |
