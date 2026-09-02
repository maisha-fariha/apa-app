#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Deploying Firebase Hosting + Firestore rules for ansanm-pou-ayiti..."
echo ""
echo "Prerequisites:"
echo "  1. Firestore enabled in Firebase Console (Build → Firestore → Create database)"
echo "  2. firebase login (if not already authenticated)"
echo ""

firebase deploy --project ansanm-pou-ayiti --only hosting,firestore:rules

echo ""
echo "Public URLs (use in Google Play Console):"
echo "  Privacy policy:  https://ansanm-pou-ayiti.web.app/privacy-policy"
echo "  Data deletion:   https://ansanm-pou-ayiti.web.app/data-deletion"
