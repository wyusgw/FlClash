# Architecture

This is a map of how FlClash is put together, for someone about to change it. It names the files that own each job and
the rules that keep them from fighting. For the build and test commands, see [CONTRIBUTING.md](../CONTRIBUTING.md).

FlClash is a Flutter app around a proxy core written in Go. The core is [Xray-core](https://github.com/XTLS/Xray-core),
embedded through a small wrapper in `core/`. The app turns your profiles and settings into one Xray JSON config, hands it
to the core, and shows what the core reports.

## Repository layout

| Path | What lives there |
| --- | --- |
| `lib/` | The Flutter app: views, widgets, state, models, and the code that talks to the core |
| `core/` | The Go wrapper around Xray-core: config loading, probes, traffic, events and the IPC server |
| `core/Xray-core/` | A git submodule with the Xray-core sources (a fork) |
| `android/` | Four Gradle modules: `app`, `common`, `core` (the JNI bridge) and `service` |
| `services/helper/` | A Rust service that runs the core with privileges on Windows and Linux |
| `plugins/` | Local Flutter packages: `setup` (the build hook), `rust_api`, `tray`, `window`, `proxy`, `code_forge` (the editor) and `wifi_ssid` |
| `site/`, `tool/` | The download page, and the release, changelog and check scripts |
| `arb/` | The strings, in four languages; `lib/l10n/` is generated from them |

## The core, and how the app reaches it

The Go code is built in two shapes:

- **Android** compiles it as a shared library (`libclash.so`, `-buildmode=c-shared`) that runs inside the app process.
  The `core` Gradle module owns the JNI calls, and Flutter reaches it through a method channel to the `service` module,
  never by calling JNI itself.
- **Desktop** runs it as a separate process (`CGO_ENABLED=0`). Dart and the core talk over a local socket: a Unix domain
  socket on macOS and Linux, a named pipe on Windows. The socket code is in `plugins/rust_api`, and everything above it
  (request ids, reconnects, the process lifecycle) is Dart.

`lib/core/controller.dart` (`CoreController`) picks the implementation for the platform and is the only thing the rest
of the app calls. `lib/core/interface.dart` is the contract both implementations meet. In `lib/core/`:

- `lib.dart` is the Android implementation.
- `service.dart` (`CoreService`) is the desktop one, assembled from the parts in `desktop/`: the transport
  (`transport.dart`), the request/response client (`rpc_client.dart`), the process launchers (`launcher.dart`,
  `helper_client.dart`) and the lifecycle (`lifecycle.dart`).

The Go side starts in `core/hub.go` (the handlers), `core/method.go` (dispatch of method calls and the response
envelope), `core/engine.go` (building and running the Xray instance), `core/message.go` (the event queues) and
`core/server.go` (the desktop socket).

### Messages

Both directions use the same JSON envelope: `CoreMethodCall(id, method, arguments)` and
`CoreMethodResponse(id, result, error)`. Keep arguments, results and event data as structured JSON, not as strings that
hold JSON, and keep the envelope identical across Dart, Go, JNI and the desktop socket.

Events go the other way and must never block the core. `core/message.go` keeps three queues: a *state* queue that never
drops anything (route changes), a *priority* queue (delay results and the like) and a *bulk* queue for logs and
connections. A full priority or bulk queue evicts only its own oldest entry, so a flood of log lines cannot push a
route change out. A batcher flushes every 16 ms or 32 messages.

### From profile to running config

`lib/common/xray_config.dart` builds the config the core runs. It takes the nodes of the current profile as outbounds,
adds the app's own outbounds (`@direct`, `@block`, `@dns`), and derives the rest from your settings:

- **Inbounds**: a mixed (HTTP and SOCKS) inbound on the configured port, plus a TUN inbound where the platform allows it.
- **Routing**: the chosen node, and the rule list (the built-in rules or the rule config in use) in Rule mode.
- **DNS**: the proxy and direct server lists, with a separate server that resolves the nodes' own domain names directly,
  so a lookup never has to go through the node it is looking for.

`lib/common/task.dart` runs this in an isolate and returns the JSON with its MD5, so an unchanged config is not sent
again. The core reads the config file, normalizes it (adding the traffic counters) and starts the instance.

Nothing in the config is hand-edited by users. Settings change the models, the models change the config, and the config is
the only thing the core sees.

## Starting and stopping

Starting the proxy touches processes, ports, VPN permissions and the system's proxy and DNS settings, so each platform has
exactly one owner of the truth, and the rest ask it:

- **Shared**: `CoreController.start()`, `restart()`, `stop()` and `close()` are the only lifecycle calls. `close()` is
  final. `CoreAction` (`lib/providers/actions/core.dart`) publishes the status the UI shows (`connecting`, `connected`,
  `disconnected`) and coalesces overlapping restarts so the newest intent wins. It orchestrates; it does not own a process.
- **Desktop**: `DesktopCoreLifecycle` reconciles the *latest* wanted state (running, restarted, stopped, closed) instead
  of replaying every request. A command reports whether it was applied, coalesced or superseded. It will not start a
  second core while the first one's exit is unconfirmed.
- **Android**: Flutter's start and stop commands are optimistic and return at once. The native `ServiceState` owns the
  real state, serializes the work, and decides between `VpnService` and a plain proxy service. Quick Settings, the
  notification and Always-on VPN all go through the same owner.
- **Exit** goes through one coordinator (`SystemAction` and `SystemExitCoordinator`): clean up DNS, the system proxy
  and the tray, close the window, close the core, exit once. A three-second watchdog is the emergency way out.

The privileged Helper in `services/helper/` exists because TUN and the system proxy need rights the app does not have.
On Windows and Linux the app asks the Helper to run the core and holds the core through a lease tied to the session; on
macOS, in an AppImage, and when the Helper is not ready, the app starts the core directly.

## State in the app

State is [Riverpod](https://riverpod.dev). The files under `lib/providers/`:

| File | Holds |
| --- | --- |
| `config.dart` | Persistent settings: app, theme, core, network, hotkeys, rule sets |
| `app.dart` | Runtime state: logs, traffic, delays, loading, view size |
| `state.dart` | Values derived from the two above (the tray, the proxy lists, the colors) |
| `action.dart` | The notifiers that do things: setup, backup, the core lifecycle, profiles |
| `core.dart` | `coreHandlerProvider`, the way to reach `CoreController` |
| `route_state.dart`, `routed_probe.dart` | See below |

The generated provider code lives in `lib/providers/generated/`, so run code generation after you change one.

Three rules keep the layers apart, and tests enforce the first two:

1. **The view layer does not reach singletons.** `lib/views`, `lib/widgets`, `lib/pages` and `lib/features` read the core
   through `coreHandlerProvider`, not through a global, so a test can swap in a fake for one container
   (`test/lint/ui_layer_singleton_test.dart`).
2. **`lib/common/` does not import the platform modules by default.** `tray.dart`, `window.dart` and a few others are not
   in the `common.dart` barrel; import them directly, so a file that wants a string helper does not pull in the tray
   package (`test/lint/platform_layering_test.dart`).
3. **Providers do not import widgets.** Presentation that needs both, such as the update dialog, lives in `lib/common/`
   (`Dialogs`), which may reach the widgets.

`lib/manager/` holds the objects that sit above the app and react to state: the tray, hotkeys, the window, the VPN,
the theme, the core's crash recovery, clipboard, Android tiles. Each one listens to providers and acts on the platform; none
of them owns business logic.

### Keeping answers consistent with the route

A probe, such as "what is my exit address" or "can I reach this service", is only true for the route it ran on. The core
keeps an *epoch* that changes when the route does, and `lib/providers/route_state.dart` tracks it. `routed_probe.dart` is
a cache that stamps every answer with the route it came from, drops an answer when the route moves on, and asks again
only for what somebody is looking at. `outbound_ip.dart` and `service_status.dart` are built on it.

## Storage

- **Settings** are kept in shared preferences (`lib/common/preferences.dart`), written from `lib/providers/config.dart`.
- **Profiles** and the icon cache are in a [Drift](https://drift.simonbinder.eu) database (`lib/database/`); the profile
  files themselves are on disk in a `profiles/` directory.
- **Backups** are archives of the data directory made by `lib/common/backup.dart`, saved to a local file or to WebDAV
  (`dav_client.dart`).

## Safe mode

`--dart-define=SAFE_MODE=true` is for developing without touching the machine. In it the app does not create a TUN
device, does not set the system proxy or rewrite the system DNS, does not register itself as a login item, does not
register global hotkeys, and does not use the privileged Helper. The flag is the `safeModeBuild` constant in
`lib/common/constant.dart`, exposed to providers as `safeModeProvider`. The check lives in the code that causes each
effect (the config builder, the setup and system actions, the tray, the hotkey manager, the window), not in the UI, so
a new feature that changes the host has to consult the same flag.

## Native pieces

- **`plugins/setup`** is the Flutter build hook. On every `flutter build`, `flutter test` and `dart run` of a root script
  it builds the Go core and, on Windows and Linux, the Helper, and caches by input fingerprint in
  `.dart_tool/setup_build_cache/`. The `hooks.user_defines` in `pubspec.yaml` can turn it off for a Dart-only loop; never
  commit the switch off.
- **`plugins/rust_api`** holds the Rust library: the local socket used for desktop IPC, the profile script engine and the
  editor's native parts, with Dart bindings generated by `flutter_rust_bridge`.
- **`plugins/tray`** draws the tray icon and the menu natively on each desktop. On macOS the menu items are drawn in
  `TrayMenuItemView.swift` so that they match the system's own menus.
- **`plugins/window`** wraps the desktop window, and **`plugins/code_forge`** is the code editor used for configs and
  rule files.

## Build, CI and releases

`dart setup.dart <platform>` builds and packages. CI (`.github/workflows/build.yaml`) runs the Dart checks, the plugin
packages, the Go and Rust tests, the Android unit tests and a debug build per desktop platform on every branch push; the
release builds start only for a `v*` tag and only after those jobs pass.

The changelog is derived from the history. `tool/changelog.dart` reads Conventional Commits and their `Changelog:`
trailers and writes `CHANGELOG.md` for readers and `changelog.json` for the renderers. The release notes carry the
current version's notes as JSON in an HTML comment, which is where the in-app update dialog reads them from.

Each release also carries a version-less copy of every package, added by `tool/release_aliases.sh`, so the readmes can link
to `releases/latest/download/FlClash-<name>`.

`site/` is the download page. `tool/build_site.sh` assembles it from the latest release's asset list and
`tool/render_site.mjs` renders the English and Chinese pages; `.github/workflows/pages.yaml` publishes it to GitHub Pages.
The page detects the visitor's system and offers the matching installer first. File names come from the release matrix
in `build.yaml`, so renaming an artifact there means changing `buildsFor` in `site/assets/app.js` too. `site/download/` is a
second page that detects the visitor's system and starts the matching installer straight away; it reads the same
`release.json` and picks the file name with `primaryFor` in `site/assets/download.js`.
