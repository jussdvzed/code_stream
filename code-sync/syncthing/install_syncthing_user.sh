#!/usr/bin/env bash
set -euo pipefail

log() { echo "[syncthing-user-install] $*"; }

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
  linux|darwin) : ;;
  *) echo "Unsupported OS: $OS" >&2; exit 1;;
 esac

ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64) ARCH=amd64;;
  aarch64|arm64) ARCH=arm64;;
  armv7l|armv7) ARCH=arm;;
  *) echo "Unsupported arch: $ARCH" >&2; exit 1;;
 esac

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

log "Fetching latest Syncthing release asset for $OS/$ARCH..."
API_JSON=$(curl -fsSL https://api.github.com/repos/syncthing/syncthing/releases/latest)
ASSET_URL=""

if [[ "$OS" == "linux" ]]; then
  ASSET_URL=$(printf "%s" "$API_JSON" | grep browser_download_url | grep "linux-$ARCH" | grep -v "sha256" | grep ".tar.gz" | cut -d '"' -f 4 | head -n1)
else
  # macOS: prefer universal zip, fallback to arch-specific
  ASSET_URL=$(printf "%s" "$API_JSON" | grep browser_download_url | grep "macos-universal" | grep ".zip" | cut -d '"' -f 4 | head -n1)
  if [[ -z "$ASSET_URL" ]]; then
    ASSET_URL=$(printf "%s" "$API_JSON" | grep browser_download_url | grep "macos-$ARCH" | grep ".zip" | cut -d '"' -f 4 | head -n1)
  fi
fi

[[ -n "$ASSET_URL" ]] || { echo "Failed to determine latest release url for $OS/$ARCH" >&2; exit 1; }

TMP_FILE=$(mktemp)
curl -fsSL "$ASSET_URL" -o "$TMP_FILE"

TMP_DIR=$(mktemp -d)
if [[ "$ASSET_URL" == *.tar.gz ]]; then
  log "Extracting tar.gz..."
  tar -xzf "$TMP_FILE" -C "$TMP_DIR"
else
  log "Extracting zip..."
  if ! command -v unzip >/dev/null 2>&1; then
    echo "unzip is required to extract macOS archive" >&2
    exit 1
  fi
  unzip -q "$TMP_FILE" -d "$TMP_DIR"
fi

EXTRACTED_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "syncthing-*" | head -n1)
if [[ -z "$EXTRACTED_DIR" ]]; then
  # some archives place binary directly
  EXTRACTED_DIR="$TMP_DIR"
fi

if [[ ! -f "$EXTRACTED_DIR/syncthing" ]]; then
  # try to find binary anywhere inside
  CAND=$(find "$EXTRACTED_DIR" -type f -name syncthing | head -n1 || true)
  [[ -n "$CAND" ]] && EXTRACTED_DIR=$(dirname "$CAND") || {
    echo "syncthing binary not found in archive" >&2; exit 1; }
fi

install -m 0755 "$EXTRACTED_DIR/syncthing" "$BIN_DIR/syncthing"

# macOS Gatekeeper hint
if [[ "$OS" == "darwin" ]]; then
  xattr -d com.apple.quarantine "$BIN_DIR/syncthing" >/dev/null 2>&1 || true
fi

log "Installed: $("$BIN_DIR/syncthing" --version | head -n1)"
log "Binary: $BIN_DIR/syncthing"
log "Run: ~/.local/bin/syncthing -home ~/.config/syncthing"