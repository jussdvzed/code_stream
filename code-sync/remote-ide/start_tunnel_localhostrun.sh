#!/usr/bin/env bash
set -euo pipefail

PORT=${1:-8080}
log() { echo "[tunnel] $*"; }

if ! command -v ssh >/dev/null 2>&1; then
  echo "ssh клиент не найден. Установите OpenSSH client." >&2
  exit 1
fi

log "Открываю публичный URL через localhost.run для 127.0.0.1:$PORT"
log "Оставьте процесс запущенным для поддержания туннеля."

# -o ExitOnForwardFailure=yes ensures we fail if binding fails
# -N: no remote command; keep connection open
# Using 'nokey@localhost.run' per provider docs
ssh -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes -R 80:127.0.0.1:$PORT nokey@localhost.run -N