# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Changed

- Project title renamed to **Kazumi 最大化/最小化插件**
  (English subtitle: Kazumi Window Controls).

### Documentation

- Rewrote `README.zh-CN.md` as a complete, self-contained Chinese guide:
  quick start, all three installation methods, build steps, verification and FAQ.
- Added `docs/BUILD.zh-CN.md`, the Chinese counterpart of the build guide.
- Added a Chinese callout and a language/documentation table to `README.md`,
  while keeping the English documentation unchanged.

## [1.1.0] - 2026-10-20

### Added

- **Portable Windows x64 build** (`Kazumi-2.3.9-Window-Controls-win64.zip`):
  extract and run, no Flutter/Visual Studio/Git required.
- **One-click patcher** (`Kazumi-Window-Controls-Patcher-v1.1.0.zip`):
  double-click `install.bat`, pick the Kazumi folder; automatic backup and
  `uninstall.bat` restore.
- Bilingual install guides: `INSTALL.md` (English) and `INSTALL.zh-CN.md` (简体中文).
- `SHA256SUMS.txt` for both packages.

### Documentation

- Includes the Chinese documentation work listed under Unreleased.

## [1.0.0] - 2026-10-20

### Added

- Minimize button (`Icons.remove`) next to the existing close button.
- Maximize / restore button (`Icons.crop_square` / `Icons.filter_none`) with live
  `WindowListener` state.
- Shared `WindowControlButtons` widget wired into the home, detail and `SysAppBar`
  title bars.
- Chinese/English documentation, build guide and screenshot set.

### Notes

- Pure Dart change; no native code, no changes to `windows/`, no new dependencies.
- Tested with Kazumi 2.3.9 on Windows 11 (Flutter 3.47.7).
