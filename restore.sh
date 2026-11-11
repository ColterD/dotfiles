#!/bin/bash
# Restore files saved by snapshot.sh into backup/. A live file is kept once as <name>.pre-restore
# (an existing .pre-restore is never overwritten, so the original survives repeated runs).
# Usage: ./restore.sh --all     restore everything
#        ./restore.sh --list    show what would be restored
# Log out and back in afterwards; Plasma rewrites some of these files while it runs.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"; B="$D/backup"
case "${1:-}" in
  --all) LIST=0 ;;
  --list) LIST=1 ;;
  *) sed -n '2,6p' "$0" | sed 's/^# \?//'; exit 64 ;;
esac
[ -d "$B" ] || { echo "no backup/ folder; run ./snapshot.sh first"; exit 1; }
one() { src="$1"; dst="$2"
  if grep -q 'pebrel-hook' "$src" 2>/dev/null && ! command -v pebrel-hook >/dev/null 2>&1; then
    echo "skipped ${dst/#$HOME/\~}: it calls pebrel-hook, which is not installed (install pebrel-bin, then re-run)"; return; fi
  if [ "$LIST" = 1 ]; then echo "$dst"; return; fi
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ] && [ ! -e "$dst.pre-restore" ]; then cp -a "$dst" "$dst.pre-restore"; fi
  sed "s|@HOME@|$HOME|g" "$src" > "$dst"; }
( cd "$B/config" && find . -type f | sed 's|^\./||' ) | while read -r f; do one "$B/config/$f" "$HOME/.config/$f"; done
( cd "$B/home" && find . -type f | sed 's|^\./||' ) | while read -r f; do one "$B/home/$f" "$HOME/$f"; done
[ "$LIST" = 1 ] || echo "Restored. Package lists are in backup/packages/ (reinstall: pacman -S --needed - < repo-explicit.txt)."
