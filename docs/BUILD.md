# Build guide

> **Don't want to build?** Two prebuilt packages are available in the
> [latest release](https://github.com/StarFall0220/kazumi-window-controls/releases/latest).
> The complete guide is in [INSTALL.md](../INSTALL.md).

## 0. Prebuilt packages (no build required)

Both packages are **Windows x64** and target **Kazumi 2.3.9**.

### Option A — Portable build

`Kazumi-2.3.9-Window-Controls-win64.zip` (~40 MB)

1. Download the zip from the latest release.
2. Extract the **whole folder** somewhere writable (do not run `kazumi.exe`
   directly from inside the archive).
3. Run `kazumi.exe`. The top-right corner shows `🕘 － □ ✕`:
   `－` minimize, `□` maximize / `❐` restore, `✕` close.

No Flutter, Visual Studio or Git is needed. Settings, history and downloads stay in
`%APPDATA%\com.example\kazumi` and are shared with any other Kazumi installation.

> **SmartScreen:** choose **More info → Run anyway**. The build is unsigned, exactly
> like the upstream Kazumi release.
>
> **Auto-update:** updating Kazumi overwrites `data/app.so`; re-apply the patcher
> afterwards, or keep using the portable build without in-app updates.

### Option B — One-click patcher

`Kazumi-Window-Controls-Patcher-v1.1.0.zip` (~6 MB)

1. **Fully exit Kazumi**, including the tray icon.
2. Extract the zip and double-click `install.bat`.
3. Select the folder that contains `kazumi.exe`
   (for example `D:\Kazumi_windows_2.3.9`).
4. Start Kazumi.

The patcher replaces only these two files:

```text
data\app.so
data\flutter_assets\fonts\MaterialIcons-Regular.otf
```

and copies both originals to `window-controls-backup-<timestamp>\` first.
`uninstall.bat` restores the latest backup.

Download checksums are in `SHA256SUMS.txt` in the same release.

## Requirements

| Tool | Version | Notes |
| --- | --- | --- |
| Flutter | **3.47.7** | The version pinned by Kazumi 2.3.9 (`pubspec.yaml` → `flutter: 3.47.7`) |
| Visual Studio 2022 | 17.x | Workload **Desktop development with C++** (MSVC, Windows SDK, CMake, Ninja) |
| Git | any | For cloning Kazumi and applying the patch |

```powershell
flutter --version   # must report 3.47.7 / Dart 3.13.5
flutter doctor -v   # "Visual Studio - develop Windows apps" must be green
```

## 1. Full build (recommended)

```powershell
git clone --branch 2.3.9 --depth 1 https://github.com/Predidit/Kazumi.git
cd Kazumi
git apply ..\patch\window-buttons.patch
flutter pub get
flutter build windows --release
```

The result is in `build\windows\x64\runner\Release\`. Copy that folder over an existing
Kazumi 2.3.9 installation (or run `kazumi.exe` from it directly).

### Signing credentials (optional)

Official builds pass four compile-time values for signed danmaku / mirror requests:

```powershell
flutter build windows --release `
  --dart-define=DANDANAPI_APPID=... `
  --dart-define=DANDANAPI_KEY=... `
  --dart-define=KAZUMI_APPID=... `
  --dart-define=KAZUMI_KEY=...
```

Without them the app still builds and runs; only requests that require a valid signature
are affected.

## 2. Snapshot-only build (advanced, no Visual Studio)

The window buttons live entirely in Dart. If you do not need to rebuild the C++ runner or
the plugins, you can rebuild only `data/app.so` and keep the official native libraries.

```powershell
cd Kazumi   # patched 2.3.9 checkout

# Encode every define as base64("KEY=VALUE"). flutter assemble expects base64 here.
# (Omit the -D arguments if you do not need signing credentials.)
$defs = @(
  "DANDANAPI_APPID=...",
  "DANDANAPI_KEY=...",
  "KAZUMI_APPID=...",
  "KAZUMI_KEY=..."
) | ForEach-Object { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($_)) }

flutter assemble --no-version-check --output=build `
  -dTargetPlatform=windows-x64 -dTrackWidgetCreation=false -dBuildMode=release `
  -dTreeShakeIcons=true -dDartObfuscation=false `
  -D $defs[0] -D $defs[1] -D $defs[2] -D $defs[3] `
  release_bundle_windows-x64_assets
```

Then copy **both** files into the existing installation:

```powershell
copy build\windows\app.so <Kazumi>\data\app.so
copy build\flutter_assets\fonts\MaterialIcons-Regular.otf `
     <Kazumi>\data\flutter_assets\fonts\MaterialIcons-Regular.otf
```

> **Icon font is mandatory.** The official build's `MaterialIcons-Regular.otf` is
> tree-shaken to the icons used by the original code. The new `－`, `□` and `❐` glyphs
> only exist in the font produced by your build. Replacing only `app.so` leaves the
> buttons blank.

> **Native asset hooks.** `flutter assemble` runs native-asset hooks for `ech_http` and
> `media_kit`, which compile C code and therefore need MSVC. If you have no C++ toolchain
> you would have to keep the native libraries/manifest from the official release and skip
> the hooks. That is unsupported and easy to get wrong — use the full build if possible.

## 3. Verify

1. Launch Kazumi. The top-right corner should show `🕘 － □ ✕`.
2. Click `－` → the window minimizes.
3. Click `□` → the window fills the work area and the icon becomes `❐`.
4. Click `❐` → the window returns to its previous size and position.
5. Enable “native window buttons” in settings → the custom buttons disappear and the
   native caption buttons are used instead.
