<h1 align="center">免编译安装（成品）</h1>

<p align="center">
  面向 Windows x64 的 <a href="https://github.com/Predidit/Kazumi">Kazumi 2.3.9</a> 成品包。
  不需要 Flutter、Visual Studio 或 Git。
</p>

<p align="center">
  <a href="INSTALL.md">English</a> · 简体中文
</p>

## 下载

从 [最新 Release](https://github.com/StarFall0220/kazumi-window-controls/releases/latest) 下载：

| 文件 | 大小 | 适合谁 |
| --- | --- | --- |
| `Kazumi-2.3.9-Window-Controls-win64.zip` | 约 40 MB | **便携版**：解压即用，不需要事先安装 Kazumi |
| `Kazumi-Window-Controls-Patcher-v1.1.0.zip` | 约 6 MB | **一键补丁包**：已经装了 Kazumi 2.3.9，想直接给现有安装打补丁 |
| `SHA256SUMS.txt` | 很小 | 校验下载文件是否完整 |

## 方式一：便携版（最简单）

1. 下载 `Kazumi-2.3.9-Window-Controls-win64.zip`；
2. 把**整个文件夹**解压到可写目录（例如 `D:\Kazumi`）；
   **不要**在压缩包里直接双击 `kazumi.exe`；
3. 双击 `kazumi.exe` 启动；
4. 右上角会显示 `🕘 － □ ✕`：
   - `－` 最小化
   - `□` 最大化（变成 `❐`，再点一次还原）
   - `✕` 关闭（行为与官方一致）

> 首次运行若弹出 Windows SmartScreen「Windows 已保护你的电脑」，
> 点「更多信息」→「仍要运行」即可。这个构建和官方 Kazumi 一样没有代码签名。

> Kazumi 的自动更新会覆盖补丁。更新后重新运行补丁包即可；
> 或者干脆使用便携版，不点应用内更新。

## 方式二：一键补丁包（保留现有安装）

1. 下载 `Kazumi-Window-Controls-Patcher-v1.1.0.zip` 并解压；
2. **完全退出 Kazumi**（包括右下角托盘图标）；
3. 双击 `install.bat`；
4. 在弹出的文件夹选择框里选中 Kazumi 目录 —— 就是包含 `kazumi.exe` 的那一层
   （例如 `D:\Kazumi_windows_2.3.9`）；
5. 看到「安装完成！Install complete!」后，启动 Kazumi 即可。

补丁只会替换两个文件：

```text
data\app.so
data\flutter_assets\fonts\MaterialIcons-Regular.otf
```

替换前会自动把原文件备份到 Kazumi 目录下的
`window-controls-backup-<时间戳>\`，不会动设置、历史记录、下载或插件。

卸载：双击 `uninstall.bat`，选择同一个 Kazumi 目录，会自动恢复最近一次备份。

> 必须同时替换图标字体：官方发布包对 `MaterialIcons-Regular.otf` 做过子集化，
> 原字体里没有 `－ / □ / ❐` 三个字形。只换 `app.so` 会出现“按钮占位但图标空白”。
> 补丁包已经自动处理，无需手动操作。

## 环境与兼容性

| 项目 | 要求 |
| --- | --- |
| 系统 | Windows 10 / 11 x64 |
| Kazumi | **仅 2.3.9**（其他版本会给出警告，可能不兼容） |
| Flutter / VS / Git | **都不需要** |
| 架构 | x64（与官方 Windows 发布包一致） |

## 校验下载

```powershell
Get-FileHash .\Kazumi-2.3.9-Window-Controls-win64.zip -Algorithm SHA256
Get-FileHash .\Kazumi-Window-Controls-Patcher-v1.1.0.zip -Algorithm SHA256
```

把输出与同一次 Release 里的 `SHA256SUMS.txt` 对比即可。

## 常见问题

**1. 右上角没有出现新按钮**
确认启动的是打过补丁的版本；并检查 Kazumi 设置里是否开启了「系统标题栏 / 显示系统窗口按钮」。
开启后官方会隐藏自定义关闭按钮，本补丁的按钮也会一起隐藏，这是预期行为。

**2. 按钮位置有，但图标是空白**
只替换了 `app.so`，没有替换 `MaterialIcons-Regular.otf`。
直接用补丁包安装，或从同一次构建里复制字体文件。

**3. 我的数据会丢吗**
不会。只替换上面两个文件；设置、历史记录、下载、插件都在
`%APPDATA%\com.example\kazumi`，不受影响。

**4. Kazumi 自动更新后按钮没了**
自动更新会覆盖 `data/app.so`。更新完成后重新运行一次 `install.bat` 即可。

**5. 为什么没有数字签名 / 被杀软提示**
官方 Windows 构建同样没有签名。补丁包不含安装器、服务或额外网络组件，
只复制两个文件；`install.ps1` 是纯 PowerShell，可以直接打开检查。

**6. 支持 Linux / macOS 吗**
补丁本身只依赖 `window_manager`，理论上跨平台；但成品包只提供 Windows x64。
其他平台请按 [README.zh-CN.md](README.zh-CN.md) 从源码构建。

## 源码与许可证

- 源码 / 补丁 / 完整文档：<https://github.com/StarFall0220/kazumi-window-controls>
- 上游：<https://github.com/Predidit/Kazumi>
- 许可证：**GPL-3.0**（与 Kazumi 一致）。
  便携版是“官方 GPL 构建 + 本补丁”的再分发，完整对应源码在本仓库和上游均可获得。
