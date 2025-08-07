#!/usr/bin/env bash
set -euo pipefail

BIN="$HOME/.local/bin/syncthing"
CONF_DIR="$HOME/.config/syncthing"
LOG_DIR="$HOME/.local/share/syncthing"
mkdir -p "$CONF_DIR" "$LOG_DIR"

if [[ ! -x "$BIN" ]]; then
  echo "Syncthing не найден в $BIN. Сначала запустите install_syncthing_user.sh" >&2
  exit 1
fi

LOG_FILE="$LOG_DIR/syncthing.log"
nohup "$BIN" -home "$CONF_DIR" >> "$LOG_FILE" 2>&1 &
PID=$!
echo "Syncthing запущен в фоне, PID=$PID, логи: $LOG_FILE"