# Merges the "Callum Slate" scheme, JetBrainsMono Nerd Font and a block cursor into
# Windows Terminal's settings.json. Backs the file up first; touches nothing else.
#
# Run from WSL:   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w ~/dotfiles/windows-terminal/apply.ps1)"
# Re-running is safe: the scheme is replaced by name, the three defaults are just set again.

$ErrorActionPreference = 'Stop'

$schemeFile = Join-Path $PSScriptRoot 'callum-slate.json'
$candidates = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)
$settingsPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $settingsPath) { throw "Windows Terminal settings.json not found. See README.md for the manual steps." }
Write-Host "Using $settingsPath"

# 1. Backup
$backup = "$settingsPath.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
Copy-Item $settingsPath $backup
Write-Host "Backup: $backup"

# 2. Parse (strip whole-line // comments, which Windows PowerShell 5.1 can't read)
$raw = (Get-Content $settingsPath -Raw) -split "`n" | Where-Object { $_ -notmatch '^\s*//' }
$settings = ($raw -join "`n") | ConvertFrom-Json
$scheme = Get-Content $schemeFile -Raw | ConvertFrom-Json

# 3. Scheme: replace by name, or append
$schemes = @()
if ($settings.PSObject.Properties.Name -contains 'schemes') {
    $schemes = @($settings.schemes | Where-Object { $_.name -ne $scheme.name })
}
$schemes += $scheme
$settings | Add-Member -NotePropertyName schemes -NotePropertyValue $schemes -Force

# 4. Defaults: colour scheme, font face, cursor shape (other defaults keep their values)
$defaults = $settings.profiles.defaults
$defaults | Add-Member -NotePropertyName colorScheme -NotePropertyValue $scheme.name -Force
$defaults | Add-Member -NotePropertyName cursorShape -NotePropertyValue 'filledBox' -Force
$font = if ($defaults.PSObject.Properties.Name -contains 'font') { $defaults.font } else { [pscustomobject]@{} }
$font | Add-Member -NotePropertyName face -NotePropertyValue 'JetBrainsMono Nerd Font' -Force
$defaults | Add-Member -NotePropertyName font -NotePropertyValue $font -Force

# 5. Write back (UTF-8, no BOM)
$json = $settings | ConvertTo-Json -Depth 32
[System.IO.File]::WriteAllText($settingsPath, $json, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Done. Windows Terminal reloads settings automatically; restart it if the colours don't change."

# Heads-up: a profile with its own colorScheme/font/cursorShape overrides these defaults.
$overrides = @($settings.profiles.list | Where-Object { $_.colorScheme -or $_.cursorShape -or ($_.font -and $_.font.face) })
foreach ($p in $overrides) { Write-Host "Note: profile '$($p.name)' sets its own colorScheme/font/cursorShape and overrides the defaults." }
