#!/usr/bin/env bash
# callum-slate palette: single source of truth for shell scripts.
# Source it:  source ~/dotfiles/lib/palette.sh
# Hex values are mirrored in starship/.config/starship.toml and
# windows-terminal/callum-slate.json -- change all three together.

PALETTE_BG="#212733"
PALETTE_FG="#c3cddb"
PALETTE_DIM="#4a5a70"
PALETTE_RED="#e0574f"
PALETTE_AMBER="#d9b45b"
PALETTE_GREEN="#6fb47e"
PALETTE_TEAL="#5fc9c6"
PALETTE_BLUE="#5b9bd8"
PALETTE_PINK="#e060a3"
PALETTE_CURSOR="#c3cddb"

# _pal_rgb "#rrggbb" -> truecolor foreground escape (real ESC byte)
_pal_rgb() {
  local h="${1#\#}"
  printf '\033[38;2;%d;%d;%dm' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

# Semantic colours (use with echo -e or printf %b)
RED="$(_pal_rgb "$PALETTE_RED")"      # bad / stress
AMBER="$(_pal_rgb "$PALETTE_AMBER")"  # middling / warning
GREEN="$(_pal_rgb "$PALETTE_GREEN")"  # good / calming
TEAL="$(_pal_rgb "$PALETTE_TEAL")"    # system tags: [run] [cal]
BLUE="$(_pal_rgb "$PALETTE_BLUE")"    # paths
PINK="$(_pal_rgb "$PALETTE_PINK")"    # prompt chevron
DIM="$(_pal_rgb "$PALETTE_DIM")"      # secondary text
RESET=$'\033[0m'
