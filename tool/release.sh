#!/usr/bin/env bash
# Publishes the APKs already built in build/app/outputs/flutter-apk as a GitHub Release.
# The website download buttons point to .../releases/latest/download/<fixed name>, so every new
# release automatically becomes the download — no website edit needed.
#
# Usage:  bash tool/release.sh tool/release-notes/v1.7.1.md
# Notes file format: English part, then a line "<!-- ar -->", then the Arabic part.
# Build first:  flutter build apk --release && flutter build apk --release --split-per-abi
set -euo pipefail
cd "$(dirname "$0")/.."

NOTES="${1:?notes file required}"
VERSION=$(grep -m1 '^version:' pubspec.yaml | sed -E 's/version: *([0-9.]+).*/\1/')
TAG="v$VERSION"
OUT=build/app/outputs/flutter-apk
STAGE=build/release
GH="${GH:-gh}"
command -v "$GH" >/dev/null 2>&1 || GH="/c/Program Files/GitHub CLI/gh.exe"

for f in app-arm64-v8a-release.apk app-armeabi-v7a-release.apk app-release.apk; do
  [ -f "$OUT/$f" ] || { echo "missing $OUT/$f — build the APKs first"; exit 1; }
done
# Refuse to publish APKs older than the version bump (stale build).
if [ "$OUT/app-release.apk" -ot pubspec.yaml ]; then echo "APKs are older than pubspec.yaml — rebuild first"; exit 1; fi

rm -rf "$STAGE" && mkdir -p "$STAGE"
cp "$OUT/app-arm64-v8a-release.apk" "$STAGE/fit-companion-arm64.apk"
cp "$OUT/app-armeabi-v7a-release.apk" "$STAGE/fit-companion-armv7.apk"
cp "$OUT/app-release.apk" "$STAGE/fit-companion-universal.apk"

"$GH" release create "$TAG" \
  "$STAGE/fit-companion-arm64.apk" "$STAGE/fit-companion-armv7.apk" "$STAGE/fit-companion-universal.apk" \
  --title "Fit Companion $VERSION" --notes-file "$NOTES" --latest
echo "Published $TAG → https://github.com/MahdiHaf2410/fit-companion/releases/tag/$TAG"
