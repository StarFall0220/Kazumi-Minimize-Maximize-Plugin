<h1 align="center">Kazumi 最大化/最小化插件</h1>

<p align="center">
  为 <a href="https://github.com/Predidit/Kazumi">Kazumi</a> 的无边框标题栏补上「最小化 / 最大化 / 还原」按钮，
  尺寸、风格、对齐方式与旁边的关闭按钮完全一致。
</p>

<p align="center">
  <a href="https://github.com/Predidit/Kazumi"><img alt="Kazumi" src="https://img.shields.io/badge/Kazumi-2.3.9-4CAF50"></a>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.47.7-02569B?logo=flutter">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey">
  <img alt="License" src="https://img.shields.io/badge/License-GPL--3.0-blue">
</p>

<p align="center">
  <b>简体中文完整说明</b> · <a href="README.md">English</a>
</p>

> 这是一份**独立、完整的中文说明**，英文原文保留在 [README.md](README.md)。
> 详细的构建步骤见 [docs/BUILD.zh-CN.md](docs/BUILD.zh-CN.md)。

![Kazumi 右上角的最小化、最大化和关闭按钮](docs/images/home.png)

## 目录

- [这个补丁解决什么问题](#这个补丁解决什么问题)
- [功能特性](#功能特性)
- [效果截图](#效果截图)
- [工作原理](#工作原理)
- [改动清单](#改动清单)
- [兼容性](#兼容性)
- [安装](#安装)
- [构建](#构建)
- [验证结果](#验证结果)
- [常见问题](#常见问题)
- [项目结构](#项目结构)
- [卸载](#卸载)
- [致谢与许可证](#致谢与许可证)

## 这个补丁解决什么问题

Kazumi 在桌面端使用无边框窗口（`window_manager` 的 `TitleBarStyle.hidden`），
标题栏由 Flutter 自己绘制。但原版的自定义标题栏只有**关闭**按钮：

- 想最小化 → 只能点任务栏，或按 `Win` + `↓`
- 想最大化 → 只能双击标题栏，或按 `Win` + `↑`

这个补丁在关闭按钮左侧补上**最小化**和**最大化 / 还原**两个按钮，
不改任何 C++ / 原生代码，也不改变窗口样式，纯 Dart 实现。

> 本仓库只包含**源码补丁和说明**，不提供成品二进制。
> 需要成品请按下面的步骤自行构建，或把补丁应用到已有的 2.3.9 源码。

## 功能特性

- **位置**：紧挨原有「关闭」按钮的左侧，顺序为 `最小化 → 最大化/还原 → 关闭`。
- **尺寸与风格完全一致**：三个按钮都是 Material `IconButton`
  （Flutter 的 `CloseButton` 内部同样基于 `IconButton`），自动继承同一套
  `IconButtonTheme` / `IconTheme`，因此图标大小、颜色、点击区域和垂直基线天然对齐。
- **最大化状态实时同步**：点击按钮、双击标题栏、`Win` + `↑` 等方式最大化时，
  图标都会在 `□` 与 `❐` 之间切换，悬停提示在「最大化」与「向下还原」之间切换。
- **纯 Dart，零原生改动**：没有新增依赖，没有修改 `windows/`、`CMakeLists.txt` 或插件。
- **不重复**：在 Kazumi 设置里开启「显示系统窗口按钮 / 系统标题栏」时，
  自定义按钮会随自定义关闭按钮一起隐藏，改用 Windows 原生按钮。

## 效果截图

| 首页 | 最大化（还原状态） |
| --- | --- |
| ![首页](docs/images/home.png) | ![最大化](docs/images/maximized.png) |
| **番剧详情页** | **还原按钮悬停提示** |
| ![详情页](docs/images/detail.png) | ![提示](docs/images/restore-tooltip.png) |

## 工作原理

核心就是一个 `Row`，里面放两个普通 `IconButton`：

```dart
IconButton(
  tooltip: '最小化',
  onPressed: () => windowManager.minimize(),
  icon: const Icon(Icons.remove),
),
IconButton(
  tooltip: _isMaximized ? '向下还原' : '最大化',
  onPressed: _toggleMaximize,
  icon: Icon(_isMaximized ? Icons.filter_none : Icons.crop_square),
),
```

`WindowControlButtons` 混入 `window_manager` 的 `WindowListener`：

1. `onWindowMaximize` / `onWindowUnmaximize` 更新 `_isMaximized`；
2. 初始化时用 `windowManager.isMaximized()` 同步一次真实状态；
3. 点击最大化按钮时先 `isMaximized()` 判断，再调用 `maximize()` 或 `unmaximize()`。

这样即使窗口是被系统快捷键最大化的，图标也不会不同步。

## 改动清单

| 文件 | 改动 |
| --- | --- |
| `lib/bean/appbar/window_control_buttons.dart` | **新增**：`WindowControlButtons` 组件（最小化 + 最大化/还原） |
| `lib/bean/appbar/sys_app_bar.dart` | 在关闭按钮前插入组件；覆盖设置、搜索、下载、我的、时间线等所有使用 `SysAppBar` 的页面 |
| `lib/pages/popular/popular_page.dart` | 首页「热门番组」标题栏接入 |
| `lib/pages/info/info_page.dart` | 番剧详情页标题栏接入 |

完整的 diff 见 [`patch/window-buttons.patch`](patch/window-buttons.patch)，
改动后的 4 个文件也放在 [`src/`](src) 里，方便直接对照。

## 兼容性

| 项目 | 说明 |
| --- | --- |
| Kazumi 版本 | **2.3.9**（补丁基于 tag `2.3.9` 生成；其他版本可能可以打上，但不保证） |
| Flutter | **3.47.7**（Kazumi 2.3.9 的 `pubspec.yaml` 锁定版本） |
| 已验证平台 | **Windows 11**，无边框标题栏模式 |
| 理论支持 | Linux / macOS（只依赖 `window_manager`，但未实机验证） |
| 原生标题栏模式 | 自动隐藏自定义按钮，使用系统按钮，不会重复 |
| 自动更新 | 更新 Kazumi 会覆盖 `data/app.so`，更新后需要重新打补丁 / 替换文件 |

## 安装

### 方式 A：应用补丁（推荐）

```bash
# 1. 克隆 Kazumi 2.3.9 源码
git clone --branch 2.3.9 --depth 1 https://github.com/Predidit/Kazumi.git
cd Kazumi

# 2. 下载并应用补丁
curl -L https://github.com/StarFall0220/kazumi-window-controls/raw/main/patch/window-buttons.patch -o window-buttons.patch
git apply window-buttons.patch

# 3. 拉依赖并构建
flutter pub get
flutter build windows --release
```

Windows 下也可以用仓库自带脚本（会自动克隆 2.3.9 并打补丁）：

```powershell
.\scripts\apply-patch.ps1
```

### 方式 B：直接复制文件

把 [`src/`](src) 下的 4 个文件，按相同相对路径复制到 Kazumi 2.3.9 源码中：

```text
src/lib/bean/appbar/window_control_buttons.dart
src/lib/bean/appbar/sys_app_bar.dart
src/lib/pages/popular/popular_page.dart
src/lib/pages/info/info_page.dart
```

### 方式 C：只替换成品里的 app.so（进阶）

如果你不想装 Visual Studio，只想重建 Dart 快照：

1. 按 [构建](#构建) 里的「只重建 Dart 快照」生成 `build/windows/app.so`；
2. 用新的 `app.so` 覆盖成品目录的 `data/app.so`；
3. **同时**用本次构建产出的
   `build/flutter_assets/fonts/MaterialIcons-Regular.otf`
   覆盖 `data/flutter_assets/fonts/MaterialIcons-Regular.otf`。

> **为什么必须换字体？**
> 官方发布包对 `MaterialIcons-Regular.otf` 做了图标子集化，原字体里没有
> `Icons.remove`、`Icons.crop_square`、`Icons.filter_none` 这三个字形。
> 只换 `app.so` 的结果是：按钮位置和点击都正常，但图标是空白的。

> **注意**：Kazumi 自动更新会整体覆盖 `data/`，更新后本补丁会失效，需要重新替换。

## 构建

### 环境要求

| 工具 | 版本 | 备注 |
| --- | --- | --- |
| Flutter | **3.47.7** | 必须与 Kazumi 2.3.9 锁定版本一致 |
| Visual Studio 2022 | 17.x | 工作负载勾选「使用 C++ 的桌面开发」 |
| Git | 任意 | 克隆源码、应用补丁 |

```powershell
flutter --version   # 应显示 3.47.7 / Dart 3.13.5
flutter doctor -v   # "Visual Studio - develop Windows apps" 必须为绿色
```

### 完整构建（推荐）

```powershell
cd Kazumi
flutter pub get
flutter build windows --release
```

产物在 `build\windows\x64\runner\Release\`。

### 官方签名凭据（可选）

官方 Kazumi 在 CI 中通过 `--dart-define` 注入四个签名凭据：

```text
DANDANAPI_APPID, DANDANAPI_KEY, KAZUMI_APPID, KAZUMI_KEY
```

它们只影响需要签名的弹幕 / 镜像请求，不提供也能正常编译和运行。
需要时这样传：

```powershell
flutter build windows --release `
  --dart-define=DANDANAPI_APPID=... `
  --dart-define=DANDANAPI_KEY=... `
  --dart-define=KAZUMI_APPID=... `
  --dart-define=KAZUMI_KEY=...
```

### 只重建 Dart 快照（不需要 Visual Studio）

```powershell
flutter assemble --no-version-check --output=build `
  -dTargetPlatform=windows-x64 -dTrackWidgetCreation=false -dBuildMode=release `
  -dTreeShakeIcons=true -dDartObfuscation=false `
  release_bundle_windows-x64_assets
```

注意 `flutter assemble` 的 `-D` 要求传入 **base64("KEY=VALUE")**，
而且 `media_kit` / `ech_http` 的原生资源 hook 在 Windows 上需要 MSVC。
完整的参数、限制和替代方案见：

- [docs/BUILD.zh-CN.md](docs/BUILD.zh-CN.md)（中文）
- [docs/BUILD.md](docs/BUILD.md)（English）

## 验证结果

在 Windows 11 + Kazumi 2.3.9 + Flutter 3.47.7 上实测：

| 验证项 | 结果 |
| --- | --- |
| 三个按钮尺寸 / 颜色 / 基线一致 | ✅ 同一 `IconButton` 主题 |
| 点击最小化 | ✅ `IsIconic = true`，窗口最小化到任务栏 |
| 点击最大化 | ✅ 窗口铺满工作区，`IsZoomed = true` |
| 点击还原 | ✅ 恢复原窗口矩形，`IsZoomed = false` |
| 图标与提示随状态切换 | ✅ `□` ↔ `❐`，「最大化」↔「向下还原」 |
| 原有关闭按钮 | ✅ 行为不变（退出确认 / 最小化到托盘设置仍然生效） |
| 详情页、设置页等 | ✅ 同样显示三个按钮 |

## 常见问题

### 1. 右上角没有出现新按钮

- 确认运行的是**桌面端**（Windows / Linux / macOS），不是手机端；
- 确认 Kazumi 设置里没有开启「显示系统窗口按钮 / 系统标题栏」——
  开启后自定义按钮会隐藏，这是预期行为；
- 确认补丁打在了 2.3.9 源码上，并且重新构建 / 替换了 `data/app.so`。

### 2. 按钮有位置和点击反馈，但图标是空白

只替换了 `app.so`，没有替换图标字体。请把同一次构建产出的
`MaterialIcons-Regular.otf` 一起复制到 `data/flutter_assets/fonts/`。

### 3. 最大化后窗口超出屏幕 / 任务栏被盖住

这是 Kazumi 无边框窗口 + `window_manager` 的既有行为，与本补丁无关。
补丁只是调用 `windowManager.maximize()` / `unmaximize()`，没有修改窗口样式。

### 4. 弹幕或镜像搜索失效

官方发布包在编译时通过 `--dart-define` 注入签名凭据。
自行重新编译时如果不传这四个值，需要签名的请求会失败。
请使用你自己的 `DANDANAPI_APPID / DANDANAPI_KEY / KAZUMI_APPID / KAZUMI_KEY`。

### 5. 支持 Kazumi 2.3.8 / 2.4.x 吗

补丁基于 **2.3.9**。其他版本如果标题栏相关文件没有大改，`git apply` 可能仍能成功；
失败时请按 [`src/`](src) 里的 4 个文件手动对照修改，通常只需要在关闭按钮前加一行
`WindowControlButtons`。

### 6. 如何恢复原版

- 源码：`git apply -R patch/window-buttons.patch`
- 成品：恢复你备份的 `data/app.so` 和 `data/flutter_assets/fonts/MaterialIcons-Regular.otf`
- 或者直接重新安装官方 2.3.9

### 7. 会不会影响 Kazumi 自动更新

不影响自动更新逻辑，但更新会覆盖 `data/`，更新后自定义按钮会消失，需要重新应用补丁。

## 项目结构

```text
.
├── README.md                 # 英文主页
├── README.zh-CN.md           # 中文完整说明（本文件）
├── CHANGELOG.md
├── NOTICE.md                 # 上游归属与 GPL 声明
├── LICENSE                   # GPL-3.0
├── docs/
│   ├── BUILD.md              # 英文构建指南
│   ├── BUILD.zh-CN.md        # 中文构建指南
│   └── images/               # 效果截图
├── patch/
│   └── window-buttons.patch  # 可直接 git apply 的补丁
├── scripts/
│   └── apply-patch.ps1       # 克隆 2.3.9 并自动打补丁
└── src/
    └── lib/…                 # 4 个改动后的源码文件
```

## 卸载

```bash
git apply -R patch/window-buttons.patch
```

或者恢复备份的 `app.so` 与 `MaterialIcons-Regular.otf`。
Kazumi 其余部分没有任何改动。

## 致谢与许可证

- [Predidit/Kazumi](https://github.com/Predidit/Kazumi) — 上游应用；
- [window_manager](https://pub.dev/packages/window_manager) — 窗口状态与标题栏控制；
- 所有反馈“缺少最小化 / 最大化按钮”的用户。

Kazumi 使用 **GNU General Public License v3.0**。本补丁属于衍生作品，
同样以 GPL-3.0 发布，详见 [LICENSE](LICENSE) 与 [NOTICE.md](NOTICE.md)。
