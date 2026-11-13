#!/bin/bash
# Keep the local recipes in this folder current. Pacman, Shelly and the AUR cannot see them,
# so this checks each recipe's GitHub releases instead.
#
#   pkgup.sh check [--notify]   compare installed / recipe / latest GitHub release for every recipe
#   pkgup.sh build <name>       bump the recipe to the latest release, refresh checksums, run makepkg
#
# `build` never installs: it prints the `sudo pacman -U` line to run. The bumped PKGBUILD is
# written back to this folder only after makepkg succeeds, so review it with `git diff`.
# Only recipes whose `url` is a GitHub repo with plain `v<version>` release tags are supported.
set -euo pipefail

D="$(cd "$(dirname "$0")" && pwd)"
BUILD_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/pkgup"

say() { printf '%s\n' "$*"; }
die() { printf 'pkgup: %s\n' "$*" >&2; exit 1; }

# recipe_vars <dir>: prints pkgname, pkgver, url, first source (variables already expanded).
recipe_vars() {
  ( # shellcheck disable=SC1091
    source "$1/PKGBUILD"
    printf '%s\n%s\n%s\n%s\n' "$pkgname" "$pkgver" "$url" "${source[0]}" )
}

latest_version() { # <github repo> -> version without the leading v
  curl -fsS -m 20 "https://api.github.com/repos/$1/releases/latest" \
    | python3 -I -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].lstrip("v"))'
}

installed_version() { pacman -Q "$1" 2>/dev/null | awk '{print $2}' || true; }

recipes() { for f in "$D"/*/PKGBUILD; do [ -e "$f" ] && dirname "$f"; done; }

cmd_check() {
  local notify=0 behind=() dir
  [ "${1:-}" = "--notify" ] && notify=1
  printf '%-30s %-12s %-12s %-12s %s\n' PACKAGE INSTALLED RECIPE LATEST STATUS
  while IFS= read -r dir; do
    local vars name rver url repo latest inst status
    mapfile -t vars < <(recipe_vars "$dir")
    name="${vars[0]}"; rver="${vars[1]}"; url="${vars[2]}"
    case "$url" in https://github.com/*) repo="${url#https://github.com/}"; repo="${repo%/}";;
      *) printf '%-30s unsupported url: %s\n' "$name" "$url"; continue;; esac
    latest="$(latest_version "$repo")" || { printf '%-30s could not query %s\n' "$name" "$repo"; continue; }
    inst="$(installed_version "$name")"; inst="${inst%-*}"
    if [ "$(vercmp "$latest" "$rver")" -gt 0 ]; then status="update available"; behind+=("$name $rver -> $latest")
    elif [ -n "$inst" ] && [ "$(vercmp "$latest" "$inst")" -gt 0 ]; then status="recipe is current, rebuild and install"; behind+=("$name installed $inst, recipe $rver")
    else status="up to date"; fi
    printf '%-30s %-12s %-12s %-12s %s\n' "$name" "${inst:--}" "$rver" "$latest" "$status"
  done < <(recipes)
  if [ "$notify" = 1 ] && [ "${#behind[@]}" -gt 0 ] && command -v notify-send >/dev/null 2>&1; then
    notify-send -a pkgup -i software-update-available "Local package updates" "$(printf '%s\n' "${behind[@]}")"
  fi
}

cmd_build() {
  local name="${1:-}" dir vars rver url repo latest work src_url
  [ -n "$name" ] || die "usage: pkgup.sh build <name>"
  dir="$D/$name"; [ -f "$dir/PKGBUILD" ] || die "no recipe named $name in $D"
  mapfile -t vars < <(recipe_vars "$dir")
  rver="${vars[1]}"; url="${vars[2]}"
  case "$url" in https://github.com/*) repo="${url#https://github.com/}"; repo="${repo%/}";; *) die "unsupported url: $url";; esac
  latest="$(latest_version "$repo")" || die "could not query releases for $repo"
  [ "$(vercmp "$latest" "$rver")" -gt 0 ] || { say "$name is already at $rver (latest $latest); building the current recipe"; latest="$rver"; }

  work="$BUILD_ROOT/$name"; rm -rf "$work"; mkdir -p "$work"; cp -a "$dir/." "$work/"
  sed -i "s/^pkgver=.*/pkgver=$latest/; s/^pkgrel=.*/pkgrel=1/" "$work/PKGBUILD"
  # Make sure the release asset the recipe points at exists for the new version before downloading it.
  mapfile -t vars < <(recipe_vars "$work"); src_url="${vars[3]#*::}"
  curl -fsIL -m 20 -o /dev/null "$src_url" || die "release asset not found: $src_url (the asset name may have changed)"
  ( cd "$work" && updpkgsums && makepkg -f --noconfirm )
  cp "$work/PKGBUILD" "$dir/PKGBUILD"
  say
  say "Built in $work and updated $dir/PKGBUILD (review with git diff). To install:"
  say "  sudo pacman -U $work/${name}-${latest}-*.pkg.tar.zst"
}

case "${1:-}" in
  check) shift; cmd_check "$@";;
  build) shift; cmd_build "$@";;
  *) sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 2;;
esac
