#!/usr/bin/env bash
set -euo pipefail

log() { echo "[tailscale-install] $*"; }

if command -v tailscale >/dev/null 2>&1; then
  log "Tailscale уже установлен: $(tailscale version | head -n1)"
  exit 0
fi

if [[ -f /etc/os-release ]]; then
  . /etc/os-release
else
  log "Не удалось определить дистрибутив (нет /etc/os-release). См. https://tailscale.com/download"
  exit 1
fi

case "${ID_LIKE:-$ID}" in
  *debian*|*ubuntu*)
    curl -fsSL https://tailscale.com/install.sh | sh
    ;;
  *fedora*|*rhel*|*centos*)
    curl -fsSL https://tailscale.com/install.sh | sh
    ;;
  *arch*)
    sudo pacman -Sy --noconfirm tailscale
    ;;
  *)
    log "Неизвестный дистрибутив (${ID:-unknown}). См. https://tailscale.com/download"
    exit 1
    ;;
esac

log "Готово: $(tailscale version | head -n1)"