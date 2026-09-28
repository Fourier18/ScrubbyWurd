# Erases everything the ScrubbyWurd app has stored on this computer: its whole Chrome profile
# folder (saved list, settings, and any older copies Chrome still keeps in its storage files).
# The app itself stays installed; it starts fresh next time.
#
# The installer adds a Start menu shortcut, "Erase ScrubbyWurd data", that runs this.
# Add -Force to skip the confirmation (for scripts).

param([switch]$Force)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

$profileDir = Join-Path $env:LOCALAPPDATA 'Programs\ScrubbyWurd\chrome-profile'

if (-not $Force) {
    $answer = [System.Windows.Forms.MessageBox]::Show(
        "Erase everything ScrubbyWurd has saved on this computer, including your list?`n`nIf ScrubbyWurd is open, it will be closed first.",
        'Erase ScrubbyWurd data', 'YesNo', 'Warning')
    if ($answer -ne 'Yes') { exit }
}

# Close the app if it's open (only Chrome processes using ScrubbyWurd's own profile).
Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" |
    Where-Object { $_.CommandLine -like "*$profileDir*" } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

if (Test-Path $profileDir) { Remove-Item -Recurse -Force $profileDir }
$done = -not (Test-Path $profileDir)

if (-not $Force) {
    $msg = if ($done) { 'All ScrubbyWurd data has been erased.' } else { "Couldn't erase everything. Close ScrubbyWurd and try again." }
    [System.Windows.Forms.MessageBox]::Show($msg, 'Erase ScrubbyWurd data') | Out-Null
} else {
    if ($done) { 'erased' } else { 'not erased' }
}
