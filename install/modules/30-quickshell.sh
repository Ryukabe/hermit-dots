#!/usr/bin/env bash
# DESC: Quickshell (the "island" shell)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

choose_shells
if ! want_shell qs; then
  c_info "Quickshell not selected, skipping."
  exit 0
fi

install_repo quickshell

# TODO: add extra Qt/QML packages here if the shell needs them
#       (depends on what the QML files import; check config/quickshell).
c_ok "Quickshell installed."
