#!/usr/bin/env bash
set -euo pipefail

log() { echo "[code-server-install] $*"; }

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
  linux|darwin) : ;; 
  *) echo "Unsupported OS: $OS" >&2; exit 1;;
 esac

ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64) ARCH=amd64;;
  aarch64|arm64) ARCH=arm64;;
  *) echo "Unsupported arch: $ARCH" >&2; exit 1;;
 esac

INSTALL_DIR="$HOME/.local/lib/code-server"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/code-server"
mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$CONFIG_DIR"

log "Fetching latest code-server release for $OS-$ARCH..."
ASSET_URL=$(curl -fsSL https://api.github.com/repos/coder/code-server/releases/latest |
  grep browser_download_url | grep "$OS-$ARCH.tar.gz" | cut -d '"' -f 4 | head -n1)
[[ -n "$ASSET_URL" ]] || { echo "Failed to determine latest release url for $OS-$ARCH" >&2; exit 1; }

TMP_TGZ=$(mktemp)
curl -fsSL "$ASSET_URL" -o "$TMP_TGZ"

log "Extracting..."
TMP_DIR=$(mktemp -d)
tar -xzf "$TMP_TGZ" -C "$TMP_DIR"
EXTRACTED_DIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "code-server-*" | head -n1)

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$EXTRACTED_DIR"/ "$INSTALL_DIR"/
else
  rm -rf "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  cp -R "$EXTRACTED_DIR"/* "$INSTALL_DIR"/
fi

ln -sf "$INSTALL_DIR/bin/code-server" "$BIN_DIR/code-server"

# Config with password
PASSWORD=${CODE_SERVER_PASSWORD:-}
if [[ -z "${PASSWORD}" ]]; then
  PASSWORD=$(head -c 24 /dev/urandom | base64 | tr -d '=+/ ' | cut -c1-20)
fi
cat > "$CONFIG_DIR/config.yaml" <<EOF
bind-addr: 127.0.0.1:8080
auth: password
password: $PASSWORD
cert: false
EOF

log "Installed: $($BIN_DIR/code-server --version | head -n1)"
log "Binary: $BIN_DIR/code-server"
log "Config: $CONFIG_DIR/config.yaml"
log "Password: $PASSWORD"
log "Run: $BIN_DIR/code-server"