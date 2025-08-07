#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo bash setup_home_git_server.sh <project-name>
# Example: sudo bash setup_home_git_server.sh myproject

PROJECT_NAME=${1:-}
if [[ -z "$PROJECT_NAME" ]]; then
  echo "Usage: sudo bash $0 <project-name>" >&2
  exit 1
fi

log() { echo "[git-home] $*"; }

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root: sudo bash $0 <project-name>" >&2
  exit 1
fi

command -v git >/dev/null 2>&1 || { log "Installing git"; apt-get update -y || true; apt-get install -y git || true; yum install -y git || true; dnf install -y git || true; }

# Create git system user without shell
if ! id git >/dev/null 2>&1; then
  log "Создаю пользователя git"
  useradd --system --create-home --shell /usr/bin/git-shell git || useradd --system --create-home --shell /usr/bin/nologin git || useradd --system --create-home git
fi

# Ensure git-shell exists for restricted access
if command -v git-shell >/dev/null 2>&1; then
  chsh -s "$(command -v git-shell)" git || true
fi

install -d -o git -g git /srv/git

REPO_PATH="/srv/git/${PROJECT_NAME}.git"
if [[ -d "$REPO_PATH" ]]; then
  log "Репозиторий уже существует: $REPO_PATH"
else
  log "Инициализирую bare репозиторий: $REPO_PATH"
  sudo -u git git init --bare "$REPO_PATH"
fi

# SSH key management
su - git -s /bin/bash -c '
  set -e
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519 <<<"" >/dev/null 2>&1 || true
  fi
  touch ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
'

PUBKEY_CONTENT=$(sudo -u git cat /home/git/.ssh/id_ed25519.pub)
log "Публичный ключ git-пользователя (добавьте на рабочем ПК в known hosts при первом подключении):"
echo "$PUBKEY_CONTENT"

log "Готово. Подключение с рабочего ПК (пример):"
echo "ssh://git@<TAILSCALE_IP_HOME>${REPO_PATH}"