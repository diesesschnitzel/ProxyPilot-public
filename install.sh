#!/bin/bash
set -e

REPO="diesesschnitzel/ProxyPilot-public"
APP_NAME="EchoGate"
INSTALL_DIR="/Applications"

echo "Installing ${APP_NAME}..."

# Get latest release download URL
DMG_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep "browser_download_url.*\.dmg" \
  | cut -d '"' -f 4)

if [ -z "$DMG_URL" ]; then
  echo "Error: could not find release DMG." >&2
  exit 1
fi

TMP_DMG="/tmp/EchoGate-$$.dmg"
rm -f "$TMP_DMG"
echo "Downloading ${APP_NAME}..."
curl -fsSL "$DMG_URL" -o "$TMP_DMG"

echo "Installing to ${INSTALL_DIR}..."
hdiutil attach "$TMP_DMG" -nobrowse -quiet
cp -R "/Volumes/${APP_NAME}/${APP_NAME}.app" "${INSTALL_DIR}/"
hdiutil detach "/Volumes/${APP_NAME}" -quiet
rm "$TMP_DMG"

# Remove quarantine so Gatekeeper doesn't block first launch
xattr -dr com.apple.quarantine "${INSTALL_DIR}/${APP_NAME}.app" 2>/dev/null || true

echo "${APP_NAME} installed. Open it from Applications."
