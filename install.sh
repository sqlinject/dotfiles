#!/usr/bin/env bash
# Idempotent bootstrap for a fresh Ubuntu/WSL box. Safe to re-run.
#   1. seed untracked *.local files from existing configs (first run only)
#   2. apt packages from packages.txt (sudo only if something is missing)
#   3. starship -> ~/.local/bin
#   4. back up conflicting files, then stow every package
#   5. make zsh the login shell (needs your password; skipped when not on a tty)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh starship git)          # add new stow packages here
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DOTFILES/.backup/$STAMP"

say()  { printf '\033[38;2;95;201;198m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[38;2;217;180;91m!!\033[0m  %s\n' "$*" >&2; }

# --- 1. seed untracked local files (only if absent and the originals are real files)
say "Seeding untracked local files (if needed)"
if [[ ! -e "$HOME/.gitconfig.local" && -f "$HOME/.gitconfig" && ! -L "$HOME/.gitconfig" ]]; then
  name="$(git config --file "$HOME/.gitconfig" user.name || true)"
  email="$(git config --file "$HOME/.gitconfig" user.email || true)"
  if [[ -n "$name$email" ]]; then
    { echo "[user]"
      [[ -n "$name" ]]  && printf '\tname = %s\n' "$name"
      [[ -n "$email" ]] && printf '\temail = %s\n' "$email"
    } > "$HOME/.gitconfig.local"
    echo "    created ~/.gitconfig.local from existing identity"
  fi
fi
if [[ ! -e "$HOME/.zshrc.local" ]]; then
  # carry over env/nvm/keychain lines you already had, so zsh keeps working
  { for f in "$HOME/.zshrc" "$HOME/.bashrc"; do
      [[ -f "$f" && ! -L "$f" ]] && grep -E '\.local/bin/env|NVM_DIR=|nvm\.sh|keychain' "$f" || true
    done; } | awk '!seen[$0]++' > "$DOTFILES/.zshrc.local.tmp"
  if [[ -s "$DOTFILES/.zshrc.local.tmp" ]]; then
    { echo "# Per-machine zsh config (untracked). Seeded from your old .zshrc/.bashrc."
      cat "$DOTFILES/.zshrc.local.tmp"; } > "$HOME/.zshrc.local"
    echo "    created ~/.zshrc.local"
  fi
  rm -f "$DOTFILES/.zshrc.local.tmp"
fi

# --- 2. apt packages
say "Checking apt packages"
missing=()
while read -r pkg; do
  [[ -z "$pkg" || "$pkg" == \#* ]] && continue
  dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done < "$DOTFILES/packages.txt"

if ((${#missing[@]})); then
  echo "    missing: ${missing[*]}"
  if sudo -n true 2>/dev/null || [[ -t 0 ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y "${missing[@]}"
  else
    warn "sudo needs your password. Run this yourself, then re-run ./install.sh:"
    echo "    sudo apt-get update && sudo apt-get install -y ${missing[*]}"
    exit 1
  fi
else
  echo "    all present"
fi

# --- 3. starship (official installer, user-local, no sudo)
say "Checking starship"
if command -v starship >/dev/null 2>&1 || [[ -x "$HOME/.local/bin/starship" ]]; then
  echo "    already installed"
else
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi

# --- 4. back up conflicts, then stow
say "Stowing: ${PACKAGES[*]}"
moved=0
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES/$pkg/"}"
    target="$HOME/$rel"
    if [[ -e "$target" || -L "$target" ]]; then
      [[ "$(readlink -f "$target")" == "$(readlink -f "$src")" ]] && continue
      mkdir -p "$BACKUP/$(dirname "$rel")"
      mv "$target" "$BACKUP/$rel"
      echo "    backed up ~/$rel -> .backup/$STAMP/$rel"
      moved=1
    fi
  done < <(find "$DOTFILES/$pkg" -type f -print0)
  stow --no-folding -d "$DOTFILES" -t "$HOME" -R "$pkg"
done
((moved)) || echo "    nothing needed backing up"

# --- 5. default shell
say "Checking login shell"
zsh_path="$(command -v zsh)"
current="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current" == "$zsh_path" ]]; then
  echo "    zsh is already your login shell"
elif [[ -t 0 ]]; then
  chsh -s "$zsh_path"      # prompts for your password
else
  warn "Not on a tty. Run this yourself (it asks for your password):"
  echo "    chsh -s $zsh_path"
fi

say "Done. Open a new terminal (or run: exec zsh)."
