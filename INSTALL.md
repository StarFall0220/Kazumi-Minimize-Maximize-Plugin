<h1 align="center">Install without building</h1>

<p align="center">
  Prebuilt packages for <a href="https://github.com/Predidit/Kazumi">Kazumi 2.3.9</a> on Windows x64.
  No Flutter, no Visual Studio, no Git.
</p>

<p align="center">
  English · <a href="INSTALL.zh-CN.md">简体中文</a>
</p>

## Downloads

Grab the files from the [latest release](https://github.com/StarFall0220/Kazumi-Minimize-Maximize-Plugin/releases/latest):

| Package | Size | Good for |
| --- | --- | --- |
| `Kazumi-2.3.9-Window-Controls-win64.zip` | ~40 MB | **Portable build** — extract and run. No existing Kazumi needed. |
| `Kazumi-Window-Controls-Patcher-v1.1.0.zip` | ~6 MB | **One-click patcher** — you already have Kazumi 2.3.9 and want to update it in place. |
| `SHA256SUMS.txt` | tiny | Verify the downloads. |

## Option 1 — Portable build (simplest)

1. Download `Kazumi-2.3.9-Window-Controls-win64.zip`.
2. Extract the **whole folder** somewhere writable (for example `D:\Kazumi`).
   Do not run `kazumi.exe` directly from inside the zip.
3. Run `kazumi.exe`.
4. The top-right corner now shows `🕘 － □ ✕`:
   - `－` minimize
   - `□` maximize (turns into `❐`; click again to restore)
   - `✕` close (unchanged behaviour)

> If Windows SmartScreen says “Windows protected your PC”, click **More info** →
> **Run anyway**. The build is unsigned, exactly like the upstream Kazumi release.

> Kazumi's auto-update will overwrite this patch. After updating, apply the patcher
> again (or keep using the portable build and skip the in-app update).

## Option 2 — One-click patcher (keep your current install)

1. Download `Kazumi-Window-Controls-Patcher-v1.1.0.zip` and extract it.
2. **Fully exit Kazumi**, including the tray icon.
3. Double-click `install.bat`.
4. Select the Kazumi folder — the one containing `kazumi.exe`
   (for example `D:\Kazumi_windows_2.3.9`).
5. Wait for “安装完成 / Install complete”, then start Kazumi.

The patcher only replaces two files:

```text
data\app.so
data\flutter_assets\fonts\MaterialIcons-Regular.otf
```

Before touching anything it copies both originals to
`window-controls-backup-<timestamp>\` inside the Kazumi folder.

To undo, double-click `uninstall.bat`, select the same folder, and the latest backup is
restored.

> The icon font must be replaced together with `app.so`: the official release ships a
> tree-shaken `MaterialIcons-Regular.otf` that does not contain the new
> `－ / □ / ❐` glyphs. The patcher always replaces both.

## Requirements and compatibility

| Item | Value |
| --- | --- |
| OS | Windows 10 / 11 x64 |
| Kazumi | **2.3.9** only (the patcher warns on other versions) |
| Flutter / VS / Git | **not required** |
| Architecture | x64 (the upstream Windows release is x64) |

## Verify the download

```powershell
Get-FileHash .\Kazumi-2.3.9-Window-Controls-win64.zip -Algorithm SHA256
Get-FileHash .\Kazumi-Window-Controls-Patcher-v1.1.0.zip -Algorithm SHA256
```

Compare the output with `SHA256SUMS.txt` from the same release.

## FAQ

**The buttons do not appear.**
Make sure you launched the patched build (portable folder, or the folder you patched), and
that “native window buttons / system title bar” is **off** in Kazumi's settings. With the
native title bar enabled, Kazumi hides the custom close button and this patch hides with it.

**Icons are blank.**
Only `app.so` was replaced. Use the patcher, or copy
`data\flutter_assets\fonts\MaterialIcons-Regular.otf` from the same build.

**Is my data kept?**
Yes. Only the two files above are replaced. Settings, history and downloads live in
`%APPDATA%\com.example\kazumi` and are untouched.

**Does it work after a Kazumi update?**
No — an update replaces `data/app.so`. Re-run `install.bat` after updating.

**Why is the zip unsigned / flagged by antivirus?**
The upstream Kazumi Windows build is also unsigned. The package contains no installer,
no service and no network component of its own; it only copies two files. You can inspect
`install.ps1` — it is plain PowerShell.

## Source and license

- Source, patch and full documentation:
  <https://github.com/StarFall0220/Kazumi-Minimize-Maximize-Plugin>
- Upstream: <https://github.com/Predidit/Kazumi>
- License: **GPL-3.0** (same as Kazumi). The portable package is a redistribution of the
  GPL-licensed Kazumi build with this patch applied; the complete corresponding source is
  available in this repository and upstream.
