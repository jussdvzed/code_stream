#!/usr/bin/env bash
set -euo pipefail

log() { echo "[syncthing-service] $*"; }

if ! command -v syncthing >/dev/null 2>&1; then
  log "Syncthing не найден. Сначала установите: syncthing/install_syncthing_linux.sh"
  exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
  log "systemd не найден. Запустите syncthing вручную: syncthing &"
  exit 0
fi

log "Включаю user-сервис..."
SYSTEMD_STATUS=0
systemctl --user enable syncthing.service || SYSTEMD_STATUS=$?
systemctl --user start syncthing.service || true

if [[ $SYSTEMD_STATUS -ne 0 ]]; then
  log "Возможно нужен пользовательский linger, включаю..."
  sudo loginctl enable-linger "$USER" || true
  systemctl --user enable syncthing.service || true
  systemctl --user start syncthing.service || true
fi

sleep 1
systemctl --user status syncthing.service --no-pager | sed -n '1,20p'
log "Web UI: http://127.0.0.1:8384"