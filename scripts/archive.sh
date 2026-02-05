#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$PROJECT_ROOT/NYXWalletApp.xcodeproj"
SCHEME="NYXWalletApp_iOS"
ARCHIVE_PATH="${1:-$PROJECT_ROOT/artifacts/NYXWalletApp.xcarchive}"
TEAM_ID="${TEAM_ID:-}"

XCODEBUILD=(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination 'generic/platform=iOS' archive -archivePath "$ARCHIVE_PATH")

if [[ -n "$TEAM_ID" ]]; then
  XCODEBUILD+=(DEVELOPMENT_TEAM="$TEAM_ID" CODE_SIGN_STYLE=Automatic -allowProvisioningUpdates)
else
  XCODEBUILD+=(CODE_SIGNING_ALLOWED=NO)
fi

"${XCODEBUILD[@]}"

echo "Archive created at: $ARCHIVE_PATH"
