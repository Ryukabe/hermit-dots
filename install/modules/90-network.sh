#!/usr/bin/env bash
# DESC: OPTIONAL: switch NetworkManager's Wi-Fi backend to iwd (system-wide change)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
preflight

c_warn "This changes how your whole system handles Wi-Fi and may drop your connection."
if ! confirm "Configure NetworkManager to use the iwd backend?" N; then
  c_info "Skipped."
  exit 0
fi

install_repo networkmanager iwd

sudo mkdir -p /etc/NetworkManager/conf.d
conf=/etc/NetworkManager/conf.d/wifi_backend.conf
if [[ -f "$conf" ]] && grep -q "wifi.backend=iwd" "$conf"; then
  c_ok "Already set to iwd."
else
  printf '[device]\nwifi.backend=iwd\n' | sudo tee "$conf" >/dev/null
  c_ok "Wrote $conf"
fi

if systemctl is-enabled --quiet iwd.service 2>/dev/null; then
  c_warn "Disabling standalone iwd.service (NetworkManager manages it instead)."
  sudo systemctl disable --now iwd.service
fi
sudo systemctl enable --now NetworkManager.service
c_ok "NetworkManager enabled with iwd backend."
