#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

zsh scripts/build_release.sh >/dev/null

APP_PATH="/tmp/EchoGateDerived/Build/Products/Release/EchoGate.app"
DEST="/Applications/EchoGate.app"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing build output: $APP_PATH" 1>&2
  exit 1
fi

echo "Installing to $DEST ..."
ditto "$APP_PATH" "$DEST"
echo "Installed: $DEST"

