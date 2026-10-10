#!/usr/bin/env bash
# DESC: Symlink config/* and scripts/ into ~/.config, backing up anything that exists
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

SCRIPTS_SRC="$REPO_ROOT/scripts"

# Everything here is a symlink into this repo, so it must live somewhere permanent.
case "$REPO_ROOT" in
  /tmp/*|/var/tmp/*)
    c_err "The configs link back into this repo, so it can't live in $REPO_ROOT."
    c_err "Clone it somewhere permanent, for example ~/hermit-dots."
    exit 1 ;;
esac

[[ -d "$CONFIG_SRC" ]] || { c_err "No config/ folder at $CONFIG_SRC"; exit 1; }
mkdir -p "$CONFIG_DST"

choose_shells

# link_path <source> <destination> <label>
# Links destination -> source. Skips it if already correct; backs up whatever else is there.
link_path() {
  local src="$1" dst="$2" label="$3"
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    c_ok "$label already linked."
    return 0
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then backup_path "$dst"; fi
  ln -s "$src" "$dst"
  c_ok "Linked $label -> $src"
}

# ---- config/* -> ~/.config/* ------------------------------------------------
shopt -s dotglob nullglob
for src in "$CONFIG_SRC"/*; do
  name="$(basename "$src")"

  # Skip the config of a shell that was not selected
  if [[ "$name" == "quickshell" ]] && ! want_shell qs;  then c_info "Skipping quickshell config (not selected)."; continue; fi
  if [[ "$name" == "ags" ]]        && ! want_shell ags; then c_info "Skipping ags config (not selected)."; continue; fi

  link_path "$src" "$CONFIG_DST/$name" "$name"
done

# ---- scripts/ -> ~/.config/hermit/scripts ----------------------------------
# The binds call scripts through ~/.config/hermit/scripts, so the path never
# depends on where the repo was cloned.
if [[ -d "$SCRIPTS_SRC" ]]; then
  hermit_dir="$CONFIG_DST/hermit"
  # An old symlink here (from when scripts lived under config/hermit) would block mkdir.
  if [[ -L "$hermit_dir" ]]; then backup_path "$hermit_dir"; fi
  mkdir -p "$hermit_dir"
  link_path "$SCRIPTS_SRC" "$hermit_dir/scripts" "scripts"
fi

# ---- executable bits --------------------------------------------------------
# Safety net: the binds call these scripts directly, so make sure every script is executable.
find "$CONFIG_SRC" -name '*.sh' -exec chmod +x {} +
if [[ -d "$SCRIPTS_SRC" ]]; then
  find "$SCRIPTS_SRC" -name '*.sh' -exec chmod +x {} +
fi

# ---- single-shell install ---------------------------------------------------
# Tell hypr which shell to use. (.active-shell is gitignored.)
if [[ "$HERMIT_SHELLS" != both && -d "$CONFIG_DST/hypr" ]]; then
  echo "$HERMIT_SHELLS" > "$CONFIG_DST/hypr/.active-shell"
  c_ok "Set hypr/.active-shell to: $HERMIT_SHELLS"
fi

c_ok "Dotfiles linked."