# Installs ScrubbyWurd as a desktop app on Windows: its own window, icon and Start menu
# entry, which can be pinned to the taskbar. No program is installed; the shortcut opens
# ScrubbyWurd.html in Microsoft Edge's app mode (no address bar or tabs).
#
# It uses a separate Edge profile just for ScrubbyWurd, with extensions and sync turned off,
# so no browser extension can see what you paste, and your list is kept apart from your
# normal browsing.
#
# Run from the folder that has ScrubbyWurd.html in it (or its tools folder):
#     powershell -ExecutionPolicy Bypass -File tools\install-windows-app.ps1
# Run it again after updating ScrubbyWurd.html to install the new version.
# To remove: delete the "ScrubbyWurd" shortcuts and %LOCALAPPDATA%\Programs\ScrubbyWurd.

$ErrorActionPreference = 'Stop'

$src = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $src 'ScrubbyWurd.html'))) { $src = $PSScriptRoot }
foreach ($f in 'ScrubbyWurd.html', 'ScrubbyWurd.ico') {
    if (-not (Test-Path (Join-Path $src $f))) { throw "Can't find $f next to this script." }
}

$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
          "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw "Microsoft Edge wasn't found." }

$dest = Join-Path $env:LOCALAPPDATA 'Programs\ScrubbyWurd'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item (Join-Path $src 'ScrubbyWurd.html'), (Join-Path $src 'ScrubbyWurd.ico') -Destination $dest -Force

$page = Join-Path $dest 'ScrubbyWurd.html'
$url = ([System.Uri]$page).AbsoluteUri
$profileDir = Join-Path $dest 'edge-profile'
# A new Edge profile can sign itself in with your Windows Microsoft account and sync your
# extensions into it. --disable-sync stops that, and --disable-extensions makes sure no
# extension can run in this window even if one gets there.
$arguments = "--user-data-dir=`"$profileDir`" --disable-extensions --disable-sync --no-first-run --no-default-browser-check --app=`"$url`""

$shell = New-Object -ComObject WScript.Shell
$places = @([Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop'))
foreach ($dir in $places) {
    $lnk = $shell.CreateShortcut((Join-Path $dir 'ScrubbyWurd.lnk'))
    $lnk.TargetPath = $edge
    $lnk.Arguments = $arguments
    $lnk.IconLocation = (Join-Path $dest 'ScrubbyWurd.ico')
    $lnk.WorkingDirectory = $dest
    $lnk.Description = 'ScrubbyWurd text redactor (offline)'
    $lnk.Save()
}

Write-Output "Installed to $dest"
Write-Output "Shortcuts: Start menu and Desktop ('ScrubbyWurd'). Right-click either one > Pin to taskbar."
