#!/usr/bin/env bash
# DESC: Fonts: Material Symbols + SF Pro / SF Serif / SF Mono
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

install_repo ttf-material-symbols-variable fontconfig

FONT_URL="https://github.com/thelioncape/San-Francisco-family.git"
FONTS=("SF Pro" "SF Serif" "SF Mono")
DEST="/usr/local/share/fonts/otf"

if fc-list | grep -qi "SF Pro"; then
  c_ok "SF Pro already installed, skipping."
  exit 0
fi

command -v git >/dev/null || { c_err "git is required."; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

c_info "Cloning San Francisco font family..."
git clone -n --depth=1 --filter=tree:0 "$FONT_URL" "$tmp/sf"
git -C "$tmp/sf" sparse-checkout set --no-cone "${FONTS[@]}"
git -C "$tmp/sf" checkout

c_info "Copying fonts to $DEST ..."
sudo mkdir -p "$DEST/sf-pro" "$DEST/sf-serif" "$DEST/sf-mono"
sudo cp "$tmp/sf/SF Pro/"*.otf   "$DEST/sf-pro/"
sudo cp "$tmp/sf/SF Serif/"*.otf "$DEST/sf-serif/"
sudo cp "$tmp/sf/SF Mono/"*.otf  "$DEST/sf-mono/"

sudo fc-cache -f
c_ok "Fonts installed and cache refreshed."
