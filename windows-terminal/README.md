# Windows Terminal setup (manual fallback)

The font and colours are rendered by Windows Terminal, so they must be set on the Windows side.

## 1. Install the font on Windows (not just WSL)

JetBrainsMono Nerd Font: https://github.com/ryanoasis/nerd-fonts/releases/latest (download `JetBrainsMono.zip`).
Unzip, select all `.ttf` files, right-click, **Install for all users**. Or from PowerShell:

    winget install --id DEVCOM.JetBrainsMonoNerdFont

## 2. Automatic (preferred)

From WSL:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w ~/dotfiles/windows-terminal/apply.ps1)"

It backs up `settings.json` (as `settings.json.bak-<timestamp>`), then adds the scheme and sets three defaults.

## 3. Manual

Open Windows Terminal, then **Settings > Open JSON file**, and:

1. Add the contents of `callum-slate.json` as a new entry in the top-level `"schemes": [ ... ]` array (create the array if missing).
2. In `"profiles"` > `"defaults"` set:

       "defaults": {
           "colorScheme": "Callum Slate",
           "cursorShape": "filledBox",
           "font": { "face": "JetBrainsMono Nerd Font" }
       }

3. If a profile in `"list"` has its own `colorScheme`, `font` or `cursorShape`, remove it or it will override the defaults.
4. Save. Restart Windows Terminal if it doesn't update.

## Locations checked

- Store: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`
- Preview: `...WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json`
- Unpackaged: `%LOCALAPPDATA%\Microsoft\Windows Terminal\settings.json`
