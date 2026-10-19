<div align="center">

<img src="assets/images/icon.png" alt="FlClash" width="88">

# FlClash

A multi-platform proxy client based on Xray-core. Simple to use, open source and ad-free.

**English** · [简体中文](README_zh_CN.md)

[![Release](https://img.shields.io/github/v/release/wyusgw/FlClash?style=flat-square&label=release)](https://github.com/wyusgw/FlClash/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/wyusgw/FlClash/total?style=flat-square&logo=github)](https://github.com/wyusgw/FlClash/releases)
[![License](https://img.shields.io/github/license/wyusgw/FlClash?style=flat-square)](LICENSE)

[Download](#download) · [Changelog](CHANGELOG.md) · [Build from source](#build-from-source)

</div>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="snapshots/preview-dark.png">
    <img alt="FlClash dashboard on a MacBook and a phone" src="snapshots/preview.png" width="92%">
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

### Download based on your OS

Open the latest release and pick the file that matches your system. In the names below, `<version>` is the release
number, such as `0.9.3`.

| Your system | File to download | Notes |
| --- | --- | --- |
| Android phone or tablet (most devices) | `FlClash-<version>-android-arm64-v8a.apk` | Use `armeabi-v7a` for an old 32-bit device and `x86_64` for an emulator or an x86 box. |
| Windows 10 and later, Intel or AMD | `FlClash-<version>-windows-amd64-setup.exe` | Or `FlClash-<version>-windows-amd64.zip` for a portable copy. |
| Windows on ARM (Snapdragon laptops) | `FlClash-<version>-windows-arm64-setup.exe` | Or `FlClash-<version>-windows-arm64.zip` for a portable copy. |
| macOS 12 and later, Apple Silicon | `FlClash-<version>-macos-arm64.dmg` | M1 and newer. |
| macOS 12 and later, Intel | `FlClash-<version>-macos-amd64.dmg` | |
| Linux, x64 | `FlClash-<version>-linux-amd64.deb`, `.rpm` or `.AppImage` | `.deb` for Debian and Ubuntu, `.rpm` for Fedora. See the tray note below. |
| Linux, ARM64 | `FlClash-<version>-linux-arm64.deb`, `.rpm` or `.AppImage` | |

`SHA256SUMS` on the release page lists a checksum for every file.

<p>
  <a href="https://github.com/wyusgw/FlClash/releases/latest"><img alt="Get it on GitHub" src="snapshots/get-it-on-github.svg" height="56"></a>
</p>

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
com.follow.clash.action.START
com.follow.clash.action.STOP
com.follow.clash.action.TOGGLE
```

From a computer, the same works over adb:

```bash
adb shell am start -a com.follow.clash.action.TOGGLE
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
