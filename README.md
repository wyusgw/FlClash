<div align="center">

<img src="assets/images/icon.png" alt="FlClash" width="88">

# FlClash

A multi-platform proxy client based on Xray-core. Simple to use, open source and ad-free.

**English** · [简体中文](README_zh_CN.md) · [繁體中文](README_zh_TW.md)

[![Release](https://img.shields.io/github/v/release/wyusgw/FlClash?style=flat-square&label=release)](https://github.com/wyusgw/FlClash/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/wyusgw/FlClash/total?style=flat-square&logo=github)](https://github.com/wyusgw/FlClash/releases)
[![License](https://img.shields.io/github/license/wyusgw/FlClash?style=flat-square)](LICENSE)

[Download](#download) · [Changelog](CHANGELOG.md) · [Build from source](#build-from-source)

</div>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="snapshots/preview-en-dark.png">
    <img alt="FlClash home on a MacBook and a phone" src="snapshots/preview-en.png" width="92%">
  </picture>
</p>

## Features

- **One app for Android, Windows, macOS and Linux**, with x64 and ARM64 builds on the desktop.
- **Xray-core** with rule routing, node groups, latency tests, system proxy and TUN mode.
- **Profiles** from a subscription link or a file (share links, base64 lists or an Xray config for VLESS, VMess,
  Trojan, Shadowsocks, Hysteria2, TUIC and AnyTLS), with a built-in editor.
- **Live views** of traffic, latency and logs.
- **Material You design** with dynamic color, light and dark themes, and layouts that adapt from phones to desktops.
- **Backup and restore** through WebDAV or a local file.
- **Platform touches**: a Quick Settings tile, per-app proxy and Android TV support on Android; a tray menu and
  global hotkeys on the desktop.
- **Open source and ad-free**, licensed under GPL-3.0.

## Download

Get the latest build from [GitHub Releases](https://github.com/wyusgw/FlClash/releases/latest).

### Download for your system automatically

<p align="center">
  <a href="https://wyusgw.github.io/FlClash/download/"><img alt="Download for my system" src="https://img.shields.io/badge/Download-for%20my%20system-6B5059?style=for-the-badge&logo=github&logoColor=white" height="48"></a>
</p>

The button detects your operating system and CPU and starts the matching installer. The
[download page](https://wyusgw.github.io/FlClash/#download) lists every file and picks the right one first. Use either
if you are not sure which file you need.

### Download based on your OS

Pick the button for your system. Most Android phones need ARMv8, Windows on Snapdragon laptops needs ARM64, and
Macs with an M-series chip need Apple Silicon. The buttons always fetch the latest release, and the
[releases page](https://github.com/wyusgw/FlClash/releases/latest) has `SHA256SUMS` with a checksum for every file.

<table>
  <thead align="left">
    <tr><th>OS</th><th>Download</th></tr>
  </thead>
  <tbody align="left">
    <tr>
      <td>Android</td>
      <td>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-android-arm64-v8a.apk"><img alt="APK-ARMv8" src="https://img.shields.io/badge/APK-ARMv8-168039.svg?logo=android"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-android-armeabi-v7a.apk"><img alt="APK-ARMv7" src="https://img.shields.io/badge/APK-ARMv7-45bf55.svg?logo=android"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-android-x86_64.apk"><img alt="APK-x64" src="https://img.shields.io/badge/APK-x64-96ed89.svg?logo=android"></a>
      </td>
    </tr>
    <tr>
      <td>Windows</td>
      <td>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-windows-amd64-setup.exe"><img alt="Setup-x64" src="https://img.shields.io/badge/Setup-x64-2d7d9a.svg?logo=windows"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-windows-amd64.zip"><img alt="Portable-x64" src="https://img.shields.io/badge/Portable-x64-67b7d1.svg?logo=windows"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-windows-arm64-setup.exe"><img alt="Setup-ARM64" src="https://img.shields.io/badge/Setup-ARM64-2d7d9a.svg?logo=windows"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-windows-arm64.zip"><img alt="Portable-ARM64" src="https://img.shields.io/badge/Portable-ARM64-67b7d1.svg?logo=windows"></a>
      </td>
    </tr>
    <tr>
      <td>macOS</td>
      <td>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-macos-arm64.dmg"><img alt="DMG-Apple Silicon" src="https://img.shields.io/badge/DMG-Apple%20Silicon-000000.svg?logo=apple"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-macos-amd64.dmg"><img alt="DMG-Intel x64" src="https://img.shields.io/badge/DMG-Intel%20x64-00A9E0.svg?logo=apple"></a>
      </td>
    </tr>
    <tr>
      <td>Linux</td>
      <td>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-linux-amd64.AppImage"><img alt="AppImage-x64" src="https://img.shields.io/badge/AppImage-x64-f84e29.svg?logo=linux"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-linux-amd64.deb"><img alt="Deb-x64" src="https://img.shields.io/badge/Deb-x64-FF9966.svg?logo=debian"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-linux-amd64.rpm"><img alt="Rpm-x64" src="https://img.shields.io/badge/Rpm-x64-F1B42F.svg?logo=redhat"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-linux-arm64.AppImage"><img alt="AppImage-ARM64" src="https://img.shields.io/badge/AppImage-ARM64-f84e29.svg?logo=linux"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-linux-arm64.deb"><img alt="Deb-ARM64" src="https://img.shields.io/badge/Deb-ARM64-FF9966.svg?logo=debian"></a>
        <a href="https://github.com/wyusgw/FlClash/releases/latest/download/FlClash-linux-arm64.rpm"><img alt="Rpm-ARM64" src="https://img.shields.io/badge/Rpm-ARM64-F1B42F.svg?logo=redhat"></a>
      </td>
    </tr>
  </tbody>
</table>

**Linux tray icon**

The `.deb` package installs its own dependencies. With the AppImage or the `.rpm`, install the AyatanaAppIndicator
library so the tray icon can show:

```bash
sudo apt-get install libayatana-appindicator3-1   # Debian and Ubuntu
sudo dnf install libayatana-appindicator-gtk3     # Fedora
```

## Usage

**Import a profile from a link.** Opening a link in this form imports the subscription into FlClash. The `clashmeta://`
and `flclash://` schemes work the same way.

```text
clash://install-config?url=<URL-encoded subscription link>
```

**Automate on Android.** Tasker, MacroDroid and similar apps can start, stop or toggle the proxy by starting an
activity with one of these actions:

```text
com.flclash.action.START
com.flclash.action.STOP
com.flclash.action.TOGGLE
```

From a computer, the same works over adb:

```bash
adb shell am start -a com.flclash.action.TOGGLE
```

## Build from source

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.47 (release builds use 3.47.4),
[Go](https://go.dev/dl/) 1.27 and [Rust](https://rustup.rs/) installed through rustup. Each platform builds on its own
host, except Android, which builds anywhere.

```bash
git clone --recursive https://github.com/wyusgw/FlClash.git
cd FlClash
flutter pub get
dart setup.dart android   # or windows, macos, linux
```

Packages land in `dist/`. The Go core and the Rust libraries are compiled as part of the Flutter build.

| Platform | Also needed |
| --- | --- |
| Android | Android SDK with the NDK. Add `--arch arm64` to build a single ABI. |
| Windows | GCC (MinGW-w64) for the core and [Inno Setup](https://jrsoftware.org/isinfo.php) 6 for the installer. |
| macOS | Xcode and Node.js. The script installs `appdmg` through npm. |
| Linux | Debian or Ubuntu. The script installs the build packages with apt and downloads `appimagetool`. |

Run `dart setup.dart --help` for the remaining options, such as `--targets` to build only some package formats.

## Documentation

Read it online at <https://wyusgw.github.io/FlClash/docs/>, or in the repository:

- [User guide](docs/user-guide.md): adding servers, routing rules, DNS, TUN, hotkeys, backup and troubleshooting.
- [Contributing](CONTRIBUTING.md): building, testing, commit messages and releasing.
- [Architecture](docs/architecture.md): how the app, the Go core and the native services fit together.

## Support

Starring the repository is the easiest way to support the project. Bugs and feature requests go to
[GitHub Issues](https://github.com/wyusgw/FlClash/issues).

<a href="https://star-history.com/#wyusgw/FlClash&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=wyusgw/FlClash&type=Date&theme=dark">
    <img alt="Star history" src="https://api.star-history.com/svg?repos=wyusgw/FlClash&type=Date" width="640">
  </picture>
</a>

## License

FlClash is released under the [GPL-3.0 license](LICENSE).
