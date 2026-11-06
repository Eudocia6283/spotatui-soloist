#!/usr/bin/env bash
# Install the Soloist user service and its watchdog.
set -euo pipefail
cd "$(dirname "$0")"

state="$HOME/.local/state/spotatui"
unit_dir="$HOME/.config/systemd/user"
env_file="$HOME/.config/soloist/env"

# Newest Soloist binary downloaded by spotatui (Settings > Soloist Path > o)
bin=$(ls -td "$state"/soloist-bin/*/soloist 2>/dev/null | head -n1 || true)
if [[ -z $bin ]]; then
    echo "Soloist not found. Download it from spotatui Settings first." >&2
    exit 1
fi

mkdir -p "$HOME/.local/bin" "$unit_dir" "$(dirname "$env_file")"
ln -sf "$bin" "$HOME/.local/bin/soloist"
install -m755 bin/soloist-watchdog "$HOME/.local/bin/soloist-watchdog"
install -m644 systemd/* "$unit_dir/"

if [[ ! -f $env_file ]]; then
    key=$(grep -oE 'spak_[A-Za-z0-9]+' "$HOME/.config/spotatui/soloist_credentials.yml" 2>/dev/null | head -n1 || true)
    [[ -z $key ]] && read -rp "Soloist API key: " key
    (umask 077; printf 'SOLOIST_API_KEY=%s\n' "$key" > "$env_file")
fi

# spotatui must not start its own Connect device under the same name
cfg="$HOME/.config/spotatui/config.yml"
if grep -q '^  enable_streaming: true$' "$cfg" 2>/dev/null; then
    cp "$cfg" "$cfg.bak"
    sed -i 's/^  enable_streaming: true$/  enable_streaming: false/' "$cfg"
    echo "Disabled enable_streaming in $cfg (backup: $cfg.bak)"
fi

systemctl --user daemon-reload
systemctl --user enable --now soloist.service soloist-watchdog.timer
echo "Done. Logs: journalctl --user -u soloist -u soloist-watchdog"
