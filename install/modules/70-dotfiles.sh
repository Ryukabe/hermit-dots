#!/usr/bin/env bash
# DESC: Link (or copy) config/* into ~/.config, backing up anything that exists
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

[[ -d "$CONFIG_SRC" ]] || { c_err "No config/ folder at $CONFIG_SRC"; exit 1; }
mkdir -p "$CONFIG_DST"

choose_shells

shopt -s dotglob nullglob
for src in "$CONFIG_SRC"/*; do
  name="$(basename "$src")"
  dst="$CONFIG_DST/$name"

  # Skip the config of a shell that was not selected
  if [[ "$name" == "quickshell" ]] && ! want_shell qs;  then c_info "Skipping quickshell config (not selected)."; continue; fi
  if [[ "$name" == "ags" ]]        && ! want_shell ags; then c_info "Skipping ags config (not selected)."; continue; fi

  if [[ "$USE_COPY" == true ]]; then
    if [[ -e "$dst" || -L "$dst" ]]; then backup_path "$dst"; fi
    cp -a "$src" "$dst"
    c_ok "Copied $name"
    continue
  fi

  # Already linked to this repo? Nothing to do.
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    c_ok "$name already linked."
    continue
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then backup_path "$dst"; fi
  ln -s "$src" "$dst"
  c_ok "Linked $name -> $src"
done

# The binds call these scripts directly, so make sure they are executable.
chmod +x "$CONFIG_DST"/hypr/scripts/*.sh "$CONFIG_DST/ags/ags-launch-kill.sh" \
  "$CONFIG_DST/wlogout/scripts/wlogout.sh" 2>/dev/null || true

# Single-shell install: tell hypr which shell to use. (.active-shell is gitignored.)
if [[ "$HERMIT_SHELLS" != both && -d "$CONFIG_DST/hypr" ]]; then
  echo "$HERMIT_SHELLS" > "$CONFIG_DST/hypr/.active-shell"
  c_ok "Set hypr/.active-shell to: $HERMIT_SHELLS"
fi

mode=symlink; [[ "$USE_COPY" == true ]] && mode=copy
c_ok "Dotfiles in place (mode: $mode)."
