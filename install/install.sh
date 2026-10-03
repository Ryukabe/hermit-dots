#!/usr/bin/env bash
#
# hermit-dots installer: runs the modules in install/modules/ in order.
#
#   ./install.sh                     run everything (asks which shells to install)
#   ./install.sh --list              show modules
#   ./install.sh --shells qs         choose shells: qs | ags | both
#   ./install.sh --only quickshell,dotfiles
#   ./install.sh --skip fonts,network
#   ./install.sh --yes               accept each prompt's default answer
#   ./install.sh --copy              copy configs instead of symlinking
#
# Each module is also runnable on its own: bash modules/30-quickshell.sh

set -euo pipefail

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export INSTALL_DIR
# shellcheck source=lib/common.sh
source "$INSTALL_DIR/lib/common.sh"

ONLY=() SKIP=()

usage() {
  sed -n '3,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

module_name() { basename "$1" .sh | sed 's/^[0-9]*-//'; }

list_modules() {
  local f
  echo "Modules (run order):"
  for f in "$INSTALL_DIR"/modules/*.sh; do
    printf '  %-12s %s\n' "$(module_name "$f")" "$(grep -m1 '^# DESC:' "$f" | cut -d' ' -f3-)"
  done
}

in_list() { # in_list needle "${arr[@]}"
  local n="$1" x; shift
  for x in "$@"; do [[ "$x" == "$n" ]] && return 0; done
  return 1
}

# selected <name> -> 0 if this module will run given --only/--skip
selected() {
  if [[ ${#ONLY[@]} -gt 0 ]] && ! in_list "$1" "${ONLY[@]}"; then return 1; fi
  if [[ ${#SKIP[@]} -gt 0 ]] && in_list "$1" "${SKIP[@]}"; then return 1; fi
  return 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list) list_modules; exit 0 ;;
    --only) IFS=, read -ra ONLY <<<"${2:?--only needs a value}"; shift 2 ;;
    --skip) IFS=, read -ra SKIP <<<"${2:?--skip needs a value}"; shift 2 ;;
    --shells)
      case "${2:-}" in
        qs|ags|both) export HERMIT_SHELLS="$2"; shift 2 ;;
        *) c_err "--shells must be one of: qs, ags, both"; exit 1 ;;
      esac ;;
    --yes|-y) export HERMIT_YES=true; shift ;;
    --copy) export HERMIT_COPY=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) c_err "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# Validate module names given to --only / --skip
known=()
for f in "$INSTALL_DIR"/modules/*.sh; do known+=("$(module_name "$f")"); done
for n in "${ONLY[@]}" "${SKIP[@]}"; do
  in_list "$n" "${known[@]}" || { c_err "Unknown module: $n"; list_modules; exit 1; }
done

preflight
c_info "Repo: $REPO_ROOT"

# Ask once, up front, if any shell-related module is going to run
for n in quickshell ags dotfiles; do
  if selected "$n"; then choose_shells; break; fi
done

for f in "$INSTALL_DIR"/modules/*.sh; do
  n="$(module_name "$f")"
  selected "$n" || continue

  c_step "Module: $n"
  if ! bash "$f"; then
    c_err "Module '$n' failed. Fix it, then resume with: ./install.sh --only $n"
    exit 1
  fi
done

echo
c_ok "All done. Log out and back in (or reboot) to apply everything."
if [[ "${HERMIT_SHELLS:-both}" == both ]]; then
  echo "  Switch shells: Super+Ctrl+Alt+Q (Quickshell) / Super+Ctrl+Alt+A (AGS)"
fi
