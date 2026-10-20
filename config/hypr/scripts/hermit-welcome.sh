#!/bin/bash
# Start the Hermit welcome app on first run, or any time with --force.
#   hermit-welcome.sh           only if it has not been completed yet
#   hermit-welcome.sh --force   always

state="$HOME/.config/quickshell/state/welcome.json"

if [ "$1" != "--force" ] && grep -q '"completed": *true' "$state" 2>/dev/null; then
    exit 0
fi

# Already open.
pgrep -f 'quickshell -c welcome' >/dev/null && exit 0

command -v quickshell >/dev/null || { echo "hermit-welcome: quickshell is not installed" >&2; exit 1; }

setsid quickshell -c welcome >/dev/null 2>&1 &