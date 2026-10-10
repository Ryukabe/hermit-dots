#!/usr/bin/env bash
# DESC: Symlink config/* into ~/.config, backing up anything that exists
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# The configs are symlinks into this repo, so it must live somewhere permanent.
case "$REPO_ROOT" in
  /tmp/*|/var/tmp/*)
    c_err "The configs link back into this repo, so it can't live in $REPO_ROOT."
    c_err "Clone it somewhere permanent, for example ~/hermit-dots."
    exit 1 ;;
esac

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

  # Already linked to this repo? Nothing to do.
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    c_ok "$name already linked."
    continue
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then backup_path "$dst"; fi
  ln -s "$src" "$dst"
  c_ok "Linked $name -> $src"
done

# Safety net: the binds call these scripts directly, so make sure every script is executable.
find "$CONFIG_SRC" -name '*.sh' -exec chmod +x {} +

# Single-shell install: tell hypr which shell to use. (.active-shell is gitignored.)
if [[ "$HERMIT_SHELLS" != both && -d "$CONFIG_DST/hypr" ]]; then
  echo "$HERMIT_SHELLS" > "$CONFIG_DST/hypr/.active-shell"
  c_ok "Set hypr/.active-shell to: $HERMIT_SHELLS"
fi

c_ok "Dotfiles linked."