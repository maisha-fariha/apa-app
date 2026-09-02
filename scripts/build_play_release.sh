#!/usr/bin/env bash
# Build a signed Android App Bundle (.aab) for Google Play upload.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KEY_PROPS="$ROOT_DIR/android/key.properties"
KEYSTORE="$ROOT_DIR/android/app/upload-keystore.jks"

if [[ ! -f "$KEY_PROPS" ]]; then
  echo "Missing android/key.properties."
  echo "Copy android/key.properties.example and set your upload keystore values."
  exit 1
fi

if [[ ! -f "$KEYSTORE" ]]; then
  echo "Missing android/app/upload-keystore.jks."
  echo "Generate one with:"
  echo "  keytool -genkeypair -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload"
  exit 1
fi

cd "$ROOT_DIR"
flutter pub get
flutter build appbundle --release

echo ""
echo "Upload this file in Google Play Console:"
echo "  build/app/outputs/bundle/release/app-release.aab"
