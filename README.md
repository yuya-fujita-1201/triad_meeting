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
