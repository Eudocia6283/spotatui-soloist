#!/usr/bin/env bash
# Remove the services and scripts. Keeps the API key and Soloist login.
set -euo pipefail
systemctl --user disable --now soloist-watchdog.timer soloist.service 2>/dev/null || true
rm -f ~/.config/systemd/user/soloist{,-watchdog}.service ~/.config/systemd/user/soloist-watchdog.timer \
      ~/.local/bin/soloist-watchdog ~/.local/bin/soloist
systemctl --user daemon-reload
echo "Removed. To use spotatui's built-in player again, set enable_streaming: true in ~/.config/spotatui/config.yml"
