#!/usr/bin/env bash
set -euo pipefail

# Usage: bash add_remote_on_work.sh <project-name> <tailscale-ip> [remote-name]
# Example: bash add_remote_on_work.sh myproject 100.101.102.103 origin

PROJECT_NAME=${1:-}
TAILSCALE_IP=${2:-}
REMOTE_NAME=${3:-origin}

if [[ -z "$PROJECT_NAME" || -z "$TAILSCALE_IP" ]]; then
  echo "Usage: bash $0 <project-name> <tailscale-ip> [remote-name]" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git не установлен" >&2
  exit 1
fi

if [[ ! -d .git ]]; then
  echo "Текущая директория не является Git-репозиторием. Запускаю git init..." >&2
  git init
fi

REMOTE_URL="ssh://git@${TAILSCALE_IP}/srv/git/${PROJECT_NAME}.git"

if git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
  echo "Remote $REMOTE_NAME уже существует. Обновляю URL..."
  git remote set-url "$REMOTE_NAME" "$REMOTE_URL"
else
  git remote add "$REMOTE_NAME" "$REMOTE_URL"
fi

echo "Remote $REMOTE_NAME => $REMOTE_URL"
echo "Первый пуш (если нет ветки main): git checkout -b main && git add . && git commit -m 'init' && git push -u $REMOTE_NAME main"