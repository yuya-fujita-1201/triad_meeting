#!/bin/bash
#
# build-pipeline.sh — 三賢会議 iOS ビルドパイプライン
# 中継サーバー（cowork-codex-relay）経由でMacのXcodeビルドを実行する
#
# 使い方:
#   bash scripts/build-pipeline.sh <ngrok-url>
#   bash scripts/build-pipeline.sh <ngrok-url> --project=snap_english  # SnapEnglish切り替え
#
# プロジェクト切り替え:
#   デフォルト: triad_meeting
#   --project=snap_english: SnapEnglish (ai-director-project)
#

set -euo pipefail

# ==================== 設定 ====================
NGROK_URL="${1:?Usage: $0 <ngrok-url> [--project=triad_meeting|snap_english]}"
AUTH_TOKEN="snap2026"

# プロジェクト設定（デフォルト: triad_meeting）
PROJECT="triad_meeting"
for arg in "$@"; do
  case $arg in
    --project=*)
      PROJECT="${arg#*=}"
      shift
      ;;
  esac
done

# プロジェクト別パス設定
case "$PROJECT" in
  triad_meeting)
    FLUTTER_PROJECT_PATH="$HOME/Projects/triad_meeting/app"
    XCODE_PROJECT_PATH="$HOME/Projects/triad_meeting/app/ios"
    SCHEME="Runner"
    BUNDLE_ID="com.sankenkaigi.app"
    APP_NAME="三賢会議"
    echo "🎯 プロジェクト: 三賢会議 (triad_meeting)"
    ;;
  snap_english)
    FLUTTER_PROJECT_PATH="$HOME/Projects/ai-director-project/app"
    XCODE_PROJECT_PATH="$HOME/Projects/ai-director-project/app/ios"
    SCHEME="Runner"
    BUNDLE_ID="com.snapenglish.app"
    APP_NAME="SnapEnglish"
    echo "🎯 プロジェクト: SnapEnglish (ai-director-project)"
    ;;
  *)
    echo "❌ 不明なプロジェクト: $PROJECT"
    echo "   使用可能: triad_meeting, snap_english"
    exit 1
    ;;
esac

# ==================== ヘルパー関数 ====================

relay_cmd() {
  local cmd="$1"
  local extra_args="${2:-}"

  local payload="{\"command\":\"$cmd\""
  if [ -n "$extra_args" ]; then
    payload="$payload,$extra_args"
  fi
  payload="$payload}"

  curl -s -X POST "$NGROK_URL/execute" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -H "ngrok-skip-browser-warning: true" \
    -d "$payload"
}

check_relay() {
  echo "📡 中継サーバー接続チェック..."
  local result
  result=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer $AUTH_TOKEN" \
    -H "ngrok-skip-browser-warning: true" \
    "$NGROK_URL/health" 2>/dev/null || echo "000")

  local http_code
  http_code=$(echo "$result" | tail -1)

  if [ "$http_code" = "200" ]; then
    echo "✅ 中継サーバー接続OK"
    return 0
  else
    echo "❌ 中継サーバーに接続できません (HTTP: $http_code)"
    echo "   Mac側で以下を実行してください:"
    echo "   bash ~/Projects/ai-director-project/scripts/relay-service.sh restart"
    echo "   bash ~/Projects/ai-director-project/scripts/relay-service.sh url"
    return 1
  fi
}

# ==================== メインパイプライン ====================

echo "================================================="
echo "  $APP_NAME — iOS ビルドパイプライン"
echo "  Bundle ID: $BUNDLE_ID"
echo "================================================="
echo ""

# Step 0: 接続チェック
check_relay || exit 1
echo ""

# Step 1: Flutter analyze
echo "🔍 Step 1/5: Flutter analyze..."
RESULT=$(relay_cmd "flutter_analyze" "\"project_path\":\"$FLUTTER_PROJECT_PATH\"")
echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('output','')[:500])" 2>/dev/null || echo "$RESULT"
echo ""

# Step 2: Flutter build ios --release
echo "🔨 Step 2/5: Flutter build iOS release..."
RESULT=$(relay_cmd "flutter_build_ios_release" "\"project_path\":\"$FLUTTER_PROJECT_PATH\"")
echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('output','')[-500:])" 2>/dev/null || echo "$RESULT"
echo ""

# Step 3: Xcode archive
echo "📦 Step 3/5: Xcode archive..."
RESULT=$(relay_cmd "xcode_archive" "\"project_path\":\"$XCODE_PROJECT_PATH\",\"scheme\":\"$SCHEME\"")
echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('output','')[-500:])" 2>/dev/null || echo "$RESULT"
echo ""

# Step 4: Export IPA
echo "📤 Step 4/5: Export IPA..."
RESULT=$(relay_cmd "xcode_archive_to_ipa" "\"project_path\":\"$XCODE_PROJECT_PATH\",\"scheme\":\"$SCHEME\"")
echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('output','')[-500:])" 2>/dev/null || echo "$RESULT"
echo ""

# Step 5: Upload to App Store Connect
echo "🚀 Step 5/5: App Store Connect にアップロード..."
RESULT=$(relay_cmd "xcrun_upload_app" "\"project_path\":\"$XCODE_PROJECT_PATH\"")
echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('output','')[-500:])" 2>/dev/null || echo "$RESULT"
echo ""

echo "================================================="
echo "  ✅ パイプライン完了!"
echo "  App Store Connectでビルドを確認してください"
echo "================================================="
