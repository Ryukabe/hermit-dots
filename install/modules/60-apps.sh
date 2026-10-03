#!/usr/bin/env bash
# DESC: Terminals, file managers, shells, and the apps used by the keybinds
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

# Core: configs for these exist in config/
install_repo kitty alacritty thunar nautilus neovim zsh fish

# Optional apps referenced in the keybinds
if confirm "Install optional apps (browsers, code, obsidian, spotify)?" Y; then
  install_aur zen-browser-bin helium-browser-bin code obsidian spotify
fi

c_ok "Apps done."
