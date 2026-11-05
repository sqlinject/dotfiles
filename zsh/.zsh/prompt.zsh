# Starship prompt (config: ~/.config/starship.toml)
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Block cursor in the terminal (DECSCUSR 2 = steady block)
printf '\e[2 q'
