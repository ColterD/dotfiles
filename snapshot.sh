#!/bin/bash
# Copy a whitelist of live config files into backup/ so they can be restored later.
# Only files reviewed as free of credentials are listed. Home paths are stored as @HOME@.
# Never add: browser profiles, cookies, shell history, ~/.claude.json, Claude/Codex app config,
# kwinoutputconfig.json (monitor serials), anything under ~/.ssh or a keyring.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"; B="$D/backup"
CONFIG=(kglobalshortcutsrc kwinrc plasmashellrc plasma-org.kde.plasma.desktop-appletsrc kdeglobals
        kcminputrc powermanagementprofilesrc plasmanotifyrc spectaclerc mimeapps.list ksmserverrc
        krunnerrc user-dirs.dirs libinput-gestures.conf plasma-localerc baloofilerc
        shelly/settings.json vesktop/settings.json vesktop/settings/settings.json
        vesktop/settings/quickCss.css fish/config.fish micro/settings.json micro/bindings.json
        psd/psd.conf autostart/vesktop.desktop autostart/cachyos-hello.desktop)
HOMEFILES=(.bashrc .bash_profile .local/share/twitch-drops-miner/settings.json .claude/settings.json)
rm -rf "$B"; mkdir -p "$B/config" "$B/home" "$B/packages"
put() { [ -f "$1" ] || return 0; mkdir -p "$(dirname "$2")"; sed -e "s|$HOME|@HOME@|g" -e '/^lastImageSaveLocation=/d' -e '/^lastVideoSaveLocation=/d' "$1" > "$2"; }
for f in "${CONFIG[@]}"; do put "$HOME/.config/$f" "$B/config/$f"; done
for f in "${HOMEFILES[@]}"; do put "$HOME/$f" "$B/home/$f"; done
pacman -Qqen > "$B/packages/repo-explicit.txt"
pacman -Qqem > "$B/packages/foreign-explicit.txt"
systemctl list-unit-files --state=enabled --no-legend 2>/dev/null | awk '{print $1}' | sort > "$B/packages/enabled-system-units.txt"
systemctl --user list-unit-files --state=enabled --no-legend 2>/dev/null | awk '{print $1}' | sort > "$B/packages/enabled-user-units.txt"
grep -v '^\s*#' /etc/pacman.conf | sed '/^\s*$/d' > "$B/packages/pacman.conf"
echo "snapshot written to $B ($(find "$B" -type f | wc -l) files)"
