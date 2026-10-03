#!/usr/bin/env bash
# DESC: Bibata-Modern-Ice cursor theme
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

ICON_DIR="$HOME/.local/share/icons"
mkdir -p "$ICON_DIR" "$HOME/.local/share/themes"

if [[ -d "$ICON_DIR/Bibata-Modern-Ice" ]]; then
  c_ok "Bibata-Modern-Ice already installed, skipping download."
else
  c_info "Downloading Bibata-Modern-Ice..."
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  wget -qO "$tmp/Bibata.tar.xz" \
    "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
  tar -xf "$tmp/Bibata.tar.xz" -C "$ICON_DIR"
  c_ok "Cursor installed."
fi

if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' \
    || c_warn "gsettings failed (no session bus?). Set the cursor after logging in."
else
  c_warn "gsettings not found, skipping cursor apply."
fi
