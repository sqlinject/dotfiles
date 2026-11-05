# ~/.zshrc -- managed in ~/dotfiles (package: zsh). Machine/secret stuff goes in ~/.zshrc.local.

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="${EDITOR:-vim}"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# Completion
autoload -Uz compinit && compinit -u

# Modules
for f in "$HOME/.zsh/aliases.zsh" "$HOME/.zsh/prompt.zsh"; do
  [[ -r "$f" ]] && source "$f"
done

# Untracked, per-machine overrides (tokens, nvm, keychain, ...)
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
