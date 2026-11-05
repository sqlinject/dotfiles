# Aliases -- each guarded so a missing tool never breaks the shell.

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -l --group-directories-first --git'
  alias la='eza -la --group-directories-first --git'
else
  alias ll='ls -lh'
  alias la='ls -lAh'
fi

# Ubuntu ships bat as "batcat"
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never --style=plain'
elif command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
  alias cat='batcat --paging=never --style=plain'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
