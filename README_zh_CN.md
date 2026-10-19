<div align="center">

<img src="assets/images/icon.png" alt="FlClash" width="88">

# FlClash

基于 Xray-core 的多平台代理客户端，简单易用，开源无广告。

[English](README.md) · **简体中文**

[![Release](https://img.shields.io/github/v/release/wyusgw/FlClash?style=flat-square&label=release)](https://github.com/wyusgw/FlClash/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/wyusgw/FlClash/total?style=flat-square&logo=github)](https://github.com/wyusgw/FlClash/releases)
[![License](https://img.shields.io/github/license/wyusgw/FlClash?style=flat-square)](LICENSE)

[下载](#下载) · [更新日志](CHANGELOG.md) · [从源码构建](#从源码构建)

</div>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="snapshots/preview-dark.png">
    <img alt="FlClash 在 MacBook 与手机上的仪表盘" src="snapshots/preview.png" width="92%">
  </picture>
</p>

## 功能

- **一个应用覆盖 Android、Windows、macOS 和 Linux**，桌面端同时提供 x64 与 ARM64 版本。
- **Xray-core 内核**：规则分流、节点组、延迟测试、系统代理与 TUN 模式。
- **配置管理**：通过订阅链接或文件导入配置（分享链接、base64 列表或 Xray 配置，支持 VLESS、VMess、Trojan、Shadowsocks、Hysteria2、TUIC 与 AnyTLS），内置编辑器。
- **实时查看**流量、延迟和日志。
- **Material You 设计**：支持动态取色、浅色与深色主题，布局随屏幕从手机到桌面自适应。
- **备份与恢复**：通过 WebDAV 或本地文件。
- **平台细节**：Android 上有快捷设置磁贴、分应用代理和 Android TV 支持；桌面端有托盘菜单和全局快捷键。
- **开源无广告**，以 GPL-3.0 协议发布。

## 下载

从 [GitHub Releases](https://github.com/wyusgw/FlClash/releases/latest) 获取最新版本。

### 按系统下载

点击与你系统对应的按钮。绝大多数 Android 手机选 ARMv8，骁龙等 ARM 架构的 Windows 笔记本选 ARM64，M 系列芯片的 Mac 选
Apple Silicon。按钮下载的是 0.9.3 版；更新的版本请到[发布页](https://github.com/wyusgw/FlClash/releases/latest)获取，
页面上的 `SHA256SUMS` 列出了每个文件的校验值。

<table>
  <thead align="left">
    <tr><th>系统</th><th>下载</th></tr>
  </thead>
  <tbody align="left">
    <tr>
      <td>Android</td>
      <td>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-android-arm64-v8a.apk"><img alt="APK-ARMv8" src="https://img.shields.io/badge/APK-ARMv8-168039.svg?logo=android"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-android-armeabi-v7a.apk"><img alt="APK-ARMv7" src="https://img.shields.io/badge/APK-ARMv7-45bf55.svg?logo=android"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-android-x86_64.apk"><img alt="APK-x64" src="https://img.shields.io/badge/APK-x64-96ed89.svg?logo=android"></a>
      </td>
    </tr>
    <tr>
      <td>Windows</td>
      <td>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-windows-amd64-setup.exe"><img alt="Setup-x64" src="https://img.shields.io/badge/Setup-x64-2d7d9a.svg?logo=windows"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-windows-amd64.zip"><img alt="Portable-x64" src="https://img.shields.io/badge/Portable-x64-67b7d1.svg?logo=windows"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-windows-arm64-setup.exe"><img alt="Setup-ARM64" src="https://img.shields.io/badge/Setup-ARM64-2d7d9a.svg?logo=windows"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-windows-arm64.zip"><img alt="Portable-ARM64" src="https://img.shields.io/badge/Portable-ARM64-67b7d1.svg?logo=windows"></a>
      </td>
    </tr>
    <tr>
      <td>macOS</td>
      <td>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-macos-arm64.dmg"><img alt="DMG-Apple Silicon" src="https://img.shields.io/badge/DMG-Apple%20Silicon-000000.svg?logo=apple"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-macos-amd64.dmg"><img alt="DMG-Intel x64" src="https://img.shields.io/badge/DMG-Intel%20x64-00A9E0.svg?logo=apple"></a>
      </td>
    </tr>
    <tr>
      <td>Linux</td>
      <td>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-linux-amd64.AppImage"><img alt="AppImage-x64" src="https://img.shields.io/badge/AppImage-x64-f84e29.svg?logo=linux"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-linux-amd64.deb"><img alt="Deb-x64" src="https://img.shields.io/badge/Deb-x64-FF9966.svg?logo=debian"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-linux-amd64.rpm"><img alt="Rpm-x64" src="https://img.shields.io/badge/Rpm-x64-F1B42F.svg?logo=redhat"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-linux-arm64.AppImage"><img alt="AppImage-ARM64" src="https://img.shields.io/badge/AppImage-ARM64-f84e29.svg?logo=linux"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-linux-arm64.deb"><img alt="Deb-ARM64" src="https://img.shields.io/badge/Deb-ARM64-FF9966.svg?logo=debian"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/download/v0.9.3/FlClash-0.9.3-linux-arm64.rpm"><img alt="Rpm-ARM64" src="https://img.shields.io/badge/Rpm-ARM64-F1B42F.svg?logo=redhat"></a>
      </td>
    </tr>
  </tbody>
</table>

**Linux 托盘图标**

`.deb` 安装包会自动安装所需依赖。使用 AppImage 或 `.rpm` 时，需要先安装 AyatanaAppIndicator 库，托盘图标才能显示：

```bash
sudo apt-get install libayatana-appindicator3-1   # Debian 与 Ubuntu
sudo dnf install libayatana-appindicator-gtk3     # Fedora
```

## 使用

**通过链接导入配置。** 打开下面格式的链接，即可把订阅导入 FlClash。`clashmeta://` 和 `flclash://` 开头的链接同样可用。

```text
clash://install-config?url=<经过 URL 编码的订阅链接>
```

**Android 自动化。** Tasker、MacroDroid 等应用可以用下面的 Action 启动 Activity，从而启动、停止或切换代理：

```text
com.follow.clash.action.START
com.follow.clash.action.STOP
com.follow.clash.action.TOGGLE
```

在电脑上也可以通过 adb 触发：

```bash
adb shell am start -a com.follow.clash.action.TOGGLE
```

## 从源码构建

需要 [Flutter](https://docs.flutter.dev/get-started/install) 3.47（正式版构建使用 3.47.4）、[Go](https://go.dev/dl/) 1.27，
以及通过 rustup 安装的 [Rust](https://rustup.rs/)。桌面端需要在对应系统上构建，Android 在任意系统上都能构建。

```bash
git clone --recursive https://github.com/wyusgw/FlClash.git
cd FlClash
flutter pub get
dart setup.dart android   # 或 windows、macos、linux
```

安装包输出到 `dist/`。Go 内核和 Rust 库会在 Flutter 构建过程中一并编译。

| 平台 | 额外依赖 |
| --- | --- |
| Android | 带 NDK 的 Android SDK。加上 `--arch arm64` 可以只构建单个 ABI。 |
| Windows | 编译内核用的 GCC（MinGW-w64），以及打包安装程序用的 [Inno Setup](https://jrsoftware.org/isinfo.php) 6。 |
| macOS | Xcode 与 Node.js。脚本会通过 npm 安装 `appdmg`。 |
| Linux | Debian 或 Ubuntu。脚本会用 apt 安装构建所需的软件包，并下载 `appimagetool`。 |

其余选项可以运行 `dart setup.dart --help` 查看，例如用 `--targets` 只构建部分安装包格式。

## 支持

给仓库点一个 Star 是支持项目最简单的方式。Bug 与功能建议请提交到 [GitHub Issues](https://github.com/wyusgw/FlClash/issues)。

<a href="https://star-history.com/#wyusgw/FlClash&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=wyusgw/FlClash&type=Date&theme=dark">
    <img alt="Star history" src="https://api.star-history.com/svg?repos=wyusgw/FlClash&type=Date" width="640">
  </picture>
</a>

## 许可证

FlClash 以 [GPL-3.0 协议](LICENSE)发布。
