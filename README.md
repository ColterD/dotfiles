# dotfiles

Personal desktop configuration for a CachyOS / KDE Plasma 6 (Wayland) machine with a
Windows 11 look. `./apply.sh` re-applies everything here; it is idempotent and needs no sudo.
Run it after re-applying the Windows Modern global theme, which resets several of these.

| Folder | What it holds |
|---|---|
| `zsh/` | `~/.zshrc` (fastfetch banner before Powerlevel10k's instant prompt) and `~/.p10k.zsh` (clock without seconds) |
| `fastfetch/` | Compact banner: no logo, eight lines |
| `pebrel/` | Pebrel font config (Fira Code Nerd Font) and settings (AI hooks on, One Half Dark selected) |
| `kvantum/` | `WindowsModernTranslucent`: Windows Modern Dark recolored to purple `#926EE4`, 15% window translucency |
| `kde/` | Default-terminal settings and the KZones layouts (3 x 2 grid first) |
| `zen/` | Zen Browser hardware video decode prefs and launcher override for NVIDIA |

## Expected packages

- Repo: `kvantum`, `ttf-firacode-nerd`, `fastfetch`, `zsh`, `zsh-theme-powerlevel10k`, `openai-codex`
- AUR: `kwin-scripts-kzones`, `claude-code`
- Local recipes in `../aur`: `pebrel-bin`, `eleven-twilight-icon-theme`
- KDE Store: Win11OS cursor (moyash), then `ln -s Win11OS/Win11OS ~/.icons/Win11OS-moyash`
- Theme: `../KDE-Windows-Modern` (branch `local-fixes`), and `../pebrel-themes/one-half-dark.json`
  imported with `pebrel theme pack` + `pebrel theme import`

## Not stored here

No credentials, tokens, browser profiles, shell history or session data. Files are copied
from the live system by hand; update the copy here when you change one.
