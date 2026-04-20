#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

DERIVED_DATA="/tmp/EchoGateDerived"

echo "Building Release to $DERIVED_DATA ..."
xcodebuild \
  -project EchoGate.xcodeproj \
  -scheme EchoGate-macOS \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA" \
  build \
  >/dev/null

APP_PATH="$DERIVED_DATA/Build/Products/Release/EchoGate.app"
echo "Built: $APP_PATH"

