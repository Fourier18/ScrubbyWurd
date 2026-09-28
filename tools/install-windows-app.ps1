# Installs ScrubbyWurd as a desktop app on Windows: its own window, icon and Start menu
# entry, which can be pinned to the taskbar. No program is installed; the shortcut opens
# ScrubbyWurd.html in Google Chrome's app mode (no address bar or tabs).
#
# It uses a separate Chrome profile just for ScrubbyWurd: not signed in to any account,
# with extensions and sync turned off, so no browser extension can see what you paste and
# your list is kept apart from your normal browsing. (Microsoft Edge isn't used: a new Edge
# profile signs itself in to your Windows Microsoft account, even when told not to.)
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

$chrome = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
            "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
            "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") |
          Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { throw "Google Chrome wasn't found. Install Chrome, or just open ScrubbyWurd.html directly." }

$dest = Join-Path $env:LOCALAPPDATA 'Programs\ScrubbyWurd'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item (Join-Path $src 'ScrubbyWurd.html'), (Join-Path $src 'ScrubbyWurd.ico') -Destination $dest -Force
# Remove the Edge profile an earlier version of this script used (it could be signed in).
Remove-Item -Recurse -Force (Join-Path $dest 'edge-profile') -ErrorAction SilentlyContinue

$page = Join-Path $dest 'ScrubbyWurd.html'
$url = ([System.Uri]$page).AbsoluteUri
$profileDir = Join-Path $dest 'chrome-profile'
$arguments = "--user-data-dir=`"$profileDir`" --disable-extensions --disable-sync --no-first-run --no-default-browser-check --app=`"$url`""

# Windows groups a window under a pinned shortcut only when both carry the same app ID
# (AppUserModelID). Chrome picks the ID for this window itself, so it's read from a running
# ScrubbyWurd window and written onto the shortcuts; otherwise a pin shows Chrome's icon.
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class AppId {
    delegate bool EnumProc(IntPtr hwnd, IntPtr lParam);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc cb, IntPtr lParam);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr hwnd);
    [DllImport("shell32.dll")] static extern int SHGetPropertyStoreForWindow(IntPtr hwnd, ref Guid iid, out IPropertyStore store);

    [ComImport, Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IPropertyStore {
        void GetCount(out uint count);
        void GetAt(uint index, out PropertyKey key);
        void GetValue(ref PropertyKey key, out PropVariant value);
        void SetValue(ref PropertyKey key, ref PropVariant value);
        void Commit();
    }
    [ComImport, Guid("0000010B-0000-0000-C000-000000000046"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IPersistFile {
        void GetClassID(out Guid clsid);
        [PreserveSig] int IsDirty();
        void Load([MarshalAs(UnmanagedType.LPWStr)] string file, uint mode);
        void Save([MarshalAs(UnmanagedType.LPWStr)] string file, bool remember);
        void SaveCompleted([MarshalAs(UnmanagedType.LPWStr)] string file);
        void GetCurFile([MarshalAs(UnmanagedType.LPWStr)] out string file);
    }
    [StructLayout(LayoutKind.Sequential, Pack = 4)]
    struct PropertyKey { public Guid fmtid; public uint pid; }
    [StructLayout(LayoutKind.Explicit, Size = 16)]
    struct PropVariant { [FieldOffset(0)] public ushort vt; [FieldOffset(8)] public IntPtr ptr; }
    const ushort VT_LPWSTR = 31;
    static PropertyKey AppUserModelId = new PropertyKey { fmtid = new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3"), pid = 5 };

    // The app ID of the first visible window owned by one of these processes.
    public static string FromWindows(uint[] pids) {
        var wanted = new HashSet<uint>(pids);
        string found = null;
        EnumWindows((hwnd, l) => {
            uint pid;
            GetWindowThreadProcessId(hwnd, out pid);
            if (!wanted.Contains(pid) || !IsWindowVisible(hwnd)) return true;
            Guid iid = typeof(IPropertyStore).GUID;
            IPropertyStore store;
            if (SHGetPropertyStoreForWindow(hwnd, ref iid, out store) != 0) return true;
            PropVariant v;
            store.GetValue(ref AppUserModelId, out v);
            if (v.vt == VT_LPWSTR && v.ptr != IntPtr.Zero) { found = Marshal.PtrToStringUni(v.ptr); return false; }
            return true;
        }, IntPtr.Zero);
        return found;
    }

    public static void SetOnShortcut(string lnkPath, string id) {
        object link = Activator.CreateInstance(Type.GetTypeFromCLSID(new Guid("00021401-0000-0000-C000-000000000046")));
        ((IPersistFile)link).Load(lnkPath, 2);
        var v = new PropVariant { vt = VT_LPWSTR, ptr = Marshal.StringToCoTaskMemUni(id) };
        try {
            ((IPropertyStore)link).SetValue(ref AppUserModelId, ref v);
            ((IPropertyStore)link).Commit();
            ((IPersistFile)link).Save(lnkPath, true);
        } finally { Marshal.FreeCoTaskMem(v.ptr); }
    }
}
'@

function Get-AppPids { @(Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" |
    Where-Object { $_.CommandLine -like "*$profileDir*" -and $_.CommandLine -notlike '*--type=*' } |
    ForEach-Object { [uint32]$_.ProcessId }) }

$appId = $null
$pids = Get-AppPids
$launched = $false
if (-not $pids) {
    # Not running: open it off-screen for a moment just to read the ID Chrome gives it.
    Start-Process $chrome -ArgumentList "$arguments --window-position=-32000,-32000"
    $launched = $true
}
for ($i = 0; $i -lt 30 -and -not $appId; $i++) {
    Start-Sleep -Milliseconds 500
    $pids = Get-AppPids
    if ($pids) { $appId = [AppId]::FromWindows([uint32[]]$pids) }
}
if ($launched) {
    Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -like "*$profileDir*" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

$shell = New-Object -ComObject WScript.Shell
$places = @([Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop'))
foreach ($dir in $places) {
    $path = Join-Path $dir 'ScrubbyWurd.lnk'
    $lnk = $shell.CreateShortcut($path)
    $lnk.TargetPath = $chrome
    $lnk.Arguments = $arguments
    $lnk.IconLocation = (Join-Path $dest 'ScrubbyWurd.ico')
    $lnk.WorkingDirectory = $dest
    $lnk.Description = 'ScrubbyWurd text redactor (offline)'
    $lnk.Save()
    if ($appId) { [AppId]::SetOnShortcut($path, $appId) }
}

# "Erase ScrubbyWurd data": deletes the app's whole Chrome profile folder, including older
# copies Chrome keeps in its storage files, which the page itself can't reach.
Copy-Item (Join-Path $PSScriptRoot 'erase-app-data.ps1') -Destination $dest -Force
$erase = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Programs')) 'Erase ScrubbyWurd data.lnk'))
$erase.TargetPath = (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe')
$erase.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$(Join-Path $dest 'erase-app-data.ps1')`""
$erase.IconLocation = (Join-Path $dest 'ScrubbyWurd.ico')
$erase.Description = 'Erase everything ScrubbyWurd has saved on this computer'
$erase.Save()

Write-Output "Installed to $dest"
if ($appId) { Write-Output "Taskbar app ID: $appId" }
else { Write-Output "Couldn't read the window's app ID, so a taskbar pin may show Chrome's icon. Run this script again to retry." }
Write-Output "Shortcuts: Start menu and Desktop ('ScrubbyWurd'). Pin it from the Start menu (right-click > Pin to taskbar), not from the open window."
