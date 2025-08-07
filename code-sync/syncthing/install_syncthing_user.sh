#!/usr/bin/env bash
set -euo pipefail

log() { echo "[syncthing-user-install] $*"; }

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64) ARCH=amd64;;
  aarch64|arm64) ARCH=arm64;;
  armv7l|armv7) ARCH=arm;;
  *) echo "Unsupported arch: $ARCH" >&2; exit 1;;
 esac

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

log "Fetching latest Syncthing release..."
ASSET_URL=$(curl -fsSL https://api.github.com/repos/syncthing/syncthing/releases/latest |
  grep browser_download_url | grep "linux-$ARCH" | grep -v "sha256" | grep ".tar.gz" | cut -d '"' -f 4 | head -n1)
[[ -n "$ASSET_URL" ]] || { echo "Failed to determine latest release url" >&2; exit 1; }

TMP_TGZ=$(mktemp)
curl -fsSL "$ASSET_URL" -o "$TMP_TGZ"

log "Extracting..."
TMP_DIR=$(mktemp -d)
tar -xzf "$TMP_TGZ" -C "$TMP_DIR"
EXTRACTED_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "syncthing-*" | head -n1)
install -m 0755 "$EXTRACTED_DIR/syncthing" "$BIN_DIR/syncthing"

log "Installed: $("$BIN_DIR/syncthing" --version | head -n1)"
log "Binary: $BIN_DIR/syncthing"
log "Run: ~/.local/bin/syncthing -home ~/.config/syncthing"