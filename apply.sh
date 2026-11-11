#!/bin/bash
# Re-apply this machine's personal desktop configuration (idempotent, no sudo).
# Packages it expects are listed in README.md. Run from anywhere:  ./apply.sh
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
say() { printf '==> %s\n' "$*"; }

say "zsh + Powerlevel10k"
install -m644 "$D/zsh/zshrc" "$HOME/.zshrc"
install -m644 "$D/zsh/p10k.zsh" "$HOME/.p10k.zsh"

say "fastfetch"
install -Dm644 "$D/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"

say "Pebrel (font config + settings; the One Half Dark theme lives in ../pebrel-themes)"
install -Dm644 "$D/pebrel/pebrel.luau" "$HOME/.config/pebrel/pebrel.luau"
install -Dm644 "$D/pebrel/pebrel_settings.txt" "$HOME/.config/pebrel/pebrel_settings.txt"

say "Kvantum: Windows Modern Dark, purple accent, 15% window translucency"
mkdir -p "$HOME/.config/Kvantum"
rm -rf "$HOME/.config/Kvantum/WindowsModernTranslucent"
cp -r "$D/kvantum/WindowsModernTranslucent" "$HOME/.config/Kvantum/"
install -m644 "$D/kvantum/kvantum.kvconfig" "$HOME/.config/Kvantum/kvantum.kvconfig"
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum

say "Default terminal = Pebrel"
install -Dm644 "$D/kde/60-terminal.conf" "$HOME/.config/environment.d/60-terminal.conf"
install -m644 "$D/kde/xdg-terminals.list" "$HOME/.config/xdg-terminals.list"
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication pebrel
kwriteconfig6 --file kdeglobals --group General --key TerminalService io.github.kuddev.pebrel.desktop

say "Icons, cursor, accent"
kwriteconfig6 --file kdeglobals --group General --key AccentColor 146,110,228
/usr/lib/plasma-changeicons ElevenTwilight >/dev/null 2>&1 || true
plasma-apply-cursortheme Win11OS-moyash >/dev/null 2>&1 || echo "    cursor theme Win11OS-moyash not installed (KDE Store: Win11OS, then link ~/.icons/Win11OS-moyash -> Win11OS/Win11OS)"

say "KZones layouts (3 x 2 grid first)"
kwriteconfig6 --file kwinrc --group Script-kzones --key layoutsJson "$(python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1]))))' "$D/kde/kzones-layouts.json")"
kwriteconfig6 --file kwinrc --group Plugins --key kzonesEnabled true
qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true

say "Panels: 56 px, translucent; wallpaper: Bing picture of the day"
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var ps = panels(); for (var i = 0; i < ps.length; i++) { ps[i].height = 56; ps[i].opacity = "translucent"; }
var ds = desktops(); for (var j = 0; j < ds.length; j++) { ds[j].wallpaperPlugin = "org.kde.potd"; ds[j].currentConfigGroup = ["Wallpaper","org.kde.potd","General"]; ds[j].writeConfig("Provider","bing"); }' >/dev/null 2>&1 || echo "    plasmashell not reachable; skipped"

say "Zen: NVIDIA hardware video decode"
ZP=$(find "$HOME/.config/zen" -maxdepth 1 -type d -name '*.Default (release)' 2>/dev/null | head -1)
[ -n "$ZP" ] && install -m644 "$D/zen/user.js" "$ZP/user.js" || echo "    no Zen profile found; skipped"
install -Dm644 "$D/zen/zen.desktop" "$HOME/.local/share/applications/zen.desktop"

say "Done. Restart apps (or log out and in) to pick up style changes."
