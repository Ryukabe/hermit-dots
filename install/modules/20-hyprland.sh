#!/usr/bin/env bash
# DESC: Hyprland, lock/idle, clipboard, screenshots, wallpaper daemon, matugen
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

# Official repos
install_repo \
  hyprland hypridle hyprlock hyprpicker \
  wl-clipboard cliphist \
  pipewire wireplumber playerctl brightnessctl

# Resolved by the AUR helper (repo or AUR, whichever has them)
# NOTE: the wallpaper daemon was called swww and has been renamed awww.
#       Check which name your pacman/AUR actually has and edit below if needed.
install_aur hyprshot wlogout wl-clip-persist awww matugen

c_ok "Hyprland stack installed."
