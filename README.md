# spotatui-soloist

Run [Spotify Soloist](https://developer.spotify.com/dashboard/soloist) as a standalone systemd user service, so music keeps playing after you quit [spotatui](https://github.com/LargeModGames/spotatui). spotatui becomes a remote control for a Connect device named `spotatui`.

Why: some accounts can't play through spotatui's built-in librespot engine (`error audio key 0 1`, [librespot#1649](https://github.com/librespot-org/librespot/issues/1649)), so spotatui offers Soloist instead. But spotatui starts Soloist as a child process, so playback stops when spotatui exits.

## What's included

| File | Purpose |
|---|---|
| `systemd/soloist.service` | Runs Soloist in the background, enabled at login |
| `bin/soloist-watchdog` | Restarts Soloist when it is unhealthy. When Spotify drops it as the active device and no other device is playing, makes it active again |
| `systemd/soloist-watchdog.{service,timer}` | Runs the watchdog every 2 minutes |

## Requirements

- Linux with systemd and PipeWire
- Spotify Premium
- spotatui already set up with Soloist (download, API key, pairing; see [spotatui docs/soloist.md](https://github.com/LargeModGames/spotatui/blob/main/docs/soloist.md))

## Install

```sh
./install.sh
```

The script:
1. Links the newest Soloist binary that spotatui downloaded to `~/.local/bin/soloist`
2. Reads the API key from `~/.config/spotatui/soloist_credentials.yml` (asks if missing) and stores it in `~/.config/soloist/env` (mode 600)
3. Sets `enable_streaming: false` in spotatui's config so two `spotatui` devices don't run at once (backs up the config first)
4. Enables `soloist.service` and `soloist-watchdog.timer`

Then open spotatui, press `d` and pick **spotatui**.

## Usage

```sh
journalctl --user -u soloist -u soloist-watchdog -f   # logs
systemctl --user start soloist-watchdog               # recover now instead of waiting up to 2 minutes
soloist ctl -D ~/.local/state/spotatui/soloist status # Soloist status
```

After spotatui updates Soloist, run `./install.sh` again to point the link at the new binary.

## Uninstall

```sh
./uninstall.sh
```
