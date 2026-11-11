#!/bin/bash
# Scan everything that would be committed for personal paths, the local username and credential
# patterns. Exit 2 on a hit. Used by snapshot.sh and by CI.
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"; cd "$D"
U="${LEAK_USER:-$(id -un)}"
PAT="(/home/[a-z]|/run/media/|/mnt/[a-z]|\b$U\b|@gmail\.|192\.168\.[0-9]+\.[0-9]+|-----BEGIN [A-Z ]*PRIVATE KEY|sk-[A-Za-z0-9_-]{24,}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9A-Za-z-]{10,}|(api[_-]?key|secret|token|passw(or)?d)[\"']?[[:space:]]*[:=][[:space:]]*[\"'][^\"'\$<{ ]{12,}[\"'])"
hits="$(grep -r -I -n -i -E "$PAT" --exclude-dir=.git --exclude-dir=.github --exclude=leak-scan.sh --exclude=snapshot.sh --exclude=README.md . \
  | grep -v -E '/home/username/|zsh/p10k\.zsh:.*(asdf|/some/not/home)' || true)"
if [ -n "$hits" ]; then
  echo "LEAK SCAN FOUND POSSIBLE PERSONAL DATA OR SECRETS - do not commit until resolved:" >&2
  printf '%s\n' "$hits" | cut -c1-160 >&2; exit 2
fi
echo "leak scan: clean"
