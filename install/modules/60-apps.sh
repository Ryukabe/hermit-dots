#!/usr/bin/env bash
# DESC: Terminals, file managers, shells, and the apps used by the keybinds
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

# ask_install <repo|aur> "<what>" <packages...>
# Asks first; answering no skips the group. With --yes the default (yes) is used.
ask_install() {
  local kind="$1" label="$2"
  shift 2
  if ! confirm "Install $label ($*)?" Y; then
    c_info "Skipped $label."
    return 0
  fi
  if [[ "$kind" == aur ]]; then install_aur "$@"; else install_repo "$@"; fi
}

# Configs for these exist in config/
ask_install repo "terminals" kitty alacritty
ask_install repo "file managers" thunar nautilus
ask_install repo "shells and editor" zsh fish neovim

# Used by the keybinds
ask_install aur "browsers" zen-browser-bin helium-browser-bin
ask_install aur "VS Code" code
ask_install aur "Obsidian" obsidian
ask_install aur "Spotify" spotify

c_ok "Apps done."