# Changelog

All notable changes to this project are documented here.

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
