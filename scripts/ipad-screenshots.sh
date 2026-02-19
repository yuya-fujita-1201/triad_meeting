#!/bin/bash
# iPad Pro 13" (2048x2732) スクリーンショット撮影スクリプト
# 使い方: bash scripts/ipad-screenshots.sh
# 前提: Xcodeとシミュレータがインストール済み

set -e

PROJECT_DIR="$HOME/Desktop/workspaces/triad_meeting/app"
OUTPUT_DIR="$PROJECT_DIR/screenshots/ipad-13"
DEVICE_NAME="iPad Pro 13-inch (M4)"

echo "=== iPad Pro 13\" スクリーンショット撮影 ==="
echo "出力先: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# 利用可能なiPadデバイスを検索
echo ""
echo "利用可能なiPadデバイス:"
xcrun simctl list devices available | grep -i "ipad" | head -10

# デバイスを探す（M4 → M2 → 通常のiPad Pro）
DEVICE_ID=""
for name in "iPad Pro 13-inch (M4)" "iPad Pro (12.9-inch) (6th generation)" "iPad Pro 13-inch (M2)" "iPad Pro (12.9-inch)"; do
    DEVICE_ID=$(xcrun simctl list devices available | grep "$name" | grep -oE '[A-F0-9-]{36}' | head -1)
    if [ -n "$DEVICE_ID" ]; then
        DEVICE_NAME="$name"
        break
    fi
done

if [ -z "$DEVICE_ID" ]; then
    echo "❌ iPad Pro シミュレータが見つかりません"
    echo "Xcodeで iPad Pro 13\" シミュレータを追加してください"
    exit 1
fi

echo ""
echo "使用デバイス: $DEVICE_NAME ($DEVICE_ID)"

# シミュレータを起動
echo "シミュレータを起動中..."
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
sleep 3

# Simulatorアプリを前面に
open -a Simulator

# アプリをビルド＆インストール
echo "アプリをビルド中（iPad シミュレータ向け）..."
cd "$PROJECT_DIR"
flutter run -d "$DEVICE_ID" --release &
FLUTTER_PID=$!

echo ""
echo "=========================================="
echo "  アプリが起動したら、以下の画面で"
echo "  手動でスクリーンショットを撮ってください："
echo ""
echo "  1. ホーム画面（三賢会議トップ）"
echo "  2. 審議画面（ラウンド表示）"
echo "  3. 決議書画面"
echo "  4. 設定画面"
echo ""
echo "  撮影コマンド（別ターミナルで実行）:"
echo "  xcrun simctl io $DEVICE_ID screenshot $OUTPUT_DIR/01_home.png"
echo "  xcrun simctl io $DEVICE_ID screenshot $OUTPUT_DIR/02_deliberation.png"
echo "  xcrun simctl io $DEVICE_ID screenshot $OUTPUT_DIR/03_resolution.png"
echo "  xcrun simctl io $DEVICE_ID screenshot $OUTPUT_DIR/04_settings.png"
echo "=========================================="
echo ""
echo "全画面撮影後、Ctrl+C で終了してください"

# flutterプロセスを待つ
wait $FLUTTER_PID 2>/dev/null || true
