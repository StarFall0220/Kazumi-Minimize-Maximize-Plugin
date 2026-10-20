# 构建指南（中文）

本文是 [BUILD.md](BUILD.md) 的中文版，步骤一一对应。

> **不想自己构建？** 最新 [Release](https://github.com/StarFall0220/Kazumi-Minimize-Maximize-Plugin/releases/latest)
> 提供两个免编译成品，完整说明见 [INSTALL.zh-CN.md](../INSTALL.zh-CN.md)。

## 零、免编译成品（两种用法）

两个包都只面向 **Windows x64 + Kazumi 2.3.9**。

### 方式 A：便携版

`Kazumi-2.3.9-Window-Controls-win64.zip`（约 40 MB）

1. 从最新 Release 下载；
2. 把**整个文件夹**解压到可写目录（不要在压缩包里直接运行 `kazumi.exe`）；
3. 双击 `kazumi.exe`，右上角显示 `🕘 － □ ✕`：
   `－` 最小化、`□` 最大化 / `❐` 还原、`✕` 关闭。

不需要 Flutter / Visual Studio / Git。设置、历史记录、下载仍保存在
`%APPDATA%\com.example\kazumi`，与其他 Kazumi 安装共用。

> **SmartScreen**：点「更多信息」→「仍要运行」。构建和官方 Kazumi 一样没有签名。
>
> **自动更新**：更新 Kazumi 会覆盖 `data/app.so`，更新后重新运行补丁包即可；
> 或者直接使用便携版、不使用应用内更新。

### 方式 B：一键补丁包

`Kazumi-Window-Controls-Patcher-v1.1.0.zip`（约 6 MB）

1. **完全退出 Kazumi**（包括右下角托盘图标）；
2. 解压压缩包，双击 `install.bat`；
3. 选择包含 `kazumi.exe` 的文件夹（例如 `D:\Kazumi_windows_2.3.9`）；
4. 启动 Kazumi。

补丁只替换这两个文件：

```text
data\app.so
data\flutter_assets\fonts\MaterialIcons-Regular.otf
```

替换前会自动备份到 `window-controls-backup-<时间戳>\`；
双击 `uninstall.bat` 可恢复最近一次备份。

下载校验值见同一 Release 里的 `SHA256SUMS.txt`。

## 环境要求

| 工具 | 版本 | 说明 |
| --- | --- | --- |
| Flutter | **3.47.7** | Kazumi 2.3.9 的 `pubspec.yaml` 锁定版本，不要用其他版本 |
| Visual Studio 2022 | 17.x | 必须勾选 **「使用 C++ 的桌面开发」** 工作负载（MSVC、Windows SDK、CMake、Ninja） |
| Git | 任意 | 克隆源码、应用补丁 |

```powershell
flutter --version    # 应为 3.47.7 / Dart 3.13.5
flutter doctor -v    # “Visual Studio - develop Windows apps” 必须为绿色
```

如果 `flutter doctor` 里 Visual Studio 一项是红色，先安装 Visual Studio 2022
并勾选 C++ 工作负载，否则 `flutter build windows` 无法进行。

## 一、完整构建（推荐）

```powershell
git clone --branch 2.3.9 --depth 1 https://github.com/Predidit/Kazumi.git
cd Kazumi

# 应用补丁（也可以在仓库根目录执行 .\scripts\apply-patch.ps1 自动完成克隆 + 打补丁）
curl -L https://github.com/StarFall0220/Kazumi-Minimize-Maximize-Plugin/raw/main/patch/window-buttons.patch -o window-buttons.patch
git apply window-buttons.patch

flutter pub get
flutter build windows --release
```

产物目录：

```text
build\windows\x64\runner\Release\
```

把这个目录覆盖到已有的 Kazumi 2.3.9 安装目录，或直接运行其中的 `kazumi.exe`。

### 签名凭据（可选）

官方 Kazumi 在 CI 中通过 `--dart-define` 注入四个签名凭据：

```text
DANDANAPI_APPID
DANDANAPI_KEY
KAZUMI_APPID
KAZUMI_KEY
```

它们只影响需要签名的弹幕 / 镜像请求。不提供也能编译和运行，
但相关接口可能返回 401/403。需要时这样构建：

```powershell
flutter build windows --release `
  --dart-define=DANDANAPI_APPID=... `
  --dart-define=DANDANAPI_KEY=... `
  --dart-define=KAZUMI_APPID=... `
  --dart-define=KAZUMI_KEY=...
```

## 二、只重建 Dart 快照（进阶，不需要 Visual Studio）

窗口按钮完全位于 Dart 层。如果你不想重编 C++ runner 和插件，可以只重建
`data/app.so`，原生 DLL 全部复用官方文件。

### 1. 生成 app.so

```powershell
cd Kazumi   # 已打补丁的 2.3.9 源码

# flutter assemble 的 -D 要求传 base64("KEY=VALUE")，不是明文
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

如果不需要签名凭据，可以去掉四个 `-D` 参数。

产物：

```text
build\windows\app.so
build\flutter_assets\fonts\MaterialIcons-Regular.otf
```

### 2. 替换到成品

```powershell
copy build\windows\app.so <Kazumi>\data\app.so
copy build\flutter_assets\fonts\MaterialIcons-Regular.otf `
     <Kazumi>\data\flutter_assets\fonts\MaterialIcons-Regular.otf
```

> **必须同时替换图标字体。**
> 官方发布包对 `MaterialIcons-Regular.otf` 做了图标子集化，原字体中不包含
> `Icons.remove`、`Icons.crop_square`、`Icons.filter_none` 的字形。
> 只替换 `app.so` 会出现“按钮占位、点击有效，但图标空白”。

> **原生资源 hook 的限制。**
> `flutter assemble` 会执行 `ech_http`、`media_kit` 等包的原生资源 hook，
> 这些 hook 在 Windows 上需要 MSVC 来编译 C 代码。没有 C++ 工具链时会失败。
> 这种情况下只能保留官方 release 里的原生 DLL 和 `NativeAssetsManifest.json`，
> 跳过 hook，只替换 `app.so` —— 这属于不受支持的偏门做法，容易出错，
> 有 Visual Studio 时请优先使用「完整构建」。

## 三、验证

1. 启动 Kazumi，右上角应显示 `🕘 － □ ✕`；
2. 点 `－`：窗口最小化；
3. 点 `□`：窗口铺满工作区，图标变成 `❐`；
4. 点 `❐`：窗口恢复原来的大小和位置；
5. 在设置里开启「系统标题栏」：自定义按钮消失，出现 Windows 原生按钮。

## 四、常见构建问题

### `flutter --version` 不是 3.47.7

Kazumi 2.3.9 对 Flutter 版本有约束。请安装 3.47.7，或在项目里使用 FVM 固定版本。
版本不一致时 `flutter pub get` 可能直接失败，或者构建出的快照与官方
`flutter_windows.dll` 不兼容。

### `Building with plugins requires symlink support`

Windows 没有开启「开发者模式」时，Flutter 创建插件符号链接会失败。
打开「设置 → 系统 → 开发者选项 → 开发人员模式」即可。

### `Install Visual Studio C++ build tools`

这是 `ech_http` / `media_kit` 的原生资源 hook 在找 MSVC。
安装 Visual Studio 2022 的 C++ 工作负载，或改用完整构建。

### 构建成功但按钮图标空白

只替换了 `app.so`。把同一次构建的 `MaterialIcons-Regular.otf` 也替换过去。

### 替换后程序打不开 / 白屏

`app.so` 必须由**完全相同版本**的 Flutter（3.47.7）构建，否则引擎无法加载快照。
请确认 `flutter --version`，并清理 `build/` 后重新构建。
