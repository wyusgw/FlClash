# Project Context

FlClash is a multi-platform proxy client based on Xray-core, built with Flutter. It supports Android, Windows, macOS, and Linux, using a Material You design with Surfboard-like UI.

## Version Notes

- Flutter stays on the 3.47.x line. Release CI pins 3.47.4 and is the source
  of truth for release builds; `.fvmrc` and local SDKs may sit on another 3.47
  patch. The editor in `plugins/code_forge` came from `code_forge` 10.14.0, which
  needs Dart 3.13.2, so the CI pin cannot go below Flutter 3.47.2.
- Before moving the pin, walk `flutter-upgrade.md`: it lists the workarounds tied to
  the current SDK, such as Impeller disabled on the Intel macOS release build.
- The Dart SDK lower bound in `pubspec.yaml` sets the package language
  version. `flutter analyze` excludes `lib/**/generated/**`, so a raise is
  proven by `flutter test`, which parses the generated code, not by analyze.

## Forked Dependencies

One `pubspec.yaml` dependency is pinned to a fork by commit SHA, and the Core's source is a submodule of a fork. Both
live under `wyusgw`, the account that owns this repository, so advancing a pin is a local decision.

- `launch_at_startup` — `wyusgw/launch_at_startup`, version 0.5.1. It migrates `win32_registry` from `^2.0.0` to
  `^3.0.3`, a breaking rename across the whole Windows implementation (`Registry.openPath` → `CURRENT_USER.open`,
  `createValue` → `setValue`, `getStringValue` → `getString`). FlClash depends on `win32_registry: ^3.0.3` directly and
  upstream's `^2.0.0` constraint cannot co-resolve with it. Drop the fork when upstream publishes a release that
  accepts `win32_registry` 3.x.
- `core/Xray-core` — `wyusgw/Xray-core`, tracking `main`. Its `go.mod` asks for Go 1.27, which sets the Go version
  of the whole build. The submodule is pinned to a commit that is not a release tag; move the pin to a release tag
  once one covers the features the Core uses (the `tun` inbound and the balancer overrides).

The `window_manager` fork was replaced by the in-repo `plugins/window` package; the behaviors it carried (work-area
maximize with a hidden title bar on Windows, geometry restore on re-map on Linux, corner preference, terminate and
activate events) live there now, see the window plugin section of `architecture.md`.

The `code_forge` fork is frozen: its Dart code now lives in the in-repo `plugins/code_forge` package and its Rust code
in the `editor/` module of `plugins/rust_api`, both trimmed to what FlClash uses. `plugins/code_forge/README.md`
records what was kept and what was removed; upstream's MIT notice stays in `plugins/code_forge/LICENSE`.

## Dependency Ceilings

`flutter pub outdated` lists only upstream-held entries, so treat them as
resolved-until-the-ceiling-moves rather than as debt:

- `intl` is intentionally unbounded (`any`) and `material_color_utilities` is
  resolved by the Flutter SDK; neither is a bound this repository sets.

`freezed`, the `riverpod` set, `build_runner`, `drift_dev`, `intl_utils` and
`test` all resolve against the analyzer the pinned SDK ships; none of them is
held back. When an upgrade fails version solving, record the blocker here with
what has to change upstream before the pin can move, so the next
`flutter pub outdated` run does not rediscover it.

`_initDynamicColor` in `lib/bootstrap.dart` reads the `dynamic_color` method
channel directly and decodes the palette list into a `TonalPalette`, instead of
going through `DynamicColorPlugin.getCorePalette()` and its deprecated
`CorePalette` return type. Everything downstream sees `DynamicColorSeeds`, so a
non-deprecated plugin accessor changes only that one function.

## Build Dependencies

Linux:

```bash
sudo apt-get install libayatana-appindicator3-dev
```

Windows:

- GCC and Inno Setup.

macOS:

```bash
npm install -g appdmg
```
