#!/bin/bash
# Re-apply this machine's personal desktop configuration (idempotent, no sudo).
# Files listed in files.map are copied repo -> live; a live file that differs is first
# kept as <name>.pre-apply. Run ./snapshot.sh first if you changed settings since the
# last snapshot, or those changes are replaced by the repo copies.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
say() { printf '==> %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }

say "Config files (files.map)"
while IFS='|' read -r src dst; do
  case "$src" in ''|'#'*) continue;; esac
  s="$D/$src"; t="$HOME/$dst"
  [ -e "$s" ] || { note "missing in repo: $src"; continue; }
  if [ -e "$t" ] && ! diff -rq "$s" "$t" >/dev/null 2>&1; then
    rm -rf "$t.pre-apply"; cp -a "$t" "$t.pre-apply"; note "changed: $dst (previous kept as $(basename "$t").pre-apply)"
  fi
  mkdir -p "$(dirname "$t")"; rm -rf "$t"; cp -r "$s" "$t"
done < "$D/files.map"

say "Kvantum application style (dark variant of the selected theme)"
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum-dark

say "Default terminal = Pebrel"
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication pebrel
kwriteconfig6 --file kdeglobals --group General --key TerminalService io.github.kuddev.pebrel.desktop

say "Pebrel theme: One Half Dark"
if [ -f "$HOME/.config/pebrel/themes/one-half-dark.pebrel-theme.json" ]; then
  note "already in Pebrel's theme library"
elif command -v pebrel >/dev/null 2>&1; then
  T="$(mktemp -d)"
  if pebrel theme pack "$D/pebrel/themes/one-half-dark.json" --output "$T/one-half-dark.zip" --author local --license MIT >/dev/null 2>&1 \
     && pebrel theme import "$T/one-half-dark.zip" >/dev/null 2>&1; then note "imported"; else note "import failed; import pebrel/themes/one-half-dark.json by hand"; fi
  rm -rf "$T"
else
  note "pebrel not installed; skipped (settings fall back to the built-in theme until it is imported)"
fi

say "Session: never restore Firefox at login"
kwriteconfig6 --file ksmserverrc --group General --key excludeApps firefox

say "Icons, cursor, accent"
kwriteconfig6 --file kdeglobals --group General --key AccentColor 146,110,228
/usr/lib/plasma-changeicons ElevenTwilight >/dev/null 2>&1 || true
plasma-apply-cursortheme Win11OS-moyash >/dev/null 2>&1 || note "cursor theme Win11OS-moyash not installed (KDE Store: Win11OS, then link ~/.icons/Win11OS-moyash -> Win11OS/Win11OS)"

say "KZones layouts (3 x 2 grid first)"
kwriteconfig6 --file kwinrc --group Script-kzones --key layoutsJson "$(python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1]))))' "$D/kde/kzones-layouts.json")"
kwriteconfig6 --file kwinrc --group Plugins --key kzonesEnabled true
qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true

say "Panels: 56 px, translucent; wallpaper: Bing picture of the day"
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var ps = panels(); for (var i = 0; i < ps.length; i++) { ps[i].height = 56; ps[i].opacity = "translucent"; }
var ds = desktops(); for (var j = 0; j < ds.length; j++) { ds[j].wallpaperPlugin = "org.kde.potd"; ds[j].currentConfigGroup = ["Wallpaper","org.kde.potd","General"]; ds[j].writeConfig("Provider","bing"); }' >/dev/null 2>&1 || note "plasmashell not reachable; skipped"

say "Zen: NVIDIA hardware video decode"
ZP="$(find "$HOME/.config/zen" -maxdepth 1 -type d -name '*.Default (release)' 2>/dev/null | head -1 || true)"
if [ -n "$ZP" ]; then install -m644 "$D/zen/user.js" "$ZP/user.js"; else note "no Zen profile yet; start Zen once, then re-run"; fi

say "Power: performance profile, screens off after 15 min, no auto-sleep"
pd() { kwriteconfig6 --file powerdevilrc --group AC --group "$1" --key "$2" "$3"; }
pd Performance PowerProfile performance
pd Display TurnOffDisplayWhenIdle true
pd Display TurnOffDisplayIdleTimeoutSec 900
pd Display TurnOffDisplayIdleTimeoutWhenLockedSec 900
pd SuspendAndShutdown AutoSuspendAction 0
command -v powerprofilesctl >/dev/null && powerprofilesctl set performance || true

say "Local package update check (pkgup.timer, daily)"
systemctl --user daemon-reload
systemctl --user enable --now pkgup.timer >/dev/null 2>&1 || note "could not enable pkgup.timer; run: systemctl --user enable --now pkgup.timer"

say "Done. Restart apps (or log out and in) to pick up style changes."
