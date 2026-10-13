#!/bin/bash
# Swift Package をビルドし、ダブルクリックで起動できる .app バンドルにまとめる。
# 使い方: ./scripts/build-app.sh  →  build/StageManagerGuide.app
set -euo pipefail

cd "$(dirname "$0")/.."
APP_NAME="StageManagerGuide"
DISPLAY_NAME="StageManager診断ガイド"
BUNDLE_ID="local.hijiri.StageManagerGuide"
VERSION="0.1.0"

swift build -c release

BIN_DIR="$(swift build -c release --show-bin-path)"
APP_DIR="build/${APP_NAME}.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BIN_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>${DISPLAY_NAME}</string>
    <key>CFBundleDisplayName</key><string>${DISPLAY_NAME}</string>
    <key>CFBundleExecutable</key><string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>${VERSION}</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleDevelopmentRegion</key><string>ja</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.utilities</string>
    <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# 自分のMacで使うためのアドホック署名
codesign --force --sign - "$APP_DIR"

echo "✅ 作成しました: $APP_DIR"
echo "   /Applications へコピーするには: cp -R \"$APP_DIR\" /Applications/"
