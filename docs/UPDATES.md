# How everything on this machine updates

Last reviewed 2026-11-13. Pacman and Shelly only see packages in a sync repo, and (through the AUR
RPC) foreign packages that are not named in any repo. Anything else needs its own path, listed here.

## Check everything

```bash
shelly list-updates all          # repo + AUR + Flatpak + AppImage (not the gaps below)
~/Documents/Projects/dotfiles/pkgbuilds/pkgup.sh check
fwupdmgr get-updates             # firmware
hermes plugins check-updates     # Hermes plugins
```

`pkgup.timer` (daily, user systemd) runs `pkgup.sh check --notify`. Shelly's tray checks every 12 h
(`TrayCheckIntervalHours`); CachyOS's `arch-update.timer` also runs daily.

## Update map

| What | Source | How it updates |
|---|---|---|
| Normal packages | CachyOS / Arch repos | Shelly, or `sudo pacman -Syu` |
| `claude-code`, `claude-desktop` | **In the CachyOS repo, which lags the AUR** | See "Repo shadows the AUR" below |
| Claude Desktop's Code tab | Own pinned CLI under `~/.config/Claude/claude-code/<version>/` | Tied to the `claude-desktop` build, not to the `claude-code` package. No supported override found (2026-11-13) |
| `curseforge`, `kwin-scripts-kzones`, `rustdesk-unattended-wayland`, `twitch-drops-miner-bin`, `visual-studio-code-bin` | AUR | Shelly (AUR list). `curseforge` lags the vendor feed: tracked in `pkgbuilds/upstream-feeds.conf` |
| `pebrel-bin`, `eleven-twilight-icon-theme` | Local recipes in `pkgbuilds/` | `pkgup.sh check`, then `pkgup.sh build <name>`, then `sudo pacman -U` the printed path |
| Craft App Suite (`ai.storyteller.*`) | Its own launcher | Opening the launcher downloads, checksum-verifies and installs updates through `pkexec` |
| `hermes-agent` | Package manager | Package update. `hermes update` refuses on a packaged install. Plugins: `hermes plugins update`; `hermes plugins auto-update on` is off by default |
| Oh-My-Codex, Oh-My-Claude (npm, user prefix) | npm | `omx-update.timer` (Sundays 03:30); `npm update -g` for the rest |
| KDE Windows Modern theme | Fork clone `~/Documents/Projects/KDE-Windows-Modern` (remote `upstream` = Jeysef) | `git fetch upstream`, merge into `local-fixes`, `./verify-all.sh`, then install components one by one (not `./install.sh all`), then `./apply.sh` here |
| Win11OS cursor | KDE Store | Manual |
| Limine bootloader | `limine` package | `80-limine-efi-deploy.hook` redeploys the EFI binary on upgrade |
| Kernel | `linux-cachyos`, `linux-cachyos-lts` | Package update; reboot to run it |
| Firmware | LVFS | `fwupdmgr` |
| Flatpak, AppImage | none installed | Shelly would cover them |

## Repo shadows the AUR

`claude-code` and `claude-desktop` exist in the CachyOS repo, so pacman treats them as repo packages
and Shelly never compares them to the AUR. Newer AUR builds do not show up as updates.

- Build the AUR version by hand: clone `https://aur.archlinux.org/<name>.git`, read the PKGBUILD,
  `makepkg -f`, `sudo pacman -U` the result. It installs as a normal upgrade.
- `pkgup.sh check` lists these under "AUR and locally built packages" when the AUR is ahead.
- Once the repo ships a higher version it replaces the hand-built one automatically.
- The same trap applies to any package that is installed from the AUR under a name a repo also uses.

## Not covered by any updater

- Hand-built packages whose recipe is not in `pkgbuilds/` (none known at the moment).
- Docker images (`docker pull` by hand).
- The old CachyOS install mounted from the second NVMe (see `lsblk`).
