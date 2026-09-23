#!/usr/bin/env bash
# Build a signed iOS IPA for App Store Connect upload.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "Cleaning..."
flutter clean
flutter pub get
cd ios
pod install
cd ..

echo "Archiving (this bypasses Xcode UI module-index issues)..."
flutter build ipa --release

echo ""
echo "IPA (if codesigning succeeded):"
echo "  build/ios/ipa/*.ipa"
echo "Archive:"
echo "  build/ios/archive/Runner.xcarchive"
echo ""
echo "Upload with Transporter or:"
echo "  xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa"
