#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE_PATH="${1:-$PROJECT_ROOT/artifacts/NYXWalletApp.xcarchive}"
METHOD="${METHOD:-app-store-connect}"
TEAM_ID="${TEAM_ID:-}"

if [[ -z "$TEAM_ID" ]]; then
  echo "TEAM_ID is required for signing."
  exit 1
fi

echo "Archiving..."
TEAM_ID="$TEAM_ID" "$PROJECT_ROOT/scripts/archive.sh" "$ARCHIVE_PATH"

echo "Exporting IPA..."
TEAM_ID="$TEAM_ID" METHOD="$METHOD" "$PROJECT_ROOT/scripts/export_ipa.sh" "$ARCHIVE_PATH"

echo "Done. IPA available under: $PROJECT_ROOT/artifacts"
