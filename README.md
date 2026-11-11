# dotfiles

Personal desktop configuration for a CachyOS / KDE Plasma 6 (Wayland) machine with a
Windows 11 look. `./apply.sh` re-applies everything here; it is idempotent and needs no sudo.
Run it after re-applying the Windows Modern global theme, which resets several of these.

| Folder | What it holds |
|---|---|
| `zsh/` | `~/.zshrc` (fastfetch banner before Powerlevel10k's instant prompt) and `~/.p10k.zsh` (clock without seconds) |
| `fastfetch/` | Compact banner: no logo, eight lines |
| `pebrel/` | Pebrel font config (Fira Code Nerd Font), settings (AI hooks on), and the One Half Dark theme source in `themes/` |
| `pkgbuilds/` | Recipes for packages not in any repo: `pebrel-bin`, `eleven-twilight-icon-theme` |
| `kvantum/` | `WindowsModernTranslucent`: Windows Modern Dark recolored to purple `#926EE4`, 15% window translucency |
| `kde/` | Default-terminal settings and the KZones layouts (3 x 2 grid first) |
| `zen/` | Zen Browser hardware video decode prefs and launcher override for NVIDIA |

## Expected packages

- Repo: `kvantum`, `ttf-firacode-nerd`, `fastfetch`, `zsh`, `zsh-theme-powerlevel10k`, `openai-codex`
- AUR: `kwin-scripts-kzones`, `claude-code`
- Local recipes in `pkgbuilds/`: `pebrel-bin`, `eleven-twilight-icon-theme` (build with `makepkg -si` in each folder;
  to publish one, clone its AUR repo and copy the three files in)
- KDE Store: Win11OS cursor (moyash), then `ln -s Win11OS/Win11OS ~/.icons/Win11OS-moyash`
- Theme: a clone of `Jeysef/KDE-Windows-Modern` with local fixes (branch `local-fixes`), and
  `pebrel/themes/one-half-dark.json` imported with `pebrel theme pack` + `pebrel theme import`

## Backup and restore

- `./snapshot.sh` copies a reviewed whitelist of live config into `backup/`: KDE shortcuts, KWin,
  panels, power, notifications, file associations, Vesktop, Shelly, micro, fish, bash, Twitch Drops
  Miner settings and Claude Code hooks, plus package and enabled-service lists. Home paths are
  stored as `@HOME@`.
- `./restore.sh` puts them back (existing files are kept as `*.pre-restore`); `--list` previews.
- `backup/packages/` lists explicitly installed repo and foreign packages for reinstalling.

## Not stored here

No credentials, tokens, browser profiles, shell history, session data, monitor serial numbers,
or Claude/Codex/ChatGPT app state. Files are copied
from the live system by hand; update the copy here when you change one.
