#!/bin/bash
# Capture the live configuration into this repo:
#   1. files.map entries (the files apply.sh installs) are refreshed live -> repo;
#   2. a whitelist of other config is copied into backup/ for restore.sh.
# Home paths are stored as @HOME@, recent-file lists are dropped, and the result is scanned for
# credentials and personal paths. The scan failing means: do NOT commit until it is resolved.
# Never add: browser profiles, cookies, shell history, ~/.claude.json, Claude/Codex app config,
# kwinoutputconfig.json (monitor serials), ksmserverrc (saved session: username, open apps),
# anything under ~/.ssh or a keyring.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"; B="$D/backup"
CONFIG=(kglobalshortcutsrc kwinrc plasmashellrc plasma-org.kde.plasma.desktop-appletsrc kdeglobals
        kcminputrc powermanagementprofilesrc plasmanotifyrc spectaclerc mimeapps.list
        krunnerrc user-dirs.dirs libinput-gestures.conf plasma-localerc baloofilerc
        shelly/settings.json vesktop/settings.json vesktop/settings/settings.json
        vesktop/settings/quickCss.css fish/config.fish micro/settings.json micro/bindings.json
        psd/psd.conf autostart/vesktop.desktop autostart/cachyos-hello.desktop)
HOMEFILES=(.bashrc .bash_profile .local/share/twitch-drops-miner/settings.json .claude/settings.json)

# Drop keys that record what you opened or where you saved; mask the home path.
clean() { sed -e '/^\(Recent Files\|Recent URLs\|History Items\|lastImageSaveLocation\|lastVideoSaveLocation\|Recent Dirs\)\(\[[^]]*\]\)\?=/d' -e "s|$HOME|@HOME@|g" "$1"; }
put() { [ -f "$1" ] || return 0; mkdir -p "$(dirname "$2")"; clean "$1" > "$2"; }

# 1. refresh the files apply.sh installs
while IFS='|' read -r src dst; do
  case "$src" in ''|'#'*) continue;; esac
  live="$HOME/$dst"; [ -e "$live" ] || continue
  rm -rf "${D:?}/$src"; mkdir -p "$(dirname "$D/$src")"; cp -r "$live" "$D/$src"
done < "$D/files.map"
if command -v kreadconfig6 >/dev/null 2>&1; then
  j="$(kreadconfig6 --file kwinrc --group Script-kzones --key layoutsJson 2>/dev/null || true)"
  [ -n "$j" ] && printf '%s' "$j" | python3 -m json.tool > "$D/kde/kzones-layouts.json" || true
fi
ZP="$(find "$HOME/.config/zen" -maxdepth 1 -type d -name '*.Default (release)' 2>/dev/null | head -1 || true)"
[ -n "$ZP" ] && [ -f "$ZP/user.js" ] && cp "$ZP/user.js" "$D/zen/user.js" || true

# 2. build backup/ in a temporary folder and swap it in only when complete
N="$(mktemp -d "$D/.backup.XXXXXX")"; trap 'rm -rf "$N"' EXIT
mkdir -p "$N/config" "$N/home" "$N/packages"
for f in "${CONFIG[@]}"; do put "$HOME/.config/$f" "$N/config/$f"; done
for f in "${HOMEFILES[@]}"; do put "$HOME/$f" "$N/home/$f"; done
pacman -Qqen > "$N/packages/repo-explicit.txt"
pacman -Qqem > "$N/packages/foreign-explicit.txt"
{ systemctl list-unit-files --state=enabled --no-legend 2>/dev/null || true; } | awk '{print $1}' | sort > "$N/packages/enabled-system-units.txt"
{ systemctl --user list-unit-files --state=enabled --no-legend 2>/dev/null || true; } | awk '{print $1}' | sort > "$N/packages/enabled-user-units.txt"
{ grep -v '^\s*#' /etc/pacman.conf || true; } | sed '/^\s*$/d' > "$N/packages/pacman.conf"
rm -rf "$B"; mv "$N" "$B"; trap - EXIT
echo "snapshot written ($(find "$B" -type f | wc -l) backup files)"

# 3. leak scan over everything that would be committed
"$D/leak-scan.sh"
