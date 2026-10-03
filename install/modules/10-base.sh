#!/usr/bin/env bash
# DESC: System update, build tools, git, AUR helper (yay)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

if confirm "Run a full system update (pacman -Syu) first?" Y; then
  sudo pacman -Syu --noconfirm
fi

install_repo base-devel git wget unzip tar fontconfig
ensure_aur_helper
c_ok "Base ready (AUR helper: $AUR_HELPER)."
