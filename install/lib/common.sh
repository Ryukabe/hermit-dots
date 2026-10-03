#!/usr/bin/env bash
# Shared helpers for hermit-dots installer modules. Source this, don't run it.

INSTALL_DIR="${INSTALL_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
REPO_ROOT="$(cd "$INSTALL_DIR/.." && pwd)"
CONFIG_SRC="$REPO_ROOT/config"
CONFIG_DST="${XDG_CONFIG_HOME:-$HOME/.config}"
ASSUME_YES="${HERMIT_YES:-false}"   # set by install.sh --yes
USE_COPY="${HERMIT_COPY:-false}"    # set by install.sh --copy
AUR_HELPER="${AUR_HELPER:-}"

# ---- output ---------------------------------------------------------------
c_info() { printf '\033[1;34m[info]\033[0m %s\n' "$1"; }
c_ok()   { printf '\033[1;32m[ ok ]\033[0m %s\n' "$1"; }
c_warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$1"; }
c_err()  { printf '\033[1;31m[fail]\033[0m %s\n' "$1" >&2; }
c_step() { printf '\n\033[1;35m==> %s\033[0m\n' "$1"; }

# ---- checks ---------------------------------------------------------------
preflight() {
  if [[ "$EUID" -eq 0 ]]; then
    c_err "Don't run this as root. Run as your normal user; sudo is called where needed."
    exit 1
  fi
  if ! command -v pacman &>/dev/null; then
    c_err "pacman not found. This installer targets Arch Linux (or Arch-based distros)."
    exit 1
  fi
  sudo -v
}

# confirm "question" [Y|N]  -> returns 0 for yes. With --yes, the default answer is used.
confirm() {
  local prompt="$1" default="${2:-Y}" ans hint="Y/n"
  [[ "$default" =~ ^[Nn] ]] && hint="y/N"
  if [[ "$ASSUME_YES" == true ]]; then
    [[ "$default" =~ ^[Yy] ]]
    return
  fi
  read -rp "$prompt [$hint] " ans || true
  ans="${ans:-$default}"
  [[ "$ans" =~ ^[Yy] ]]
}

# ---- packages -------------------------------------------------------------
# Prints the names from "$@" that are not yet satisfied (installed or provided).
filter_missing() {
  local p
  for p in "$@"; do
    pacman -T "$p" >/dev/null 2>&1 || echo "$p"
  done
}

# Official repo packages via pacman.
install_repo() {
  local missing=()
  mapfile -t missing < <(filter_missing "$@")
  if [[ ${#missing[@]} -eq 0 ]]; then
    c_ok "Nothing new to install (repo)."
    return
  fi
  c_info "Installing (repo): ${missing[*]}"
  sudo pacman -S --needed --noconfirm "${missing[@]}"
}

ensure_aur_helper() {
  [[ -n "$AUR_HELPER" ]] && return
  if command -v yay &>/dev/null; then AUR_HELPER=yay; return; fi
  if command -v paru &>/dev/null; then AUR_HELPER=paru; return; fi

  c_info "No AUR helper found, building yay from source."
  install_repo base-devel git
  local tmp
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm)
  rm -rf "$tmp"
  AUR_HELPER=yay
  c_ok "yay installed."
}

# AUR packages via yay/paru. The helper also resolves repo packages,
# so it's safe for names that may live in either place.
install_aur() {
  ensure_aur_helper
  local missing=()
  mapfile -t missing < <(filter_missing "$@")
  if [[ ${#missing[@]} -eq 0 ]]; then
    c_ok "Nothing new to install (AUR)."
    return
  fi
  c_info "Installing (AUR via $AUR_HELPER): ${missing[*]}"
  "$AUR_HELPER" -S --needed --noconfirm "${missing[@]}"
}

# ---- files ----------------------------------------------------------------
# Moves an existing path aside as <path>.bak-<timestamp>.
backup_path() {
  local p="$1" dest
  dest="${p}.bak-$(date +%Y%m%d-%H%M%S)"
  mv "$p" "$dest"
  c_ok "Backed up $p -> $dest"
}

# ---- shell choice ---------------------------------------------------------
# HERMIT_SHELLS is one of: qs | ags | both
choose_shells() {
  [[ -n "${HERMIT_SHELLS:-}" ]] && return 0
  if [[ "$ASSUME_YES" == true ]]; then
    export HERMIT_SHELLS=both
    return 0
  fi

  local ans
  echo
  echo "Which shell(s) do you want to install?"
  echo "  1) Both Quickshell and AGS (switch between them with a keybind)"
  echo "  2) Quickshell only"
  echo "  3) AGS only"
  while true; do
    read -rp "Choose [1-3, default 1]: " ans || ans=1
    case "${ans:-1}" in
      1) export HERMIT_SHELLS=both; break ;;
      2) export HERMIT_SHELLS=qs;   break ;;
      3) export HERMIT_SHELLS=ags;  break ;;
      *) c_warn "Please enter 1, 2 or 3." ;;
    esac
  done
  c_ok "Shell choice: $HERMIT_SHELLS"
}

# want_shell qs|ags -> 0 if that shell was chosen
want_shell() {
  [[ "$HERMIT_SHELLS" == both || "$HERMIT_SHELLS" == "$1" ]]
}
