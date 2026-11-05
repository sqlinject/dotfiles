# dotfiles

WSL terminal setup for a dark, desaturated "data-console" look: zsh, Starship, and a shared
semantic colour palette. Managed with [GNU stow](https://www.gnu.org/software/stow/), one
package per tool.

## Bootstrap on a fresh WSL

    sudo apt-get update && sudo apt-get install -y git
    git clone <your-remote> ~/dotfiles    # or copy the folder
    cd ~/dotfiles && ./install.sh

`install.sh` is idempotent. It installs the apt packages in `packages.txt`, installs Starship
to `~/.local/bin`, backs up any conflicting real files to `.backup/<timestamp>/` (nothing is
deleted), stows every package, and sets zsh as your login shell (`chsh` asks for your password).

Then apply the Windows side (font + colours), see `windows-terminal/README.md`.

## Layout

| Path | Purpose |
|---|---|
| `zsh/` | `.zshrc`, `.zsh/aliases.zsh`, `.zsh/prompt.zsh` |
| `starship/` | `.config/starship.toml` |
| `git/` | `.gitconfig` (no identity; includes `~/.gitconfig.local`) |
| `lib/palette.sh`, `lib/palette.py` | Semantic colours for your own scripts (not stowed) |
| `windows-terminal/` | Colour scheme + `apply.ps1` (not stowed) |

## Untracked per-machine files

`~/.zshrc.local` (nvm, keychain, tokens) and `~/.gitconfig.local` (`[user] name/email`).
`*.local` and `.backup/` are git-ignored.

## Changing the palette

Hex values live in four places; change them together:
`lib/palette.sh`, `lib/palette.py`, `starship/.config/starship.toml` (`[palettes.callum_slate]`),
and `windows-terminal/callum-slate.json` (then re-run `apply.ps1`).

Semantics: red = bad, amber = warning, green = good, teal = system tags, blue = paths,
pink = prompt chevron, dim = secondary text.

## Adding a new package

1. Make `~/dotfiles/<tool>/` mirroring `$HOME`, e.g. `tmux/.tmux.conf` or `nvim/.config/nvim/init.lua`.
2. Add `<tool>` to the `PACKAGES=(...)` array in `install.sh`.
3. Run `./install.sh` (or `stow --no-folding <tool>`). Existing files are backed up first.
