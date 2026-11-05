"""callum-slate palette for Python scripts.

Usage (from ~/Projects/scripts/*):
    import os, sys; sys.path.insert(0, os.path.expanduser("~/dotfiles/lib"))
    from palette import RED, GREEN, RESET
    print(f"{GREEN}ok{RESET}")

Hex values are mirrored in lib/palette.sh, starship.toml and
callum-slate.json -- change all of them together.
"""

HEX = {
    "bg": "#212733",
    "fg": "#c3cddb",
    "dim": "#4a5a70",
    "red": "#e0574f",
    "amber": "#d9b45b",
    "green": "#6fb47e",
    "teal": "#5fc9c6",
    "blue": "#5b9bd8",
    "pink": "#e060a3",
    "cursor": "#c3cddb",
}


def _fg(hex_: str) -> str:
    h = hex_.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    return f"\033[38;2;{r};{g};{b}m"


RED = _fg(HEX["red"])      # bad / stress
AMBER = _fg(HEX["amber"])  # middling / warning
GREEN = _fg(HEX["green"])  # good / calming
TEAL = _fg(HEX["teal"])    # system tags: [run] [cal]
BLUE = _fg(HEX["blue"])    # paths
PINK = _fg(HEX["pink"])    # prompt chevron
DIM = _fg(HEX["dim"])      # secondary text
RESET = "\033[0m"
