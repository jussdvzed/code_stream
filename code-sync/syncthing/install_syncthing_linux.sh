#!/usr/bin/env bash
set -euo pipefail

log() { echo "[syncthing-install] $*"; }

if command -v syncthing >/dev/null 2>&1; then
  log "Syncthing уже установлен: $(syncthing --version | head -n1)"
  exit 0
fi

if [[ -f /etc/os-release ]]; then
  . /etc/os-release
else
  log "Не удалось определить дистрибутив (нет /etc/os-release). Попробуйте установить вручную: https://syncthing.net/"
  exit 1
fi

case "${ID_LIKE:-$ID}" in
  *debian*|*ubuntu*)
    log "Debian/Ubuntu: установка из официального репо"
    sudo apt-get update -y
    sudo apt-get install -y curl apt-transport-https gnupg lsb-release ca-certificates
    curl -fsSL https://syncthing.net/release-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/syncthing-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y syncthing
    ;;
  *fedora*|*rhel*|*centos*)
    log "Fedora/RHEL: установка через dnf/copr"
    if command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y syncthing
    else
      sudo yum install -y epel-release || true
      sudo yum install -y syncthing
    fi
    ;;
  *arch*)
    log "Arch: установка через pacman"
    sudo pacman -Sy --noconfirm syncthing
    ;;
  *)
    log "Неизвестный дистрибутив (${ID:-unknown}). Попробуйте универсальный установщик."
    bash <(curl -fsSL https://raw.githubusercontent.com/syncthing/syncthing/main/packaging/scripts/syncthing-install.sh)
    ;;
esac

log "Готово: $(syncthing --version | head -n1)"