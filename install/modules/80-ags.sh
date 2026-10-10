#!/usr/bin/env bash
# DESC: AGS (Aylur's GTK Shell) + Astal libraries, then npm install in ~/.config/ags
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

choose_shells
if ! want_shell ags; then
  c_info "AGS not selected, skipping."
  exit 0
fi

# Official repos. dart-sass compiles .scss; ttf-material-symbols-variable
# is installed by the fonts module.
install_repo \
  gjs gtk4 gtk4-layer-shell \
  nodejs npm dart-sass \
  networkmanager iwd \
  bluez bluez-utils upower \
  vala polkit json-glib \
  wireplumber pipewire brightnessctl playerctl

# AGS + only the Astal libraries the widgets use:
#   Workspaces -> hyprland | Media -> mpris | Wi-Fi -> network
#   Volume -> wireplumber | Battery -> battery
#   Notifications -> notifd | Bluetooth toggle -> bluetooth
install_aur \
  aylurs-gtk-shell-git \
  libastal-io-git libastal-hyprland-git libastal-network-git \
  libastal-wireplumber-git libastal-battery-git libastal-mpris-git \
  libastal-notifd-git libastal-bluetooth-git

# Needs the dotfiles module to have run first (that's why this is last).
AGS_DIR="$CONFIG_DST/ags"
if [[ -f "$AGS_DIR/package.json" ]]; then
  c_info "Running npm install in $AGS_DIR ..."
  (cd "$AGS_DIR" && npm install)
  c_ok "npm install done."
else
  c_warn "No package.json in $AGS_DIR (run the dotfiles module first if you expected one)."
fi
[[ -f "$AGS_DIR/reload.sh" ]] && chmod +x "$AGS_DIR/reload.sh"
c_ok "AGS ready."
