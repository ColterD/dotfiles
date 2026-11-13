# dotfiles

Personal desktop configuration for a CachyOS / KDE Plasma 6 (Wayland) machine with a
Windows 11 look. `./apply.sh` re-applies everything here; it is idempotent and needs no sudo.
Run it after re-applying the Windows Modern global theme, which resets several of these.

| Folder | What it holds |
|---|---|
| `zsh/` | `~/.zshrc` (fastfetch banner before Powerlevel10k's instant prompt) and `~/.p10k.zsh` (clock without seconds) |
| `fastfetch/` | Compact banner: no logo, eight lines |
| `pebrel/` | Pebrel font config (Fira Code Nerd Font), settings (AI hooks on), and the One Half Dark theme source in `themes/` |
| `pkgbuilds/` | Recipes for packages not in any repo: `pebrel-bin`, `eleven-twilight-icon-theme`, plus `pkgup.sh` (checks their GitHub releases; `pkgup.sh build <name>` bumps and builds one) |
| `systemd/` | `pkgup.timer`: daily desktop notification when a local recipe has a newer release |
| `kvantum/` | `WindowsModernTranslucent`: Windows Modern Dark recolored to purple `#926EE4`, 15% window translucency |
| `kde/` | Default-terminal settings and the KZones layouts (3 x 2 grid first) |
| `zen/` | Zen Browser hardware video decode prefs and launcher override for NVIDIA |

## Expected packages

- Repo: `kvantum`, `ttf-firacode-nerd`, `fastfetch`, `zsh`, `zsh-theme-powerlevel10k`, `openai-codex`
- AUR: `kwin-scripts-kzones`, `claude-code`
- Local recipes in `pkgbuilds/`: `pebrel-bin`, `eleven-twilight-icon-theme` (Shelly and pacman cannot see updates for these;
  `pkgbuilds/pkgup.sh check` can, and `pkgup.sh build <name>` makes the new package; install it with `sudo pacman -U`.
  To publish one, clone its AUR repo and copy the three files in)
- Self-updating: the `ai.storyteller.*` Craft App Suite is updated by its own launcher whenever the launcher is opened
- KDE Store: Win11OS cursor (moyash), then `ln -s Win11OS/Win11OS ~/.icons/Win11OS-moyash`
- Theme: a clone of `Jeysef/KDE-Windows-Modern` with local fixes (branch `local-fixes`), and
  `pebrel/themes/one-half-dark.json` imported with `pebrel theme pack` + `pebrel theme import`

## Backup and restore

- `files.map` lists the files `apply.sh` installs (repo path | live path).
- `./leak-scan.sh` scans the tree for personal paths and credential patterns; CI runs it with ShellCheck.
- `./snapshot.sh` refreshes those files from the live system, then copies a reviewed whitelist of
  other config into `backup/`: KDE shortcuts, KWin, panels, power, notifications, file
  associations, Vesktop, Shelly, micro, fish, bash, Twitch Drops Miner settings and Claude Code
  hooks, plus package and enabled-service lists. Home paths are stored as `@HOME@`, recent-file
  lists are dropped, and a leak scan runs at the end. If the scan fails, do not commit.
- `./apply.sh` copies the `files.map` entries back and re-applies KDE settings. A live file that
  differs is kept as `*.pre-apply`. Run `./snapshot.sh` first if you changed settings since.
- `./restore.sh --all` restores `backup/` (existing files are kept once as `*.pre-restore`);
  `--list` previews. Files that call `pebrel-hook` are skipped until Pebrel is installed.
- `backup/packages/` lists explicitly installed repo and foreign packages for reinstalling.

## Not stored here

No credentials, tokens, browser profiles, shell history, session data, monitor serial numbers,
or Claude/Codex/ChatGPT app state. Files are copied
from the live system by hand; update the copy here when you change one.
