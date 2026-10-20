<h1 align="center">Kazumi 窗口控制按钮</h1>

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
  简体中文 · <a href="README.md">English</a>
</p>

![Kazumi 右上角的最小化、最大化和关闭按钮](docs/images/home.png)

## 为什么做这个

Kazumi 在桌面端隐藏了系统标题栏（`TitleBarStyle.hidden`），自己绘制窗口按钮。
但原来的自定义标题栏只有**关闭**按钮，想最小化或最大化只能靠任务栏或快捷键。

这个项目在关闭按钮左侧补上两个按钮，不改任何原生代码，也不改变窗口样式。

## 特性

- 在原有「关闭」按钮左侧新增**最小化**和**最大化 / 还原**按钮。
- **尺寸、图标大小、颜色、垂直对齐完全一致**：三个按钮都是 Material `IconButton`
  （Flutter 的 `CloseButton` 内部同样基于 `IconButton`），自动继承同一套
  `IconButtonTheme` 和 `IconTheme`。
- **最大化状态实时同步**：用 `Win`+`↑` 或双击标题栏最大化时，图标也会在 `□` 与 `❐`
  之间切换，提示文字在「最大化」与「向下还原」之间切换。
- **零原生改动**：纯 Dart 实现，Windows / Linux / macOS 通用。
- 开启「系统标题栏」设置时自动隐藏，不会和系统原生按钮重复。

## 效果截图

| 首页 | 最大化（还原状态） |
| --- | --- |
| ![首页](docs/images/home.png) | ![最大化](docs/images/maximized.png) |
| **番剧详情页** | **还原按钮提示** |
| ![详情页](docs/images/detail.png) | ![提示](docs/images/restore-tooltip.png) |

## 实现方式

新增组件就是一行两个普通 `IconButton`：

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

`WindowControlButtons` 混入 `window_manager` 的 `WindowListener`，用真实窗口状态维护
`_isMaximized`。它被插入到所有桌面端关闭按钮之前：

| 文件 | 改动 |
| --- | --- |
| `lib/bean/appbar/window_control_buttons.dart` | **新增**：两个按钮的组件 |
| `lib/bean/appbar/sys_app_bar.dart` | 设置、搜索、下载、我的、时间线等页面 |
| `lib/pages/popular/popular_page.dart` | 首页「热门番组」 |
| `lib/pages/info/info_page.dart` | 番剧详情页 |

## 兼容性

- Kazumi **2.3.9**（补丁基于 tag `2.3.9` 生成）。
- Flutter **3.47.7**（Kazumi 2.3.9 锁定的版本）。
- 已在 **Windows 11** 的无边框标题栏上实测；只依赖 `window_manager`，
  Linux / macOS 理论上同样可用。
- 在 Kazumi 设置中开启「显示系统窗口按钮」后，自定义按钮会随关闭按钮一起隐藏，
  改用系统原生按钮。

## 安装

### 方式一：应用补丁（推荐）

```bash
git clone --branch 2.3.9 --depth 1 https://github.com/Predidit/Kazumi.git
cd Kazumi
git apply /path/to/patch/window-buttons.patch
flutter pub get
flutter build windows --release
```

也可以使用脚本：

```powershell
.\scripts\apply-patch.ps1
```

### 方式二：直接复制文件

把 [`src/`](src) 下的 4 个文件复制到 Kazumi 2.3.9 源码的对应路径。

### 只替换成品里的 app.so

如果你只重建 Dart 快照并替换 `data/app.so`：

> **必须同时替换 `data/flutter_assets/fonts/MaterialIcons-Regular.otf`**，且必须来自同一次构建。
> 官方发布包对图标字体做了子集化，原字体里没有 `Icons.remove`、`Icons.crop_square`、
> `Icons.filter_none` 的字形。只换 `app.so` 会出现“按钮占位但图标空白”。

## 构建说明

官方 Kazumi 构建会在编译期注入签名凭据：

```text
DANDANAPI_APPID, DANDANAPI_KEY, KAZUMI_APPID, KAZUMI_KEY
```

它们通过 `String.fromEnvironment` 读取，只影响需要签名的弹幕 / 镜像请求。
不提供也能正常编译；需要这些功能时请传入自己的值：

```bash
flutter build windows --release \
  --dart-define=DANDANAPI_APPID=... \
  --dart-define=DANDANAPI_KEY=... \
  --dart-define=KAZUMI_APPID=... \
  --dart-define=KAZUMI_KEY=...
```

完整构建与「只重建快照」的流程见 [docs/BUILD.md](docs/BUILD.md)。

## 验证结果

在 Windows 11 + Kazumi 2.3.9 上实测：

| 验证项 | 结果 |
| --- | --- |
| 三个按钮尺寸 / 颜色 / 基线一致 | ✅ 同一 `IconButton` 主题 |
| 点击最小化 | ✅ `IsIconic = true` |
| 点击最大化 | ✅ 铺满工作区，`IsZoomed = true` |
| 点击还原 | ✅ 恢复原窗口矩形，`IsZoomed = false` |
| 图标与提示随状态切换 | ✅ `□` ↔ `❐`，「最大化」↔「向下还原」 |
| 原有关闭按钮 | ✅ 行为不变 |

## 项目结构

```text
.
├── docs/
│   ├── BUILD.md
│   └── images/
├── patch/
│   └── window-buttons.patch
├── scripts/
│   └── apply-patch.ps1
└── src/
    └── lib/…                 # 4 个改动文件
```

## 卸载

反向应用补丁（`git apply -R patch/window-buttons.patch`），或恢复之前的 `app.so`
和图标字体即可，Kazumi 其余部分没有任何改动。

## 致谢

- [Predidit/Kazumi](https://github.com/Predidit/Kazumi) — 上游应用。
- [window_manager](https://pub.dev/packages/window_manager) — 窗口状态与标题栏控制。
- 所有反馈“缺少最小化/最大化按钮”的用户。

## 许可证

Kazumi 使用 **GNU General Public License v3.0**。本补丁属于衍生作品，
同样以 GPL-3.0 发布，详见 [LICENSE](LICENSE)。
