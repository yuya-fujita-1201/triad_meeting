---
name: app-store-connect-api
description: >
  App Store Connect APIをPythonから直接呼び出してアプリ管理を自動化するスキル。
  ブラウザ操作不要でスクリーンショットアップロード、ビルド管理、暗号化コンプライアンス設定、
  審査提出などを実行できる。
  このスキルは以下のようなリクエストで必ず使用すること:
  - スクリーンショットをApp Store Connectにアップロードしたい
  - ビルドの暗号化コンプライアンスをAPIで設定したい
  - App Store Connect APIでアプリ情報を取得・更新したい
  - 審査提出を自動化したい
  - App Store Connectへのアップロード・提出を全自動で行いたい
  ブラウザ操作ではなくAPI経由でApp Store Connectを操作する場合は必ずこのスキルを読むこと。
---

# App Store Connect API 自動化スキル

ブラウザ操作ではなくREST APIで直接App Store Connectを操作する。Cowork VM上のPythonから実行でき、ブラウザの制約（ファイルアップロード不可等）を回避できる。

## 認証情報

### 必要なもの
- **API Key ID**: `P26V6QTLTW`
- **Issuer ID**: `e359cd97-a6d4-4ef9-bcb3-24336fda0e74`
- **.p8 Private Key**: `.appstoreconnect/private_keys/AuthKey_P26V6QTLTW.p8`

### .p8キーの場所
プロジェクトルートの `.appstoreconnect/private_keys/` に保存済み。
`.gitignore` で除外されているためGitには含まれない。

---

## JWT トークン生成

```python
import jwt
import time

API_KEY_ID = "P26V6QTLTW"
ISSUER_ID = "e359cd97-a6d4-4ef9-bcb3-24336fda0e74"
P8_KEY_PATH = ".appstoreconnect/private_keys/AuthKey_P26V6QTLTW.p8"

def generate_token():
    with open(P8_KEY_PATH, 'r') as f:
        private_key = f.read()
    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,  # 20分間有効
        "aud": "appstoreconnect-v1"
    }
    headers = {"alg": "ES256", "kid": API_KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
```

### 必要なPythonライブラリ
```bash
pip install PyJWT cryptography requests --break-system-packages
```

### APIリクエストのヘッダー
```python
headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}
```

---

## ワークフロー1: スクリーンショットアップロード

**最重要ワークフロー。** ブラウザのファイルピッカーを回避してAPI経由で直接アップロードできる。

### 手順

#### Step 1: バージョンID取得
```python
GET /v1/apps/{appId}/appStoreVersions
# filter[appStoreState]=PREPARE_FOR_SUBMISSION でインフライト版を取得
```

#### Step 2: ローカリゼーションID取得
```python
GET /v1/appStoreVersions/{versionId}/appStoreVersionLocalizations
# locale: "ja" の ID を取得
```

#### Step 3: 既存スクリーンショットセット確認
```python
GET /v1/appStoreVersionLocalizations/{localizationId}/appScreenshotSets
# screenshotDisplayType をチェック
```

#### Step 4: スクリーンショットセット作成（なければ）
```python
POST /v1/appScreenshotSets
{
  "data": {
    "type": "appScreenshotSets",
    "attributes": {
      "screenshotDisplayType": "APP_IPAD_PRO_3GEN_129"  # iPad 13"の場合
    },
    "relationships": {
      "appStoreVersionLocalization": {
        "data": {"type": "appStoreVersionLocalizations", "id": localization_id}
      }
    }
  }
}
```

#### Step 5: スクリーンショット枠予約
```python
POST /v1/appScreenshots
{
  "data": {
    "type": "appScreenshots",
    "attributes": {
      "fileName": "001_screenshot.png",
      "fileSize": 3424453
    },
    "relationships": {
      "appScreenshotSet": {
        "data": {"type": "appScreenshotSets", "id": set_id}
      }
    }
  }
}
# レスポンスに uploadOperations（アップロード先URL・オフセット・長さ）が含まれる
```

#### Step 6: 実ファイルアップロード
```python
for op in upload_operations:
    url = op["url"]
    offset = op["offset"]
    length = op["length"]
    headers = {h["name"]: h["value"] for h in op["requestHeaders"]}
    chunk = file_data[offset:offset + length]
    requests.put(url, headers=headers, data=chunk)
```

#### Step 7: アップロードコミット
```python
PATCH /v1/appScreenshots/{screenshotId}
{
  "data": {
    "type": "appScreenshots",
    "id": screenshot_id,
    "attributes": {
      "sourceFileChecksum": md5_hex,  # ファイルのMD5ハッシュ
      "uploaded": true
    }
  }
}
```

### screenshotDisplayType 一覧
| デバイス | タイプ値 | 推奨サイズ(px) |
|---|---|---|
| iPhone 5.5" | APP_IPHONE_55 | 1242×2208 |
| iPhone 6.5" | APP_IPHONE_65 | 1284×2778 |
| iPhone 6.7" | APP_IPHONE_67 | 1290×2796 |
| iPhone 6.9" | APP_IPHONE_69 | 1320×2868 |
| iPad Pro 12.9" (3rd gen) / 13" | APP_IPAD_PRO_3GEN_129 | 2064×2752 |
| iPad Pro 11" | APP_IPAD_PRO_3GEN_11 | 1668×2388 |

---

## ワークフロー2: 暗号化コンプライアンス設定

### ビルドIDの取得
```python
GET /v1/builds?filter[app]={appId}&filter[version]={buildNumber}
```

### コンプライアンス設定
```python
# ビルド詳細からbetaBuildLocalizationsを取得して更新
# または直接ビルドに対して設定:
PATCH /v1/builds/{buildId}
{
  "data": {
    "type": "builds",
    "id": build_id,
    "attributes": {
      "usesNonExemptEncryption": false
    }
  }
}
```

**注意:** この設定はTestFlight用。App Store Connectのバージョン提出時の暗号化コンプライアンスは別途UIまたは別APIエンドポイントで設定する必要がある場合がある。

---

## ワークフロー3: 審査提出（API経由）

### App Store Version の審査提出
```python
# Step 1: Review Submission 作成
POST /v1/reviewSubmissions
{
  "data": {
    "type": "reviewSubmissions",
    "attributes": {
      "platform": "IOS"
    },
    "relationships": {
      "app": {
        "data": {"type": "apps", "id": app_id}
      }
    }
  }
}

# Step 2: 提出アイテム追加
POST /v1/reviewSubmissionItems
{
  "data": {
    "type": "reviewSubmissionItems",
    "relationships": {
      "reviewSubmission": {
        "data": {"type": "reviewSubmissions", "id": submission_id}
      },
      "appStoreVersion": {
        "data": {"type": "appStoreVersions", "id": version_id}
      }
    }
  }
}

# Step 3: 審査提出確定
PATCH /v1/reviewSubmissions/{submissionId}
{
  "data": {
    "type": "reviewSubmissions",
    "id": submission_id,
    "attributes": {
      "submitted": true
    }
  }
}
```

---

## ワークフロー4: ビルド管理

### アプリの全ビルド一覧
```python
GET /v1/builds?filter[app]={appId}&sort=-uploadedDate&limit=10
```

### 特定バージョンへのビルド紐付け
```python
PATCH /v1/appStoreVersions/{versionId}/relationships/build
{
  "data": {
    "type": "builds",
    "id": build_id
  }
}
```

---

## 完全自動化スクリプト（参考実装）

プロジェクトルートに `scripts/upload_screenshots.py` として保存推奨。

```python
#!/usr/bin/env python3
"""Upload screenshots to App Store Connect via API.

Usage:
    python3 scripts/upload_screenshots.py --device ipad-13 --dir app/screenshots/ipad-13
    python3 scripts/upload_screenshots.py --device iphone-6.9 --dir app/screenshots/iphone-6.9
"""
# 実装は upload_ipad_screenshots.py を参照
```

---

## トラブルシューティング

| 症状 | 原因と対処 |
|---|---|
| 401 Unauthorized | JWT有効期限切れ。新しいトークンを生成 |
| 409 Conflict（screenshotSet作成時） | 同じdisplayTypeのセットが既に存在。既存のsetを使用する |
| screenshotのcommitで400 Bad Request | MD5チェックサムが不一致。ファイル全体のMD5を正しく計算しているか確認 |
| uploadOperationsのURLが期限切れ | 予約から実アップロードまでに時間がかかりすぎ。再度reserveからやり直す |
| ビルドが「処理中」で使えない | Appleの処理が完了するまで5-10分待つ |

---

## API リファレンス

- ベースURL: `https://api.appstoreconnect.apple.com`
- ドキュメント: https://developer.apple.com/documentation/appstoreconnectapi
- Rate Limit: 1時間あたり3600リクエスト
