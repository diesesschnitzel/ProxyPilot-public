#!/bin/bash
set -e

REPO="diesesschnitzel/EchoGate"
APP_NAME="EchoGate"
INSTALL_DIR="/Applications"
TMP_DMG="/tmp/EchoGate-$$.dmg"

echo "Installing ${APP_NAME}..."

# Get latest release DMG URL
DMG_URL=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
  | grep "browser_download_url.*\.dmg" \
  | cut -d '"' -f 4)

if [ -z "$DMG_URL" ]; then
  echo "Error: could not find release DMG." >&2
  exit 1
fi

# Download
echo "Downloading ${APP_NAME}..."
curl -fsSL "$DMG_URL" -o "$TMP_DMG"

# Mount, copy, unmount
echo "Installing to ${INSTALL_DIR}..."
hdiutil attach "$TMP_DMG" -nobrowse -quiet
sleep 1
cp -R "/Volumes/${APP_NAME}/${APP_NAME}.app" "${INSTALL_DIR}/"
hdiutil detach "/Volumes/${APP_NAME}" -quiet
rm -f "$TMP_DMG"

# Remove quarantine flag so Gatekeeper doesn't block first launch
xattr -dr com.apple.quarantine "${INSTALL_DIR}/${APP_NAME}.app" 2>/dev/null || true

echo "${APP_NAME} installed. Open it from Applications."
