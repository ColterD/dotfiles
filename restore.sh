#!/bin/bash
# Restore files saved by snapshot.sh. Existing files are kept as <name>.pre-restore.
# Usage: ./restore.sh            restore everything
#        ./restore.sh --list     show what would be restored
# Log out and back in afterwards; Plasma rewrites some of these files while it runs.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"; B="$D/backup"
[ -d "$B" ] || { echo "no backup/ folder; run ./snapshot.sh first"; exit 1; }
one() { src="$1"; dst="$2"
  if [ "${LIST:-0}" = 1 ]; then echo "$dst"; return; fi
  mkdir -p "$(dirname "$dst")"; [ -f "$dst" ] && cp -a "$dst" "$dst.pre-restore"
  sed "s|@HOME@|$HOME|g" "$src" > "$dst"; }
[ "${1:-}" = "--list" ] && LIST=1
( cd "$B/config" && find . -type f | sed 's|^\./||' ) | while read -r f; do one "$B/config/$f" "$HOME/.config/$f"; done
( cd "$B/home" && find . -type f | sed 's|^\./||' ) | while read -r f; do one "$B/home/$f" "$HOME/$f"; done
[ "${LIST:-0}" = 1 ] || echo "Restored. Package lists are in backup/packages/ (reinstall: pacman -S --needed - < repo-explicit.txt)."
