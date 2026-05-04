#!/usr/bin/env bash
# Build a universal release .app and package it as a .dmg.
# Usage: scripts/build-dmg.sh <version>   e.g. scripts/build-dmg.sh 0.2.0
# Output: ./Ghostinote-<version>.dmg (gitignored)

set -euo pipefail

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Ghostinote"
APP_BUNDLE="$ROOT/build/$APP_NAME.app"
STAGING="$ROOT/build/dmg-staging"
DMG_OUT="$ROOT/$APP_NAME-$VERSION.dmg"

echo "▶ Building universal release binary..."
cd "$ROOT/app"
swift build -c release --arch arm64 --arch x86_64

echo "▶ Assembling .app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"
cp .build/apple/Products/Release/$APP_NAME "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>en</string>
    <key>CFBundleExecutable</key><string>$APP_NAME</string>
    <key>CFBundleIdentifier</key><string>dev.dimasdangga.$APP_NAME</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>$APP_NAME</string>
    <key>CFBundleDisplayName</key><string>$APP_NAME</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.productivity</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key><true/>
    <key>NSHumanReadableCopyright</key><string>Copyright © 2026 Dimas D. Angga. MIT License.</string>
</dict>
</plist>
PLIST
printf 'APPL????' > "$APP_BUNDLE/Contents/PkgInfo"

echo "▶ Packaging .dmg..."
rm -rf "$STAGING"
mkdir -p "$STAGING"
cp -R "$APP_BUNDLE" "$STAGING/"
ln -sf /Applications "$STAGING/Applications"

rm -f "$DMG_OUT"
hdiutil create -volname "$APP_NAME $VERSION" -srcfolder "$STAGING" -ov -format UDZO "$DMG_OUT"

echo "✔ $DMG_OUT"
ls -lh "$DMG_OUT"
