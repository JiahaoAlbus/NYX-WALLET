#!/usr/bin/env bash
set -euo pipefail

DEVICE_NAME="${1:-iPhone 16}"
OUT_DIR="${2:-$(pwd)/artifacts/screenshots}"

mkdir -p "$OUT_DIR"

echo "Booting simulator: $DEVICE_NAME"
xcrun simctl boot "$DEVICE_NAME" || true
xcrun simctl bootstatus "$DEVICE_NAME" -b

echo "Launching app (update bundle id if needed)..."
xcrun simctl launch "$DEVICE_NAME" com.nyx.wallet || true

echo "Capturing screenshot..."
xcrun simctl io "$DEVICE_NAME" screenshot "$OUT_DIR/nyxwallet-home.png"

echo "Screenshots saved to: $OUT_DIR"
